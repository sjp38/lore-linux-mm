Date: Mon, 18 Aug 2008 16:58:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Message-Id: <20080818165856.0faeb0bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080813071505.930965A75@siro.lan>
References: <1218116168.8625.38.camel@twins>
	<20080813071505.930965A75@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Aug 2008 16:15:05 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> hi,
> 
> > > @@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> > >  		if (PageUnevictable(page) ||
> > >  		    (PageActive(page) && !active) ||
> > >  		    (!PageActive(page) && active)) {
> > > -			__mem_cgroup_move_lists(pc, page_lru(page));
> > > +			if (try_lock_page_cgroup(page)) {
> > > +				__mem_cgroup_move_lists(pc, page_lru(page));
> > > +				unlock_page_cgroup(page);
> > > +			}
> > >  			continue;
> > >  		}
> > 
> > This chunk seems unrelated and lost....
> 
> it's necessary to protect from mem_cgroup_{set,clear}_dirty
> which modify pc->flags without holding mz->lru_lock.
> 

I'm now writing a patch to make page_cgroup->flags to be atomic_ops.
Don't worry about this.
(With remove-page-lock-cgroup patch, atomic_ops patch's performace is
 quite well.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
