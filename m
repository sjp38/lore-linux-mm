Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 916B96B0292
	for <linux-mm@kvack.org>; Sat, 22 Jul 2017 23:03:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g14so112377433pgu.9
        for <linux-mm@kvack.org>; Sat, 22 Jul 2017 20:03:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 85si5075066pgc.418.2017.07.22.20.03.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 22 Jul 2017 20:03:33 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
	<20170721150002.GF5944@dhcp22.suse.cz>
	<201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
	<20170721153353.GG5944@dhcp22.suse.cz>
	<201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
In-Reply-To: <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
Message-Id: <201707231203.DHD90159.tFMOLVFSHFJOQO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Jul 2017 12:03:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170722.txt.xz .

Oops, I forgot to remove mmput_async() in Patch2. Below is updated result.
Though, situation (i.e. we can't tell without Patch1 whether we raced with
OOM_MMF_SKIP) is same.

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
 mm/oom_kill.c | 41 +++++------------------------------------
 2 files changed, 12 insertions(+), 36 deletions(-)

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
index fb7b2c8..ed88355 100644
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
@@ -558,16 +535,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
-	/*
-	 * Drop our reference but make sure the mmput slow path is called from a
-	 * different context because we shouldn't risk we get stuck there and
-	 * put the oom_reaper out of the way.
-	 */
-	mmput_async(mm);
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
index ed88355..59737bf 100644
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
 
@@ -646,8 +648,10 @@ static void mark_oom_victim(struct task_struct *tsk)
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

Log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170723.txt.xz .

# grep MMF_OOM_SKIP serial-20170723.txt | sed -e 's/=/ /g' | awk ' { if ($5 + $7) printf("%10u %10u %10f\n", $5, $7, ($5*100/($5+$7))); else printf("-----\n"); }'

----------------------------------------
----- # Patch1
        42      72416   0.057965
       684     100569   0.675536
      1169     103432   1.117580
      1169     103843   1.113206
      1169     254979   0.456377
      1169     260675   0.446449
      1449     268899   0.535976
      1449     268905   0.535964
      1449     268927   0.535920
      1449     268965   0.535845
      1449     268990   0.535796
      1449     269089   0.535599
      1469     269307   0.542515
      1469     270651   0.539835
      1545     272860   0.563036
      1738     275991   0.625790
      1738     276321   0.625047
      1738     277121   0.623254
      1861     282203   0.655134
      2214     289569   0.758783
      2590     302229   0.849685
      3036     315279   0.953772
----- # Patch1 + Patch2
         0         21   0.000000
         0         45   0.000000
        12         79  13.186813
        12        159   7.017544
        12       2270   0.525855
        12       4750   0.251995
       178      15222   1.155844
       178      16997   1.036390
       178      19847   0.888889
       178      20645   0.854824
       178      23135   0.763522
       178      30479   0.580618
       178      32475   0.545126
       178      35060   0.505137
       178      36122   0.490358
       178      44854   0.395274
       178      49726   0.356685
       178      51619   0.343649
       178      57369   0.309312
       506      61344   0.818108
       506      63039   0.796286
       506      69691   0.720829
       506      83565   0.601872
       506      86330   0.582708
      1358     102218   1.311115
      1358     106653   1.257279
      1358     108003   1.241759
      1358     113901   1.178216
      1358     115739   1.159722
      1358     115739   1.159722
      1358     225671   0.598161
      1680     253286   0.658911
      9368     760763   1.216416
      9368     760852   1.216276
      9368     761841   1.214716
      9368     765167   1.209500
      9381     770368   1.203079
      9381     773975   1.197540
      9816     786044   1.233383
      9875     808291   1.206968
      9875     840890   1.160720
     10770     854555   1.244619
     10794     857956   1.242475
     10794     866148   1.230868
     11161     869111   1.267904
     11226     941179   1.178700
     11697     945889   1.221509
     12222     980317   1.231387
     12948    1038330   1.231644
     13157    1054693   1.232102
     14412    1077659   1.319694
     14953    1097134   1.344589
     15466    1252732   1.219526
----- # Patch1 + Patch2 + Patch3
         0          2   0.000000
         2         75   2.597403
        46        995   4.418828
       175       5416   3.130030
       358      15725   2.225953
       736      28838   2.488672
       736      36445   1.979506
      1008      63860   1.553925
      1008      75472   1.317992
      1008      78268   1.271507
      1408      95598   1.451457
      2142     141059   1.495800
      2537     215187   1.165237
      3123     222191   1.386066
      3478     318033   1.081767
      3618     505315   0.710899
      4768     615277   0.768976
      5939     825753   0.714086
      5939     926402   0.636999
      6969    1088325   0.636268
      7852    1361918   0.573235
----- # Patch1 + Patch2 + Patch3 + Patch4
         0         25   0.000000
         0        959   0.000000
        55       3868   1.401988
      3514      10387  25.278757
      5532      38260  12.632444
      7325      44891  14.028267
      7325      45320  13.913952
      7325      45320  13.913952
      7327      45322  13.916694
      8202      48418  14.486047
     11548      71310  13.937097
     14330      96425  12.938468
     14793     126763  10.450281
     14793     152881   8.822477
     14793     177491   7.693308
     19953     191976   9.414946
     19953     192330   9.399245
     19953     192684   9.383597
     19953     193750   9.336790
     19953     194106   9.321262
     50961     226093  18.393887
     54075     254175  17.542579
     54075     255039  17.493546
     54224     258917  17.316161
     54224     262745  17.107036
     55053     267306  17.078164
     56026     276647  16.841162
     56026     284621  16.446938
     58931     308741  16.028145
     64579     353502  15.446528
     81552     416345  16.379291
    102796     585118  14.943147
    125723     837199  13.056405
    153081    1010078  13.160797
    182049    1067762  14.566122
    184647    1111130  14.249906
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
