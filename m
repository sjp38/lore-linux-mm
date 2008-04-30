Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m3UIf13s018139
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 19:41:02 +0100
Received: from fk-out-0910.google.com (fkq18.prod.google.com [10.94.17.18])
	by zps35.corp.google.com with ESMTP id m3UIexQk010428
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 11:41:00 -0700
Received: by fk-out-0910.google.com with SMTP id 18so384989fkq.10
        for <linux-mm@kvack.org>; Wed, 30 Apr 2008 11:40:59 -0700 (PDT)
Message-ID: <d43160c70804301140q16aed710rcafcab95876de078@mail.gmail.com>
Date: Wed, 30 Apr 2008 14:40:59 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [RFC/PATH 1/2] MM: Make Page Tables Relocatable -- conditional flush
In-Reply-To: <4818B262.5020909@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080429134254.635FEDC683@localhost> <4818B262.5020909@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 1:54 PM, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> Hi Ross,
>
>> These Patches make page tables relocatable for numa, memory
>> defragmentation, and memory hotblug.  The potential need to rewalk the
>> page tables before making any changes causes a 1.6% peformance
>> degredation in the lmbench page miss micro benchmark.
>
> So you mean the check to see if there's a migration currently in
> progress?  Surely that's a single test+branch?

Yup.  But the page fault code is so efficient, that a test and
associated potential cache effects are noticable.

>> page tables with the process will be a performance win.
>
> I would have thought cross-node TLB misses would be a bigger factor.

That's where the traffic comes from.

>
> I've read through this patch a couple of times so far, but I still
> don't quite get it.  The "why" rationale is good, but it would be nice
> to have a high-level "how" paragraph which explains the overall
> principle of operation.  (OK, I think I see how all this fits
> together now.)

There are comments in migrate.c on the how.  If they are insufficient,
please indicate what you would like to see.  I've been staring at the
code so long it all seems obvious to me.

>
> From looking at it, a few points to note:
>
> - It only tries to move usermode pagetables.  For the most part (at
>  least on x86) the kernel pagetables are fairly static (and
>  effectively statically allocated), but vmalloc does allocate new
>  kernel pagetable memory.
>   As a consequence, it doesn't need to worry about tlb-flushing global
>  pages or unlocked updates to init_mm.

Correct.

>
> - It would be nice to explain the "delimbo" terminology.  I got it in
>  the end, but it took me a while to work out what you meant.

I never liked the delimbo terminology, but it's the best I've been
able to come up with so far.  I'm open to changing it. Otherwise I can
explain it.

>
> Open questions in my mind:
>
> - How does it deal with migrating the accessed/dirty bits in ptes if
>  cpus can be using old versions of the pte for a while after the
>  copy?  Losing dirty updates can lose data, so explicitly addressing
>  this point in code and/or comments is important.

It doesn't currently.  Although it's easy to fix.  Just before the
free, we just have to copy the dirty bits again.  Slow, but not in a
critical path.

>
> - Is this deeply incompatible with shared ptes?

Not deeply.  It just doesn't support them at the moment (although it
doesn't check either.)  It would just need to do all the pmd's
pointing to the pte's at the same time.

>
> - It assumes that each pagetable level is a page in size.  This isn't
>  even true on x86 (32-bit PAE pgds are not), and definitely not true
>  on other architectures.  It would make sense to skip migrating
>  non-page-sized pagetable levels, but the code could/should check for
>  it.

Yes it does.  Not something I like, but I wasn't sure how to check.

>
> - Does it work on 2 and 3-level pagetable systems?  Ideally the clever
>  folding stuff would make it all fall out naturally, but somehow that
>  never seems to end up working.

I've never tried to compile it on anything other than a 4 level
system.  I suspect it will fail, but a couple of well placed #ifdef's
or something similiar will fix it.


>
> - Could you use the existing tlb batching machinery rather than
>  MMF_NEED_FLUSH?  They seem to overlap somewhat.

As of 2.6.22, I couldn't use any of the existing batching.  They do
overlap, but not 100% and I didn't want to impact the other batching
mechanisms by making them do what I needed.

>
> - What architectures does this support?  You change a lot of arch
>  files, but it looks to me like you've only implemented this for
>  x86-64.  Is that right?  A lot of this patch won't apply to x86 at
>  the moment because of the pagetable unifications I've been doing.
>  Will you be able to adapt it to the unified pagetable code?  Will it
>  support all x86 variants in the process?

It currently only supports X86_64.  There are only a couple of missing
things to support other architectures.  The tlb_reload code needs to
be created on all architectures and the node specific page table
allocation code needs to be created.

