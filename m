Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0BD6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 17:23:11 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so911355pab.33
        for <linux-mm@kvack.org>; Thu, 29 May 2014 14:23:10 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ot7si2550811pbc.164.2014.05.29.14.23.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 14:23:10 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so913350pab.12
        for <linux-mm@kvack.org>; Thu, 29 May 2014 14:23:10 -0700 (PDT)
Message-ID: <1401398588.3645.60.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock
 contention
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 May 2014 14:23:08 -0700
In-Reply-To: <20140529130544.56213f048f331723329ff828@linux-foundation.org>
References: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <20140529130544.56213f048f331723329ff828@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>

On Thu, 2014-05-29 at 13:05 -0700, Andrew Morton wrote:
> On Thu, 29 May 2014 15:22:34 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > Richard Yao reported a month ago that his system have a trouble
> > with vmap_area_lock contention during performance analysis
> > by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> > stressfully, but he didn't answer it.
> > 
> > https://lkml.org/lkml/2014/4/10/416
> > 
> > Although I'm not sure that this is right usage or not, there is a solution
> > reducing vmap_area_lock contention with no side-effect. That is just
> > to use rcu list iterator in get_vmalloc_info(). This function only needs
> > values on vmap_area structure, so we don't need to grab a spinlock.
> 
> The mixture of rcu protection and spinlock protection for
> vmap_area_list is pretty confusing.  Are you able to describe the
> overall design here?  When and why do we use one versus the other?

The spinlock protects writers.

rcu can be used in this function because all RCU protocol is already
respected by writers, since Nick Piggin commit db64fe02258f1507e13fe5
("mm: rewrite vmap layer") back in linux-2.6.28

Specifically :
   insertions use list_add_rcu(), 
   deletions use list_del_rcu() and kfree_rcu().

Note the rb tree is not used from rcu reader (it would not be safe),
only the vmap_area_list has full RCU protection.

Note that __purge_vmap_area_lazy() already uses this rcu protection.

        rcu_read_lock();
        list_for_each_entry_rcu(va, &vmap_area_list, list) {
                if (va->flags & VM_LAZY_FREE) {
                        if (va->va_start < *start)
                                *start = va->va_start;
                        if (va->va_end > *end)
                                *end = va->va_end;
                        nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
                        list_add_tail(&va->purge_list, &valist);
                        va->flags |= VM_LAZY_FREEING;
                        va->flags &= ~VM_LAZY_FREE;
                }
        }
        rcu_read_unlock();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
