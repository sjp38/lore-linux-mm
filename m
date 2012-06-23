Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 45AE76B027D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 20:19:23 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so1458136vbk.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:19:22 -0700 (PDT)
Message-ID: <4FE50B81.5080603@gmail.com>
Date: Fri, 22 Jun 2012 20:19:13 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com> <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com> <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com> <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com> <alpine.DEB.2.00.1206221634230.18408@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206221634230.18408@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(6/22/12 7:36 PM), David Rientjes wrote:
> On Fri, 22 Jun 2012, KOSAKI Motohiro wrote:
> 
>>>>> -               pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
>>>>> +               pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
>>>>>                        task->pid, from_kuid(&init_user_ns, task_uid(task)),
>>>>>                        task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
>>>>> -                       task_cpu(task), task->signal->oom_adj,
>>>>> +                       task->mm->nr_ptes,
>>>>
>>>> nr_ptes should be folded into rss. it's "resident".
>>>> btw, /proc rss info should be fixed too.
>>>
>>> If we can fold rss into get_mm_rss() and every caller is ok with that,
>>> then we can remove showing it here and adding it explicitly in
>>> oom_badness().
>>
>> No worth to make fragile ABI. Do you have any benefit?
>>
> 
> Yes, because this is exactly where we would discover something like a 
> mm->nr_ptes accounting issue since it would result in an oom kill and we'd 
> notice the mismatch between nr_ptes and rss in the tasklist dump.

Below patch is better, then. tasklist dump should show brief summary and
final killed process output should show most detail info. And, now all of
get_mm_rss() callsite got consistent.



---
 arch/sparc/mm/fault_64.c |    3 ++-
 arch/sparc/mm/tsb.c      |    3 ++-
 include/linux/mm.h       |    3 ++-
 mm/oom_kill.c            |    8 ++++----
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 1fe0429..f342a7c 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -463,7 +463,8 @@ good_area:
 	}
 	up_read(&mm->mmap_sem);
 
-	mm_rss = get_mm_rss(mm);
+	mm_rss = get_mm_counter(mm, MM_FILEPAGES) + get_mm_counter(mm, MM_ANONPAGES);
+
 #ifdef CONFIG_HUGETLB_PAGE
 	mm_rss -= (mm->context.huge_pte_count * (HPAGE_SIZE / PAGE_SIZE));
 #endif
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index c52add7..20889dd 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -472,7 +472,8 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	/* If this is fork, inherit the parent's TSB size.  We would
 	 * grow it to that size on the first page fault anyways.
 	 */
-	tsb_grow(mm, MM_TSB_BASE, get_mm_rss(mm));
+	tsb_grow(mm, MM_TSB_BASE, get_mm_counter(mm, MM_FILEPAGES) +
+		 get_mm_counter(mm, MM_ANONPAGES));
 
 #ifdef CONFIG_HUGETLB_PAGE
 	if (unlikely(huge_pte_count))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..c2b8d34 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1091,7 +1091,8 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
-		get_mm_counter(mm, MM_ANONPAGES);
+		get_mm_counter(mm, MM_ANONPAGES) +
+		mm->nr_ptes;
 }
 
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ac300c9..c3fba3c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -203,8 +203,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + p->mm->nr_ptes +
-		 get_mm_counter(p->mm, MM_SWAPENTS);
+	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS);
 	task_unlock(p);
 
 	/*
@@ -483,10 +482,11 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukBJPYn",
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB pte-rss:%lukBJPYn",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
+		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
+		K(mm->nr_ptes));
 	task_unlock(victim);
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
