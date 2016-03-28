Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E24A56B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 08:29:20 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id 20so15417327wmh.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 05:29:20 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id j5si28213891wjz.127.2016.03.28.05.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 05:29:19 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id 20so3318720wmh.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 05:29:19 -0700 (PDT)
Date: Mon, 28 Mar 2016 15:29:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
Message-ID: <20160328122916.GA23853@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> On Sat, 12 Mar 2016, Kirill A. Shutemov wrote:
...
> As I've said on several occasions, I am not interested in emulating
> the limitations of hugetlbfs inside tmpfs: there might one day be a
> case for such a project, but it's transparent hugepages that we want to
> have now - blocksize 4kB, but in 2MB extents when possible (on x86_64).
> 
> I accept that supporting small files correctly is not the #1
> requirement for a "huge" tmpfs; and if it were impossible or
> unreasonable to ask for, I'd give up on it.  But since we (Google)
> have been using a successful implementation for a year now, I see
> no reason to give up on it at all: it allows for much wider and
> easier adoption (and testing) of huge tmpfs - without "but"s.

I think, once we get collapse work, huge=within_size would provide
reasonable support for fs with mixed-sized files.

Yes, we still would have overhead on sparsed or punch-holed files.
As for now, I don't see it being show-stopper. The hugepage allocation
policy can be overwritten with MADV/FADV_NOHUGEPAGE if an application
don't want to see huge pages in a particular case.

...

> Hmm, I just went to repeat that test, to see if MemFree goes down and
> down on each run, but got a VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> in put_page_testzero() in find_get_entries() during shmem_evict_inode().
> So, something not quite right with the refcounting when under pressure.

I suspect some race with split_huge_page(), but don't see it so far.

> My third impression was much better, when I just did a straight
> cp /dev/zero /tmpfs_twice_size_of_RAM: that went smoothly,
> pushed into swap just as it should, nice.
> 
> > 
> > The main difference with Hugh's approach[1] is that I continue with
> > compound pages, where Hugh invents new way couple pages: team pages.
> > I believe THP refcounting rework made team pages unnecessary: compound
> > page are flexible enough to serve needs of page cache.
> 
> I have disagreed with you about the suitability of compound pages;
> but at some point on Sunday night, after reading your patchset,
> found myself looking at it differently, and now agreeing with you.
> 
> They are not flexible enough yet, but I believe you have done a large
> part of the work (by diverting all those tail ops to the head), and it
> just needs a little more.  I say "a little", but it might not be easy.
> 
> What I realize now, is that you should be able to do almost everything
> I did with team pages, instead with your compound pages.  Just abandon
> the idea that the whole compound page has to be initialized in one go:
> initialize (charge to memcg, add to page cache, fill, SetPageUptodate)
> each subpage as it is touched.  (But of course, the whole extent has
> to be to be initialized before it can be pmd-mapped.)

I'm not convinced, that doing such operations on per-4k is better.
All-at-once is simpler and has natural performance benefit from batching.

I think we can switch some operations to per-4k basis once upside will be
obvious. It's more on optimization side.

> And the convenient thing about a compound page is that you have plenty
> of space to hold your metadata: where I have been squeezing everything
> into page->private (which makes it difficult then to extend the same
> design to miscellaneous filesystems), you're free to use (certain)
> fields of 511 more struct pages.
> 
> I said above that you should be able to do almost everything: I think
> that "almost" involves dropping a few things that I have, that we can
> well do without.  With team pages, it is possible for each member to
> be charged to a different memcg; but I don't have anyone calling out
> for that behaviour, it's more an awkward possibility that we have to
> be on guard against in a few places, and I'd be quite happy just to
> stop it (charging instead to whichever memcg first touched the extent).
> 
> And it's been nice to entertain the idea of the individual team tails,
> travelling separately up and down their own lrus, subject to their own
> pagesize access patterns even while the whole is pmd-mapped.  But in
> practice, we continue to throw them on the unevictable list once they
> get in the way, with no attempt to bring them back when accessed
> individually; so I think it's a nice idea that we can live without.
> 
> And a compound page implementation would avoid the overhead I have,
> of putting all those tails on lru in the first place.

