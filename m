Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8DD6C6B00EA
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:45:05 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so6436715wgb.26
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 08:45:03 -0700 (PDT)
Date: Wed, 18 Apr 2012 18:44:48 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] kmemleak: do not leak object after tree insertion error (v3)
Message-ID: <20120418154448.GA3617@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

 [PATCH] kmemleak: do not leak object after tree insertion error

 In case when tree insertion fails due to already existing object
 error, pointer to allocated object gets lost because of overwrite
 with lookup_object() return. Free allocated object before object
 lookup. 

 Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 mm/kmemleak.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 45eb621..5f05993 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -578,6 +578,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	if (node != &object->tree_node) {
 		kmemleak_stop("Cannot insert 0x%lx into the object search tree "
 			      "(already existing)\n", ptr);
+		kmem_cache_free(object_cache, object);
 		object = lookup_object(ptr, 1);
 		spin_lock(&object->lock);
 		dump_object_info(object);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
