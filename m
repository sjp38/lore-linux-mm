Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2048D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:40:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E0B133EE0C3
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:40:40 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C559445DD02
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:40:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EE7145DE56
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:40:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AD74E38002
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:40:40 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 496C9E08001
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:40:40 +0900 (JST)
Date: Mon, 28 Feb 2011 11:34:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 5/9] memcg: add dirty page accounting infrastructure
Message-Id: <20110228113417.b924dfec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110227164730.GD3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
	<1298669760-26344-6-git-send-email-gthelen@google.com>
	<20110227164730.GD3226@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, 28 Feb 2011 01:47:30 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Feb 25, 2011 at 01:35:56PM -0800, Greg Thelen wrote:
> > Add memcg routines to track dirty, writeback, and unstable_NFS pages.
> > These routines are not yet used by the kernel to count such pages.
> > A later change adds kernel calls to these new routines.
> > 
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> > Changelog since v1:
> > - Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
> >   memory.stat to match /proc/meminfo.
> > - Rename (for clarity):
> >   - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
> >   - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
> > - Remove redundant comments.
> > - Made mem_cgroup_move_account_page_stat() inline.
> > 
> >  include/linux/memcontrol.h |    5 ++-
> >  mm/memcontrol.c            |   87 ++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 83 insertions(+), 9 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 3da48ae..e1f70a9 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -25,9 +25,12 @@ struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> >  
> > -/* Stats that can be updated by kernel. */
> > +/* mem_cgroup page counts accessed by kernel. */
> 
> I confused by 'kernel', 'access'?
> So, What's the page counts accessed by user?
> I don't like such words.
> 
> Please, clarify the comment.
> 'Stats of page that can be tracking by memcg' or whatever.
> 
Ah, yes. that's better.




> >  enum mem_cgroup_page_stat_item {
> >  	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> > +	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
> > +	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
> > +	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
> >  };
> >  
> >  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1c2704a..38f786b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -92,8 +92,11 @@ enum mem_cgroup_stat_index {
> >  	 */
> >  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> >  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > +	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
> > +	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
> > +	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
> >  	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> >  	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
> >  	MEM_CGROUP_STAT_NSTATS,
> > @@ -1622,6 +1625,44 @@ void mem_cgroup_update_page_stat(struct page *page,
> >  			ClearPageCgroupFileMapped(pc);
> >  		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> >  		break;
> > +
> > +	case MEMCG_NR_FILE_DIRTY:
> > +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> > +		if (val > 0) {
> > +			if (TestSetPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		} else {
> > +			if (!TestClearPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		}
> > +		idx = MEM_CGROUP_STAT_FILE_DIRTY;
> > +		break;
> > +
> > +	case MEMCG_NR_FILE_WRITEBACK:
> > +		/*
> > +		 * This counter is adjusted while holding the mapping's
> > +		 * tree_lock.  Therefore there is no race between settings and
> > +		 * clearing of this flag.
> > +		 */
> > +		if (val > 0)
> > +			SetPageCgroupFileWriteback(pc);
> > +		else
> > +			ClearPageCgroupFileWriteback(pc);
> > +		idx = MEM_CGROUP_STAT_FILE_WRITEBACK;
> > +		break;
> > +
> > +	case MEMCG_NR_FILE_UNSTABLE_NFS:
> > +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> > +		if (val > 0) {
> > +			if (TestSetPageCgroupFileUnstableNFS(pc))
> > +				val = 0;
> > +		} else {
> > +			if (!TestClearPageCgroupFileUnstableNFS(pc))
> > +				val = 0;
> > +		}
> > +		idx = MEM_CGROUP_STAT_FILE_UNSTABLE_NFS;
> > +		break;
> 
> This part can be simplified by some macro work.
> But it's another issue.
> 
Agreed, doing in another patch is better.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
