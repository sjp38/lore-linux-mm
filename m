Date: Wed, 20 Feb 2008 18:58:21 +0900 (JST)
Message-Id: <20080220.185821.61784723.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <47BBC15E.5070405@linux.vnet.ibm.com>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<47BBC15E.5070405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> >> I'd like to start from RFC.
> >>
> >> In following code
> >> ==
> >>   lock_page_cgroup(page);
> >>   pc = page_get_page_cgroup(page);
> >>   unlock_page_cgroup(page);
> >>
> >>   access 'pc' later..
> >> == (See, page_cgroup_move_lists())
> >>
> >> There is a race because 'pc' is not a stable value without lock_page_cgroup().
> >> (mem_cgroup_uncharge can free this 'pc').
> >>
> >> For example, page_cgroup_move_lists() access pc without lock.
> >> There is a small race window, between page_cgroup_move_lists()
> >> and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
> >> freed but move_list can access it after taking lru_lock.
> >> (*) mem_cgroup_uncharge_page() can be called without zone->lru lock.
> >>
> >> This is not good manner.
> >> .....
> >> There is no quick fix (maybe). Moreover, I hear some people around me said
> >> current memcontrol.c codes are very complicated.
> >> I agree ;( ..it's caued by my work.
> >>
> >> I'd like to fix problems in clean way.
> >> (Note: current -rc2 codes works well under heavy pressure. but there
> >>  is possibility of race, I think.)
> > 
> > Yes, yes, indeed, I've been working away on this too.
> > 
> > Ever since the VM_BUG_ON(page_get_page_cgroup(page)) went into
> > free_hot_cold_page (at my own prompting), I've been hitting it
> > just very occasionally in my kernel build testing.  Was unable
> > to reproduce it over the New Year, but a week or two ago found
> > one machine and config on which it is relatively reproducible,
> > pretty sure to happen within 12 hours.
> > 
> > And on Saturday evening at last identified the cause, exactly
> > where you have: that unsafety in mem_cgroup_move_lists - which
> > has the nice property of putting pages from the lru on to SLUB's
> > freelist!
> > 
> > Unlike the unsafeties of force_empty, this is liable to hit anyone
> > running with MEM_CONT compiled in, they don't have to be consciously
> > using mem_cgroups at all.
> > 
> > (I consider that, by the way, quite a serious defect in the current
> > mem_cgroup work: that a distro compiling it in for 1% of customers
> > is then subjecting all to the mem_cgroup overhead - effectively
> > doubled struct page size and unnecessary accounting overhead.  I
> > believe there needs to be a way to opt out, a force_empty which
> > sticks.  Yes, I know the page_cgroup which does that doubling of
> > size is only allocated on demand, but every page cache page and
> > every anonymous page is going to have one.  A kmem_cache for them
> > will reduce the extra, but there still needs to be a way to opt
> > out completely.)
> > 
> 
> I've been thinking along these lines as well
> 
> 1. Have a boot option to turn on/off the memory controller

It will be much convenient if the memory controller can be turned on/off on
demand. I think you can turn it off if there aren't any mem_cgroups except
the root mem_cgroup, 

> 2. Have a separate cache for the page_cgroup structure. I sent this suggestion
>    out just yesterday or so.

I think the policy that every mem_cgroup should be dynamically allocated and
assigned to the proper page every time is causing some overheads and spinlock
contentions.

What do you think if you allocate all page_cgroups and assign to all the pages
when the memory controller gets turned on, which will allow you to remove
most of the spinlocks.

And you may possibly have a chance to remove page->page_cgroup member
if you allocate array of page_cgroups and attach them to the zone which
the pages belong to.

               zone
    page[]    +----+    page_cgroup[]
    +----+<----    ---->+----+
    |    |    |    |    |    |
    +----+    |    |    +----+
    |    |    +----+    |    |
    +----+              +----+
    |    |              |    |
    +----+              +----+
    |    |              |    |
    +----+              +----+
    |    |              |    |
    +----+              +----+


> I agree that these are necessary enhancements/changes.

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
