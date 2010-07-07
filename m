Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C21E96B0248
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 21:15:51 -0400 (EDT)
Subject: [PATCH]shmem: reduce one time of locking in pagefault
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: multipart/mixed; boundary="=-cyJ/P2kZGKSKnIpmMnTl"
Date: Wed, 07 Jul 2010 09:15:46 +0800
Message-ID: <1278465346.11107.8.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>
List-ID: <linux-mm.kvack.org>


--=-cyJ/P2kZGKSKnIpmMnTl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

I'm running a shmem pagefault test case (see attached file) under a 64 CPU
system. Profile shows shmem_inode_info->lock is heavily contented and 100%
CPUs time are trying to get the lock. In the pagefault (no swap) case,
shmem_getpage gets the lock twice, the last one is avoidable if we prealloc a
page so we could reduce one time of locking. This is what below patch does.

The result of the test case:
2.6.35-rc3: ~20s
2.6.35-rc3 + patch: ~12s
so this is 40% improvement.

One might argue if we could have better locking for shmem. But even shmem is lockless,
the pagefault will soon have pagecache lock heavily contented because shmem must add
new page to pagecache. So before we have better locking for pagecache, improving shmem
locking doesn't have too much improvement. I did a similar pagefault test against
a ramfs file, the test result is ~10.5s.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/shmem.c b/mm/shmem.c
index f65f840..c5f2939 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1223,6 +1223,7 @@ static int shmem_getpage(struct inode *inode, unsigned long idx,
 	struct shmem_sb_info *sbinfo;
 	struct page *filepage = *pagep;
 	struct page *swappage;
+	struct page *prealloc_page = NULL;
 	swp_entry_t *entry;
 	swp_entry_t swap;
 	gfp_t gfp;
@@ -1247,7 +1248,6 @@ repeat:
 		filepage = find_lock_page(mapping, idx);
 	if (filepage && PageUptodate(filepage))
 		goto done;
-	error = 0;
 	gfp = mapping_gfp_mask(mapping);
 	if (!filepage) {
 		/*
@@ -1258,7 +1258,19 @@ repeat:
 		if (error)
 			goto failed;
 		radix_tree_preload_end();
+		if (sgp != SGP_READ) {
+			/* don't care if this successes */
+			prealloc_page = shmem_alloc_page(gfp, info, idx);
+			if (prealloc_page) {
+				if (mem_cgroup_cache_charge(prealloc_page,
+				    current->mm, GFP_KERNEL)) {
+					page_cache_release(prealloc_page);
+					prealloc_page = NULL;
+				}
+			}
+		}
 	}
+	error = 0;
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
@@ -1407,28 +1419,37 @@ repeat:
 		if (!filepage) {
 			int ret;
 
-			spin_unlock(&info->lock);
-			filepage = shmem_alloc_page(gfp, info, idx);
-			if (!filepage) {
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				error = -ENOMEM;
-				goto failed;
-			}
-			SetPageSwapBacked(filepage);
+			if (!prealloc_page) {
+				spin_unlock(&info->lock);
+				filepage = shmem_alloc_page(gfp, info, idx);
+				if (!filepage) {
+					shmem_unacct_blocks(info->flags, 1);
+					shmem_free_blocks(inode, 1);
+					error = -ENOMEM;
+					goto failed;
+				}
+				SetPageSwapBacked(filepage);
 
-			/* Precharge page while we can wait, compensate after */
-			error = mem_cgroup_cache_charge(filepage, current->mm,
-					GFP_KERNEL);
-			if (error) {
-				page_cache_release(filepage);
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				filepage = NULL;
-				goto failed;
+				/* Precharge page while we can wait, compensate
+				 * after
+				 */
+				error = mem_cgroup_cache_charge(filepage,
+					current->mm, GFP_KERNEL);
+				if (error) {
+					page_cache_release(filepage);
+					shmem_unacct_blocks(info->flags, 1);
+					shmem_free_blocks(inode, 1);
+					filepage = NULL;
+					goto failed;
+				}
+
+				spin_lock(&info->lock);
+			} else {
+				filepage = prealloc_page;
+				prealloc_page = NULL;
+				SetPageSwapBacked(filepage);
 			}
 
-			spin_lock(&info->lock);
 			entry = shmem_swp_alloc(info, idx, sgp);
 			if (IS_ERR(entry))
 				error = PTR_ERR(entry);
@@ -1469,6 +1490,10 @@ repeat:
 	}
 done:
 	*pagep = filepage;
+	if (prealloc_page) {
+		mem_cgroup_uncharge_cache_page(prealloc_page);
+		page_cache_release(prealloc_page);
+	}
 	return 0;
 
 failed:
@@ -1476,6 +1501,10 @@ failed:
 		unlock_page(filepage);
 		page_cache_release(filepage);
 	}
+	if (prealloc_page) {
+		mem_cgroup_uncharge_cache_page(prealloc_page);
+		page_cache_release(prealloc_page);
+	}
 	return error;
 }
 


--=-cyJ/P2kZGKSKnIpmMnTl
Content-Disposition: attachment; filename="shmem-test.c"
Content-Type: text/x-csrc; name="shmem-test.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>
#include <pthread.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>

#define THREAD_NUM (64L)
#define MEM_SIZE (1024*1024*1024*16L)
#define PER_TH_SIZE (MEM_SIZE/THREAD_NUM)

void *thread_func(void *data)
{
	char *addr = data;
	unsigned long size = PER_TH_SIZE, index = 0;
	int t;

	while (index < size) {
		t = *(addr + index);
		index += 4096;
	}
}

int main(int argc, char *argv[])
{
	int i;
	pthread_t threads[THREAD_NUM];
	pthread_attr_t attr;
	struct timeval start, stop, diff;
	char *mem;

	mem = mmap(NULL, MEM_SIZE, PROT_READ|PROT_WRITE,
		MAP_SHARED|MAP_ANON, 0, 0);
	if (!mem) {
		perror("mmap error");
		exit(1);
	}
	
	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
	gettimeofday(&start, NULL);
	for (i = 0; i < THREAD_NUM; i++)
		if (pthread_create(&threads[i], &attr, thread_func,
			mem + PER_TH_SIZE * i)) {
			perror("thread create error");
			exit(1);
		}

	for (i=0; i< THREAD_NUM; i++)
		pthread_join(threads[i], NULL);

	gettimeofday(&stop, NULL);
	timersub(&stop, &start, &diff);
	printf("Thread %ld Mem %dG time %lu.%03lusec\n",
		THREAD_NUM, MEM_SIZE/1024/1024/1024,
		diff.tv_sec, diff.tv_usec/1000);

	pthread_attr_destroy(&attr);
	return 0;
}

--=-cyJ/P2kZGKSKnIpmMnTl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