Exactly. LRU scanning is one of places where this kind of batching is
beneficial.

> Another thing I did, that I think you can safely fail to emulate:
> I was careful to allow sparse population, and not insist that the
> head page be instantiated.  That might turn out to be more of a
> problem for compound pages, and has been an awkward edge case for me.
> Although in principle there are sparse files which would be doubled
> in charge by insisting that the head be instantiated, I doubt they
> will hurt anyone in practice: perhaps best treated as a bug to be
> revisited if it actually comes up as an issue later.

Agreed.

> (Thinking about that last paragraph later, I'm not so sure.
> Forcing the instantiation of the head is okay when first allocating,
> but when trying to recover a fragmented extent into a hugepage later,
> it might prove to be seriously limiting to require that the head be
> migrated into place before anything else is done.)

Hm. I think you imply some implementation details of your recovering
process here, don't you?

> > 
> > Many ideas and some patches were stolen from Hugh's patchset. Having this
> > patchset around was very helpful.
> 
> People are probably wondering why I didn't repost it, and whether
> it's vapourware.  No, it's worked out very well, better than we were
> expecting; and several of the TODOs that I felt needed attention,
> have not yet caused anyone trouble - though wider adoption is sure
> to meet new usecases and new bugs.  I didn't repost it because, as I
> said at the time, I felt it wasn't ready for real use until recovery
> of huge pages after fragmentation and swapping (what khugepaged does
> for anon THP) was added.  After that went in (and then quite a period
> of fixing the bugs, I admit!), other priorities intervened until now.
> Your patchset also lacks recovery at present, so equally that's a
> reason why I don't consider yours ready for merging.

I hoped we will be able to address this later, after initial merge, but
since you insist...

I have started looking into collapsing. I have week or so catch you up on
this. Will see what I'll be able to achieve...

Not having your repair implementation public is a bummer -- I miss
opportunity to rip off your ideas. :-P

