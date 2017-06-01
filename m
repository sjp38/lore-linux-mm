Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4941D6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:33:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j22so17262896qtj.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:33:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o17si7018356qta.238.2017.06.01.07.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 07:33:48 -0700 (PDT)
Date: Thu, 1 Jun 2017 10:33:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Message-ID: <20170601143344.GA3961@redhat.com>
References: <20170531150349.4816-1-jglisse@redhat.com>
 <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 01, 2017 at 06:59:04AM -0700, Andy Lutomirski wrote:
> On Wed, May 31, 2017 at 8:03 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
> > we no longer cleanup stall pgd entries and thus the BUG_ON() inside
> > sync_global_pgds() is wrong.
> >
> > This patch remove the BUG_ON() and unconditionaly update stall pgd
> > entries.
> >
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Ingo Molnar <mingo@kernel.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/mm/init_64.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> >
> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > index ff95fe8..36b9020 100644
> > --- a/arch/x86/mm/init_64.c
> > +++ b/arch/x86/mm/init_64.c
> > @@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
> >                         pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
> >                         spin_lock(pgt_lock);
> >
> > -                       if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
> > -                               BUG_ON(p4d_page_vaddr(*p4d)
> > -                                      != p4d_page_vaddr(*p4d_ref));
> > -
> > -                       if (p4d_none(*p4d))
> > -                               set_p4d(p4d, *p4d_ref);
> > +                       set_p4d(p4d, *p4d_ref);
> 
> If we have a mismatch in the vmalloc range, vmalloc_fault is going to
> screw up and we'll end up using incorrect page tables.
> 
> What's causing the mismatch?  If you're hitting this BUG in practice,
> I suspect we have a bug elsewhere.

No bug elsewhere, simply hotplug memory then hotremove same memory you
just hotplugged then hotplug it again and you will trigger this as on
the first hotplug we allocate p4d/pud for the struct pages area, then on
hot remove we free that memory and clear the p4d/pud in the mm_init pgd
but not in any of the other pgds. So at that point the next hotplug
will trigger the BUG because of stall entries from the first hotplug.

Maybe we can add a flag to differentiate between hotplug and vmalloc
(thought looking at virtual address range is a dead give away of vmalloc
versus hotplug) and only avoid BUG_ON and force overwritte for hotplug.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
