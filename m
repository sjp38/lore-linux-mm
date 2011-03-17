Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0ABE8D003B
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 10:46:50 -0400 (EDT)
Date: Thu, 17 Mar 2011 15:46:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110317144641.GC4116@quack.suse.cz>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
 <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
 <20110316215214.GO2140@cmpxchg.org>
 <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Wed 16-03-11 21:41:48, Greg Thelen wrote:
> I have been thinking about Johannes' struct memcg_mapping.  I think the idea
> may address several of the issues being discussed, especially
> interaction between
> IO-less balance_dirty_pages() and memcg writeback.
> 
> Here is my thinking.  Feedback is most welcome!
> 
> The data structures:
> - struct memcg_mapping {
>        struct address_space *mapping;
>        struct mem_cgroup *memcg;
>        int refcnt;
>   };
> - each memcg contains a (radix, hash_table, etc.) mapping from bdi to memcg_bdi.
> - each memcg_bdi contains a mapping from inode to memcg_mapping.  This may be a
>   very large set representing many cached inodes.
> - each memcg_mapping represents all pages within an bdi,inode,memcg.  All
>   corresponding cached inode pages point to the same memcg_mapping via
>   pc->mapping.  I assume that all pages of inode belong to no more than one bdi.
> - manage a global list of memcg that are over their respective background dirty
>   limit.
> - i_mapping continues to point to a traditional non-memcg mapping (no change
>   here).
> - none of these memcg_* structures affect root cgroup or kernels with memcg
>   configured out.
> 
> The routines under discussion:
> - memcg charging a new inode page to a memcg: will use inode->mapping and inode
>   to walk memcg -> memcg_bdi -> memcg_mapping and lazily allocating missing
>   levels in data structure.
> 
> - Uncharging a inode page from a memcg: will use pc->mapping->memcg to locate
>   memcg.  If refcnt drops to zero, then remove memcg_mapping from the memcg_bdi.
>   Also delete memcg_bdi if last memcg_mapping is removed.
> 
> - account_page_dirtied(): nothing new here, continue to set the per-page flags
>   and increment the memcg per-cpu dirty page counter.  Same goes for routines
>   that mark pages in writeback and clean states.
> 
> - mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if above
>   background limit, then add memcg to global memcg_over_bg_limit list and
>   use memcg's set of memcg_bdi to wakeup each(?) corresponding bdi
>   flusher. 
  In fact, mem_cgroup_balance_dirty_pages() is called for a particular bdi.
So after some thought I think we should wake up flusher thread only for that
bdi to mimic the logic of global background limit. If memcg is dirtying
pages on another bdi, mem_cgroup_balance_dirty_pages() will get called for
that bdi eventually as well.

>   If over fg limit, then use IO-less style foreground
>   throttling with per-memcg per-bdi (aka memcg_bdi) accounting structure.
  We'll probably need a counter of written pages in memcg_bdi so that we
are able to tell how big progress are we making with the writeback and
decide when to release throttled thread. But it should be doable just fine.

> - bdi writeback: will revert some of the mmotm memcg dirty limit changes to
>   fs-writeback.c so that wb_do_writeback() will return to checking
>   wb_check_background_flush() to check background limits and being
> interruptible if
>   sync flush occurs.  wb_check_background_flush() will check the global
>   memcg_over_bg_limit list for memcg that are over their dirty limit.
>   wb_writeback() will either (I am not sure):
>   a) scan memcg's bdi_memcg list of inodes (only some of them are dirty)
>   b) scan bdi dirty inode list (only some of them in memcg) using
>      inode_in_memcg() to identify inodes to write.  inode_in_memcg(inode,memcg),
>      would walk memcg- -> memcg_bdi -> memcg_mapping to determine if the memcg
>      is caching pages from the inode.
Hmm, both has its problems. With a) we could queue all the dirty inodes
from the memcg for writeback but then we'd essentially write all dirty data
for a memcg, not only enough data to get below bg limit. And if we started
skipping inodes when memcg(s) inode belongs to get below bg limit, we'd
risk copying inodes there and back without reason, cases where some inodes
never get written because they always end up skipped etc. Also the question
whether some of the memcgs inode belongs to is still over limit is the
hardest part of solution b) so we wouldn't help ourselves much.

The problem with b) is that the flusher thread will not work on behalf
of one memcg but rather on behalf of all memcgs that have crossed their
background limits.  Thus what it should do is to scan inode dirty list and
for each inode ask: Does the inode belong to any of memcgs that have
crossed background limit? If yes, write it, if no, skip it. I'm not sure
about the best data structure for such query - essentially we have a set of
memcgs for an inode (memcgs which have pages in a mapping - ideally only
dirty ones but I guess that's asking for too much ;)) and a set of
memcgs that have crossed background limit and ask whether they have
nonempty intersection. Hmm, if we had memcgs for the inode and memcgs
over bg limit in a tree ordered (by an arbitrary criterion), we could do
the intersection rather efficiently in time O(m*log(n)) where 'm' is size
of the smaller tree and 'n' size of the larger tree. But it gets complex.

All in all I see as reasonable choices either b) or a) in a trivial variant
where we write all the dirty data in a memcg...

> - over_bground_thresh() will determine if memcg is still over bg limit.
>   If over limit, then it per bdi per memcg background flushing will continue.
>   If not over limit then memcg will be removed from memcg_over_bg_limit list.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
