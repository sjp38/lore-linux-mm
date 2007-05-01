Message-ID: <4636FDD7.9080401@yahoo.com.au>
Date: Tue, 01 May 2007 18:44:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>  mm-simplify-filemap_nopage.patch
>  mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
>  mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
>  mm-merge-nopfn-into-fault.patch
>  convert-hugetlbfs-to-use-vm_ops-fault.patch
>  mm-remove-legacy-cruft.patch
>  mm-debug-check-for-the-fault-vs-invalidate-race.patch

>  mm-fix-clear_page_dirty_for_io-vs-fault-race.patch

> Miscish MM changes.  Will merge, dependent upon what still applies and works
> if the moveable-zone patches get stalled.

These fix some bugs in the core vm, at least the former one we have
seen numerous people hitting in production...

I don't suppose you mean these are logically dependant on new features
sitting below them in your patch stack, just that you don't want to
spend time fixing a lot of rejects? If so, I can help fix those up, but
I don't think there is anything major, IIRC the biggest annoyance is
just that changing some GFP_types throws some big hunks.

So, do you or anyone else have any problems with these patches going in
2.6.22? I haven't had much feedback for a while, but I was under the
impression that people are more-or-less happy with them?

mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch

This patch fixes the core filemap_nopage vs invalidate_inode_pages2
race by having filemap_nopage return a locked page to do_no_page,
and removes the fairly complex (and inadequate) truncate_count
synchronisation logic.

There were concerns that we could do this more cheaply, but I think it
is important to start with a base that is simple and more likely to
be correct and build on that. My testing didn't show any obvious
problems with performance.

mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
mm-merge-nopfn-into-fault.patch
etc.

These move ->nopage, ->populate, ->nopfn (and soon, ->page_mkwrite)
into a single, unified interface. Although this strictly closes some
similar holes in nonlinear faults as well, they are very uncommon, so
I wouldn't be so upset if these aren't merged in 2.6.22 (I don't see
any reason not to, but at least they don't fix major bugs).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
