Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7D0906B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 12:06:00 -0500 (EST)
Message-ID: <4EF211EC.7090002@oracle.com>
Date: Wed, 21 Dec 2011 11:05:48 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: [PATCH v2] vfs: __read_cache_page should use gfp argument rather
 than GFP_KERNEL
References: <201112210054.46995.rjw@sisk.pl> <CA+55aFzee7ORKzjZ-_PrVy796k2ASyTe_Odz=ji7f1VzToOkKw@mail.gmail.com> <4EF15F42.4070104@oracle.com> <CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com> <alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, jfs-discussion@lists.sourceforge.net, Kernel Testers List <kernel-testers@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Maciej Rutecki <maciej.rutecki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Mickler <florian@mickler.org>, davem@davemloft.net, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

[ updated to remove now-obsolete comment in read_cache_page_gfp()]

lockdep reports a deadlock in jfs because a special inode's rw semaphore
is taken recursively. The mapping's gfp mask is GFP_NOFS, but is not used
when __read_cache_page() calls add_to_page_cache_lru().

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/mm/filemap.c b/mm/filemap.c
index c106d3b..5f0a3c9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1828,7 +1828,7 @@ repeat:
 		page = __page_cache_alloc(gfp | __GFP_COLD);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
-		err = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);
+		err = add_to_page_cache_lru(page, mapping, index, gfp);
 		if (unlikely(err)) {
 			page_cache_release(page);
 			if (err == -EEXIST)
@@ -1925,10 +1925,7 @@ static struct page *wait_on_page_read(struct page *page)
  * @gfp:	the page allocator flags to use if allocating
  *
  * This is the same as "read_mapping_page(mapping, index, NULL)", but with
- * any new page allocations done using the specified allocation flags. Note
- * that the Radix tree operations will still use GFP_KERNEL, so you can't
- * expect to do this atomically or anything like that - but you can pass in
- * other page requirements.
+ * any new page allocations done using the specified allocation flags.
  *
  * If the page does not get brought uptodate, return -EIO.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
