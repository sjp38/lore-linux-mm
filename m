Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4O81fdT6664222
	for <linux-mm@kvack.org>; Thu, 24 May 2007 18:01:41 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4O83Uns131232
	for <linux-mm@kvack.org>; Thu, 24 May 2007 18:03:33 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4O7xvBB013558
	for <linux-mm@kvack.org>; Thu, 24 May 2007 17:59:57 +1000
Message-ID: <465545FB.2080801@linux.vnet.ibm.com>
Date: Thu, 24 May 2007 13:29:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] Per-container pages reclamation
References: <461A3010.90403@sw.ru> <461A397A.8080609@sw.ru> <464C3D0E.3010603@linux.vnet.ibm.com> <4651B794.4040302@sw.ru>
In-Reply-To: <4651B794.4040302@sw.ru>
Content-Type: multipart/mixed;
 boundary="------------040409070904020008050306"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Paul Menage <menage@google.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, Balbir Singh <balbir@in.ibm.com>, devel@openvz.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kirill Korotaev <dev@sw.ru>, Chandra Seetharaman <sekharan@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Rohit Seth <rohitseth@google.com>, Linux Containers <containers@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040409070904020008050306
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Pavel Emelianov wrote:
>> Index: linux-2.6.20/mm/rss_container.c
>> ===================================================================
>> --- linux-2.6.20.orig/mm/rss_container.c	2007-05-15 05:13:46.000000000 -0700
>> +++ linux-2.6.20/mm/rss_container.c	2007-05-16 20:45:45.000000000 -0700
>> @@ -212,6 +212,7 @@ void container_rss_del(struct page_conta
>>  
>>  	css_put(&rss->css);
>>  	kfree(pc);
>> +	init_page_container(page);
> 
> This hunk is bad.
> See, when the page drops its mapcount to 0 it may be reused right
> after this if it belongs to a file map - another CPU can touch it.
> Thus you're risking to reset the wrong container.
> 
> The main idea if the accounting is that you cannot trust the
> page_container(page) value after the page's mapcount became 0.
> 

Good catch, I'll move the initialization to free_hot_cold_page().
I'm attaching a new patch. I've also gotten rid of the unused
variable page in container_rss_del().

I've compile and boot tested the fix

-- 
	Thanks,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--------------040409070904020008050306
Content-Type: text/x-patch;
 name="rss-fix-lru-race.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rss-fix-lru-race.patch"

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

Index: linux-2.6.20/mm/page_alloc.c
===================================================================
--- linux-2.6.20.orig/mm/page_alloc.c	2007-05-16 10:30:10.000000000 -0700
+++ linux-2.6.20/mm/page_alloc.c	2007-05-24 00:41:00.000000000 -0700
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/rss_container.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -791,6 +792,7 @@ static void fastcall free_hot_cold_page(
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
+	init_page_container(page);
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -1977,6 +1979,7 @@ void __meminit memmap_init_zone(unsigned
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
+		init_page_container(page);
 		SetPageReserved(page);
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
Index: linux-2.6.20/include/linux/rss_container.h
===================================================================
--- linux-2.6.20.orig/include/linux/rss_container.h	2007-05-16 10:31:04.000000000 -0700
+++ linux-2.6.20/include/linux/rss_container.h	2007-05-16 10:32:14.000000000 -0700
@@ -28,6 +28,11 @@ void container_rss_move_lists(struct pag
 unsigned long isolate_pages_in_container(unsigned long nr_to_scan,
 		struct list_head *dst, unsigned long *scanned,
 		struct zone *zone, struct rss_container *, int active);
+static inline void init_page_container(struct page *page)
+{
+	page_container(page) = NULL;
+}
+
 #else
 static inline int container_rss_prepare(struct page *pg,
 		struct vm_area_struct *vma, struct page_container **pc)
@@ -56,6 +61,10 @@ static inline void mm_free_container(str
 {
 }
 
+static inline void init_page_container(struct page *page)
+{
+}
+
 #define isolate_container_pages(nr, dst, scanned, rss, act, zone) ({ BUG(); 0;})
 #define container_rss_move_lists(pg, active) do { } while (0)
 #endif
Index: linux-2.6.20/mm/rss_container.c
===================================================================
--- linux-2.6.20.orig/mm/rss_container.c	2007-05-15 05:13:46.000000000 -0700
+++ linux-2.6.20/mm/rss_container.c	2007-05-24 00:58:43.000000000 -0700
@@ -199,12 +199,9 @@ void container_rss_add(struct page_conta
 
 void container_rss_del(struct page_container *pc)
 {
-	struct page *page;
 	struct rss_container *rss;
 
-	page = pc->page;
 	rss = pc->cnt;
-
 	spin_lock_irq(&rss->res.lock);
 	list_del(&pc->list);
 	res_counter_uncharge_locked(&rss->res, 1);

--------------040409070904020008050306--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
