Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 910A06B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 16:09:17 -0400 (EDT)
Received: by mail-oi0-f42.google.com with SMTP id d205so34562452oia.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 13:09:17 -0700 (PDT)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id nz3si2094882obc.61.2016.03.23.13.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 13:09:16 -0700 (PDT)
Received: by mail-ob0-x235.google.com with SMTP id fp4so22057315obb.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 13:09:16 -0700 (PDT)
Date: Wed, 23 Mar 2016 13:09:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, 12 Mar 2016, Kirill A. Shutemov wrote:

> Here is an updated version of huge pages support implementation in
> tmpfs/shmem.
> 
> All known issues has been fixed. I'll continue with validation.
> I will also send follow up patch with documentation update.
> 
> Hugh, I would be glad to hear your opinion on this patchset.

At long last I've managed to spend some time getting into it.

My opinion is simple: generally I liked your patches,
but I'm disappointed by where they leave tmpfs functionally,
so wouldn't want the patchset to go in as is.

As soon as I ran it up and tried to copy a tree in there for testing,
my (huge) tmpfs filled up with all these 2MB files: which is just the
same as when you started out two or three years ago on ramfs.

As I've said on several occasions, I am not interested in emulating
the limitations of hugetlbfs inside tmpfs: there might one day be a
case for such a project, but it's transparent hugepages that we want to
have now - blocksize 4kB, but in 2MB extents when possible (on x86_64).

I accept that supporting small files correctly is not the #1
requirement for a "huge" tmpfs; and if it were impossible or
unreasonable to ask for, I'd give up on it.  But since we (Google)
have been using a successful implementation for a year now, I see
no reason to give up on it at all: it allows for much wider and
easier adoption (and testing) of huge tmpfs - without "but"s.

