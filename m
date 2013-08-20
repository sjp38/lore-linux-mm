Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5811A6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 00:17:54 -0400 (EDT)
Message-ID: <5212EDB5.4050801@asianux.com>
Date: Tue, 20 Aug 2013 12:16:53 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/zbud.c: consider about the invalid handle value for handle
 related extern functions.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: linux-mm@kvack.org

For handle related extern functions, recommend to consider about
invalid handle value, or can not be easily used by callers.

In our case:

  if need call zbud_alloc/free() multiple times, the caller need additional value to mark current status.
  the caller can not continue call zbud_free() multiple times like kfree().
  when call zbud_map(), the caller can not know about whether succeed or not.

And NULL (or 0) should be also treated as invalid handle value, since
the internal implementation has already assumed NULL is an invalid
address.

  e.g. "struct zbud_header *zhdr = NULL;" in function 'zbud_alloc'.

At least, current interface definition still has no bugs, so the common
patch appliers is better to keep compatible with the original interface.

And related maintainers can re-construct interface without considering
the compatibility at a suitable time point, so the interface can be get
additional improvement.

  e.g. for handle's type, "void *" is more commonly used than "unsigned long".
       can find support macros or functions in "include/linux/err.h" for "void *".
       but can not find any support macros or functions for "unsigned long" in "./include" sub directory.

  e.g. for zbud_alloc(), can return a handle directly instead of an error code.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/zbud.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 9451361..b5363ea 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -244,8 +244,8 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * as zbud pool pages.
  *
  * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
- * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
- * a new page.
+ * gfp arguments are invalid, or -ENOMEM if the pool was unable to allocate
+ * a new page, or -NOSPC if no space left, also set invalid value to handle.
  */
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 			unsigned long *handle)
@@ -255,6 +255,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	enum buddy bud;
 	struct page *page;
 
+	*handle = 0;
+
 	if (size <= 0 || gfp & __GFP_HIGHMEM)
 		return -EINVAL;
 	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
@@ -328,6 +330,9 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	struct zbud_header *zhdr;
 	int freechunks;
 
+	if (IS_ERR_OR_NULL((void *)handle))
+		return;
+
 	spin_lock(&pool->lock);
 	zhdr = handle_to_zbud_header(handle);
 
@@ -478,7 +483,8 @@ next:
  * in the handle and could create temporary mappings to make the data
  * accessible to the user.
  *
- * Returns: a pointer to the mapped allocation
+ * Returns: a pointer to the mapped allocation, or an invalid value which can
+ * be checked by IS_ERR_OR_NULL().
  */
 void *zbud_map(struct zbud_pool *pool, unsigned long handle)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
