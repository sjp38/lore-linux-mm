Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3898D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 03:58:12 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2I7vY9N018545
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:57:34 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe17.cbf.corp.google.com with ESMTP id p2I7vUkL000661
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:57:33 -0700
Received: by qyk10 with SMTP id 10so3064299qyk.11
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:57:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110317124350.GQ2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com> <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com> <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
 <20110316215214.GO2140@cmpxchg.org> <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
 <20110317124350.GQ2140@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 18 Mar 2011 00:57:09 -0700
Message-ID: <AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Thu, Mar 17, 2011 at 5:43 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Mar 16, 2011 at 09:41:48PM -0700, Greg Thelen wrote:
>> In '[PATCH v6 8/9] memcg: check memcg dirty limits in page writeback' Ja=
n and
>> Vivek have had some discussion around how memcg and writeback mesh.
>> In my mind, the
>> discussions in 8/9 are starting to blend with this thread.
>>
>> I have been thinking about Johannes' struct memcg_mapping. =A0I think th=
e idea
>> may address several of the issues being discussed, especially
>> interaction between
>> IO-less balance_dirty_pages() and memcg writeback.
>>
>> Here is my thinking. =A0Feedback is most welcome!
>>
>> The data structures:
>> - struct memcg_mapping {
>> =A0 =A0 =A0 =A0struct address_space *mapping;
>> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
>> =A0 =A0 =A0 =A0int refcnt;
>> =A0 };
>> - each memcg contains a (radix, hash_table, etc.) mapping from bdi to me=
mcg_bdi.
>> - each memcg_bdi contains a mapping from inode to memcg_mapping. =A0This=
 may be a
>> =A0 very large set representing many cached inodes.
>> - each memcg_mapping represents all pages within an bdi,inode,memcg. =A0=
All
>> =A0 corresponding cached inode pages point to the same memcg_mapping via
>> =A0 pc->mapping. =A0I assume that all pages of inode belong to no more t=
han one bdi.
>> - manage a global list of memcg that are over their respective backgroun=
d dirty
>> =A0 limit.
>> - i_mapping continues to point to a traditional non-memcg mapping (no ch=
ange
>> =A0 here).
>> - none of these memcg_* structures affect root cgroup or kernels with me=
mcg
>> =A0 configured out.
>
> So structures roughly like this:
>
> struct mem_cgroup {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0/* key is struct backing_dev_info * */
> =A0 =A0 =A0 =A0struct rb_root memcg_bdis;
> };
>
> struct memcg_bdi {
> =A0 =A0 =A0 =A0/* key is struct address_space * */
> =A0 =A0 =A0 =A0struct rb_root memcg_mappings;
> =A0 =A0 =A0 =A0struct rb_node node;
> };
>
> struct memcg_mapping {
> =A0 =A0 =A0 =A0struct address_space *mapping;
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0struct rb_node node;
> =A0 =A0 =A0 =A0atomic_t count;
> };
>
> struct page_cgroup {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0struct memcg_mapping *memcg_mapping;
> };
>
>> The routines under discussion:
>> - memcg charging a new inode page to a memcg: will use inode->mapping an=
d inode
>> =A0 to walk memcg -> memcg_bdi -> memcg_mapping and lazily allocating mi=
ssing
>> =A0 levels in data structure.
>>
>> - Uncharging a inode page from a memcg: will use pc->mapping->memcg to l=
ocate
>> =A0 memcg. =A0If refcnt drops to zero, then remove memcg_mapping from th=
e memcg_bdi.
>> =A0 Also delete memcg_bdi if last memcg_mapping is removed.
>>
>> - account_page_dirtied(): nothing new here, continue to set the per-page=
 flags
>> =A0 and increment the memcg per-cpu dirty page counter. =A0Same goes for=
 routines
>> =A0 that mark pages in writeback and clean states.
>
> We may want to remember the dirty memcg_mappings so that on writeback
> we don't have to go through every single one that the memcg refers to?

I think this is a good idea to allow per memcg per bdi list of dirty mappin=
gs.

It feels like some of this is starting to gel.  I've been sketching
some of the code to see how the memcg locking will work out.  The
basic structures I see are:

struct mem_cgroup {
        ...
        /*
         * For all file pages cached by this memcg sort by bdi.
         * key is struct backing_dev_info *; value is struct memcg_bdi *
         * Protected by bdis_lock.
         */
        struct rb_root bdis;
        spinlock_t bdis_lock;  /* or use rcu structure, memcg:bdi set
could be fairly static */
};

struct memcg_bdi {
        struct backing_dev_info *bdi;
        /*
         * key is struct address_space *; value is struct
memcg_mapping *
         * memcg_mappings live within either mappings or
dirty_mappings set.
         */
        struct rb_root mappings;
        struct rb_root dirty_mappings;
        struct rb_node node;
        spinlock_t lock; /* protect [dirty_]mappings */
};

struct memcg_mapping {
        struct address_space *mapping;
        struct memcg_bdi *memcg_bdi;
        struct rb_node node;
        atomic_t nr_pages;
        atomic_t nr_dirty;
};

struct page_cgroup {
        ...
        struct memcg_mapping *memcg_mapping;
};

- each memcg contains a mapping from bdi to memcg_bdi.
- each memcg_bdi contains two mappings:
  mappings: from address_space to memcg_mapping for clean pages
  dirty_mappings: from address_space to memcg_mapping when there are
some dirty pages
- each memcg_mapping represents a set of cached pages within an
bdi,inode,memcg.  All
 corresponding cached inode pages point to the same memcg_mapping via
 pc->mapping.  I assume that all pages of inode belong to no more than one =
bdi.
- manage a global list of memcg that are over their respective background d=
irty
 limit.
- i_mapping continues to point to a traditional non-memcg mapping (no chang=
e
 here).
- none of these memcg_* structures affect root cgroup or kernels with memcg
 configured out.

The routines under discussion:
- memcg charging a new inode page to a memcg: will use inode->mapping and i=
node
 to walk memcg -> memcg_bdi -> mappings and lazily allocating missing
 levels in data structure.

- Uncharging a inode page from a memcg: will use pc->mapping->memcg to loca=
te
 memcg.  If refcnt drops to zero, then remove memcg_mapping from the
memcg_bdi.[dirty_]mappings.
 Also delete memcg_bdi if last memcg_mapping is removed.

- account_page_dirtied(): increment nr_dirty.  If first dirty page,
then move memcg_mapping from memcg_bdi.mappings to
memcg_bdi.dirty_mappings page counter.  When marking page clean, do
the opposite.

- mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if above
 background limit, then add memcg to global memcg_over_bg_limit list and us=
e
 memcg's set of memcg_bdi to wakeup each(?) corresponding bdi flusher.  If =
over
 fg limit, then use IO-less style foreground throttling with per-memcg per-=
bdi
 (aka memcg_bdi) accounting structure.

- bdi writeback: will revert some of the mmotm memcg dirty limit changes to
 fs-writeback.c so that wb_do_writeback() will return to checking
 wb_check_background_flush() to check background limits and being
interruptible if sync flush occurs.  wb_check_background_flush() will
check the global
 memcg_over_bg_limit list for memcg that are over their dirty limit.
Within each memcg write inodes from the dirty_mappings list until a
threshold page count has been reached (MAX_WRITEBACK_PAGES).  Then
move to next listed memcg.

- over_bground_thresh() will determine if memcg is still over bg limit.
 If over limit, then it per bdi per memcg background flushing will continue=
.
 If not over limit then memcg will be removed from memcg_over_bg_limit list=
.

I'll post my resulting patches in RFC form, or (at the least) my conclusion=
s.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
