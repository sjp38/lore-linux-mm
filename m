Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBFB8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:13:44 -0400 (EDT)
Date: Wed, 16 Mar 2011 14:13:24 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110316131324.GM2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110315184839.GB5740@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Tue, Mar 15, 2011 at 02:48:39PM -0400, Vivek Goyal wrote:
> On Mon, Mar 14, 2011 at 07:41:13PM -0700, Greg Thelen wrote:
> > On Mon, Mar 14, 2011 at 1:23 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> > > On Mon, Mar 14, 2011 at 11:29:17AM -0700, Greg Thelen wrote:
> > >
> > > [..]
> > >> > We could just crawl the memcg's page LRU and bring things under control
> > >> > that way, couldn't we?  That would fix it.  What were the reasons for
> > >> > not doing this?
> > >>
> > >> My rational for pursuing bdi writeback was I/O locality.  I have heard that
> > >> per-page I/O has bad locality.  Per inode bdi-style writeback should have better
> > >> locality.
> > >>
> > >> My hunch is the best solution is a hybrid which uses a) bdi writeback with a
> > >> target memcg filter and b) using the memcg lru as a fallback to identify the bdi
> > >> that needed writeback.  I think the part a) memcg filtering is likely something
> > >> like:
> > >>  http://marc.info/?l=linux-kernel&m=129910424431837
> > >>
> > >> The part b) bdi selection should not be too hard assuming that page-to-mapping
> > >> locking is doable.
> > >
> > > Greg,
> > >
> > > IIUC, option b) seems to be going through pages of particular memcg and
> > > mapping page to inode and start writeback on particular inode?
> > 
> > Yes.
> > 
> > > If yes, this might be reasonably good. In the case when cgroups are not
> > > sharing inodes then it automatically maps one inode to one cgroup and
> > > once cgroup is over limit, it starts writebacks of its own inode.
> > >
> > > In case inode is shared, then we get the case of one cgroup writting
> > > back the pages of other cgroup. Well I guess that also can be handeled
> > > by flusher thread where a bunch or group of pages can be compared with
> > > the cgroup passed in writeback structure. I guess that might hurt us
> > > more than benefit us.
> > 
> > Agreed.  For now just writing the entire inode is probably fine.
> > 
> > > IIUC how option b) works then we don't even need option a) where an N level
> > > deep cache is maintained?
> > 
> > Originally I was thinking that bdi-wide writeback with memcg filter
> > was a good idea.  But this may be unnecessarily complex.  Now I am
> > agreeing with you that option (a) may not be needed.  Memcg could
> > queue per-inode writeback using the memcg lru to locate inodes
> > (lru->page->inode) with something like this in
> > [mem_cgroup_]balance_dirty_pages():
> > 
> >   while (memcg_usage() >= memcg_fg_limit) {
> >     inode = memcg_dirty_inode(cg);  /* scan lru for a dirty page, then
> > grab mapping & inode */
> >     sync_inode(inode, &wbc);
> >   }
> > 
> >   if (memcg_usage() >= memcg_bg_limit) {
> >     queue per-memcg bg flush work item
> >   }
> 
> I think even for background we shall have to implement some kind of logic
> where inodes are selected by traversing memcg->lru list so that for
> background write we don't end up writting too many inodes from other
> root group in an attempt to meet the low background ratio of memcg.
> 
> So to me it boils down to coming up a new inode selection logic for
> memcg which can be used both for background as well as foreground
> writes. This will make sure we don't end up writting pages from the
> inodes we don't want to.

Originally for struct page_cgroup reduction, I had the idea of
introducing something like

	struct memcg_mapping {
		struct address_space *mapping;
		struct mem_cgroup *memcg;
	};

hanging off page->mapping to make memcg association no longer per-page
and save the pc->memcg linkage (it's not completely per-inode either,
multiple memcgs can still refer to a single inode).

We could put these descriptors on a per-memcg list and write inodes
from this list during memcg-writeback.

We would have the option of extending this structure to contain hints
as to which subrange of the inode is actually owned by the cgroup, to
further narrow writeback to the right pages - iff shared big files
become a problem.

Does that sound feasible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
