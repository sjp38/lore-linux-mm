Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 521AF8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 05:13:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5F07A3EE0C0
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 18:13:08 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FAFA45DE60
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 18:13:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2511645DE58
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 18:13:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B1D31DB8046
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 18:13:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1C86E08003
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 18:13:07 +0900 (JST)
Date: Wed, 23 Mar 2011 18:06:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-Id: <20110323180628.09cd770e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
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
	<20110317124350.GQ2140@cmpxchg.org>
	<AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Fri, 18 Mar 2011 00:57:09 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Thu, Mar 17, 2011 at 5:43 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Mar 16, 2011 at 09:41:48PM -0700, Greg Thelen wrote:
> >> In '[PATCH v6 8/9] memcg: check memcg dirty limits in page writeback' Jan and
> >> Vivek have had some discussion around how memcg and writeback mesh.
> >> In my mind, the
> >> discussions in 8/9 are starting to blend with this thread.
> >>
> >> I have been thinking about Johannes' struct memcg_mapping. A I think the idea
> >> may address several of the issues being discussed, especially
> >> interaction between
> >> IO-less balance_dirty_pages() and memcg writeback.
> >>
> >> Here is my thinking. A Feedback is most welcome!
> >>
> >> The data structures:
> >> - struct memcg_mapping {
> >> A  A  A  A struct address_space *mapping;
> >> A  A  A  A struct mem_cgroup *memcg;
> >> A  A  A  A int refcnt;
> >> A  };
> >> - each memcg contains a (radix, hash_table, etc.) mapping from bdi to memcg_bdi.
> >> - each memcg_bdi contains a mapping from inode to memcg_mapping. A This may be a
> >> A  very large set representing many cached inodes.
> >> - each memcg_mapping represents all pages within an bdi,inode,memcg. A All
> >> A  corresponding cached inode pages point to the same memcg_mapping via
> >> A  pc->mapping. A I assume that all pages of inode belong to no more than one bdi.
> >> - manage a global list of memcg that are over their respective background dirty
> >> A  limit.
> >> - i_mapping continues to point to a traditional non-memcg mapping (no change
> >> A  here).
> >> - none of these memcg_* structures affect root cgroup or kernels with memcg
> >> A  configured out.
> >
> > So structures roughly like this:
> >
> > struct mem_cgroup {
> > A  A  A  A ...
> > A  A  A  A /* key is struct backing_dev_info * */
> > A  A  A  A struct rb_root memcg_bdis;
> > };
> >
> > struct memcg_bdi {
> > A  A  A  A /* key is struct address_space * */
> > A  A  A  A struct rb_root memcg_mappings;
> > A  A  A  A struct rb_node node;
> > };
> >
> > struct memcg_mapping {
> > A  A  A  A struct address_space *mapping;
> > A  A  A  A struct mem_cgroup *memcg;
> > A  A  A  A struct rb_node node;
> > A  A  A  A atomic_t count;
> > };
> >
> > struct page_cgroup {
> > A  A  A  A ...
> > A  A  A  A struct memcg_mapping *memcg_mapping;
> > };
> >
> >> The routines under discussion:
> >> - memcg charging a new inode page to a memcg: will use inode->mapping and inode
> >> A  to walk memcg -> memcg_bdi -> memcg_mapping and lazily allocating missing
> >> A  levels in data structure.
> >>
> >> - Uncharging a inode page from a memcg: will use pc->mapping->memcg to locate
> >> A  memcg. A If refcnt drops to zero, then remove memcg_mapping from the memcg_bdi.
> >> A  Also delete memcg_bdi if last memcg_mapping is removed.
> >>
> >> - account_page_dirtied(): nothing new here, continue to set the per-page flags
> >> A  and increment the memcg per-cpu dirty page counter. A Same goes for routines
> >> A  that mark pages in writeback and clean states.
> >
> > We may want to remember the dirty memcg_mappings so that on writeback
> > we don't have to go through every single one that the memcg refers to?
> 
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
> 
> - bdi writeback: will revert some of the mmotm memcg dirty limit changes to
>  fs-writeback.c so that wb_do_writeback() will return to checking
>  wb_check_background_flush() to check background limits and being
> interruptible if sync flush occurs.  wb_check_background_flush() will
> check the global
>  memcg_over_bg_limit list for memcg that are over their dirty limit.
> Within each memcg write inodes from the dirty_mappings list until a
> threshold page count has been reached (MAX_WRITEBACK_PAGES).  Then
> move to next listed memcg.
> 
> - over_bground_thresh() will determine if memcg is still over bg limit.
>  If over limit, then it per bdi per memcg background flushing will continue.
>  If not over limit then memcg will be removed from memcg_over_bg_limit list.
> 
> I'll post my resulting patches in RFC form, or (at the least) my conclusions.
> 
please take care of force_empty and move_mapping at el. when you do this
and please do rmdir() tests.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
