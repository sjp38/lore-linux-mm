Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55E128D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 00:42:18 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2H4gGv1001295
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 21:42:16 -0700
Received: from qwg5 (qwg5.prod.google.com [10.241.194.133])
	by kpbe20.cbf.corp.google.com with ESMTP id p2H4g9c9020443
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 21:42:15 -0700
Received: by qwg5 with SMTP id 5so1701710qwg.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 21:42:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110316215214.GO2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com> <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com> <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com> <20110316215214.GO2140@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 16 Mar 2011 21:41:48 -0700
Message-ID: <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Wed, Mar 16, 2011 at 2:52 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Mar 16, 2011 at 02:19:26PM -0700, Greg Thelen wrote:
>> On Wed, Mar 16, 2011 at 6:13 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Tue, Mar 15, 2011 at 02:48:39PM -0400, Vivek Goyal wrote:
>> >> I think even for background we shall have to implement some kind of l=
ogic
>> >> where inodes are selected by traversing memcg->lru list so that for
>> >> background write we don't end up writting too many inodes from other
>> >> root group in an attempt to meet the low background ratio of memcg.
>> >>
>> >> So to me it boils down to coming up a new inode selection logic for
>> >> memcg which can be used both for background as well as foreground
>> >> writes. This will make sure we don't end up writting pages from the
>> >> inodes we don't want to.
>> >
>> > Originally for struct page_cgroup reduction, I had the idea of
>> > introducing something like
>> >
>> > =A0 =A0 =A0 =A0struct memcg_mapping {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct address_space *mapping;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
>> > =A0 =A0 =A0 =A0};
>> >
>> > hanging off page->mapping to make memcg association no longer per-page
>> > and save the pc->memcg linkage (it's not completely per-inode either,
>> > multiple memcgs can still refer to a single inode).
>> >
>> > We could put these descriptors on a per-memcg list and write inodes
>> > from this list during memcg-writeback.
>> >
>> > We would have the option of extending this structure to contain hints
>> > as to which subrange of the inode is actually owned by the cgroup, to
>> > further narrow writeback to the right pages - iff shared big files
>> > become a problem.
>> >
>> > Does that sound feasible?
>>
>> If I understand your memcg_mapping proposal, then each inode could
>> have a collection of memcg_mapping objects representing the set of
>> memcg that were charged for caching pages of the inode's data. =A0When a
>> new file page is charged to a memcg, then the inode's set of
>> memcg_mapping would be scanned to determine if current's memcg is
>> already in the memcg_mapping set. =A0If this is the first page for the
>> memcg within the inode, then a new memcg_mapping would be allocated
>> and attached to the inode. =A0The memcg_mapping may be reference counted
>> and would be deleted when the last inode page for a particular memcg
>> is uncharged.
>
> Dead-on. =A0Well, on which side you put the list - a per-memcg list of
> inodes, or a per-inode list of memcgs - really depends on which way
> you want to do the lookups. =A0But this is the idea, yes.
>
>> =A0 page->mapping =3D &memcg_mapping
>> =A0 inode->i_mapping =3D collection of memcg_mapping, grows/shrinks with=
 [un]charge
>
> If the memcg_mapping list (or hash-table for quick find-or-create?)
> was to be on the inode side, I'd put it in struct address_space, since
> this is all about page cache, not so much an fs thing.
>
> Still, correct in general.
>

In '[PATCH v6 8/9] memcg: check memcg dirty limits in page writeback' Jan a=
nd
Vivek have had some discussion around how memcg and writeback mesh.
In my mind, the
discussions in 8/9 are starting to blend with this thread.

I have been thinking about Johannes' struct memcg_mapping.  I think the ide=
a
may address several of the issues being discussed, especially
interaction between
IO-less balance_dirty_pages() and memcg writeback.

Here is my thinking.  Feedback is most welcome!

The data structures:
- struct memcg_mapping {
       struct address_space *mapping;
       struct mem_cgroup *memcg;
       int refcnt;
  };
- each memcg contains a (radix, hash_table, etc.) mapping from bdi to memcg=
_bdi.
- each memcg_bdi contains a mapping from inode to memcg_mapping.  This may =
be a
  very large set representing many cached inodes.
- each memcg_mapping represents all pages within an bdi,inode,memcg.  All
  corresponding cached inode pages point to the same memcg_mapping via
  pc->mapping.  I assume that all pages of inode belong to no more than one=
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
  to walk memcg -> memcg_bdi -> memcg_mapping and lazily allocating missing
  levels in data structure.

- Uncharging a inode page from a memcg: will use pc->mapping->memcg to loca=
te
  memcg.  If refcnt drops to zero, then remove memcg_mapping from the memcg=
_bdi.
  Also delete memcg_bdi if last memcg_mapping is removed.

- account_page_dirtied(): nothing new here, continue to set the per-page fl=
ags
  and increment the memcg per-cpu dirty page counter.  Same goes for routin=
es
  that mark pages in writeback and clean states.

- mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if above
  background limit, then add memcg to global memcg_over_bg_limit list and u=
se
  memcg's set of memcg_bdi to wakeup each(?) corresponding bdi flusher.  If=
 over
  fg limit, then use IO-less style foreground throttling with per-memcg per=
-bdi
  (aka memcg_bdi) accounting structure.

- bdi writeback: will revert some of the mmotm memcg dirty limit changes to
  fs-writeback.c so that wb_do_writeback() will return to checking
  wb_check_background_flush() to check background limits and being
interruptible if
  sync flush occurs.  wb_check_background_flush() will check the global
  memcg_over_bg_limit list for memcg that are over their dirty limit.
  wb_writeback() will either (I am not sure):
  a) scan memcg's bdi_memcg list of inodes (only some of them are dirty)
  b) scan bdi dirty inode list (only some of them in memcg) using
     inode_in_memcg() to identify inodes to write.  inode_in_memcg(inode,me=
mcg),
     would walk memcg- -> memcg_bdi -> memcg_mapping to determine if the me=
mcg
     is caching pages from the inode.

- over_bground_thresh() will determine if memcg is still over bg limit.
  If over limit, then it per bdi per memcg background flushing will continu=
e.
  If not over limit then memcg will be removed from memcg_over_bg_limit lis=
t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
