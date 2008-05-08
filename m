Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m48NMSqW009589
	for <linux-mm@kvack.org>; Fri, 9 May 2008 00:22:29 +0100
Received: from an-out-0708.google.com (anac10.prod.google.com [10.100.54.10])
	by zps38.corp.google.com with ESMTP id m48NM5KB022856
	for <linux-mm@kvack.org>; Thu, 8 May 2008 16:22:27 -0700
Received: by an-out-0708.google.com with SMTP id c10so275402ana.50
        for <linux-mm@kvack.org>; Thu, 08 May 2008 16:22:27 -0700 (PDT)
Message-ID: <6599ad830805081622l1d0c3716yd0a70fc246a9cf51@mail.gmail.com>
Date: Thu, 8 May 2008 16:22:27 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
In-Reply-To: <48231438.9030803@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	 <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
	 <6599ad830805062017n67d67f19w1469050d45e46ad6@mail.gmail.com>
	 <48231438.9030803@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 8, 2008 at 7:54 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Paul Menage wrote:
>  > On Sat, May 3, 2008 at 2:38 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  >>  +
>  >>  +int rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
>  >>  +{
>  >>  +       int ret;
>  >>  +       struct rlimit_cgroup *rcg;
>  >>  +
>  >>  +       rcu_read_lock();
>  >>  +       rcg = rlimit_cgroup_from_task(rcu_dereference(mm->owner));
>  >>  +       css_get(&rcg->css);
>  >>  +       rcu_read_unlock();
>  >>  +
>  >>  +       ret = res_counter_charge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
>  >>  +       css_put(&rcg->css);
>  >>  +       return ret;
>  >>  +}
>  >
>  > You need to synchronize against mm->owner changing, or
>  > mm->owner->cgroups changing. How about:
>  >
>
>  My mind goes blank at times, so forgive me asking, what happens if we don't use
>  task_lock(). mm->owner cannot be freed, even if it changes, we get the callback
>  in mm_owner_changed(). The locations from where we call _charge and _uncharge,
>  we know that the mm is not going to change either.

I guess I'm concerned about a race like:

A and B are threads in cgroup G, and C is a different process
A->mm->owner == B

A: enter rlimit_cgroup_charge_as()
A: charge new page to G
C: enter attach_task(newG, B)
C: update B->cgroup to point to newG
C: call memrlimit->attach(G, newG, B)
C: charge mm->total_vm to newG
C: uncharge mm->total_vm from G
A: add new page to mm->total_vm

Maybe this can be solved very simply by just taking mm->mmap_sem in
rlimit_cgroup_move_task() and rlimit_cgroup_mm_owner_changed() ? Since
mmap_sem is (I hope) held across all operations that change
mm->total_vm

>
>>  Consider the following scenario
>
>  We try to move task "t1" from cgroup "A" to cgroup "B".
>  Doing so, causes "B" to go over it's limit, what do we do?
>  Ideally, we would like to be able to go back to cgroups and say, please fail
>  attach, since that causes "B" to go over it's specified limit.
>

OK, that sounds reasonable - that's what the can_attach() callback is for.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