I'm waiting for the x86 unification to setlle out before doing another
merge.  My guess is that it should support all 4 level page table x86
variants at that point.  The 3 level variants will take a little
cleanup.

> - How much have you tested it?

It's had tons of testing on moving a few simple programs around on a
fake numa system.  It's had no testing on a real numa system and I
don't think it's had adequate testing with multi-threaded apps.
>> +static inline int migrate_top_level_page_table(struct mm_struct *mm,
>> +                                              struct page *dest,
>> +                                              struct list_head
>> *old_pages)
>
> Seems a bit large to be static inline in a header.  Why not just put
> it in mm/migrate.c?

I think it was a simple little macro at one point.  At this point, it
doesn't matter and should be moved.
> On the other hand, I've got plans to change the way Xen manages pgds
> which would alleviate this problem and allow this code to work as-is,
> but it would still require careful handling of the other pagetable
> levels (update, which look mostly ok already).

Let me know what you decide to do here.  It shouldn't be too hard to
single Xen that pgds are changing.
>> +#define MMF_NEED_REWALK                9       /* Must rewalk page tables
>> with spin
>> +                                        * lock held. */
>
> Does this get used anywhere?

Not anymore.  It's been replaced by the nesting count and just didn't
get deleted.

> Hm, another pagetable walker.  Sure this one is necessary?  Or does it
> replace one of the others?  Is it guaranteed to work on 2, 3 and 4
> level pagetables?

When I started, none of the other page table walkers were pure
walkers.  I'll take a look and see if I can find one I can use.
Otherwise this is only really
guaranteed to work on 4 level page tables at this point.  It should
work on others, but it hasn't been tested.

>> +       delimbo_pmd(&pmd, &init_mm, address);
>
>
> I think you're never migrating anything in init_mm, so this should be a
> no-op, right?

Correct, but I included it for completeness.  We could eliminate it
for speed, but I'd like to keep it.

>> @@ -647,6 +667,12 @@ static int migrate_to_node(struct mm_str
>>        if (!list_empty(&pagelist))
>>                err = migrate_pages(&pagelist, new_node_page, dest);
>>  +#ifdef CONFIG_RELOCATE_PAGE_TABLES
>> +       if (!err)
>> +               err = migrate_page_tables_mm(mm, source,
>> +                                            new_node_page_page_tables,
>> dest);
>
> Why the indirection?  Do you expect to be passing another function in
> here at some point?

Mostly I just copied the format of similar functions in migrate.c.
Although, it might be useful for memory hotplug.

>
> Why not switch to init_mm, do all the migrations on the target mm,
> then switch back and get all the other cpus to do a reload/flush?
> Wouldn't that achieve the same effect?

I don't think so.  If there are other threads running on other CPU's
wouldn't we also need to get the to switch to a process using another
mm?

> So you're saying that you've copied the pte pages, updated the
> pagetable to point to them, but the cpu could still have the old
> pagetable state in its tlb.
>
> How do you migrate the accessed/dirty state from the old ptes to the
> new one?  Losing accessed isn't a huge problem, but losing dirty can
> cause data loss.

Forgot to.  But it would be easy to copy them over right before
freeing the old page.  However, there is a little race in there if a
sync occurs.  Not really a big deal I don't think.

>
> optl == outer_ptl?

Yes.

>> +/*
>> + * Call this function to migrate a pgd to the page dest.
>> + * mm is the mm struct that this pgd is part of and
>> + * addr is the address for the pgd inside of the mm.
>> + * Technically this only moves one page worth of pud's
>> + * starting with the pud that represents addr.
>
> So really its migrate_pgd_entry?  It migrates a single thing that a
> pgd entry points to?

I think so.  The naming has confused me to no end.  I was hoping
someone would suggest better naming.  I don't think it's
migrate_pgd_entry as much as migrate the thing that the pgd points to
and update the pgd.

> A pud isn't necessarily a page size either.  I don't think you can
> assume that any pagetable level has page-sized elements, though I
> guess those levels will necessarily be non-migratable.

We just need a good test to see if it's a page or not.

>
>> +
>> +       list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
>
> As above: a pud isn't necessarily a page.  Also, you need to
> specifically deallocate it as a pud to make sure the page is free for
> generally useful again (but not until you're sure there are no
> lingering users on all cpus).  I think think means you need to queue a
> (type, page) tuple on your old_pages list so they can be deallocated
> properly.

I'm trying very hard not to expand struct page.  But you are correct.
I also need to save the original page so I can copy the dirty bits
over.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