> I'll repost mine, including recovery and a few minor additions, against
> v4.6-rc2.  I still haven't got around to doing any NUMA work on it, but
> it does appear to be useful to many people even without that.  I'd have
> preferred to spend longer rebasing it, it may turn out to be a little
> raw: most of the rebases from one release to another have been easy,
> but to v4.5 was messier - not particularly due to your THP refcounting
> work going in, just various different conflicts that I feel I've not
> properly digested yet.  But v4.6-rc2 looks about as early and as late
> as I can do it, with LSF/MM coming up later in April; and should be a
> good base for people to try it out on.  (I'll work on preparing it in
> advance, then I guess a last-minute edit of PAGE_CACHEs before posting.)
> 
> I now believe that the right way forward is to get that team page
> implementation in as soon as we can, so users have the functionality;
> and then (if you're still interested) you work on converting it over
> from teams to compound pages, both as an optimization, and to satisfy
> your understandable preference for a single way of managing huge pages.

That might work. But major switch of implementation is always risky.
Minor inconsistency in behaviour after switch may be considered as
regression. So we need to be careful.

> (I would say "How does that sound to you?" but I'd prefer you to think
> it over, maybe wait to see what the new team patchset looks like.  Though
> aside from the addition of recovery, it is very much like the one against
> v3.19 from February last year: no changes to the design at all, which
> turned out to fit recovery well; but quite a few bug fixes folded back
> in.  Or you may prefer to wait to discuss the way forward at LSF/MM.)
> 
> > 
> > I will continue with code validation. I would expect mlock require some
> > more attention.
> > 
> > Please, review and test the code.
> > 
> > Git tree:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4
> > 
> > Rebased onto linux-next:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4-next
> 
> It wasn't obvious to me what tree your posted patchset was based on,
> so I made a patch out of the top your hugetmpfs/v4-next branch, and
> applied that on top of Andrew's 4.5-rc7-mm1: which appeared to be
> fine, just a trivial clash with mmotm's
> "do_shared_fault(): check that mmap_sem is held".

It was based on mhocko/mm.git since-4.4.

> 
> [...]
> 
> Some random thoughts on your patches FWIW:
> 
> 01/25 mm: do not pass mm_struct into handle_mm_fault
> 02/25 mm: introduce fault_env
> 
> These two inflate your patchset considerably, with seemingly unrelated
> changes: the first with arch files otherwise untouched, the second with
> lots of change to memory.c that makes it harder to compare our patchsets.
> 
> I think it would be better to leave the handle_mm_fault(mm) removal to
> another patchset, and I'm ambivalent about the struct fault_env changes:
> I prefer to avoid such argument blocks (and think I saw Linus once say
> he detested my zap_details), which do make it harder to see what the
> real arguments are.  I wonder what your 03/25 would look like without
> the fault_env, perhaps I'd agree it's too cumbersome that way (and
> perhaps I should look back at earlier versions of your patchset).
> 
> But I do understand your desire to get some cleanups out of the way
> before basing the real work on the new structure: I'm going to have
> to reconsider the initial patches of my series in the light of this
> criticism of yours, not sure yet if I'll try to cut them out or not.

On my side, I would prefer to keep them unless it's total no-go.
Cutting them out would be painful.

> 03/25 mm: postpone page table allocation until we have page to map
> 
> I've not stopped to consider whether your prealloc_pte work (which
> perhaps was the trigger for fault_env) meets the case or not, but
> want to mention that we recently discovered a drawback to my delaying
> the pagetable allocation: I'm allocating the pagetable while holding
> the lock on the page from the filesystem (any filesystem, though the
> change was to suit tmpfs), which presented a deadlock to the OOM killer.
> The base kernel involved was not a recent one, and there have been
> rewrites in the OOMing area since, so I'm not sure whether it would
> be a deadlock today: but I am sure that it would be better to do the
> allocation while not holding the page lock.  We have a fix in place,
> but I don't think it's quite the right fix, so I want to revisit it:
> unless I get a gift of time from somewhere, I'll post my series with
> the ordering here just as I had it before.

prealloc_pte was invented to avoid allocation under ptl in faultaround
case. But I think we can re-use it to pre-allocate page table before
->fault request.

I wounder why it's a deadlock for OOM. Shoudn't oom-killer use trylock and
bail out if it fails?

> You remark on yours: "This way we can postpone allocation even in
> faultaround case without moving do_fault_around() after __do_fault()."
> Was there something wrong or inefficient with my moving do_fault_around()
> after __do_fault()?

For hot page cache case we can avoid ->fault() call if do_fault_around()
managed to solve the fault. It also means we don't need to lock the page
again and take ptl.

> I thought it was fine; but I did also think when
> I made the change, that it would be fixing a bug in VM_FAULT_MAJOR
> acccounting too; yet when I went to confirm that, couldn't find evidence
> for such a bug before; but I moved on before getting to the bottom of it. 

Hm. do_fault_around() is not able to solve major page fault by design.
Or am I missing something?

> 04/25 rmap: support file thp
> 05/25 mm: introduce do_set_pmd()
> 06/25 mm, rmap: account file thp pages
> 
> A firm NAK on this one, for a simple reason: we have enough times
> regretted mixing up the swap-backed Shmem into File stats; so although
> you intend to support huge file pages by the same mechanism later,
> the ones you support in this patchset are Shmem: ShmemPmdMapped is
> the name I was using.

Okay. I'll rework that.
> 
> 07/25 thp, vmstats: add counters for huge file pages
> 08/25 thp: support file pages in zap_huge_pmd()
> 
> I see there's an ongoing discussion with Aneesh about whether you
> need to deposit/withdraw pagetables.  I blindly assumed that I would
> have to participate in that mechanism, so my series should be safe
> in that regard, though not as nice as yours.  (But I did get the
> sequence needed for PowerPC wrong somewhere in my original posting.)
> 
> 09/25 thp: handle file pages in split_huge_pmd()
> 
> That's neat, just unmapping the pmd for the shared file/shmem case,
> I didn't think to do it that way.  Or did I have some other reason
> for converting the pmd to ptes?  I think it is incorrect not to
> provide ptes when splitting when it's an mlock()ed area; but
> you've said yourself that mlock probably needs more work.

