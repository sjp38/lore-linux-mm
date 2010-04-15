Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AC30D6B0202
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:18:13 -0400 (EDT)
Date: Thu, 15 Apr 2010 10:17:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][BUGFIX][PATCH 1/2] memcg: fix charge bypass route of
 migration
Message-ID: <20100415081743.GP32034@random.random>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
 <20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
 <20100415154324.834dace9.nishimura@mxp.nes.nec.co.jp>
 <20100415155611.da707913.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415155611.da707913.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 03:56:11PM +0900, KAMEZAWA Hiroyuki wrote:
> Ok, ignore this patch.

Ok so I'll stick to my original patch on aa.git:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=f0a05fea58501298ab7b800ac8220f017c66f427

I already also merged the move from /proc to debugfs from Mel of two
files. So now I've to:

1) finish the generic doc in Documentation/ (mostly taken from
   transparent hugepage core changeset comments here:
   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=b901f7e1ab412241d4299954ae28505f2206af1d
   )

2) add alloc_pages_vma for numa awareness in the huge page faults

3) have the kernel stack 2m aligned and growsdown the vm_start in 2m
   chunks when enabled=always. I doubt it makes sense to decouple this
   feature from enabled=always and to add a special sysfs control for
   it, plus I don't like adding too many apis and it can always
   decoupled later.

4) I think I will not add a prctl to achieve Ingo's per-process enable
   for now. I'm quite convinced in real life madvise is enough and
   enabled=always|madvise|never is more than enough for the testing
   without having to add a prctl. This is identical issue to KSM after
   all, in the end also KSM is missing a prctl to enabled merging on a
   per process basis and that's fine. prctl really looks very much
   like libhugetlbfs to me so I'm not very attracted to it as I doubt
   its usefulness strongly and if I add it, it becomes a
   forever-existing API (actually even worse than the sysfs layout
   from the kernel API point of view) so there has to be a strong
   reason for it. And I don't think there's any point to add a
   madvise(MADV_NO_HUGEPAGE) or a prctl to selectively _disable_
   hugepages on mappings or processes when enabled=always. It makes no
   sense to use enabled=always and then to disable hugepages in a few
   apps. The opposite makes sense to save memory of course! I don't
   want to add kernel APIs in prctl useful only for testing and
   benchmarking. It can always be added later anyway...

5) Ulrich sent me a _three_ liner that will make glibc fully cooperate
   and guarantee all anon ram goes in hugepages without using
   khugepaged (just like libhugetlbfs would cooperate with
   hugetlbfs). For the posix threads it won't work yet and for that we
   may need to add a MAP_ALIGN flag to mmap (suggested by him) to be
   optimal and not waste address space on 32bit archs. That's no big
   deal, it's still orders of magnitude simpler that backing an
   mmap(4k) with a 2M page and collect the still unmapped parts of
   the 2M pages when system is low on memory. Furthermore MAP_ALIGN
   will involve the mmap paths with mmap_sem write mode, that aren't
   really fast paths, while the mmap(4k) backed by 2M would slowdown
   do_anonymous_pages and other core fast paths that are much more
   performance critical than the mmap paths. So I think this is the
   way to go. And if somebody don't want to risk wasting memory the
   default should be enabled=madvise and then add madvise where
   needed. One either has to choose between performance and memory,
   and I don't want intermediate terms like "a bit faster but not as
   fast as it can be, but waste a little less memory" which also
   complicates the code a lot and microslowdown the fast paths.

6) add a config option at kernel configuration time to select the
   transparent hugepage default between always/madvise/never
   (in-kernel set_recommended_min_free_kbytes late_initcall() will be
   running only for always/madvise, as it already checks the built time
   default and it won't run unless enabled=always|madvise).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
