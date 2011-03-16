Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D8E158D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 17:19:55 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p2GLJlk6031983
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:19:48 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz5.hot.corp.google.com with ESMTP id p2GLIRHx016763
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:19:46 -0700
Received: by qyk2 with SMTP id 2so2000449qyk.16
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:19:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110316131324.GM2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com> <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com> <20110316131324.GM2140@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 16 Mar 2011 14:19:26 -0700
Message-ID: <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Wed, Mar 16, 2011 at 6:13 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Mar 15, 2011 at 02:48:39PM -0400, Vivek Goyal wrote:
>> On Mon, Mar 14, 2011 at 07:41:13PM -0700, Greg Thelen wrote:
>> > On Mon, Mar 14, 2011 at 1:23 PM, Vivek Goyal <vgoyal@redhat.com> wrote=
:
>> > > On Mon, Mar 14, 2011 at 11:29:17AM -0700, Greg Thelen wrote:
>> > >
>> > > [..]
>> > >> > We could just crawl the memcg's page LRU and bring things under c=
ontrol
>> > >> > that way, couldn't we? =A0That would fix it. =A0What were the rea=
sons for
>> > >> > not doing this?
>> > >>
>> > >> My rational for pursuing bdi writeback was I/O locality. =A0I have =
heard that
>> > >> per-page I/O has bad locality. =A0Per inode bdi-style writeback sho=
uld have better
>> > >> locality.
>> > >>
>> > >> My hunch is the best solution is a hybrid which uses a) bdi writeba=
ck with a
>> > >> target memcg filter and b) using the memcg lru as a fallback to ide=
ntify the bdi
>> > >> that needed writeback. =A0I think the part a) memcg filtering is li=
kely something
>> > >> like:
>> > >> =A0http://marc.info/?l=3Dlinux-kernel&m=3D129910424431837
>> > >>
>> > >> The part b) bdi selection should not be too hard assuming that page=
-to-mapping
>> > >> locking is doable.
>> > >
>> > > Greg,
>> > >
>> > > IIUC, option b) seems to be going through pages of particular memcg =
and
>> > > mapping page to inode and start writeback on particular inode?
>> >
>> > Yes.
>> >
>> > > If yes, this might be reasonably good. In the case when cgroups are =
not
>> > > sharing inodes then it automatically maps one inode to one cgroup an=
d
>> > > once cgroup is over limit, it starts writebacks of its own inode.
>> > >
>> > > In case inode is shared, then we get the case of one cgroup writting
>> > > back the pages of other cgroup. Well I guess that also can be handel=
ed
>> > > by flusher thread where a bunch or group of pages can be compared wi=
th
>> > > the cgroup passed in writeback structure. I guess that might hurt us
>> > > more than benefit us.
>> >
>> > Agreed. =A0For now just writing the entire inode is probably fine.
>> >
>> > > IIUC how option b) works then we don't even need option a) where an =
N level
>> > > deep cache is maintained?
>> >
>> > Originally I was thinking that bdi-wide writeback with memcg filter
>> > was a good idea. =A0But this may be unnecessarily complex. =A0Now I am
>> > agreeing with you that option (a) may not be needed. =A0Memcg could
>> > queue per-inode writeback using the memcg lru to locate inodes
>> > (lru->page->inode) with something like this in
>> > [mem_cgroup_]balance_dirty_pages():
>> >
>> > =A0 while (memcg_usage() >=3D memcg_fg_limit) {
>> > =A0 =A0 inode =3D memcg_dirty_inode(cg); =A0/* scan lru for a dirty pa=
ge, then
>> > grab mapping & inode */
>> > =A0 =A0 sync_inode(inode, &wbc);
>> > =A0 }
>> >
>> > =A0 if (memcg_usage() >=3D memcg_bg_limit) {
>> > =A0 =A0 queue per-memcg bg flush work item
>> > =A0 }
>>
>> I think even for background we shall have to implement some kind of logi=
c
>> where inodes are selected by traversing memcg->lru list so that for
>> background write we don't end up writting too many inodes from other
>> root group in an attempt to meet the low background ratio of memcg.
>>
>> So to me it boils down to coming up a new inode selection logic for
>> memcg which can be used both for background as well as foreground
>> writes. This will make sure we don't end up writting pages from the
>> inodes we don't want to.
>
> Originally for struct page_cgroup reduction, I had the idea of
> introducing something like
>
> =A0 =A0 =A0 =A0struct memcg_mapping {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct address_space *mapping;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0};
>
> hanging off page->mapping to make memcg association no longer per-page
> and save the pc->memcg linkage (it's not completely per-inode either,
> multiple memcgs can still refer to a single inode).
>
> We could put these descriptors on a per-memcg list and write inodes
> from this list during memcg-writeback.
>
> We would have the option of extending this structure to contain hints
> as to which subrange of the inode is actually owned by the cgroup, to
> further narrow writeback to the right pages - iff shared big files
> become a problem.
>
> Does that sound feasible?

If I understand your memcg_mapping proposal, then each inode could
have a collection of memcg_mapping objects representing the set of
memcg that were charged for caching pages of the inode's data.  When a
new file page is charged to a memcg, then the inode's set of
memcg_mapping would be scanned to determine if current's memcg is
already in the memcg_mapping set.  If this is the first page for the
memcg within the inode, then a new memcg_mapping would be allocated
and attached to the inode.  The memcg_mapping may be reference counted
and would be deleted when the last inode page for a particular memcg
is uncharged.

  page->mapping =3D &memcg_mapping
  inode->i_mapping =3D collection of memcg_mapping, grows/shrinks with [un]=
charge

Am I close?

I still have to think though the various use cases, but I wanted to
make sure I had the basic idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
