Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F9C96B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 00:28:16 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so1322539rvb.26
        for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:28:14 -0800 (PST)
Date: Fri, 16 Jan 2009 14:28:04 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Remove needless flush_dcache_page call
Message-ID: <20090116052804.GA18737@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: npiggin@suse.de, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Now, Anyone don't maintain cramfs.
I don't know who is maintain romfs. so I send this patch to linux-mm, 
lkml, linux-dev. 

I am not sure my thought is right. 

When readpage is called, page with argument in readpage is just new 
allocated because kernel can't find that page in page cache. 

At this time, any user process can't map the page to their address space. 
so, I think D-cache aliasing probelm never occur. 

It make sense ?

---
diff --git a/arch/arm/mach-integrator/clock.h b/arch/arm/mach-integrator/clock.h
deleted file mode 100644
index e69de29..0000000
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index a07338d..40c8b84 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -492,7 +492,6 @@ static int cramfs_readpage(struct file *file, struct page * page)
 		pgdata = kmap(page);
 	memset(pgdata + bytes_filled, 0, PAGE_CACHE_SIZE - bytes_filled);
 	kunmap(page);
-	flush_dcache_page(page);
 	SetPageUptodate(page);
 	unlock_page(page);
 	return 0;
diff --git a/fs/romfs/inode.c b/fs/romfs/inode.c
index 98a232f..d008262 100644
--- a/fs/romfs/inode.c
+++ b/fs/romfs/inode.c
@@ -454,7 +454,6 @@ romfs_readpage(struct file *file, struct page * page)
 
 	if (!result)
 		SetPageUptodate(page);
-	flush_dcache_page(page);
 
 	unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
