Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0DF46B0292
	for <linux-mm@kvack.org>; Sat, 22 Jul 2017 20:42:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g5so6829956oic.10
        for <linux-mm@kvack.org>; Sat, 22 Jul 2017 17:42:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t11si3242186oig.489.2017.07.22.17.42.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 22 Jul 2017 17:42:08 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170720141138.GJ9058@dhcp22.suse.cz>
	<201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
	<20170721150002.GF5944@dhcp22.suse.cz>
	<201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
	<20170721153353.GG5944@dhcp22.suse.cz>
In-Reply-To: <20170721153353.GG5944@dhcp22.suse.cz>
Message-Id: <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Jul 2017 09:41:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 22-07-17 00:18:48, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > OK, so let's say you have another task just about to jump into
> > > out_of_memory and ... end up in the same situation.
> > 
> > Right.
> > 
> > > 
> > >                                                     This race is just
> > > unavoidable.
> > 
> > There is no perfect way (always timing dependent). But
> 
> I would rather not add a code which _pretends_ it solves something. If
> we see the above race a real problem in out there then we should think
> about how to fix it. I definitely do not want to add more hack into an
> already complicated code base.

So, how can we verify the above race a real problem? I consider that
it is impossible. The " free:%lukB" field by show_free_areas() is too
random/inaccurate/racy/outdated for evaluating this race window.

Only actually calling alloc_page_from_freelist() immediately after
MMF_OOM_SKIP test (like Patch1 shown below) can evaluate this race window,
but I know that you won't allow me to add such code to the OOM killer layer.

Your "[RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap" patch
is shown below as Patch2.

My "ignore MMF_OOM_SKIP once" patch is shown below as Patch3.

My "wait for oom_lock" patch is shown below as Patch4.

Patch1:
----------------------------------------
 include/linux/oom.h |  4 ++++
 mm/internal.h       |  4 ++++
 mm/oom_kill.c       | 28 +++++++++++++++++++++++++++-
 mm/page_alloc.c     | 10 +++++++---
 4 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a266e2..1b0bbb6 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -11,6 +11,7 @@
 struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
+struct alloc_context;
 
 /*
  * Details of the page allocation that triggered the oom killer that are used to
@@ -39,6 +40,9 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+
+	const struct alloc_context *alloc_context;
+	unsigned int alloc_flags;
 };
 
 extern struct mutex oom_lock;
diff --git a/mm/internal.h b/mm/internal.h
index 24d88f0..95a08b5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -522,4 +522,8 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 	return get_pageblock_migratetype(page) == MIGRATE_HIGHATOMIC;
 }
 
+struct page *get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
+				    int alloc_flags,
+				    const struct alloc_context *ac);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f0..fb7b2c8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -288,6 +288,9 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
+static unsigned int mmf_oom_skip_raced;
+static unsigned int mmf_oom_skip_not_raced;
+
 static int oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
@@ -303,8 +306,21 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+			const struct alloc_context *ac = oc->alloc_context;
+
+			if (ac) {
+				struct page *page = get_page_from_freelist
+					(oc->gfp_mask, oc->order,
+					 oc->alloc_flags, ac);
+				if (page) {
+					__free_pages(page, oc->order);
+					mmf_oom_skip_raced++;
+				} else
+					mmf_oom_skip_not_raced++;
+			}
 			goto next;
+		}
 		goto abort;
 	}
 
@@ -1059,6 +1075,16 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		schedule_timeout_killable(1);
 	}
+	{
+		static unsigned long last;
+		unsigned long now = jiffies;
+
+		if (!last || time_after(now, last + 5 * HZ)) {
+			last = now;
+			pr_info("MMF_OOM_SKIP: raced=%u not_raced=%u\n",
+				mmf_oom_skip_raced, mmf_oom_skip_not_raced);
+		}
+	}
 	return !!oc->chosen;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..4cf2861 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3054,7 +3054,7 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
-static struct page *
+struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
@@ -3245,7 +3245,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+		      unsigned int alloc_flags, const struct alloc_context *ac,
+		      unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3253,6 +3254,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.alloc_context = ac,
+		.alloc_flags = alloc_flags,
 	};
 	struct page *page;
 
@@ -3955,7 +3958,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto retry_cpuset;
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags, ac,
+				     &did_some_progress);
 	if (page)
 		goto got_pg;
 
----------------------------------------

Patch2:
----------------------------------------
 mm/mmap.c     |  7 +++++++
 mm/oom_kill.c | 35 +++++------------------------------
 2 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf..669f07d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2993,6 +2993,11 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables or unmap VMAs under its feet
+	 */
+	down_write(&mm->mmap_sem);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
@@ -3005,7 +3010,9 @@ void exit_mmap(struct mm_struct *mm)
 			nr_accounted += vma_pages(vma);
 		vma = remove_vma(vma);
 	}
+	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
+	up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fb7b2c8..3ef14f0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -486,39 +486,16 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return false;
 	}
 
-	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
+	/* There is nothing to reap so bail out without signs in the log */
+	if (!mm->mmap) {
 		up_read(&mm->mmap_sem);
-		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return true;
 	}
 
 	trace_start_task_reaping(tsk->pid);
@@ -565,9 +542,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mmput_async(mm);
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
----------------------------------------

Patch3:
----------------------------------------
 mm/oom_kill.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3ef14f0..9cc6634 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -306,7 +306,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+		if (task->signal->oom_mm->async_put_work.func) {
 			const struct alloc_context *ac = oc->alloc_context;
 
 			if (ac) {
@@ -321,6 +321,8 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 			}
 			goto next;
 		}
+		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+			task->signal->oom_mm->async_put_work.func = (void *) 1;
 		goto abort;
 	}
 
