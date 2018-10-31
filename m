Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id A92A46B02E0
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:39:19 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id m2-v6so11754827oic.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:39:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 77si3606525otf.271.2018.10.31.02.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 02:39:18 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9V9YCqG053743
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:39:18 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nf9fc1e56-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:39:17 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 09:39:16 -0000
Date: Wed, 31 Oct 2018 10:39:10 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
In-Reply-To: <20181031074647.32c6e0d7@mschwideX1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
	<1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
	<CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
	<20181031073149.55ddc085@mschwideX1>
	<CAEemH2f2gW22PJYpVrh7p5zJyHOVRfVawJWD+kN3+8LmApePbw@mail.gmail.com>
	<20181031074647.32c6e0d7@mschwideX1>
MIME-Version: 1.0
Message-Id: <20181031103910.41f916ea@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 31 Oct 2018 07:46:47 +0100
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> On Wed, 31 Oct 2018 14:43:38 +0800
> Li Wang <liwang@redhat.com> wrote:
> 
> > On Wed, Oct 31, 2018 at 2:31 PM, Martin Schwidefsky <schwidefsky@de.ibm.com>
> > wrote:
> >   
> > > BUG: non-zero pgtables_bytes on freeing mm: -16384
> > >    
> > 
> > Okay, the problem is still triggered by LTP/cve-2017-17052.c?  
> 
> No, unfortunately we do not have a simple testcase to trigger this new bug.
> It happened once with one of our test kernels, the path that leads to this
> is completely unclear.
 
Ok, got it. There is a mm_inc_nr_puds(mm) missing in the s390 code:

diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 76d89ee8b428..814f26520aa2 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -101,6 +101,7 @@ int crst_table_upgrade(struct mm_struct *mm, unsigned long end)
                        mm->context.asce_limit = _REGION1_SIZE;
                        mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
                                _ASCE_USER_BITS | _ASCE_TYPE_REGION2;
+                       mm_inc_nr_puds(mm);
                } else {
                        crst_table_init(table, _REGION1_ENTRY_EMPTY);
                        pgd_populate(mm, (pgd_t *) table, (p4d_t *) pgd);

One of our test-cases did an upgrade of a 3-level page table.
I'll update the patch and send a v3.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
