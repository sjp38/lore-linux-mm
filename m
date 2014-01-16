Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id EC5536B003B
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 18:23:36 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so3318610pbb.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:23:36 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id s7si8358843pae.243.2014.01.16.15.23.33
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 15:23:34 -0800 (PST)
From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [RFC PATCH 1/3] Supporting hacks to be able to test slab allocated buffers in place of page_frag without rewriting lots of net code. We make several assumptions here, first that slab allocator is selected. Second, no one is doing get_page or put_page on pages marked PG_slab. Third we allocated all slabs page aligned that we do these calls on.
Date: Thu, 16 Jan 2014 18:17:02 -0500
Message-Id: <1389914224-10453-2-git-send-email-dbanerje@akamai.com>
In-Reply-To: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
References: <1389914224-10453-1-git-send-email-dbanerje@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org
Cc: dbanerje@akamai.com, johunt@akamai.com, jbaron@akamai.com, davem@davemloft.net, linux-mm@kvack.org

---
 include/linux/mm.h |  6 ++++++
 mm/slab.c          |  8 ++++++++
 mm/swap.c          | 13 ++++++++++++-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e0c8528..de21a92 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -398,12 +398,18 @@ static inline void get_huge_page_tail(struct page *page)
 }
 
 extern bool __get_page_tail(struct page *page);
+extern struct page *slabpage_to_headpage(struct page *page);
 
 static inline void get_page(struct page *page)
 {
 	if (unlikely(PageTail(page)))
 		if (likely(__get_page_tail(page)))
 			return;
+
+	//Hack for slab page
+	if (unlikely(page->flags & (1L << PG_slab)))
+		page = slabpage_to_headpage(page);
+
 	/*
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_count.
diff --git a/mm/slab.c b/mm/slab.c
index bd88411..36d5176 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -483,6 +483,14 @@ static inline unsigned int obj_to_index(const struct kmem_cache *cache,
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
 }
 
+struct page *slabpage_to_headpage(struct page *page)
+{
+	//Hack to support get_page/put_page on slabs bigger than a page
+	unsigned int idx = obj_to_index(page->slab_cache, page->slab_page, page_address(page));
+	return virt_to_page(index_to_obj(page->slab_cache, page->slab_page, idx));
+}
+EXPORT_SYMBOL(slabpage_to_headpage);
+
 static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
diff --git a/mm/swap.c b/mm/swap.c
index 9f2225f..94c75bc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -172,9 +172,20 @@ skip_lock_tail:
 	}
 }
 
+extern struct page *slabpage_to_headpage(struct page *page);
+
 void put_page(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
+	if (unlikely(page->flags & (1L << PG_slab))) {
+		struct page *head_page = slabpage_to_headpage(page);
+		//Hack. Assume we have >PAGE_SIZE and aligned slabs, and no one is dumb enough
+		//to do a put_page to 0 on a slab page without meaning to free it from the slab.
+		if (put_page_testzero(head_page)) {
+			get_page(head_page); //restore 1 _count for slab
+			kmem_cache_free(page->slab_cache, page_address(head_page));
+		}
+	}
+	else if (unlikely(PageCompound(page)))
 		put_compound_page(page);
 	else if (put_page_testzero(page))
 		__put_single_page(page);
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
