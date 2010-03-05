Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C17AF6B004D
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 17:15:01 -0500 (EST)
Date: Fri, 5 Mar 2010 23:14:56 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100305221456.GB1578@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
 <1267699215-4101-4-git-send-email-arighi@develer.com>
 <20100305101234.909001e8.nishimura@mxp.nes.nec.co.jp>
 <20100305105855.9b53176c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100305105855.9b53176c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 05, 2010 at 10:58:55AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 5 Mar 2010 10:12:34 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Thu,  4 Mar 2010 11:40:14 +0100, Andrea Righi <arighi@develer.com> wrote:
> > > Infrastructure to account dirty pages per cgroup and add dirty limit
> > >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> > >  {
> > >  	int *val = data;
> > > @@ -1275,34 +1423,70 @@ static void record_last_oom(struct mem_cgroup *mem)
> > >  }
> > >  
> > >  /*
> > > - * Currently used to update mapped file statistics, but the routine can be
> > > - * generalized to update other statistics as well.
> > > + * Generalized routine to update file cache's status for memcg.
> > > + *
> > > + * Before calling this, mapping->tree_lock should be held and preemption is
> > > + * disabled.  Then, it's guarnteed that the page is not uncharged while we
> > > + * access page_cgroup. We can make use of that.
> > >   */
> > IIUC, mapping->tree_lock is held with irq disabled, so I think "mapping->tree_lock
> > should be held with irq disabled" would be enouth.
> > And, as far as I can see, callers of this function have not ensured this yet in [4/4].
> > 
> > how about:
> > 
> > 	void mem_cgroup_update_stat_locked(...)
> > 	{
> > 		...
> > 	}
> > 
> > 	void mem_cgroup_update_stat_unlocked(mapping, ...)
> > 	{
> > 		spin_lock_irqsave(mapping->tree_lock, ...);
> > 		mem_cgroup_update_stat_locked();
> > 		spin_unlock_irqrestore(...);
> > 	}
> >
> Rather than tree_lock, lock_page_cgroup() can be used if tree_lock is not held.
> 
> 		lock_page_cgroup();
> 		mem_cgroup_update_stat_locked();
> 		unlock_page_cgroup();
> 
> Andrea-san, FILE_MAPPED is updated without treelock, at least. You can't depend
> on migration_lock about FILE_MAPPED.

Right. I'll consider this in the next version of the patch.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
