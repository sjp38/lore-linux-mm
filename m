Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9A1996B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:33:08 -0500 (EST)
Date: Wed, 29 Feb 2012 08:27:43 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/9] memcg: add dirty page accounting infrastructure
Message-ID: <20120229002743.GA11583@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144746.971869014@intel.com>
 <20120228143738.b84d49ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228143738.b84d49ff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 28, 2012 at 02:37:38PM -0800, Andrew Morton wrote:
> On Tue, 28 Feb 2012 22:00:24 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > From: Greg Thelen <gthelen@google.com>
> > 
> > Add memcg routines to count dirty, writeback, and unstable_NFS pages.
> > These routines are not yet used by the kernel to count such pages.  A
> > later change adds kernel calls to these new routines.
> > 
> > As inode pages are marked dirty, if the dirtied page's cgroup differs
> > from the inode's cgroup, then mark the inode shared across several
> > cgroup.
> > 
> > ...
> >
> > @@ -1885,6 +1888,44 @@ void mem_cgroup_update_page_stat(struct 
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
> 
> Made me scratch my head for a while, but I see now that the `val' arg
> to (the undocumented) mem_cgroup_update_page_stat() can only ever have
> the values 1 or -1.  I hope.

Yeah, I see it's called this way:

   3    151  /c/linux/include/linux/memcontrol.h <<mem_cgroup_inc_page_stat>>
             mem_cgroup_update_page_stat(page, idx, 1);

   4    157  /c/linux/include/linux/memcontrol.h <<mem_cgroup_dec_page_stat>>
             mem_cgroup_update_page_stat(page, idx, -1);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
