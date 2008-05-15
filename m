Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4F745j1008119
	for <linux-mm@kvack.org>; Thu, 15 May 2008 12:34:05 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4F73tG21454250
	for <linux-mm@kvack.org>; Thu, 15 May 2008 12:33:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4F744ob020982
	for <linux-mm@kvack.org>; Thu, 15 May 2008 12:34:05 +0530
Date: Thu, 15 May 2008 12:33:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
	control (v4)
Message-ID: <20080515070342.GJ31115@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080514132529.GA25653@balbir.in.ibm.com> <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com> <20080515061727.GC31115@balbir.in.ibm.com> <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Paul Menage <menage@google.com> [2008-05-14 23:55:07]:

> On Wed, May 14, 2008 at 11:17 PM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
> >  >
> >  > Assuming that we're holding a write lock on mm->mmap_sem here, and we
> >  > additionally hold mmap_sem for the whole of mm_update_next_owner(),
> >  > then maybe we don't need any extra synchronization here? Something
> >  > like simply:
> >  >
> >  > int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
> >  > {
> >  >        struct memrlimit_cgroup *memrcg = memrlimit_cgroup_from_task(mm->owner);
> >  >        return res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
> >  > }
> >
> >  The charge_as routine is not always called with mmap_sem held, since
> >  the undo path gets more complicated under the lock. We already have
> >  our own locking mechanism for the counters.
> 
> I'm not worried about the counters themselves being inconsistent - I'm
> worried about the case where charge_as() is called in the middle of
> the attach operation, and we account the charge X to the new cgroup's
> res_counter and update mm->total_vm, and then when we do the move, we
> charge the whole of mm->total_mm to the new cgroup even though the
> last charge was already accounted to the new res_counter, not the old
> one.
> 
> That's what I'm hoping to address with the idea of splitting the
> attach into one update per subsystem, and letting the subsystems
> control their own synchronization.
> 
> > We're not really accessing
> >  any member of the mm here except the owner. Do we need to be called
> >  with mmap_sem held?
> >
> 
> Not necessarily mmap_sem, but there needs to be something to ensure
> that the update to mm->total_vm and the charge/uncharge against the
> res_counter are an atomic pair with respect to the code that shifts an
> mm between two cgroups, either due to mm->owner change or due to an
> attach_task(). Since mmap_sem is held for write on almost all the fast
> path calls to the rlimit_as charge/uncharge functions, using that for
> the synchronization avoids the need for any additional synchronization
> in the fast path.
> 
> Can you say more about the complications of holding a write lock on
> mmap_sem in the cleanup calls to uncharge?
> 
> >  >  retry:
> >  >         mm = get_task_mm(p);
> >  >         if (mm == NULL) {
> >  >           task_lock(p);
> >  >           rcu_assign_ptr(p->cgroups, new_css_set);
> >
> >  Will each callback assign p->cgroups to new_css_set?
> 
> Yes - but new_css_set will be slightly different for each callback.
> Specifically, it will differ from the existing set pointed to by
> p->cgroups in the pointer for this particular subsystem. So the task
> will move over in a staggered fashion, and each subsystem will get to
> choose its own synchronization.
> 
> >  >         task_lock(p);
> >  >         if (p->mm != mm) {
> >  >                 /* We raced */
> >
> >  With exit_mmap() or exec_mmap() right?
> >
> 
> Yes.
> 
> >  If we agree with the assertion/conclusion above, then a simple lock
> >  might be able to protect us, assuming that it does not create a
> >  interwined locking hierarchy.
> >
> 
> Right - and if we can make that lock be the mmap_sem of the mm in
> question, we avoid introducing a new lock into the fast path.
>

I want to focus on this conclusion/assertion, since it takes care of
most of the locking related discussion above, unless I missed
something.

My concern with using mmap_sem, is that

1. It's highly contended (every page fault, vma change, etc)
2. It's going to make the locking hierarchy deeper and complex
3. It's not appropriate to call all the accounting callbacks with
   the mmap_sem() held, since the undo operations _can get_ complicated
   at the caller.

I would prefer introducing a new lock, so that other subsystems are
not affected. 

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
