Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92B686B02F2
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:19:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q199so20467017oic.2
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 04:19:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j108si905454otc.89.2017.04.27.04.19.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 04:19:20 -0700 (PDT)
Subject: block: mempool allocation hangs under OOM. (Re: A pitfall of mempool?)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201704252022.DFB26076.FMOQVFOtJOSFHL@I-love.SAKURA.ne.jp>
In-Reply-To: <201704252022.DFB26076.FMOQVFOtJOSFHL@I-love.SAKURA.ne.jp>
Message-Id: <201704272019.JEH26057.SHFOtMLJOOVFQF@I-love.SAKURA.ne.jp>
Date: Thu, 27 Apr 2017 20:19:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-block@vger.kernel.org, linux-mm@kvack.org
Cc: axboe@kernel.dk, mhocko@kernel.org

Hello.

I noticed a hang up where kswapd was unable to get memory for bio from mempool
at bio_alloc_bioset(GFP_NOFS) request at
http://lkml.kernel.org/r/201704252022.DFB26076.FMOQVFOtJOSFHL@I-love.SAKURA.ne.jp .

Since there is no mean to check whether kswapd was making progress, I tried
below patch on top of allocation watchdog patch at
http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

----------
 include/linux/gfp.h | 8 ++++++++
 kernel/hung_task.c  | 5 ++++-
 mm/mempool.c        | 9 ++++++++-
 mm/page_alloc.c     | 6 ++----
 4 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 2b1a44f5..cc16050 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -469,6 +469,14 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+extern void start_memalloc_timer(const gfp_t gfp_mask, const int order);
+extern void stop_memalloc_timer(const gfp_t gfp_mask);
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 8f237c0..7d11e8e 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -17,6 +17,7 @@
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
 #include <linux/oom.h>
+#include <linux/console.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/debug.h>
 
@@ -149,7 +150,9 @@ static bool rcu_lock_break(struct task_struct *g, struct task_struct *t)
 	get_task_struct(g);
 	get_task_struct(t);
 	rcu_read_unlock();
-	cond_resched();
+	if (console_trylock())
+		console_unlock();
+	//cond_resched();
 	rcu_read_lock();
 	can_cont = pid_alive(g) && pid_alive(t);
 	put_task_struct(t);
diff --git a/mm/mempool.c b/mm/mempool.c
index 47a659d..8b449af 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -324,11 +324,14 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
+	start_memalloc_timer(gfp_temp, -1);
 repeat_alloc:
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
-	if (likely(element != NULL))
+	if (likely(element != NULL)) {
+		stop_memalloc_timer(gfp_temp);
 		return element;
+	}
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
@@ -341,6 +344,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(element);
+		stop_memalloc_timer(gfp_temp);
 		return element;
 	}
 
@@ -350,13 +354,16 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	 */
 	if (gfp_temp != gfp_mask) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		gfp_temp = gfp_mask;
+		start_memalloc_timer(gfp_temp, -1);
 		goto repeat_alloc;
 	}
 
 	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		return NULL;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f539752..652ba4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4008,7 +4008,7 @@ bool memalloc_maybe_stalling(void)
 	return false;
 }
 
-static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+void start_memalloc_timer(const gfp_t gfp_mask, const int order)
 {
 	struct memalloc_info *m = &current->memalloc;
 
@@ -4032,7 +4032,7 @@ static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
 	m->in_flight++;
 }
 
-static void stop_memalloc_timer(const gfp_t gfp_mask)
+void stop_memalloc_timer(const gfp_t gfp_mask)
 {
 	struct memalloc_info *m = &current->memalloc;
 
@@ -4055,8 +4055,6 @@ static void memalloc_counter_fold(int cpu)
 }
 
 #else
-#define start_memalloc_timer(gfp_mask, order) do { } while (0)
-#define stop_memalloc_timer(gfp_mask) do { } while (0)
 #define memalloc_counter_fold(cpu) do { } while (0)
 #endif
 
----------

