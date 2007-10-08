Received: by fk-out-0910.google.com with SMTP id 18so1348808fkq
        for <linux-mm@kvack.org>; Mon, 08 Oct 2007 08:28:08 -0700 (PDT)
Message-ID: <3d0408630710080828h7ad160dbxf6cbd8513c1ad3e8@mail.gmail.com>
Date: Mon, 8 Oct 2007 23:28:07 +0800
From: "Yan Zheng" <yanzheng@21cn.com>
Subject: [PATCH]fix page release issue in filemap_fault
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi all

find_lock_page increases page's usage count, we should decrease it
before return VM_FAULT_SIGBUS

Signed-off-by: Yan Zheng<yanzheng@21cn.com>
----
diff -ur linux-2.6.23-rc9/mm/filemap.c linux/mm/filemap.c
--- linux-2.6.23-rc9/mm/filemap.c	2007-10-07 15:03:33.000000000 +0800
+++ linux/mm/filemap.c	2007-10-08 23:14:39.000000000 +0800
@@ -1388,6 +1388,7 @@
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (unlikely(vmf->pgoff >= size)) {
 		unlock_page(page);
+		page_cache_release(page);
 		goto outside_data_content;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
