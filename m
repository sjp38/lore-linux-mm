Date: Mon, 17 Mar 2008 11:25:48 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] Move memory controller allocations to their own slabs (v3)
Message-ID: <20080317112548.GA3835@shadowen.org>
References: <20080313140307.20133.30405.sendpatchset@localhost.localdomain> <20080314115645.e78b7f5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080314115645.e78b7f5c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 14, 2008 at 11:56:45AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 13 Mar 2008 19:33:07 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > 
> > Changelog v3
> > 
> > 1. Remove HWCACHE_ALIGN
> > 
> > Changelog v2
> > 
> > 1. Remove extra slab for mem_cgroup_per_zone
> > 
> > Move the memory controller data structure page_cgroup to its own slab cache.
> > It saves space on the system, allocations are not necessarily pushed to order
> > of 2 and should provide performance benefits. Users who disable the memory
> > controller can also double check that the memory controller is not allocating
> > page_cgroup's.
> > 
> > NOTE: Hugh Dickins brought up the issue of whether we want to mark page_cgroup
> > as __GFP_MOVABLE or __GFP_RECLAIMABLE. I don't think there is an easy
> > answer at the moment. page_cgroup's are associated with user pages,
> > they can be reclaimed once the user page has been reclaimed, so it might
> > make sense to mark them as __GFP_RECLAIMABLE. For now, I am leaving the
> > marking to default values that the slab allocator uses.
> > 
> > Comments?
> > 
> At first, in my understanding,
> - MOVABLE is for migratable pages. (so, not for kernel objects.)
> - RECLAIMABLE is for reclaimable kernel objects. (for slab etc..)

Yes, MOVABLE is for things which are very easily moved out, whether that
is migrated to another page, or paged out to swap, or trivially freed as
it can be re-read from somewhere such as text from a binary; generally
this is things on the LRU.

RECLAIMABLE, is things which are harder to get rid of, but for which
there is some hope of evicting their contents; as you say things like
those slab caches with shrinkers.

> All reclaimable objects are not necessary to be always reclaimable but
> some amount of RECLAIMABLE objects (not all) should be recraimable easily.
> For example, some of dentry-cache, inode-cache is reclaimable because *unused*
> objects are cached.
> 
> When it comes to page_cgroup, *all* objects has dependency to pages which are
> assigned to.  And user pages are reclaimable.
> There is a similar object....the radix tree. radix-tree's node is allocated as
> RECLAIMABLE object.
> 
> So I think it makes sense to changing page_cgroup to be reclaimable.

That sounds correct to me.

> But final decision should be done by how fragmentation avoidance works.
> It's good to test "how many hugepages can be allocated dynamically" when we
> make page_cgroup to be GFP_RECAIMABLE 

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