@@ -652,8 +654,10 @@ static void mark_oom_victim(struct task_struct *tsk)
 		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
+		tsk->signal->oom_mm->async_put_work.func = NULL;
+	}
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
----------------------------------------

Patch4:
----------------------------------------
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4cf2861..3e0e7da 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3265,7 +3265,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;
----------------------------------------

Memory stressor is shown below.
----------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <poll.h>

int main(int argc, char *argv[])
{
        static char buffer[4096] = { };
        char *buf = NULL;
        unsigned long size;
        unsigned long i;
        for (i = 0; i < 1024; i++) {
                if (fork() == 0) {
                        int fd = open("/proc/self/oom_score_adj", O_WRONLY);
                        write(fd, "1000", 4);
                        close(fd);
                        sleep(1);
                        if (!i)
                                pause();
                        snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
                        fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
                        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer)) {
                                poll(NULL, 0, 10);
                                fsync(fd);
                        }
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
        for (i = 0; i < size; i += 4096)
                buf[i] = 0;
        pause();
        return 0;
}
----------------------------------------

Log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170722.txt.xz .

# grep MMF_OOM_SKIP serial-20170722.txt | sed -e 's/=/ /g' | awk ' { if ($5 + $7) printf("%10u %10u %10f\n", $5, $7, ($5*100/($5+$7))); else printf("-----\n"); }'
----------------------------------------
----- # Patch1
         0         10   0.000000
         0         25   0.000000
        16        178   8.247423
        16        591   2.635914
        51       1476   3.339882
        51       1517   3.252551
        51       1559   3.167702
        51       1602   3.085299
        51       1646   3.005303
        51       1832   2.708444
        51       1931   2.573158
        51       2141   2.326642
       172       2950   5.509289
       172       4890   3.397866
       471       7916   5.615834
       471       8255   5.397662
       471       8717   5.126252
       471       8954   4.997347
       471       9435   4.754694
       471      10060   4.472510
       471      10840   4.164088
       471      10973   4.115694
       471      12475   3.638189
       471      14318   3.184800
       471      14762   3.091971
       471      16122   2.838546
       471      16433   2.786323
       471      16748   2.735350
       471      17067   2.685597
       471      18507   2.481821
       471      19173   2.397679
       471      22002   2.095848
       471      22173   2.080021
       471      22867   2.018168
       655      26574   2.405524
       655      30397   2.109365
       655      31030   2.067224
       655      32971   1.947897
       655      33414   1.922569
       655      33637   1.910066
       682      34285   1.950410
       682      34740   1.925357
       936      34740   2.623613
       936      34740   2.623613
       936      34777   2.620894
       936      34846   2.615840
       936      35104   2.597114
       968      35377   2.663365
      1046      36776   2.765586
      1099      38417   2.781152
      1176      41715   2.741834
      1176      42957   2.664673
      1286      55200   2.276670
      1640      67105   2.385628
      2138     186214   1.135109
      2138     188287   1.122752
      2138     188288   1.122746
      2164     188724   1.133649
      2164     189131   1.131237
      2164     189432   1.129460
      2164     190152   1.125231
      2164     190323   1.124232
      2164     190890   1.120930
      2164     193030   1.108641
      2164     197603   1.083262
      2283     199866   1.129365
      2283     202543   1.114605
      2283     203293   1.110538
      2437     204552   1.177357
----- # Patch1 + Patch2
         2        151   1.307190
         2        188   1.052632
         2        208   0.952381
         2        208   0.952381
         2        223   0.888889
         8        355   2.203857
        62        640   8.831909
        96       1681   5.402364
        96       3381   2.761001
       190       5403   3.397104
       344      14944   2.250131
       589      31461   1.837754
       589      65517   0.890993
       589      99284   0.589749
       750     204676   0.365095
      1157     283736   0.406117
      1157     286966   0.401565
      1647     368642   0.444788
      4870     494913   0.974423
      8615     646051   1.315938
      9266     743860   1.230339
----- # Patch1 + Patch2 + Patch3
         0         39   0.000000
         0        109   0.000000
         0        189   0.000000
         0        922   0.000000
        31       1101   2.738516
        31       1130   2.670112
        31       1175   2.570481
        31       1214   2.489960
        31       1230   2.458366
      2204      16429  11.828476
      9855      78544  11.148316
     17286     165828   9.440021
     29345     276217   9.603616
     41258     413082   9.080865
     63125     597249   9.558977
     73859     799400   8.457857
    100960     965601   9.465938
    100960     965806   9.464119
    100960     967986   9.444818
    101025     969145   9.440089
    101040     976753   9.374713
    101040     982309   9.326634
    101040     982469   9.325257
    101100     983224   9.323781
    101227     990001   9.276430
    101715    1045386   8.867136
    101968    1063231   8.751123
    103042    1090044   8.636595
    104288    1154220   8.286638
    105186    1230825   7.873139
----- # Patch1 + Patch2 + Patch3 + Patch4
      5400        297  94.786730
      5941       1843  76.323227
      7750       4445  63.550636
      9443       8928  51.401666
     11596      29502  28.215485
     11596     417423   2.702911
     11596     525783   2.157881
     14241     529736   2.617942
     21111     550020   3.696350
     45408     610006   6.928140
     82501     654515  11.193923
     98495     676552  12.708262
    111349     709904  13.558428
    133540     742574  15.242309
    203589     854338  19.244144
    249020    1049335  19.179654
----------------------------------------

The result shows that this race is highly timing dependent, but it
at least shows that it is not rare case that get_page_from_freelist()
can succeed after we checked that victim's mm already has MMF_OOM_SKIP.

So, how can we check the above race a real problem? I consider that
it is impossible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
