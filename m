Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 99C9D6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:40:43 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so1085817pbc.16
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:40:43 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id go6si3140423pac.116.2014.05.29.17.40.41
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 17:40:42 -0700 (PDT)
Date: Fri, 30 May 2014 09:43:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock
 contention
Message-ID: <20140530004350.GA8906@js1304-P5Q-DELUXE>
References: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140529130544.56213f048f331723329ff828@linux-foundation.org>
 <1401398588.3645.60.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401398588.3645.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>

On Thu, May 29, 2014 at 02:23:08PM -0700, Eric Dumazet wrote:
> On Thu, 2014-05-29 at 13:05 -0700, Andrew Morton wrote:
> > On Thu, 29 May 2014 15:22:34 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > 
> > > Richard Yao reported a month ago that his system have a trouble
> > > with vmap_area_lock contention during performance analysis
> > > by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> > > stressfully, but he didn't answer it.
> > > 
> > > https://lkml.org/lkml/2014/4/10/416
> > > 
> > > Although I'm not sure that this is right usage or not, there is a solution
> > > reducing vmap_area_lock contention with no side-effect. That is just
> > > to use rcu list iterator in get_vmalloc_info(). This function only needs
> > > values on vmap_area structure, so we don't need to grab a spinlock.
> > 
> > The mixture of rcu protection and spinlock protection for
> > vmap_area_list is pretty confusing.  Are you able to describe the
> > overall design here?  When and why do we use one versus the other?
> 
> The spinlock protects writers.
> 
> rcu can be used in this function because all RCU protocol is already
> respected by writers, since Nick Piggin commit db64fe02258f1507e13fe5
> ("mm: rewrite vmap layer") back in linux-2.6.28
> 
> Specifically :
>    insertions use list_add_rcu(), 
>    deletions use list_del_rcu() and kfree_rcu().
> 
> Note the rb tree is not used from rcu reader (it would not be safe),
> only the vmap_area_list has full RCU protection.
> 
> Note that __purge_vmap_area_lazy() already uses this rcu protection.
> 
>         rcu_read_lock();
>         list_for_each_entry_rcu(va, &vmap_area_list, list) {
>                 if (va->flags & VM_LAZY_FREE) {
>                         if (va->va_start < *start)
>                                 *start = va->va_start;
>                         if (va->va_end > *end)
>                                 *end = va->va_end;
>                         nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
>                         list_add_tail(&va->purge_list, &valist);
>                         va->flags |= VM_LAZY_FREEING;
>                         va->flags &= ~VM_LAZY_FREE;
>                 }
>         }
>         rcu_read_unlock();
> 

Thanks Eric.
I will add more.

Although it is really complicated, I try to demonstrate overall design
how I understood.

There are five things we have to know, vm_struct structure, vmap_area
structure, rbtree rooted from vmap_area_root, vmap_area_list
and vmap_area_lock.

vmap_area is main structure representing virtual address range for this area.
vm_struct is the structure to keep information about mapped pages or phys_addr
for this vmap_area.
rbtree is used for finding target area or vacant area rapidly and is protected
by vmap_area_lock on all insert/remove/find operations.

vmap_area_list links the vmap_area in ascending order in virtaul address.
Manipulation of this list is protected by vmap_area_lock and RCU. When we
insert/remove vmap_area, we need to hold the vmap_area_lock so no concurrent
user can insert/remove different vmap_area. And when insert/remove, we use
list_add_rcu() and list_del_rcu(), so we can iterate the vmap_area_list safely
if we hold rcu_read_lock().

Another things vmap_area_lock is protecting are va->vm, that is, pointer to
vm_struct and VM_VM_AREA value on vmap_area's flag. We set/unset these values
with holding the vmap_area_lock to serialize access to this values. So when
we need to access these values, we should hold the lock.

In conclusion, get_vmalloc_info() needs to iterate vmap_area_list, but,
it doesn't access va->vm so we don't need to grab the vmap_area_lock.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
