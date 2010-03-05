Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1175E6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 17:35:24 -0500 (EST)
Date: Fri, 5 Mar 2010 23:35:20 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 2/4] page_cgroup: introduce file cache flags
Message-ID: <20100305223519.GC1578@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
 <1267699215-4101-3-git-send-email-arighi@develer.com>
 <20100305063249.GH3073@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100305063249.GH3073@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 05, 2010 at 12:02:49PM +0530, Balbir Singh wrote:
> * Andrea Righi <arighi@develer.com> [2010-03-04 11:40:13]:
> 
> > Introduce page_cgroup flags to keep track of file cache pages.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > ---
> 
> Looks good
> 
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>  
> 
> >  include/linux/page_cgroup.h |   49 +++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 49 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index 30b0813..1b79ded 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -39,6 +39,12 @@ enum {
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> >  	PCG_ACCT_LRU, /* page has been accounted for */
> > +	PCG_MIGRATE_LOCK, /* used for mutual execution of account migration */
> > +	PCG_ACCT_FILE_MAPPED, /* page is accounted as file rss*/
> > +	PCG_ACCT_DIRTY, /* page is dirty */
> > +	PCG_ACCT_WRITEBACK, /* page is being written back to disk */
> > +	PCG_ACCT_WRITEBACK_TEMP, /* page is used as temporary buffer for FUSE */
> > +	PCG_ACCT_UNSTABLE_NFS, /* NFS page not yet committed to the server */
> >  };
> > 
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -73,6 +79,27 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
> > 
> > +/* File cache and dirty memory flags */
> > +TESTPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +SETPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +CLEARPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +
> > +TESTPCGFLAG(Dirty, ACCT_DIRTY)
> > +SETPCGFLAG(Dirty, ACCT_DIRTY)
> > +CLEARPCGFLAG(Dirty, ACCT_DIRTY)
> > +
> > +TESTPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +SETPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +CLEARPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +
> > +TESTPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +SETPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +CLEARPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +
> > +TESTPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +SETPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +CLEARPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > @@ -83,6 +110,9 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
> >  	return page_zonenum(pc->page);
> >  }
> > 
> > +/*
> > + * lock_page_cgroup() should not be held under mapping->tree_lock
> > + */
> 
> May be a DEBUG WARN_ON would be appropriate here?

Sounds good. WARN_ON_ONCE()?

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
