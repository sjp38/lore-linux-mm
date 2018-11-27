Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 887D06B4682
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:34:27 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so13364792pfi.22
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:34:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y29si3030351pgk.376.2018.11.26.23.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 23:34:26 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAR7YOtg074543
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:34:25 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p10kujdxv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:34:25 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Nov 2018 07:34:18 -0000
Date: Tue, 27 Nov 2018 08:34:12 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
 <20181031100944.GA3546@osiris>
 <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
MIME-Version: 1.0
In-Reply-To: <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
Message-Id: <20181127073411.GA3625@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Oct 31, 2018 at 01:36:23PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 31, 2018 at 11:09:44AM +0100, Heiko Carstens wrote:
> > On Wed, Oct 31, 2018 at 07:31:49AM +0100, Martin Schwidefsky wrote:
> > > Thanks for testing. Unfortunately Heiko reported another issue yesterday
> > > with the patch applied. This time the other way around:
> > > 
> > > BUG: non-zero pgtables_bytes on freeing mm: -16384
> > > 
> > > I am trying to understand how this can happen. For now I would like to
> > > keep the patch on hold in case they need another change.
> > 
> > FWIW, Kirill: is there a reason why this "BUG:" output is done with
> > pr_alert() and not with VM_BUG_ON() or one of the WARN*() variants?
> > 
> > That would to get more information with DEBUG_VM and / or
> > panic_on_warn=1 set. At least for automated testing it would be nice
> > to have such triggers.
> 
> Stack trace is not helpful there. It will always show the exit path which
> is useless.

So, even with the updated version of these patches I can flood dmesg
and the console with

BUG: non-zero pgtables_bytes on freeing mm: 16384

messages with this complex reproducer on s390:

echo "void main(void) {}" | gcc -m31 -xc -o compat - && ./compat

Besides that this needs to be fixed, I'd really like to see this
changed to either a printk_once() or a WARN_ON_ONCE() within
check_mm() so that an arbitrary user cannot flood the console.

E.g. something like the below. If there aren't any objections, I will
provide a proper patch with changelog, etc.

diff --git a/kernel/fork.c b/kernel/fork.c
index 07cddff89c7b..d7aeec03c57f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
 	}
 
 	if (mm_pgtables_bytes(mm))
-		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
-				mm_pgtables_bytes(mm));
+		printk_once(KERN_ALERT "BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
+			    mm_pgtables_bytes(mm));
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
