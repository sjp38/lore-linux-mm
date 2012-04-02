Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DDA4B6B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 02:35:41 -0400 (EDT)
Received: by werj55 with SMTP id j55so1996957wer.14
        for <linux-mm@kvack.org>; Sun, 01 Apr 2012 23:35:40 -0700 (PDT)
Date: Mon, 2 Apr 2012 09:35:32 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] kmemleak: do not leak object after tree insertion error
Message-ID: <20120402063532.GA3464@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

[PATCH] kmemleak: do not leak object after tree insertion error

In case when tree insertion fails due to already existing object
error, pointer to allocated object gets lost due to lookup_object()
overwrite. Free allocated object before lookup happens.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 mm/kmemleak.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 45eb621..d6eec2d 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -260,6 +260,7 @@ static struct early_log
 static int crt_early_log __initdata;
 
 static void kmemleak_disable(void);
+static void __delete_object(struct kmemleak_object *);
 
 /*
  * Print a warning and dump the stack trace.
@@ -576,6 +577,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	 * random memory blocks.
 	 */
 	if (node != &object->tree_node) {
+		__delete_object(object);
 		kmemleak_stop("Cannot insert 0x%lx into the object search tree "
 			      "(already existing)\n", ptr);
 		object = lookup_object(ptr, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
