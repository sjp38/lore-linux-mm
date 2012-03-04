Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 8A8286B00EC
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 00:06:06 -0500 (EST)
Date: Sun, 4 Mar 2012 09:29:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/9] memcg: add page_cgroup flags for dirty page tracking
Message-ID: <20120304012952.GA22066@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144746.900395448@intel.com>
 <20120229095051.739bb363.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120229095051.739bb363.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 29, 2012 at 09:50:51AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 28 Feb 2012 22:00:23 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > From: Greg Thelen <gthelen@google.com>
> > 
> > Add additional flags to page_cgroup to track dirty pages
> > within a mem_cgroup.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> 
> I'm sorry but I changed the design of page_cgroup's flags update
> and never want to add new flags (I'd like to remove page_cgroup->flags.)

No sorry - it makes good sense to reuse the native page flags :)

> Please see linux-next.
> 
> A good example is PCG_FILE_MAPPED, which I removed.
> 
> memcg: use new logic for page stat accounting
> memcg: remove PCG_FILE_MAPPED
> 
> You can make use of PageDirty() and PageWriteback() instead of new flags.. (I hope.)

The dirty page accounting is currently done in account_page_dirtied()
which is called from

__set_page_dirty <= __set_page_dirty_buffers
__set_page_dirty_nobuffers
ceph_set_page_dirty

inside &mapping->tree_lock. TestSetPageDirty() is also called inside
&mapping->private_lock. So we'll be including the two mapping locks
and possibly &ci->i_ceph_lock if doing

         move_lock_mem_cgroup(page) # may take &memcg->move_lock
         TestSetPageDirty(page)
         update page stats (without any checks)
         move_unlock_mem_cgroup(page)

It should be feasible if that lock dependency is fine.

The PG_writeback accounting is very similar to the PG_dirty accounting
and can be handled in the same way.

Thanks,
Fengguang

> > ---
> >  include/linux/page_cgroup.h |   23 +++++++++++++++++++++++
> >  1 file changed, 23 insertions(+)
> > 
> > --- linux.orig/include/linux/page_cgroup.h	2012-02-19 10:53:14.000000000 +0800
> > +++ linux/include/linux/page_cgroup.h	2012-02-19 10:53:16.000000000 +0800
> > @@ -10,6 +10,9 @@ enum {
> >  	/* flags for mem_cgroup and file and I/O status */
> >  	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
> >  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> > +	PCG_FILE_DIRTY, /* page is dirty */
> > +	PCG_FILE_WRITEBACK, /* page is under writeback */
> > +	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
> >  	__NR_PCG_FLAGS,
> >  };
> >  
> > @@ -64,6 +67,10 @@ static inline void ClearPageCgroup##unam
> >  static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
> >  	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
> >  
> > +#define TESTSETPCGFLAG(uname, lname)			\
> > +static inline int TestSetPageCgroup##uname(struct page_cgroup *pc)	\
> > +	{ return test_and_set_bit(PCG_##lname, &pc->flags); }
> > +
> >  /* Cache flag is set only once (at allocation) */
> >  TESTPCGFLAG(Cache, CACHE)
> >  CLEARPCGFLAG(Cache, CACHE)
> > @@ -77,6 +84,22 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
> >  CLEARPCGFLAG(FileMapped, FILE_MAPPED)
> >  TESTPCGFLAG(FileMapped, FILE_MAPPED)
> >  
> > +SETPCGFLAG(FileDirty, FILE_DIRTY)
> > +CLEARPCGFLAG(FileDirty, FILE_DIRTY)
> > +TESTPCGFLAG(FileDirty, FILE_DIRTY)
> > +TESTCLEARPCGFLAG(FileDirty, FILE_DIRTY)
> > +TESTSETPCGFLAG(FileDirty, FILE_DIRTY)
> > +
> > +SETPCGFLAG(FileWriteback, FILE_WRITEBACK)
> > +CLEARPCGFLAG(FileWriteback, FILE_WRITEBACK)
> > +TESTPCGFLAG(FileWriteback, FILE_WRITEBACK)
> > +
> > +SETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> > +CLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> > +TESTPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> > +TESTCLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> > +TESTSETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
> > +
> >  SETPCGFLAG(Migration, MIGRATION)
> >  CLEARPCGFLAG(Migration, MIGRATION)
> >  TESTPCGFLAG(Migration, MIGRATION)
> > 
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