Since we don't deposit page tables for file mapping, there's no easy way
to provide ptes for mlocked() areas. DAX has the same problem too.

Special-cased deposit for VM_LOCKED VMAs is going to be ugly and prune to
leaks.

Always-deposit is to wasteful especially for very large mappings (consider
DAX).

/me hates mlock.

> 10/25 thp: handle file COW faults
> 
> We made the same decision (and Matthew for DAX too IIRC): don't
> bother to COW hugely, it's more code, and often not beneficial.

Actually, one small topic I wanted to discuss on LSF/MM is if we want to
do the same for anon-THP. New refcounting allows that.

Although, it probably would require some work on khugepaged side to allow
COW-break of PTE-mapped THP to collapse.

> 11/25 thp: handle file pages in mremap()
> 
> Right, I missed that from my v3.19 rebase, but added it later
> when I woke up to your v3.15 mod: I prefer my version of this patch,
> which adds take_rmap_locks(vma) and drop_rmap_locks(vma) helpers.

Okay, I'll check it out once it will be public.

> 12/25 thp: skip file huge pmd on copy_huge_pmd()
> 
> Oh, that looks good, I'd forgotten about that optimization.
> And I think in this case you don't have to worry about VM_LOCKED
> or deposit/withdraw, it's just fine to skip over it.  I think I'll
> post my one as it is, and let you scoff at it then.
> 
> 13/25 thp: prepare change_huge_pmd() for file thp
> 
> You're very dedicated to inserting the vma_is_anonymous(),
> where I just delete the BUG_ON.  Good for you.

Dave suggested this. :)

> 14/25 thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
> 
> Interesting.  I haven't spent long enough looking at this, just noted
> it as something to come back to: I haven't decided whether this is a
> good safe obvious change (always better to do something outside the
> lock if it's safe), or not.  I don't have that issue of munlock()ing
> when splitting, so hadn't noticed the peculiar placing of
> vma_adjust_trans_huge() inside the one lock but outside the other.

We had the same issue back on my first attempt of huge page cache. Before
refcounting rework vma_adjust_trans_huge() implied split_huge_page() which
does rmap walk.

> 15/25 thp: file pages support for split_huge_page()
> 
> I didn't go much beyond your very helpful commit comment on this one.
> I'd been worried by how you would freeze for the split, but it sounds
> right.  Very interested to see your comment about dropping pages beyond
> i_size from the radix-tree: I think that's absolutely right, but never
> occurred to me to do - not something that tests or users notice, but
> needed for correctness.
> 
> 16/25 thp, mlock: do not mlock PTE-mapped file huge pages
> 
> I think we both wish there were no mlock(), it gave me more trouble
> than anything.  And it wouldn't be a surprise if what I have and
> think works, actually turns out to be very broken.  So I'm going to
> be careful about criticising your workarounds, they might be better.
> 
> 17/25 vmscan: split file huge pages before paging them out
> 
> As mentioned at the beginning, seemed to work well for the straight
> cp, but not when the huge pages were mapped.
> 
> 18/25 page-flags: relax policy for PG_mappedtodisk and PG_reclaim
> 19/25 radix-tree: implement radix_tree_maybe_preload_order()
> 20/25 filemap: prepare find and delete operations for huge pages
> 21/25 truncate: handle file thp
> 22/25 shmem: prepare huge= mount option and sysfs knob
> 23/25 shmem: get_unmapped_area align huge page
> 24/25 shmem: add huge pages support
> 25/25 shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
> 
> Not much to say on these at the moment, but clearly we'll need to
> settle the user interfaces of 22/25 and 25/25 before anything reaches
> Linus.  For simplicity, I've carried on with my distinct mount options
> and knobs, but agree that some rapprochement with anon THP conventions
> will probably be required before finalizing.
> 
> That's all for now - thanks,
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
