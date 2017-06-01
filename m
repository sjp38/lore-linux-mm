Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83DD36B0292
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:11:14 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r58so17811895qtb.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:11:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a9si11922795qkj.295.2017.06.01.08.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:11:13 -0700 (PDT)
Date: Thu, 1 Jun 2017 11:11:09 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Message-ID: <20170601151107.GC3961@redhat.com>
References: <20170531150349.4816-1-jglisse@redhat.com>
 <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
 <20170601143344.GA3961@redhat.com>
 <CALCETrWhehYF-2pPxH5S6px=hi=MaTeO6OC7_Ro3MgfKpyBhxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrWhehYF-2pPxH5S6px=hi=MaTeO6OC7_Ro3MgfKpyBhxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 01, 2017 at 07:38:25AM -0700, Andy Lutomirski wrote:
> On Thu, Jun 1, 2017 at 7:33 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Thu, Jun 01, 2017 at 06:59:04AM -0700, Andy Lutomirski wrote:
> >> On Wed, May 31, 2017 at 8:03 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> > Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
> >> > we no longer cleanup stall pgd entries and thus the BUG_ON() inside
> >> > sync_global_pgds() is wrong.
> >> >
> >> > This patch remove the BUG_ON() and unconditionaly update stall pgd
> >> > entries.
> >> >
> >> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> >> > Cc: Ingo Molnar <mingo@kernel.org>
> >> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> > ---
> >> >  arch/x86/mm/init_64.c | 7 +------
> >> >  1 file changed, 1 insertion(+), 6 deletions(-)
> >> >
> >> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> >> > index ff95fe8..36b9020 100644
> >> > --- a/arch/x86/mm/init_64.c
> >> > +++ b/arch/x86/mm/init_64.c
> >> > @@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
> >> >                         pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
> >> >                         spin_lock(pgt_lock);
> >> >
> >> > -                       if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
> >> > -                               BUG_ON(p4d_page_vaddr(*p4d)
> >> > -                                      != p4d_page_vaddr(*p4d_ref));
> >> > -
> >> > -                       if (p4d_none(*p4d))
> >> > -                               set_p4d(p4d, *p4d_ref);
> >> > +                       set_p4d(p4d, *p4d_ref);
> >>
> >> If we have a mismatch in the vmalloc range, vmalloc_fault is going to
> >> screw up and we'll end up using incorrect page tables.
> >>
> >> What's causing the mismatch?  If you're hitting this BUG in practice,
> >> I suspect we have a bug elsewhere.
> >
> > No bug elsewhere, simply hotplug memory then hotremove same memory you
> > just hotplugged then hotplug it again and you will trigger this as on
> > the first hotplug we allocate p4d/pud for the struct pages area, then on
> > hot remove we free that memory and clear the p4d/pud in the mm_init pgd
> > but not in any of the other pgds.
> 
> That sounds like a bug to me.  Either we should remove the stale
> entries and fix all the attendant races, or we should unconditionally
> allocate second-highest-level kernel page tables in unremovable memory
> and never free them.  I prefer the latter even though it's slightly
> slower.
> 
> > So at that point the next hotplug
> > will trigger the BUG because of stall entries from the first hotplug.
> 
> By the time we have a pgd with an entry pointing off into the woods,
> we've already lost.  Removing the BUG just hides the problem.

Then why did you sign of on af2cf278ef4f9289f88504c3e03cb12f76027575
this is what introduced this change in behavior.

If i understand you correctly you want to avoid deallocating p4d/pud
directory page when hotremove happen ? But this happen in common non
arch specific code vmemmap_populate_basepages() thought we can make
x86 vmemmap_populate() code arch different thought.

So i am not sure how to proceed here. My first attempt was to undo
af2cf278ef4f9289f88504c3e03cb12f76027575 so that we keep all pgds
synchronize. No if we want special case p4d/pud allocation that's
a different approach all together.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
