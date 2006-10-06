Subject: [PATCH] mm: D-cache flushing was forgotten 
From: Dmitriy Monakhov <dmonakhov@openvz.org>
Date: Fri, 06 Oct 2006 13:44:50 +0400
Message-ID: <87psd5lqwd.fsf@sw.ru>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, David Miller <davem@davemloft.net>, Dmitriy Monakhov <dmonakhov@openvz.org>
List-ID: <linux-mm.kvack.org>

--=-=-=

Here is a patch that add D-cache flushing  routine
after page was changed. It is forgotten in current code.

David Miller agree with patch.

Signed-off-by: Dmitriy Monakhov <dmonakhov@openvz.org>


--=-=-=
Content-Disposition: inline; filename=diff-buffer-flush-dcache-page

diff --git a/fs/buffer.c b/fs/buffer.c
index 71649ef..b2652aa 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2008,6 +2008,7 @@ static int __block_prepare_write(struct 
 			clear_buffer_new(bh);
 			kaddr = kmap_atomic(page, KM_USER0);
 			memset(kaddr+block_start, 0, bh->b_size);
+			flush_dcache_page(page);
 			kunmap_atomic(kaddr, KM_USER0);
 			set_buffer_uptodate(bh);
 			mark_buffer_dirty(bh);
@@ -2514,6 +2515,7 @@ failed:
 	 */
 	kaddr = kmap_atomic(page, KM_USER0);
 	memset(kaddr, 0, PAGE_CACHE_SIZE);
+	flush_dcache_page(page);
 	kunmap_atomic(kaddr, KM_USER0);
 	SetPageUptodate(page);
 	set_page_dirty(page);

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
