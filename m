Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA532802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 09:00:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j85so7105332wmj.2
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 06:00:28 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o25si5565529wra.182.2017.06.30.06.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 06:00:27 -0700 (PDT)
Date: Fri, 30 Jun 2017 15:00:22 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
In-Reply-To: <3f2395c6-bbe0-23c1-fe06-d17ffbf619c3@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1706301418190.1748@nanos>
References: <alpine.DEB.2.20.1706291803380.1861@nanos> <20170630092747.GD22917@dhcp22.suse.cz> <alpine.DEB.2.20.1706301210210.1748@nanos> <3f2395c6-bbe0-23c1-fe06-d17ffbf619c3@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri, 30 Jun 2017, Andrey Ryabinin wrote:
> On 06/30/2017 01:15 PM, Thomas Gleixner wrote:
> > On Fri, 30 Jun 2017, Michal Hocko wrote:
> >> So I like this simplification a lot! Even if we can get rid of the
> >> stop_machine eventually this patch would be an improvement. A short
> >> comment on why the per-cpu semaphore over the regular one is better
> >> would be nice.
> > 
> > Yes, will add one.
> > 
> > The main point is that the current locking construct is evading lockdep due
> > to the ability to support recursive locking, which I did not observe so
> > far.
> > 
> 
> Like this?

Cute.....

> [  131.023034] Call Trace:
> [  131.023034]  dump_stack+0x85/0xc7
> [  131.023034]  __lock_acquire+0x1747/0x17a0
> [  131.023034]  ? lru_add_drain_all+0x3d/0x190
> [  131.023034]  ? __mutex_lock+0x218/0x940
> [  131.023034]  ? trace_hardirqs_on+0xd/0x10
> [  131.023034]  lock_acquire+0x103/0x200
> [  131.023034]  ? lock_acquire+0x103/0x200
> [  131.023034]  ? lru_add_drain_all+0x42/0x190
> [  131.023034]  cpus_read_lock+0x3d/0x80
> [  131.023034]  ? lru_add_drain_all+0x42/0x190
> [  131.023034]  lru_add_drain_all+0x42/0x190
> [  131.023034]  __offline_pages.constprop.25+0x5de/0x870
> [  131.023034]  offline_pages+0xc/0x10
> [  131.023034]  memory_subsys_offline+0x43/0x70
> [  131.023034]  device_offline+0x83/0xb0
> [  131.023034]  store_mem_state+0xdb/0xe0
> [  131.023034]  dev_attr_store+0x13/0x20
> [  131.023034]  sysfs_kf_write+0x40/0x50
> [  131.023034]  kernfs_fop_write+0x130/0x1b0
> [  131.023034]  __vfs_write+0x23/0x130
> [  131.023034]  ? rcu_read_lock_sched_held+0x6d/0x80
> [  131.023034]  ? rcu_sync_lockdep_assert+0x2a/0x50
> [  131.023034]  ? __sb_start_write+0xd4/0x1c0
> [  131.023034]  ? vfs_write+0x1a8/0x1d0
> [  131.023034]  vfs_write+0xc8/0x1d0
> [  131.023034]  SyS_write+0x44/0xa0

Why didn't trigger that here? Bah, I should have become suspicious due to
not seeing a splat ....

The patch below should cure that.

Thanks,

	tglx

8<-------------------
Subject: mm: Change cpuhotplug lock order in lru_add_drain_all()
From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 30 Jun 2017 14:25:24 +0200

Not-Yet-Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/swap.h |    1 +
 mm/memory_hotplug.c  |    4 ++--
 mm/swap.c            |   11 ++++++++---
 3 files changed, 11 insertions(+), 5 deletions(-)

Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -277,6 +277,7 @@ extern void mark_page_accessed(struct pa
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
+extern void lru_add_drain_all_cpuslocked(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
Index: b/mm/memory_hotplug.c
===================================================================
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1860,7 +1860,7 @@ static int __ref __offline_pages(unsigne
 		goto failed_removal;
 	ret = 0;
 	if (drain) {
-		lru_add_drain_all();
+		lru_add_drain_all_cpuslocked();
 		cond_resched();
 		drain_all_pages(zone);
 	}
@@ -1881,7 +1881,7 @@ static int __ref __offline_pages(unsigne
 		}
 	}
 	/* drain all zone's lru pagevec, this is asynchronous... */
-	lru_add_drain_all();
+	lru_add_drain_all_cpuslocked();
 	yield();
 	/* drain pcp pages, this is synchronous. */
 	drain_all_pages(zone);
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -687,7 +687,7 @@ static void lru_add_drain_per_cpu(struct
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
-void lru_add_drain_all(void)
+void lru_add_drain_all_cpuslocked(void)
 {
 	static DEFINE_MUTEX(lock);
 	static struct cpumask has_work;
@@ -701,7 +701,6 @@ void lru_add_drain_all(void)
 		return;
 
 	mutex_lock(&lock);
-	get_online_cpus();
 	cpumask_clear(&has_work);
 
 	for_each_online_cpu(cpu) {
@@ -721,10 +720,16 @@ void lru_add_drain_all(void)
 	for_each_cpu(cpu, &has_work)
 		flush_work(&per_cpu(lru_add_drain_work, cpu));
 
-	put_online_cpus();
 	mutex_unlock(&lock);
 }
 
+void lru_add_drain_all(void)
+{
+	get_online_cpus();
+	lru_add_drain_all_cpuslocked();
+	put_online_cpus();
+}
+
 /**
  * release_pages - batched put_page()
  * @pages: array of pages to release

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
