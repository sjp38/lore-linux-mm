Date: Mon, 29 Sep 2008 12:27:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080929122751.611451fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48E0452F.4080300@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<48DC9AF2.1050101@linux.vnet.ibm.com>
	<20080926182253.a62cc2d0.kamezawa.hiroyu@jp.fujitsu.com>
	<48DCAC02.5050108@linux.vnet.ibm.com>
	<20080926193602.6b397910.kamezawa.hiroyu@jp.fujitsu.com>
	<20080927121917.9058a41e.kamezawa.hiroyu@jp.fujitsu.com>
	<48E0452F.4080300@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp, YAMAMOTO Takashi <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 08:32:07 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Fri, 26 Sep 2008 19:36:02 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> >>> I think (1) might be OK, except for the accounting issues pointed out (change in
> >>> behaviour visible to end user again, sigh! :( ).
> >> But it was just a BUG from my point of view...
> >>
> >>> Is (1) a serious issue? 
> >> considering force_empty(), it's serious.
> >>
> >>> (2) seems OK, except for the locking change for mark_page_accessed. I am looking at
> >>> (4) and (6) currently.
> >>>
> > 
> > I'll do in following way in the next Monday.
> > Divide patches into 2 set
> > 
> > in early fix/optimize set.
> >   - push (2)
> >   - push (4)
> >   - push (6)
> >   - push (1)
> > 
> 
> Yes, sounds reasonable
> 
I'll just post this, today. 

> > drops (3).
> > 
> > I don't want to remove all? pages-never-on-LRU before fixing force_empty.
> > 
> > in updates
> >   - introduce atomic flags. (5)
> >   - add move_account() function (7)
> 
> without (3), don't we have a problem pushing (7)?
> 
I'll add -EBUSY behavior to force_empty.
I'm now adding(merging) code to move_account.patch for supporing force_empty.
It seems much clearer than v5.


> >   - add memory.attribute to each memcg dir. (NEW)
> >   - enhance force_empty (was (8))
> >        - remove "forget all" logic. and add attribute to select following 2 behavior
> >           - call try_to_free_page() until the usage goes down to 0.
> >             This allows faiulre (if page is mlocked, we can't do.). (NEW)
> >           - call move_account() to move all charges to its parent (as much as possible) (NEW)
> >           In future, I'd liket to add trash-box cgroup for force_empty somewhere.
> >   - allocate all page cgroup at boot (9)
> >   - lazy lru free/add (10,11) with fixes.
> >   - fix race at charging swap. (12)
> > 
> 
> I think (9) is probably the most important. I'll review it today
> 
Thanks. no major changes in my current stack from already posted one.

Thanks,
-Kame

> > After (9), all page and page_cgroup has one-to-one releationship and we want to
> > assume that "if page is alive and on LRU, it's accounted and has page_cgroup."
> > (other team, bio cgroup want to use page_cgroup and I want to make it easy.)
> > 
> > For this, fix to behavior of force_empty..."forget all" is necessary.
> > SwapCache handling is also necessary but I'd like to postpone until next set
> > because it's complicated.
> > 
> > After above all.
> >  - handle swap cache 
> >  - Mem+Swap controller.
> >  - add trashbox feature ?
> >  - add memory.shrink_usage_to file.
> > 
> > It's long way to what I really want to do....
> > 
> 
> Yes a long way to go, I want to add
> 
> 1) Multi-hierarchy support
> 2) Support for soft-limits
> 3) get swappiness working (there are patches posted for it by Yamamoto-San, but
> something is broken, I suspect even in global swappiness).
> 
> 
> 
> > 
> > Thanks,
> > -Kame
> 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
