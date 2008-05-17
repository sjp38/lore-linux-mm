Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4HKG2rd030762
	for <linux-mm@kvack.org>; Sun, 18 May 2008 06:16:02 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4HKGGDd4067548
	for <linux-mm@kvack.org>; Sun, 18 May 2008 06:16:16 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4HKGSCm001755
	for <linux-mm@kvack.org>; Sun, 18 May 2008 06:16:28 +1000
Date: Sun, 18 May 2008 01:45:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
	control (v4)
Message-ID: <20080517201545.GA14727@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080514132529.GA25653@balbir.in.ibm.com> <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com> <20080515061727.GC31115@balbir.in.ibm.com> <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com> <20080515070342.GJ31115@balbir.in.ibm.com> <6599ad830805150039u76c9002cg6c873fd71e687a69@mail.gmail.com> <20080515082553.GK31115@balbir.in.ibm.com> <6599ad830805150828i6b61755dk9ce5213607621af7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <6599ad830805150828i6b61755dk9ce5213607621af7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Paul Menage <menage@google.com> [2008-05-15 08:28:46]:

> On Thu, May 15, 2008 at 1:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >  >
> >  > But the only *new* cases of taking the mmap_sem that this would
> >  > introduce would be:
> >  >
> >  > - on a failed vm limit charge
> >
> >  Why a failed charge? Aren't we talking of moving all charge/uncharge
> >  under mmap_sem?
> >
> 
> Sorry, I worded that wrongly - I meant "cleaning up a successful
> charge after an expansion fails for other reasons"
> 
> I thought that all the charges and most of the uncharges were already
> under mmap_sem, and it would just be a few of the cleanup paths that
> needed to take it.
> 
> >
> >  > - when a task moves between two cgroups in the memrlimit hierarchy.
> >  >
> >
> >  Yes, this would nest cgroup_mutex and mmap_sem. Not sure if that would
> >  be a bad side-effect.
> >
> 
> I think it's already nested that way - e.g. the cpusets code can call
> various migration functions (which take mmap_sem) while holding
> cgroup_mutex.
> 
> >
> >  Refactor the code to try and use mmap_sem and see what I come up
> >  with. Basically use mmap_sem for all charge/uncharge operations as
> >  well use mmap_sem in read_mode in the move_task() and
> >  mm_owner_changed() callbacks. That should take care of the race
> >  conditions discussed, unless I missed something.
> 
> Sounds good.
> 
> Thanks,
>
I've revamped the last two patches. Please review


This patch adds an additional field to the mm_owner callbacks. This field
is required to get to the mm that changed. Hold mmap_sem in write mode
before calling the mm_owner_changed callback

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/cgroup.h |    3 ++-
 kernel/cgroup.c        |    4 +++-
 kernel/exit.c          |    3 +++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff -puN include/linux/cgroup.h~cgroup-add-task-to-mm-owner-callbacks include/linux/cgroup.h
--- linux-2.6.26-rc2/include/linux/cgroup.h~cgroup-add-task-to-mm-owner-callbacks	2008-05-14 18:36:59.000000000 +0530
+++ linux-2.6.26-rc2-balbir/include/linux/cgroup.h	2008-05-14 18:36:59.000000000 +0530
@@ -310,7 +310,8 @@ struct cgroup_subsys {
 	 */
 	void (*mm_owner_changed)(struct cgroup_subsys *ss,
 					struct cgroup *old,
-					struct cgroup *new);
+					struct cgroup *new,
+					struct task_struct *p);
 	int subsys_id;
 	int active;
 	int disabled;
diff -puN kernel/cgroup.c~cgroup-add-task-to-mm-owner-callbacks kernel/cgroup.c
--- linux-2.6.26-rc2/kernel/cgroup.c~cgroup-add-task-to-mm-owner-callbacks	2008-05-14 18:36:59.000000000 +0530
+++ linux-2.6.26-rc2-balbir/kernel/cgroup.c	2008-05-17 22:09:57.000000000 +0530
@@ -2758,6 +2758,8 @@ void cgroup_fork_callbacks(struct task_s
  * Called on every change to mm->owner. mm_init_owner() does not
  * invoke this routine, since it assigns the mm->owner the first time
  * and does not change it.
+ *
+ * The callbacks are invoked with mmap_sem held in read mode.
  */
 void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
 {
@@ -2772,7 +2774,7 @@ void cgroup_mm_owner_callbacks(struct ta
 			if (oldcgrp == newcgrp)
 				continue;
 			if (ss->mm_owner_changed)
-				ss->mm_owner_changed(ss, oldcgrp, newcgrp);
+				ss->mm_owner_changed(ss, oldcgrp, newcgrp, new);
 		}
 	}
 }
diff -puN kernel/exit.c~cgroup-add-task-to-mm-owner-callbacks kernel/exit.c
--- linux-2.6.26-rc2/kernel/exit.c~cgroup-add-task-to-mm-owner-callbacks	2008-05-17 22:10:00.000000000 +0530
+++ linux-2.6.26-rc2-balbir/kernel/exit.c	2008-05-17 23:14:44.000000000 +0530
@@ -621,6 +621,7 @@ retry:
 assign_new_owner:
 	BUG_ON(c == p);
 	get_task_struct(c);
+	down_write(&mm->mmap_sem);
 	/*
 	 * The task_lock protects c->mm from changing.
 	 * We always want mm->owner->mm == mm
@@ -634,12 +635,14 @@ assign_new_owner:
 	if (c->mm != mm) {
 		task_unlock(c);
 		put_task_struct(c);
+		up_write(&mm->mmap_sem);
 		goto retry;
 	}
 	cgroup_mm_owner_callbacks(mm->owner, c);
 	mm->owner = c;
 	task_unlock(c);
 	put_task_struct(c);
+	up_write(&mm->mmap_sem);
 }
 #endif /* CONFIG_MM_OWNER */
 
_
 

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
