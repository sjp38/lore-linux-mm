Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D44A68D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 08:44:18 -0400 (EDT)
Date: Thu, 17 Mar 2011 13:43:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110317124350.GQ2140@cmpxchg.org>
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
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Wed, Mar 16, 2011 at 09:41:48PM -0700, Greg Thelen wrote:
> In '[PATCH v6 8/9] memcg: check memcg dirty limits in page writeback' Jan and
> Vivek have had some discussion around how memcg and writeback mesh.
> In my mind, the
> discussions in 8/9 are starting to blend with this thread.
> 
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

So structures roughly like this:

struct mem_cgroup {
	...
	/* key is struct backing_dev_info * */
	struct rb_root memcg_bdis;
};

struct memcg_bdi {
	/* key is struct address_space * */
	struct rb_root memcg_mappings;
	struct rb_node node;
};

struct memcg_mapping {
	struct address_space *mapping;
	struct mem_cgroup *memcg;
	struct rb_node node;
	atomic_t count;
};

struct page_cgroup {
	...
	struct memcg_mapping *memcg_mapping;
};

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

We may want to remember the dirty memcg_mappings so that on writeback
we don't have to go through every single one that the memcg refers to?

> - mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if above
>   background limit, then add memcg to global memcg_over_bg_limit list and use
>   memcg's set of memcg_bdi to wakeup each(?) corresponding bdi flusher.  If over
>   fg limit, then use IO-less style foreground throttling with per-memcg per-bdi
>   (aka memcg_bdi) accounting structure.

I wonder if we could just schedule a for_background work manually in
the memcg case that writes back the corresponding memcg_bdi set (and
e.g. having it continue until either the memcg is below bg thresh OR
the global bg thresh is exceeded OR there is other work scheduled)?
Then we would get away without the extra list, and it doesn't sound
overly complex to implement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
