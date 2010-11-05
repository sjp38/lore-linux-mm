Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E8998D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 23:09:11 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 44/49] mm: Use vzalloc
Date: Thu,  4 Nov 2010 20:08:08 -0700
Message-Id: <fb9608ce19d2a2a536be8330c40fc922583a5bda.1288925425.git.joe@perches.com>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/memcontrol.c  |    5 ++---
 mm/page_cgroup.c |    3 +--
 mm/percpu.c      |    8 ++------
 mm/swapfile.c    |    3 +--
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a99cfa..90da698 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4199,14 +4199,13 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
-		mem = kmalloc(size, GFP_KERNEL);
+		mem = kzalloc(size, GFP_KERNEL);
 	else
-		mem = vmalloc(size);
+		mem = vzalloc(size);
 
 	if (!mem)
 		return NULL;
 
-	memset(mem, 0, size);
 	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!mem->stat) {
 		if (size < PAGE_SIZE)
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada..34970c7 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -450,11 +450,10 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	length = ((max_pages/SC_PER_PAGE) + 1);
 	array_size = length * sizeof(void *);
 
-	array = vmalloc(array_size);
+	array = vzalloc(array_size);
 	if (!array)
 		goto nomem;
 
-	memset(array, 0, array_size);
 	ctrl = &swap_cgroup_ctrl[type];
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl->length = length;
diff --git a/mm/percpu.c b/mm/percpu.c
index efe8168..9e16d1c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -293,12 +293,8 @@ static void *pcpu_mem_alloc(size_t size)
 
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
-	else {
-		void *ptr = vmalloc(size);
-		if (ptr)
-			memset(ptr, 0, size);
-		return ptr;
-	}
+	else
+		return vzalloc(size);
 }
 
 /**
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 67ddaaf..43e6988 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2044,13 +2044,12 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 
 	/* OK, set up the swap map and apply the bad block list */
-	swap_map = vmalloc(maxpages);
+	swap_map = vzalloc(maxpages);
 	if (!swap_map) {
 		error = -ENOMEM;
 		goto bad_swap;
 	}
 
-	memset(swap_map, 0, maxpages);
 	nr_good_pages = maxpages - 1;	/* omit header page */
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
