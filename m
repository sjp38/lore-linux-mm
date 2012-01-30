Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 074366B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 03:36:49 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so2802545bkb.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 00:36:48 -0800 (PST)
From: Dmitry Antipov <dmitry.antipov@linaro.org>
Subject: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
Date: Mon, 30 Jan 2012 12:37:34 +0400
Message-Id: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org, Dmitry Antipov <dmitry.antipov@linaro.org>

Fix pcpu_alloc() to return ZERO_SIZE_PTR if requested size is 0;
fix free_percpu() to check passed pointer with ZERO_OR_NULL_PTR.

Signed-off-by: Dmitry Antipov <dmitry.antipov@linaro.org>
---
 mm/percpu.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index f47af91..e903a19 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -702,7 +702,8 @@ static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
  * Does GFP_KERNEL allocation.
  *
  * RETURNS:
- * Percpu pointer to the allocated area on success, NULL on failure.
+ * ZERO_SIZE_PTR if @size is zero, percpu pointer to the
+ * allocated area on success or NULL on failure.
  */
 static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 {
@@ -713,7 +714,10 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	unsigned long flags;
 	void __percpu *ptr;
 
-	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
+	if (unlikely(!size))
+		return ZERO_SIZE_PTR;
+
+	if (unlikely(size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "
 		     "percpu allocation\n", size, align);
 		return NULL;
@@ -834,7 +838,8 @@ fail_unlock_mutex:
  * Does GFP_KERNEL allocation.
  *
  * RETURNS:
- * Percpu pointer to the allocated area on success, NULL on failure.
+ * ZERO_SIZE_PTR if @size is zero, percpu pointer to the
+ * allocated area on success, NULL on failure.
  */
 void __percpu *__alloc_percpu(size_t size, size_t align)
 {
@@ -856,7 +861,8 @@ EXPORT_SYMBOL_GPL(__alloc_percpu);
  * Does GFP_KERNEL allocation.
  *
  * RETURNS:
- * Percpu pointer to the allocated area on success, NULL on failure.
+ * ZERO_SIZE_PTR if @size is zero, percpu pointer to the
+ * allocated area on success or NULL on failure.
  */
 void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
 {
@@ -917,7 +923,7 @@ void free_percpu(void __percpu *ptr)
 	unsigned long flags;
 	int off;
 
-	if (!ptr)
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
 		return;
 
 	kmemleak_free_percpu(ptr);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
