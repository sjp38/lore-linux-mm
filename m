Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m4F6t9gM029366
	for <linux-mm@kvack.org>; Thu, 15 May 2008 07:55:09 +0100
Received: from an-out-0708.google.com (andd30.prod.google.com [10.100.30.30])
	by zps18.corp.google.com with ESMTP id m4F6t8tq002843
	for <linux-mm@kvack.org>; Wed, 14 May 2008 23:55:08 -0700
Received: by an-out-0708.google.com with SMTP id d30so162007and.77
        for <linux-mm@kvack.org>; Wed, 14 May 2008 23:55:08 -0700 (PDT)
Message-ID: <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com>
Date: Wed, 14 May 2008 23:55:07 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control (v4)
In-Reply-To: <20080515061727.GC31115@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
	 <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
	 <20080514132529.GA25653@balbir.in.ibm.com>
	 <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com>
	 <20080515061727.GC31115@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2008 at 11:17 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>  >
>  > Assuming that we're holding a write lock on mm->mmap_sem here, and we
>  > additionally hold mmap_sem for the whole of mm_update_next_owner(),
>  > then maybe we don't need any extra synchronization here? Something
>  > like simply:
>  >
>  > int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
>  > {
>  >        struct memrlimit_cgroup *memrcg = memrlimit_cgroup_from_task(mm->owner);
>  >        return res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
>  > }
>
>  The charge_as routine is not always called with mmap_sem held, since
>  the undo path gets more complicated under the lock. We already have
>  our own locking mechanism for the counters.

I'm not worried about the counters themselves being inconsistent - I'm
worried about the case where charge_as() is called in the middle of
the attach operation, and we account the charge X to the new cgroup's
res_counter and update mm->total_vm, and then when we do the move, we
charge the whole of mm->total_mm to the new cgroup even though the
last charge was already accounted to the new res_counter, not the old
one.

That's what I'm hoping to address with the idea of splitting the
attach into one update per subsystem, and letting the subsystems
control their own synchronization.

> We're not really accessing
>  any member of the mm here except the owner. Do we need to be called
>  with mmap_sem held?
>

Not necessarily mmap_sem, but there needs to be something to ensure
that the update to mm->total_vm and the charge/uncharge against the
res_counter are an atomic pair with respect to the code that shifts an
mm between two cgroups, either due to mm->owner change or due to an
attach_task(). Since mmap_sem is held for write on almost all the fast
path calls to the rlimit_as charge/uncharge functions, using that for
the synchronization avoids the need for any additional synchronization
in the fast path.

Can you say more about the complications of holding a write lock on
mmap_sem in the cleanup calls to uncharge?

>  >  retry:
>  >         mm = get_task_mm(p);
>  >         if (mm == NULL) {
>  >           task_lock(p);
>  >           rcu_assign_ptr(p->cgroups, new_css_set);
>
>  Will each callback assign p->cgroups to new_css_set?

Yes - but new_css_set will be slightly different for each callback.
Specifically, it will differ from the existing set pointed to by
p->cgroups in the pointer for this particular subsystem. So the task
will move over in a staggered fashion, and each subsystem will get to
choose its own synchronization.

>  >         task_lock(p);
>  >         if (p->mm != mm) {
>  >                 /* We raced */
>
>  With exit_mmap() or exec_mmap() right?
>

Yes.

>  If we agree with the assertion/conclusion above, then a simple lock
>  might be able to protect us, assuming that it does not create a
>  interwined locking hierarchy.
>

Right - and if we can make that lock be the mmap_sem of the mm in
question, we avoid introducing a new lock into the fast path.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
