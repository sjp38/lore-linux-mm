Date: Thu, 3 Jul 2008 18:54:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [0/7] misc memcg patch set
Message-Id: <20080703185419.ea515e1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <486C96C8.5070104@linux.vnet.ibm.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	<486C96C8.5070104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 03 Jul 2008 14:37:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Balbir, I'd like to import your idea of soft-limit to memcg-background-job
> > patch set. (Maybe better than adding hooks to very generic part.)
> > How do you think ?
> > 
> 
> I am all for integration. My only requirement is that I want to reclaim from a
> node when there is system memory contention. The soft limit patches touch the
> generic infrastructure, just barely to indicate that we should look at
> reclaiming from controllers over their soft limit.
> 
One of my concern is that soft-limit path is added to alloc_pages()'s not to
kswapd()'s path. I wonder it's better to detect memory shortage by some 
calculation and do it by ourselves rather than adding hook to memory allocation
path.

For example.

 start soft limit reclaim when the amount of free pages of zone < XXXMbytes.
 
 But I'm not sure how this kind of voluntary memory freeing should be done.
 It seems soft-limit at memory contention implies to add some lru priority to
 pages. Maybe someone wants.


> > Other patches in plan (including other guy's)
> > - soft-limit (Balbir works.)
> >   I myself think memcg-background-job patches can copperative with this.
> > 
> 
> That'll be nice thing to do. I am planning on a new version of the soft limit
> patches soon (but due to data structure experimentation, it's taking me longer
> to get done).
> 
  My new version of background-job will be much smarter than 7/7.

> > - dirty_ratio for memcg. (haven't written at all)
> >   Support dirty_ratio for memcg. This will improve OOM avoidance.
> > 
> 
> OK, might be worth doing
> 
> > - swapiness for memcg (had patches..but have to rewrite.)
> >   Support swapiness per memcg. (of no use ?)
> > 
> 
> OK, Might be worth doing
> 
> > - swap_controller (Maybe Nishimura works on.)
> >   The world may change after this...cgroup without swap can appears easily.
> > 
> 
> I see a swap controller and swap namespace emerging, we'll need to see how they
> work. The swap controller is definitely important
> 
> > - hierarchy (needs more discussion. maybe after OLS?)
> >   have some pathes, but not in hurry.
> > 
> 
> Same here, not in a hurry, but I think it will help define full functionality
> 
> > - more performance improvements (we need some trick.)
> >   = Can we remove lock_page_cgroup() ?
> 
> We exchanged some early patches on this. We'll get back to it after the things
> above.
> 
> >   = Can we reduce spinlocks ?
> > 
> 
> Yes and most of our work happens under irqs disabled. We'll need to investigate
> a bit more.
> 
> > - move resource at task move (needs helps from cgroup)
> >   We need some magical way. It seems impossible to implement this only by memcg.
> > 
> 
> I have some ideas on this. May be we can discuss this in the OLS BoF or on
> email. This is low priority at the moment.
> 
I'm also not in hurry but
Why I argue this is because I consider following (special) situation.

  echo PID > /dev/memcg/group01/tasks
  
  "PID" PID allocates tons of memory and mlock it. (or make swap full.)

  admin moved it.
  echo PID > /dev/memcg/group02/tasks

  What happens ? If OOM occurs in group01, only not-guilty processes will be killed.


> > - NUMA statistics (needs helps from cgroup)
> >   It seems dynamic file creation feature or some rule to show array of
> >   statistics should be defined.
> > 
> > - memory guarantee (soft-mlock.)
> >   guard parameter against global LRU for saying "Don't reclaim from me more ;("
> >   Maybe HA Linux people will want this....
> > 
> 
> This is  hard goal to achieve, since we do have unreclaimable memory. Guarantees
> would probably imply reservation of resources. Water marks might be a better way
> to do it.
> 
Yes, I recognize this is a hard goal ;)

But this is one of function most of users wants.


> > Do you have others ?
> > 
> 
> I think that should be it (it covers most if not all the documented TODOs we have)
> 
> 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
