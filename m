Message-ID: <4818CEDA.8000908@goop.org>
Date: Wed, 30 Apr 2008 12:56:10 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATH 1/2] MM: Make Page Tables Relocatable -- conditional
 flush
References: <20080429134254.635FEDC683@localhost> <4818B262.5020909@goop.org> <d43160c70804301140q16aed710rcafcab95876de078@mail.gmail.com>
In-Reply-To: <d43160c70804301140q16aed710rcafcab95876de078@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ross Biro wrote:
> On Wed, Apr 30, 2008 at 1:54 PM, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>   
>> Hi Ross,
>>
>>     
>>> These Patches make page tables relocatable for numa, memory
>>> defragmentation, and memory hotblug.  The potential need to rewalk the
>>> page tables before making any changes causes a 1.6% peformance
>>> degredation in the lmbench page miss micro benchmark.
>>>       
>> So you mean the check to see if there's a migration currently in
>> progress?  Surely that's a single test+branch?
>>     
>
> Yup.  But the page fault code is so efficient, that a test and
> associated potential cache effects are noticable.
>   

I wonder if rearranging mm_struct could put it on an already-hot cacheline?

>   
>>> page tables with the process will be a performance win.
>>>       
>> I would have thought cross-node TLB misses would be a bigger factor.
>>     
>
> That's where the traffic comes from.
>
>   
>> I've read through this patch a couple of times so far, but I still
>> don't quite get it.  The "why" rationale is good, but it would be nice
>> to have a high-level "how" paragraph which explains the overall
>> principle of operation.  (OK, I think I see how all this fits
>> together now.)
>>     
>
> There are comments in migrate.c on the how.  If they are insufficient,
> please indicate what you would like to see.  I've been staring at the
> code so long it all seems obvious to me.
>   

Yeah, its easy for that to happen.  Those comments are helpful, I was 
thinking very high-level things like:

    * what initiates migration?
    * how can an mm be under multiple levels of migration?
    * ...?

Maybe the existing comments are sufficient.

>> From looking at it, a few points to note:
>>
>> - It only tries to move usermode pagetables.  For the most part (at
>>  least on x86) the kernel pagetables are fairly static (and
>>  effectively statically allocated), but vmalloc does allocate new
>>  kernel pagetable memory.
>>   As a consequence, it doesn't need to worry about tlb-flushing global
>>  pages or unlocked updates to init_mm.
>>     
>
> Correct.
>
>   
>> - It would be nice to explain the "delimbo" terminology.  I got it in
>>  the end, but it took me a while to work out what you meant.
>>     
>
> I never liked the delimbo terminology, but it's the best I've been
> able to come up with so far.  I'm open to changing it. Otherwise I can
> explain it.
>   

Just a comment saying something like "a pagetable page is considered to 
be in limbo if it has been copied, but may still be in use.  It may be 
either in a cpu's stale tlb entry, or in use by the kernel on another 
cpu with a transient reference." would clarify what the delimbo is 
trying to achieve.

>> Open questions in my mind:
>>
>> - How does it deal with migrating the accessed/dirty bits in ptes if
>>  cpus can be using old versions of the pte for a while after the
>>  copy?  Losing dirty updates can lose data, so explicitly addressing
>>  this point in code and/or comments is important.
>>     
>
> It doesn't currently.  Although it's easy to fix.  Just before the
> free, we just have to copy the dirty bits again.  Slow, but not in a
> critical path.
>   

But the issue I'm concerned about is what happens if a process writes 
the page, causing its cpu to mark the (old, in-limbo) pte dirty.  
Meanwhile someone else is scanning the pagetables looking for things to 
evict.  It check the (shiny new) pte, finds it not dirty, and decides to 
evict the apparently clean page.

What, for that matter, stops a page from being evicted from under a 
limboed mapping?  Does it get accounted for (I guess the existing tlb 
flushing should be sufficient to keep it under control).

Also, what happens if a page happens to get migrated twice in quick 
succession (ie, while there's still an in-limbo page from the first 
time)?  Is there something to prevent that, or would it just all work out?

>   
>> - Is this deeply incompatible with shared ptes?
>>     
>
> Not deeply.  It just doesn't support them at the moment (although it
> doesn't check either.)  It would just need to do all the pmd's
> pointing to the pte's at the same time.
>
>   
>> - It assumes that each pagetable level is a page in size.  This isn't
>>  even true on x86 (32-bit PAE pgds are not), and definitely not true
>>  on other architectures.  It would make sense to skip migrating
>>  non-page-sized pagetable levels, but the code could/should check for
>>  it.
>>     
>
> Yes it does.  Not something I like, but I wasn't sure how to check.
>   

PTRS_PER_PGD * sizeof(pgd_t) == PAGE_SIZE

>> - Does it work on 2 and 3-level pagetable systems?  Ideally the clever
>>  folding stuff would make it all fall out naturally, but somehow that
>>  never seems to end up working.
>>     
>
> I've never tried to compile it on anything other than a 4 level
> system.  I suspect it will fail, but a couple of well placed #ifdef's
> or something similiar will fix it.
>   

Erm, if you're lucky.  It can get pretty hairy.

> It currently only supports X86_64.  There are only a couple of missing
> things to support other architectures.  The tlb_reload code needs to
> be created on all architectures and the node specific page table
> allocation code needs to be created.
>   

