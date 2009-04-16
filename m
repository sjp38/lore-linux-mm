Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0FF845F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 04:16:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3G8H5cN014902
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Apr 2009 17:17:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 463BA45DE51
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:17:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 26B3A45DD79
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:17:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A7731DB803C
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:17:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93EE81DB803B
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:17:04 +0900 (JST)
Date: Thu, 16 Apr 2009 17:15:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


> Sorry, some troubles found. Ignore above Ack. 3points now.
> 
> 1. get_cpu should be after (*)
> ==mem_cgroup_update_mapped_file_stat()
> +	int cpu = get_cpu();
> +
> +	if (!page_is_file_cache(page))
> +		return;
> +
> +	if (unlikely(!mm))
> +		mm = &init_mm;
> +
> +	mem = try_get_mem_cgroup_from_mm(mm);
> +	if (!mem)
> +		return;
> + ----------------------------------------(*)
> +	stat = &mem->stat;
> +	cpustat = &stat->cpustat[cpu];
> +
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
> +	put_cpu();
> +}
> ==
> 
> 2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
> (Because it's file cache, pc->mem_cgroup is not NULL always.)
> 
> I saw this very easily.
> ==
> Cache: 4096
> mapped_file: 20480
> ==
> 
> 3. at force_empty().
> ==
> +
> +	cpu = get_cpu();
> +	/* Update mapped_file data for mem_cgroup "from" */
> +	stat = &from->stat;
> +	cpustat = &stat->cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, -1);
> +
> +	/* Update mapped_file data for mem_cgroup "to" */
> +	stat = &to->stat;
> +	cpustat = &stat->cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, 1);
> +	put_cpu();
> 
> This just breaks counter when page is not mapped. please check page_mapped().
> 
> like this:
> ==
>     if (page_is_file_cache(page) && page_mapped(page)) {
> 	modify counter.
>     }
> ==
> 
> and call lock_page_cgroup() in  mem_cgroup_update_mapped_file_stat().
> 
> This will be slow, but optimization will be very tricky and need some amount of time.
> 

This is my fix for above 3 problems. but plz do as you like.
I'm not very intersted in details.
==

---
Index: mmotm-2.6.30-Apr14/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-Apr14.orig/mm/memcontrol.c
+++ mmotm-2.6.30-Apr14/mm/memcontrol.c
@@ -322,33 +322,39 @@ static bool mem_cgroup_is_obsolete(struc
 	return css_is_removed(&mem->css);
 }
 
-/*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
- */
-void mem_cgroup_update_mapped_file_stat(struct page *page, struct mm_struct *mm,
-					int val)
+void mem_cgroup_update_mapped_file_stat(struct page *page, bool map)
 {
 	struct mem_cgroup *mem;
 	struct mem_cgroup_stat *stat;
 	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
+	struct page_cgroup *pc;
+	int cpu;
 
 	if (!page_is_file_cache(page))
 		return;
 
-	if (unlikely(!mm))
-		mm = &init_mm;
-
-	mem = try_get_mem_cgroup_from_mm(mm);
-	if (!mem)
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
 		return;
-
-	stat = &mem->stat;
-	cpustat = &stat->cpustat[cpu];
-
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
-	put_cpu();
+	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
+	if (mem) {
+		cpu = get_cpu();
+		stat = &mem->stat;
+		cpustat = &stat->cpustat[cpu];
+		if (map)
+			__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_MAPPED_FILE, 1);
+		else
+			__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_MAPPED_FILE, -1);
+		put_cpu();
+	}
+	if (map)
+		SetPageCgroupMapped(pc);
+	else
+		ClearPageCgroupMapped(pc);
+	unlock_page_cgroup(pc);
 }
 
 /*
@@ -1149,17 +1155,19 @@ static int mem_cgroup_move_account(struc
 	res_counter_uncharge(&from->res, PAGE_SIZE);
 	mem_cgroup_charge_statistics(from, pc, false);
 
-	cpu = get_cpu();
-	/* Update mapped_file data for mem_cgroup "from" */
-	stat = &from->stat;
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, -1);
-
-	/* Update mapped_file data for mem_cgroup "to" */
-	stat = &to->stat;
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, 1);
-	put_cpu();
+	if (PageCgroupMapped(pc)) {
+		cpu = get_cpu();
+		/* Update mapped_file data for mem_cgroup "from" and "to" */
+		stat = &from->stat;
+		cpustat = &stat->cpustat[cpu];
+		__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_MAPPED_FILE, -1);
+		stat = &to->stat;
+		cpustat = &stat->cpustat[cpu];
+		__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_MAPPED_FILE, 1);
+		put_cpu();
+	}
 
 	if (do_swap_account)
 		res_counter_uncharge(&from->memsw, PAGE_SIZE);
Index: mmotm-2.6.30-Apr14/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.30-Apr14.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.30-Apr14/include/linux/page_cgroup.h
@@ -26,6 +26,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_MAPPED, /* mapped file cache */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -46,6 +47,10 @@ TESTPCGFLAG(Cache, CACHE)
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
+TESTPCGFLAG(Mapped, USED)
+CLEARPCGFLAG(Mapped, USED)
+SETPCGFLAG(Mapped, USED)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
Index: mmotm-2.6.30-Apr14/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.30-Apr14.orig/include/linux/memcontrol.h
+++ mmotm-2.6.30-Apr14/include/linux/memcontrol.h
@@ -116,8 +116,7 @@ static inline bool mem_cgroup_disabled(v
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
-void mem_cgroup_update_mapped_file_stat(struct page *page, struct mm_struct *mm,
-					int val);
+void mem_cgroup_update_mapped_file_stat(struct page *page, bool map);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -266,8 +265,7 @@ mem_cgroup_print_oom_info(struct mem_cgr
 }
 
 static inline void mem_cgroup_update_mapped_file_stat(struct page *page,
-							struct mm_struct *mm,
-							int val)
+							bool map)
 {
 }
 
Index: mmotm-2.6.30-Apr14/mm/rmap.c
===================================================================
--- mmotm-2.6.30-Apr14.orig/mm/rmap.c
+++ mmotm-2.6.30-Apr14/mm/rmap.c
@@ -690,7 +690,7 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_mapped_file_stat(page, vma->vm_mm, 1);
+		mem_cgroup_update_mapped_file_stat(page, true);
 	}
 }
 
@@ -740,7 +740,7 @@ void page_remove_rmap(struct page *page,
 			mem_cgroup_uncharge_page(page);
 		__dec_zone_page_state(page,
 			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
-		mem_cgroup_update_mapped_file_stat(page, vma->vm_mm, -1);
+		mem_cgroup_update_mapped_file_stat(page, false);
 		/*
 		 * It would be tidy to reset the PageAnon mapping here,
 		 * but that might overwrite a racing page_add_anon_rmap





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
