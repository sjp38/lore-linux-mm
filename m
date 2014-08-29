Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AF9236B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 17:38:13 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1253837pdj.31
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 14:38:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rm10si1816113pab.228.2014.08.29.14.38.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 14:38:12 -0700 (PDT)
Date: Fri, 29 Aug 2014 14:38:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup
Message-Id: <20140829143811.90bfab2a46ccade0f586b369@linux-foundation.org>
In-Reply-To: <20140820150509.4194.24336.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
	<20140820150509.4194.24336.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Rafael Aquini <aquini@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, 20 Aug 2014 19:05:09 +0400 Konstantin Khlebnikov <k.khlebnikov@samsung.com> wrote:

> * move special branch for balloon migraion into migrate_pages
> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> * embed struct balloon_dev_info into struct virtio_balloon
> * cleanup balloon_page_dequeue, kill balloon_page_free

Another testing failure.  Guys, allnoconfig is really fast.

> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -54,58 +54,27 @@
>   * balloon driver as a page book-keeper for its registered balloon devices.
>   */
>  struct balloon_dev_info {
> -	void *balloon_device;		/* balloon device descriptor */
> -	struct address_space *mapping;	/* balloon special page->mapping */
>  	unsigned long isolated_pages;	/* # of isolated pages for migration */
>  	spinlock_t pages_lock;		/* Protection to pages list */
>  	struct list_head pages;		/* Pages enqueued & handled to Host */
> +	int (* migrate_page)(struct balloon_dev_info *, struct page *newpage,
> +			struct page *page, enum migrate_mode mode);
>  };

If CONFIG_MIGRATION=n this gets turned into "NULL" and chaos ensues.  I
think I'll just nuke that #define:

--- a/include/linux/migrate.h~include-linux-migrateh-remove-migratepage-define
+++ a/include/linux/migrate.h
@@ -82,9 +82,6 @@ static inline int migrate_huge_page_move
 	return -ENOSYS;
 }
 
-/* Possible settings for the migrate_page() method in address_operations */
-#define migrate_page NULL
-
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_NUMA_BALANCING
--- a/mm/swap_state.c~include-linux-migrateh-remove-migratepage-define
+++ a/mm/swap_state.c
@@ -28,7 +28,9 @@
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
 	.set_page_dirty	= swap_set_page_dirty,
+#ifdef CONFIG_MIGRATION
 	.migratepage	= migrate_page,
+#endif
 };
 
 static struct backing_dev_info swap_backing_dev_info = {
--- a/mm/shmem.c~include-linux-migrateh-remove-migratepage-define
+++ a/mm/shmem.c
@@ -3075,7 +3075,9 @@ static const struct address_space_operat
 	.write_begin	= shmem_write_begin,
 	.write_end	= shmem_write_end,
 #endif
+#ifdef CONFIG_MIGRATION
 	.migratepage	= migrate_page,
+#endif
 	.error_remove_page = generic_error_remove_page,
 };
 

Our mixture of "migratepage" and "migrate_page" is maddening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