The small files thing formed my first impression.  My second
impression was similar, when I tried mmap(NULL, size_of_RAM,
PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
cycled around the arena touching all the pages (which of
course has to push a little into swap): that soon OOMed.

But there I think you probably just have some minor bug to be fixed:
I spent a little while trying to debug it, but then decided I'd
better get back to writing to you.  I didn't really understand what
I was seeing, but when I hacked some stats into shrink_page_list(),
converting !is_page_cache_freeable(page) to page_cache_references(page)
to return the difference instead of the bool, a large proportion of
huge tmpfs pages seemed to have count 1 too high to be freeable at
that point (and one huge tmpfs page had a count of 3477).

Hmm, I just went to repeat that test, to see if MemFree goes down and
down on each run, but got a VM_BUG_ON_PAGE(page_ref_count(page) == 0)
in put_page_testzero() in find_get_entries() during shmem_evict_inode().
So, something not quite right with the refcounting when under pressure.

My third impression was much better, when I just did a straight
cp /dev/zero /tmpfs_twice_size_of_RAM: that went smoothly,
pushed into swap just as it should, nice.

> 
> The main difference with Hugh's approach[1] is that I continue with
> compound pages, where Hugh invents new way couple pages: team pages.
> I believe THP refcounting rework made team pages unnecessary: compound
> page are flexible enough to serve needs of page cache.

I have disagreed with you about the suitability of compound pages;
but at some point on Sunday night, after reading your patchset,
found myself looking at it differently, and now agreeing with you.

They are not flexible enough yet, but I believe you have done a large
part of the work (by diverting all those tail ops to the head), and it
just needs a little more.  I say "a little", but it might not be easy.

What I realize now, is that you should be able to do almost everything
I did with team pages, instead with your compound pages.  Just abandon
the idea that the whole compound page has to be initialized in one go:
initialize (charge to memcg, add to page cache, fill, SetPageUptodate)
each subpage as it is touched.  (But of course, the whole extent has
to be to be initialized before it can be pmd-mapped.)

And the convenient thing about a compound page is that you have plenty
of space to hold your metadata: where I have been squeezing everything
into page->private (which makes it difficult then to extend the same
design to miscellaneous filesystems), you're free to use (certain)
fields of 511 more struct pages.

I said above that you should be able to do almost everything: I think
that "almost" involves dropping a few things that I have, that we can
well do without.  With team pages, it is possible for each member to
be charged to a different memcg; but I don't have anyone calling out
for that behaviour, it's more an awkward possibility that we have to
be on guard against in a few places, and I'd be quite happy just to
stop it (charging instead to whichever memcg first touched the extent).

And it's been nice to entertain the idea of the individual team tails,
travelling separately up and down their own lrus, subject to their own
pagesize access patterns even while the whole is pmd-mapped.  But in
practice, we continue to throw them on the unevictable list once they
get in the way, with no attempt to bring them back when accessed
individually; so I think it's a nice idea that we can live without.

And a compound page implementation would avoid the overhead I have,
of putting all those tails on lru in the first place.

Another thing I did, that I think you can safely fail to emulate:
I was careful to allow sparse population, and not insist that the
head page be instantiated.  That might turn out to be more of a
problem for compound pages, and has been an awkward edge case for me.
Although in principle there are sparse files which would be doubled
in charge by insisting that the head be instantiated, I doubt they
will hurt anyone in practice: perhaps best treated as a bug to be
revisited if it actually comes up as an issue later.

(Thinking about that last paragraph later, I'm not so sure.
Forcing the instantiation of the head is okay when first allocating,
but when trying to recover a fragmented extent into a hugepage later,
it might prove to be seriously limiting to require that the head be
migrated into place before anything else is done.)

> 
> Many ideas and some patches were stolen from Hugh's patchset. Having this
> patchset around was very helpful.

People are probably wondering why I didn't repost it, and whether
it's vapourware.  No, it's worked out very well, better than we were
expecting; and several of the TODOs that I felt needed attention,
have not yet caused anyone trouble - though wider adoption is sure
to meet new usecases and new bugs.  I didn't repost it because, as I
said at the time, I felt it wasn't ready for real use until recovery
of huge pages after fragmentation and swapping (what khugepaged does
for anon THP) was added.  After that went in (and then quite a period
of fixing the bugs, I admit!), other priorities intervened until now.
Your patchset also lacks recovery at present, so equally that's a
reason why I don't consider yours ready for merging.

I'll repost mine, including recovery and a few minor additions, against
v4.6-rc2.  I still haven't got around to doing any NUMA work on it, but
it does appear to be useful to many people even without that.  I'd have
preferred to spend longer rebasing it, it may turn out to be a little
raw: most of the rebases from one release to another have been easy,
but to v4.5 was messier - not particularly due to your THP refcounting
work going in, just various different conflicts that I feel I've not
properly digested yet.  But v4.6-rc2 looks about as early and as late
as I can do it, with LSF/MM coming up later in April; and should be a
good base for people to try it out on.  (I'll work on preparing it in
advance, then I guess a last-minute edit of PAGE_CACHEs before posting.)

I now believe that the right way forward is to get that team page
implementation in as soon as we can, so users have the functionality;
and then (if you're still interested) you work on converting it over
from teams to compound pages, both as an optimization, and to satisfy
your understandable preference for a single way of managing huge pages.

(I would say "How does that sound to you?" but I'd prefer you to think
it over, maybe wait to see what the new team patchset looks like.  Though
aside from the addition of recovery, it is very much like the one against
v3.19 from February last year: no changes to the design at all, which
turned out to fit recovery well; but quite a few bug fixes folded back
in.  Or you may prefer to wait to discuss the way forward at LSF/MM.)

> 
> I will continue with code validation. I would expect mlock require some
> more attention.
> 
> Please, review and test the code.
> 
> Git tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4
> 
> Rebased onto linux-next:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4-next

It wasn't obvious to me what tree your posted patchset was based on,
so I made a patch out of the top your hugetmpfs/v4-next branch, and
applied that on top of Andrew's 4.5-rc7-mm1: which appeared to be
fine, just a trivial clash with mmotm's
"do_shared_fault(): check that mmap_sem is held".

[...]

Some random thoughts on your patches FWIW:

01/25 mm: do not pass mm_struct into handle_mm_fault
02/25 mm: introduce fault_env

These two inflate your patchset considerably, with seemingly unrelated
changes: the first with arch files otherwise untouched, the second with
lots of change to memory.c that makes it harder to compare our patchsets.

I think it would be better to leave the handle_mm_fault(mm) removal to
another patchset, and I'm ambivalent about the struct fault_env changes:
I prefer to avoid such argument blocks (and think I saw Linus once say
he detested my zap_details), which do make it harder to see what the
real arguments are.  I wonder what your 03/25 would look like without
the fault_env, perhaps I'd agree it's too cumbersome that way (and
perhaps I should look back at earlier versions of your patchset).

But I do understand your desire to get some cleanups out of the way
before basing the real work on the new structure: I'm going to have
to reconsider the initial patches of my series in the light of this
criticism of yours, not sure yet if I'll try to cut them out or not.

03/25 mm: postpone page table allocation until we have page to map

I've not stopped to consider whether your prealloc_pte work (which
perhaps was the trigger for fault_env) meets the case or not, but
want to mention that we recently discovered a drawback to my delaying
the pagetable allocation: I'm allocating the pagetable while holding
the lock on the page from the filesystem (any filesystem, though the
change was to suit tmpfs), which presented a deadlock to the OOM killer.
The base kernel involved was not a recent one, and there have been
rewrites in the OOMing area since, so I'm not sure whether it would
be a deadlock today: but I am sure that it would be better to do the
allocation while not holding the page lock.  We have a fix in place,
but I don't think it's quite the right fix, so I want to revisit it:
unless I get a gift of time from somewhere, I'll post my series with
the ordering here just as I had it before.

You remark on yours: "This way we can postpone allocation even in
faultaround case without moving do_fault_around() after __do_fault()."
Was there something wrong or inefficient with my moving do_fault_around()
after __do_fault()?  I thought it was fine; but I did also think when
I made the change, that it would be fixing a bug in VM_FAULT_MAJOR
acccounting too; yet when I went to confirm that, couldn't find evidence
for such a bug before; but I moved on before getting to the bottom of it. 

04/25 rmap: support file thp
05/25 mm: introduce do_set_pmd()
06/25 mm, rmap: account file thp pages

A firm NAK on this one, for a simple reason: we have enough times
regretted mixing up the swap-backed Shmem into File stats; so although
you intend to support huge file pages by the same mechanism later,
the ones you support in this patchset are Shmem: ShmemPmdMapped is
the name I was using.

07/25 thp, vmstats: add counters for huge file pages
08/25 thp: support file pages in zap_huge_pmd()

I see there's an ongoing discussion with Aneesh about whether you
need to deposit/withdraw pagetables.  I blindly assumed that I would
have to participate in that mechanism, so my series should be safe
in that regard, though not as nice as yours.  (But I did get the
sequence needed for PowerPC wrong somewhere in my original posting.)

09/25 thp: handle file pages in split_huge_pmd()

That's neat, just unmapping the pmd for the shared file/shmem case,
I didn't think to do it that way.  Or did I have some other reason
for converting the pmd to ptes?  I think it is incorrect not to
provide ptes when splitting when it's an mlock()ed area; but
you've said yourself that mlock probably needs more work.

10/25 thp: handle file COW faults

We made the same decision (and Matthew for DAX too IIRC): don't
bother to COW hugely, it's more code, and often not beneficial.

11/25 thp: handle file pages in mremap()

Right, I missed that from my v3.19 rebase, but added it later
when I woke up to your v3.15 mod: I prefer my version of this patch,
which adds take_rmap_locks(vma) and drop_rmap_locks(vma) helpers.

12/25 thp: skip file huge pmd on copy_huge_pmd()

Oh, that looks good, I'd forgotten about that optimization.
And I think in this case you don't have to worry about VM_LOCKED
or deposit/withdraw, it's just fine to skip over it.  I think I'll
post my one as it is, and let you scoff at it then.

13/25 thp: prepare change_huge_pmd() for file thp

You're very dedicated to inserting the vma_is_anonymous(),
where I just delete the BUG_ON.  Good for you.

14/25 thp: run vma_adjust_trans_huge() outside i_mmap_rwsem

Interesting.  I haven't spent long enough looking at this, just noted
it as something to come back to: I haven't decided whether this is a
good safe obvious change (always better to do something outside the
lock if it's safe), or not.  I don't have that issue of munlock()ing
when splitting, so hadn't noticed the peculiar placing of
vma_adjust_trans_huge() inside the one lock but outside the other.

15/25 thp: file pages support for split_huge_page()

I didn't go much beyond your very helpful commit comment on this one.
I'd been worried by how you would freeze for the split, but it sounds
right.  Very interested to see your comment about dropping pages beyond
i_size from the radix-tree: I think that's absolutely right, but never
occurred to me to do - not something that tests or users notice, but
needed for correctness.

16/25 thp, mlock: do not mlock PTE-mapped file huge pages

I think we both wish there were no mlock(), it gave me more trouble
than anything.  And it wouldn't be a surprise if what I have and
think works, actually turns out to be very broken.  So I'm going to
be careful about criticising your workarounds, they might be better.

17/25 vmscan: split file huge pages before paging them out

As mentioned at the beginning, seemed to work well for the straight
cp, but not when the huge pages were mapped.

18/25 page-flags: relax policy for PG_mappedtodisk and PG_reclaim
19/25 radix-tree: implement radix_tree_maybe_preload_order()
20/25 filemap: prepare find and delete operations for huge pages
21/25 truncate: handle file thp
22/25 shmem: prepare huge= mount option and sysfs knob
23/25 shmem: get_unmapped_area align huge page
24/25 shmem: add huge pages support
25/25 shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings

Not much to say on these at the moment, but clearly we'll need to
settle the user interfaces of 22/25 and 25/25 before anything reaches
Linus.  For simplicity, I've carried on with my distinct mount options
and knobs, but agree that some rapprochement with anon THP conventions
will probably be required before finalizing.

That's all for now - thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
