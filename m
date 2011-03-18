Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 27C428D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 10:50:23 -0400 (EDT)
Date: Fri, 18 Mar 2011 10:50:03 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110318145003.GB19859@redhat.com>
References: <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
 <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
 <20110316215214.GO2140@cmpxchg.org>
 <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
 <20110317124350.GQ2140@cmpxchg.org>
 <AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Fri, Mar 18, 2011 at 12:57:09AM -0700, Greg Thelen wrote:

[..]
> I think this is a good idea to allow per memcg per bdi list of dirty mappings.
> 
> It feels like some of this is starting to gel.  I've been sketching
> some of the code to see how the memcg locking will work out.  The
> basic structures I see are:
> 
> struct mem_cgroup {
>         ...
>         /*
>          * For all file pages cached by this memcg sort by bdi.
>          * key is struct backing_dev_info *; value is struct memcg_bdi *
>          * Protected by bdis_lock.
>          */
>         struct rb_root bdis;
>         spinlock_t bdis_lock;  /* or use rcu structure, memcg:bdi set
> could be fairly static */
> };
> 
> struct memcg_bdi {
>         struct backing_dev_info *bdi;
>         /*
>          * key is struct address_space *; value is struct
> memcg_mapping *
>          * memcg_mappings live within either mappings or
> dirty_mappings set.
>          */
>         struct rb_root mappings;
>         struct rb_root dirty_mappings;
>         struct rb_node node;
>         spinlock_t lock; /* protect [dirty_]mappings */
> };
> 
> struct memcg_mapping {
>         struct address_space *mapping;
>         struct memcg_bdi *memcg_bdi;
>         struct rb_node node;
>         atomic_t nr_pages;
>         atomic_t nr_dirty;
> };
> 
> struct page_cgroup {
>         ...
>         struct memcg_mapping *memcg_mapping;
> };
> 
> - each memcg contains a mapping from bdi to memcg_bdi.
> - each memcg_bdi contains two mappings:
>   mappings: from address_space to memcg_mapping for clean pages
>   dirty_mappings: from address_space to memcg_mapping when there are
> some dirty pages

Keeping dirty_mappings separate sounds like a good idea. To me this is
equivalent of wb->b_dirty and down the line we might want to also
maintain equivalent of ->b_io and ->b_more_io. But that's for later.

> - each memcg_mapping represents a set of cached pages within an
> bdi,inode,memcg.  All
>  corresponding cached inode pages point to the same memcg_mapping via
>  pc->mapping.  I assume that all pages of inode belong to no more than one bdi.
> - manage a global list of memcg that are over their respective background dirty
>  limit.
> - i_mapping continues to point to a traditional non-memcg mapping (no change
>  here).
> - none of these memcg_* structures affect root cgroup or kernels with memcg
>  configured out.

So there will not be any memcg structure for root cgroup? Then how would
we make sure that flusher thread does not starve either root cgroup inodes
or memory cgroup inodes. I thought if everything is on a single list
(including root group), then we could just select cgroups to writeback in
round robin manner. Now with root cgroup not being on that list, how
would you make sure that root group's inodes don't starve writeback. 

> 
> The routines under discussion:
> - memcg charging a new inode page to a memcg: will use inode->mapping and inode
>  to walk memcg -> memcg_bdi -> mappings and lazily allocating missing
>  levels in data structure.
> 
> - Uncharging a inode page from a memcg: will use pc->mapping->memcg to locate
>  memcg.  If refcnt drops to zero, then remove memcg_mapping from the
> memcg_bdi.[dirty_]mappings.
>  Also delete memcg_bdi if last memcg_mapping is removed.
> 
> - account_page_dirtied(): increment nr_dirty.  If first dirty page,
> then move memcg_mapping from memcg_bdi.mappings to
> memcg_bdi.dirty_mappings page counter.  When marking page clean, do
> the opposite.
> 
> - mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if above
>  background limit, then add memcg to global memcg_over_bg_limit list and use
>  memcg's set of memcg_bdi to wakeup each(?) corresponding bdi flusher.  If over
>  fg limit, then use IO-less style foreground throttling with per-memcg per-bdi
>  (aka memcg_bdi) accounting structure.

In other mail Jan mentioned that mem_cgroup_balance_dirty_pages() is per bdi
so we have to wake up only corresponding bdi flusher thread only.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
