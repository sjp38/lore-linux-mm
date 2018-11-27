Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAA4B6B46B7
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:05:21 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so13435064pfk.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:05:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14sor3819557pgl.37.2018.11.27.00.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 00:05:20 -0800 (PST)
Date: Tue, 27 Nov 2018 11:05:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
Message-ID: <20181127080515.py6naga4gsi2yad2@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
 <20181031100944.GA3546@osiris>
 <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
 <20181127073411.GA3625@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127073411.GA3625@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Nov 27, 2018 at 08:34:12AM +0100, Heiko Carstens wrote:
> On Wed, Oct 31, 2018 at 01:36:23PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 31, 2018 at 11:09:44AM +0100, Heiko Carstens wrote:
> > > On Wed, Oct 31, 2018 at 07:31:49AM +0100, Martin Schwidefsky wrote:
> > > > Thanks for testing. Unfortunately Heiko reported another issue yesterday
> > > > with the patch applied. This time the other way around:
> > > > 
> > > > BUG: non-zero pgtables_bytes on freeing mm: -16384
> > > > 
> > > > I am trying to understand how this can happen. For now I would like to
> > > > keep the patch on hold in case they need another change.
> > > 
> > > FWIW, Kirill: is there a reason why this "BUG:" output is done with
> > > pr_alert() and not with VM_BUG_ON() or one of the WARN*() variants?
> > > 
> > > That would to get more information with DEBUG_VM and / or
> > > panic_on_warn=1 set. At least for automated testing it would be nice
> > > to have such triggers.
> > 
> > Stack trace is not helpful there. It will always show the exit path which
> > is useless.
> 
> So, even with the updated version of these patches I can flood dmesg
> and the console with
> 
> BUG: non-zero pgtables_bytes on freeing mm: 16384
> 
> messages with this complex reproducer on s390:
> 
> echo "void main(void) {}" | gcc -m31 -xc -o compat - && ./compat
> 
> Besides that this needs to be fixed, I'd really like to see this
> changed to either a printk_once() or a WARN_ON_ONCE() within
> check_mm() so that an arbitrary user cannot flood the console.
> 
> E.g. something like the below. If there aren't any objections, I will
> provide a proper patch with changelog, etc.
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 07cddff89c7b..d7aeec03c57f 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
>  	}
>  
>  	if (mm_pgtables_bytes(mm))
> -		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> -				mm_pgtables_bytes(mm));
> +		printk_once(KERN_ALERT "BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> +			    mm_pgtables_bytes(mm));

You can be the first user of pr_alert_once(). Don't miss a chance! ;)

-- 
 Kirill A. Shutemov
