Date: Tue, 1 May 2007 20:31:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
In-Reply-To: <4636FDD7.9080401@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <4636FDD7.9080401@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Nick Piggin wrote:
> Andrew Morton wrote:
> 
> >  mm-simplify-filemap_nopage.patch
> >  mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
> >  mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
> >  mm-merge-nopfn-into-fault.patch
> >  convert-hugetlbfs-to-use-vm_ops-fault.patch
> >  mm-remove-legacy-cruft.patch
> >  mm-debug-check-for-the-fault-vs-invalidate-race.patch
> 
> > mm-fix-clear_page_dirty_for_io-vs-fault-race.patch
> 
> > Miscish MM changes.  Will merge, dependent upon what still applies and works
> > if the moveable-zone patches get stalled.
> 
> These fix some bugs in the core vm, at least the former one we have
> seen numerous people hitting in production...
...
> 
> So, do you or anyone else have any problems with these patches going in
> 2.6.22? I haven't had much feedback for a while, but I was under the
> impression that people are more-or-less happy with them?
> 
> mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
> 
> This patch fixes the core filemap_nopage vs invalidate_inode_pages2
> race by having filemap_nopage return a locked page to do_no_page,
> and removes the fairly complex (and inadequate) truncate_count
> synchronisation logic.
> 
> There were concerns that we could do this more cheaply, but I think it
> is important to start with a base that is simple and more likely to
> be correct and build on that. My testing didn't show any obvious
> problems with performance.

I don't see _problems_ with performance, but I do consistently see the
same kind of ~5% degradation in lmbench fork, exec, sh, mmap latency
and page fault tests on SMP, several machines, just as I did last year.

I'm assuming this patch is the one responsible: at 2.6.20-rc4 time
you posted a set of 10 and a set of 7 patches I tried in versus out;
at 2.6.21-rc3-mm2 time you had a group of patches in -mm I tried in
versus out; with similar results.

I did check the graphs on test.kernel.org, I couldn't see any bad
behaviour there that correlated with this work; though each -mm
has such a variety of new work in it, it's very hard to attribute.
And nobody else has reported any regression from your patches.

I'm inclined to write it off as poorer performance in some micro-
benchmarks, against which we offset the improved understandabilty
of holding the page lock over the file fault.

But I was quite disappointed when 
mm-fix-fault-vs-invalidate-race-for-linear-mappings-fix.patch
appeared, putting double unmap_mapping_range calls in.  Certainly
you were wrong to take the one out, but a pity to end up with two.

Your comment says/said:
The nopage vs invalidate race fix patch did not take care of truncating
private COW pages. Mind you, I'm pretty sure this was previously racy
even for regular truncate, not to mention vmtruncate_range.

vmtruncate_range (holepunch) was deficient I agree, and though we
can now take out your second unmap_mapping_range there, that's only
because I've slipped one into shmem_truncate_range.  In due course it
needs to be properly handled by noting the range in shmem inode info.

(I think you couldn't take that approach, noting invalid range in
->mapping while invalidating, because NFS has/had some cases of
invalidate_whatever without i_mutex?)

But I'm pretty sure (to use your words!) regular truncate was not racy
before: I believe Andrea's sequence count was handling that case fine,
without a second unmap_mapping_range.

Well, I guess I've come to accept that, expensive as unmap_mapping_range
may be, truncating files while they're mmap'ed is perverse behaviour:
perhaps even deserving such punishment.

But it is a shame, and leaves me wondering what you gained with the
page lock there.

One thing gained is ease of understanding, and if your later patches
build an edifice upon the knowledge of holding that page lock while
faulting, I've no wish to undermine that foundation.

> 
> mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
> mm-merge-nopfn-into-fault.patch
> etc.
> 
> These move ->nopage, ->populate, ->nopfn (and soon, ->page_mkwrite)
> into a single, unified interface. Although this strictly closes some
> similar holes in nonlinear faults as well, they are very uncommon, so
> I wouldn't be so upset if these aren't merged in 2.6.22 (I don't see
> any reason not to, but at least they don't fix major bugs).

I don't have an opinion on these, but I think BenH and others
were strongly in favour, with various people waiting upon them.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