These patches reported that mempool_alloc(GFP_NOFS|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOMEMALLOC)
was not able to get memory for more than 15 minutes (and thus unable to submit block I/O
request for reclaiming memory via FS writeback, and thus unable to unblock __GFP_FS
allocation requests waiting for FS writeback, and thus unable to invoke the OOM killer for
reclaiming memory for more than 12 minutes, and thus unable to unblock mempool_alloc(),
and thus silent hang up).

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170427.txt.xz .
----------
[    0.000000] Linux version 4.11.0-rc8-next-20170426+ (root@localhost.localdomain) (gcc version 6.2.1 20160916 (Red Hat 6.2.1-3) (GCC) ) #96 SMP Thu Apr 27 09:45:31 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc8-next-20170426+ root=UUID=98df1583-260a-423a-a193-182dade5d085 ro crashkernel=256M security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8
(...snipped...)
[  588.687385] Out of memory: Kill process 8050 (a.out) score 999 or sacrifice child
[  588.691029] Killed process 8050 (a.out) total-vm:4168kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  588.699415] oom_reaper: reaped process 8050 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[ 1401.127653] MemAlloc: a.out(8865) flags=0x400040 switches=1816 seq=25 gfp=0x1411240(GFP_NOFS|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOMEMALLOC) order=4294967295 delay=1054846 uninterruptible
[ 1401.134726] a.out           D11768  8865   7842 0x00000080
[ 1401.137339] Call Trace:
[ 1401.138802]  __schedule+0x403/0x940
[ 1401.140626]  schedule+0x3d/0x90
[ 1401.142324]  schedule_timeout+0x23b/0x510
[ 1401.144348]  ? init_timer_on_stack_key+0x60/0x60
[ 1401.146578]  io_schedule_timeout+0x1e/0x50
[ 1401.148618]  ? io_schedule_timeout+0x1e/0x50
[ 1401.150689]  mempool_alloc+0x18b/0x1c0
[ 1401.152587]  ? remove_wait_queue+0x70/0x70
[ 1401.154619]  bio_alloc_bioset+0xae/0x230
[ 1401.156580]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[ 1401.158750]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[ 1401.160916]  write_cache_pages+0x230/0x680
[ 1401.162935]  ? xfs_add_to_ioend+0x260/0x260 [xfs]
[ 1401.165169]  ? sched_clock+0x9/0x10
[ 1401.166961]  ? xfs_vm_writepages+0x55/0xa0 [xfs]
[ 1401.169183]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[ 1401.171312]  do_writepages+0x21/0x30
[ 1401.173115]  __filemap_fdatawrite_range+0xc6/0x100
[ 1401.175381]  filemap_write_and_wait_range+0x2d/0x70
[ 1401.177705]  xfs_file_fsync+0x86/0x2b0 [xfs]
[ 1401.179785]  vfs_fsync_range+0x4b/0xb0
[ 1401.181660]  ? __audit_syscall_exit+0x21f/0x2c0
[ 1401.183824]  do_fsync+0x3d/0x70
[ 1401.185473]  SyS_fsync+0x10/0x20
[ 1401.187160]  do_syscall_64+0x6c/0x1c0
[ 1401.189004]  entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[ 1401.211964] MemAlloc: a.out(8866) flags=0x400040 switches=1825 seq=31 gfp=0x1411240(GFP_NOFS|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOMEMALLOC) order=4294967295 delay=1055258 uninterruptible
[ 1401.219018] a.out           D11320  8866   7842 0x00000080
[ 1401.221583] Call Trace:
[ 1401.223032]  __schedule+0x403/0x940
[ 1401.224871]  schedule+0x3d/0x90
[ 1401.226545]  schedule_timeout+0x23b/0x510
[ 1401.228550]  ? init_timer_on_stack_key+0x60/0x60
[ 1401.230773]  io_schedule_timeout+0x1e/0x50
[ 1401.232791]  ? io_schedule_timeout+0x1e/0x50
[ 1401.234890]  mempool_alloc+0x18b/0x1c0
[ 1401.236768]  ? remove_wait_queue+0x70/0x70
[ 1401.238757]  bvec_alloc+0x90/0xf0
[ 1401.240444]  bio_alloc_bioset+0x17b/0x230
[ 1401.242425]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[ 1401.244566]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[ 1401.246709]  write_cache_pages+0x230/0x680
[ 1401.248736]  ? xfs_add_to_ioend+0x260/0x260 [xfs]
[ 1401.250944]  ? sched_clock+0x9/0x10
[ 1401.252720]  ? xfs_vm_writepages+0x55/0xa0 [xfs]
[ 1401.254918]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[ 1401.257028]  do_writepages+0x21/0x30
[ 1401.258832]  __filemap_fdatawrite_range+0xc6/0x100
[ 1401.261079]  filemap_write_and_wait_range+0x2d/0x70
[ 1401.263383]  xfs_file_fsync+0x86/0x2b0 [xfs]
[ 1401.265435]  vfs_fsync_range+0x4b/0xb0
[ 1401.267301]  ? __audit_syscall_exit+0x21f/0x2c0
[ 1401.269449]  do_fsync+0x3d/0x70
[ 1401.271080]  SyS_fsync+0x10/0x20
[ 1401.272738]  do_syscall_64+0x6c/0x1c0
[ 1401.274574]  entry_SYSCALL64_slow_path+0x25/0x25
----------

# ./scripts/faddr2line vmlinux bio_alloc_bioset+0xae/0x230
bio_alloc_bioset+0xae/0x230:
bio_alloc_bioset at block/bio.c:484
# ./scripts/faddr2line vmlinux bio_alloc_bioset+0x17b/0x230
bio_alloc_bioset+0x17b/0x230:
bio_alloc_bioset at block/bio.c:501
# ./scripts/faddr2line vmlinux bvec_alloc+0x90/0xf0
bvec_alloc+0x90/0xf0:
bvec_alloc at block/bio.c:216

Something is wrong with assumptions for mempool_alloc() under memory pressure.
I was expecting for a patch that forces not to wait for FS writeback forever
at shrink_inactive_list() at
http://lkml.kernel.org/r/20170307133057.26182-1-mhocko@kernel.org , but
I think this mempool allocation hang problem should be examined before
we give up and workaround shrink_inactive_list().

Reproducer is shown below. Just write()ing & fsync()ing files on a plain
XFS filesystem ( /dev/sda1 ) on a plain SCSI disk under memory pressure.
No RAID/LVM/loopback etc. are used.
----------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	static char buffer[128] = { };
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			sleep(1);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer))
				fsync(fd);
			_exit(0);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(2);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096) {
		buf[i] = 0;
	}
	pause();
	return 0;
}
----------

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