Also the notion of a pgd_list, which is an x86-special at the moment.

> I'm waiting for the x86 unification to setlle out before doing another
> merge.  My guess is that it should support all 4 level page table x86
> variants at that point.  The 3 level variants will take a little
> cleanup.
>   

Well, x86-64 is 4 level, x86-32 PAE is 3 level, and x86-32 non-PAE is 2 
level.  I don't think there'd be too much crying if you didn't support 
32-bit non-PAE, but 32-bit PAE is useful.

I would say that x86 unification is still a fair way from "done", but 
the areas you're dealing with should be getting more settled now.

> Let me know what you decide to do here.  It shouldn't be too hard to
> single Xen that pgds are changing.
>   

OK.  I was planning on making the change anyway, and this is just 
another reason to do it.

>>> +       delimbo_pmd(&pmd, &init_mm, address);
>>>       
>> I think you're never migrating anything in init_mm, so this should be a
>> no-op, right?
>>     
>
> Correct, but I included it for completeness.  We could eliminate it
> for speed, but I'd like to keep it.
>   

I wouldn't eliminate it for speed, but it could be misleading if someone 
thought that it would actually do something.  Don't know; no clear 
answer.  Given that delimbo_X are inlines, you could easily put a "if 
(mm == &init_mm)" to skip everything, which would make these cases 
compile to nothing (and "if (__builtin_constant_p(mm) && mm == 
&init_mm)" if you really want to make sure there's no additional 
generated code).

>> Why not switch to init_mm, do all the migrations on the target mm,
>> then switch back and get all the other cpus to do a reload/flush?
>> Wouldn't that achieve the same effect?
>>     
>
> I don't think so.  If there are other threads running on other CPU's
> wouldn't we also need to get the to switch to a process using another
> mm?
>   

It's OK for them to be using the old mm while you're migrating because 
they'll be using the limbo pages.  When you've completed the migration 
(when the count gets to 0?) then you can do a cross-cpu tlb flush (or 
function call to do the flush) to sync everything up.

Or, I guess looking at it the other way, the MMF_NEED_FLUSH means "I 
changed something, so sync up".  If you're migrating, the only reason 
that something didn't change was because you failed to allocate new 
pages to migrate into.  Given that that's unlikely, why not just 
(globally) flush unconditionally when migration is complete?  Similarly, 
why do you need MMF_NEED_RELOAD?  Couldn't you just compare mm->pgd with 
the new pgd and globally reload it if it changed?

Also, do you need to do the syncing and page freeing each time you're 
leaving a relocation_mode, or just the last time?  I guess if you defer 
it to the last leaving there's a possibility of livelock where you're 
always relocating and never free anything.

>> So you're saying that you've copied the pte pages, updated the
>> pagetable to point to them, but the cpu could still have the old
>> pagetable state in its tlb.
>>
>> How do you migrate the accessed/dirty state from the old ptes to the
>> new one?  Losing accessed isn't a huge problem, but losing dirty can
>> cause data loss.
>>     
>
> Forgot to.  But it would be easy to copy them over right before
> freeing the old page.  However, there is a little race in there if a
> sync occurs.  Not really a big deal I don't think.
>   

Well, see my comment above.

>>> +/*
>>> + * Call this function to migrate a pgd to the page dest.
>>> + * mm is the mm struct that this pgd is part of and
>>> + * addr is the address for the pgd inside of the mm.
>>> + * Technically this only moves one page worth of pud's
>>> + * starting with the pud that represents addr.
>>>       
>> So really its migrate_pgd_entry?  It migrates a single thing that a
>> pgd entry points to?
>>     
>
> I think so.  The naming has confused me to no end.  I was hoping
> someone would suggest better naming.  I don't think it's
> migrate_pgd_entry as much as migrate the thing that the pgd points to
> and update the pgd.
>   

I think "migrate_X_entry()" is a better description of that.  The "pgd" 
is a whole array of pgd entries, so when I first saw migrate_pgd I was 
expecting you to be traversing the whole array and doing stuff.  
"pgd_entry" makes it clear you're only doing something to one of those.

>> A pud isn't necessarily a page size either.  I don't think you can
>> assume that any pagetable level has page-sized elements, though I
>> guess those levels will necessarily be non-migratable.
>>     
>
> We just need a good test to see if it's a page or not.
>   

I think if its page-sized you can be reasonably sure that its also 
page-aligned.  Or just have the arch set some Kconfig variables: 
MIGRATE_PAGETABLE_PGD, etc.

>>> +
>>> +       list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
>>>       
>> As above: a pud isn't necessarily a page.  Also, you need to
>> specifically deallocate it as a pud to make sure the page is free for
>> generally useful again (but not until you're sure there are no
>> lingering users on all cpus).  I think think means you need to queue a
>> (type, page) tuple on your old_pages list so they can be deallocated
>> properly.
>>     
>
> I'm trying very hard not to expand struct page.  But you are correct.
>   

I think pagetable pages have quite a few struct page entries which can 
be overloaded, because they don't participate in most of the other 
activities a normal vm page does.  You could probably add something to 
the "_mapcount/inuse,objects" union, or steal some page flags.  (Not 
"private", because I'm planning on using that for some Xen-specific 
pagetable information ;)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
