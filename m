Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 783BC6B0071
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:27 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so397078bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:26 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 7/7] net,9p: use new hashtable implementation
Date: Fri,  3 Aug 2012 16:23:08 +0200
Message-Id: <1344003788-1417-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Switch 9p error table to use the new hashtable implementation. This reduces the amount of
generic unrelated code in 9p.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/9p/error.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/9p/error.c b/net/9p/error.c
index 2ab2de7..f1037db 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -34,7 +34,7 @@
 #include <linux/jhash.h>
 #include <linux/errno.h>
 #include <net/9p/9p.h>
-
+#include <linux/hashtable.h>
 /**
  * struct errormap - map string errors from Plan 9 to Linux numeric ids
  * @name: string sent over 9P
@@ -50,8 +50,8 @@ struct errormap {
 	struct hlist_node list;
 };
 
-#define ERRHASHSZ		32
-static struct hlist_head hash_errmap[ERRHASHSZ];
+#define ERRHASHSZ 5
+DEFINE_STATIC_HASHTABLE(hash_errmap, ERRHASHSZ);
 
 /* FixMe - reduce to a reasonable size */
 static struct errormap errmap[] = {
@@ -196,15 +196,14 @@ int p9_error_init(void)
 	int bucket;
 
 	/* initialize hash table */
-	for (bucket = 0; bucket < ERRHASHSZ; bucket++)
-		INIT_HLIST_HEAD(&hash_errmap[bucket]);
+	hash_init(&hash_errmap, ERRHASHSZ);
 
 	/* load initial error map into hash table */
 	for (c = errmap; c->name != NULL; c++) {
 		c->namelen = strlen(c->name);
-		bucket = jhash(c->name, c->namelen, 0) % ERRHASHSZ;
+		bucket = jhash(c->name, c->namelen, 0);
 		INIT_HLIST_NODE(&c->list);
-		hlist_add_head(&c->list, &hash_errmap[bucket]);
+		hash_add(&hash_errmap, &c->list, bucket);
 	}
 
 	return 1;
@@ -228,8 +227,8 @@ int p9_errstr2errno(char *errstr, int len)
 	errno = 0;
 	p = NULL;
 	c = NULL;
-	bucket = jhash(errstr, len, 0) % ERRHASHSZ;
-	hlist_for_each_entry(c, p, &hash_errmap[bucket], list) {
+	bucket = jhash(errstr, len, 0);
+	hash_for_each_possible(&hash_errmap, p, c, list, bucket) {
 		if (c->namelen == len && !memcmp(c->name, errstr, len)) {
 			errno = c->val;
 			break;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
