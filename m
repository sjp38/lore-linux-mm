Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 5163B6B00A2
	for <linux-mm@kvack.org>; Tue, 14 May 2013 07:49:50 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so361156pbc.4
        for <linux-mm@kvack.org>; Tue, 14 May 2013 04:49:49 -0700 (PDT)
Message-ID: <519224D8.5090704@gmail.com>
Date: Tue, 14 May 2013 19:49:44 +0800
From: majianpeng <majianpeng@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm/kmemleak.c: Use list_for_each_entry_safe to reconstruct
 function scan_gray_list
Content-Type: multipart/mixed;
 boundary="------------020009070502010607090301"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------020009070502010607090301
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Signed-off-by: Jianpeng Ma <majianpeng@gmail.com>
---
 mm/kmemleak.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index b1525db..f0ece93 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1225,22 +1225,16 @@ static void scan_gray_list(void)
      * from inside the loop. The kmemleak objects cannot be freed from
      * outside the loop because their use_count was incremented.
      */
-    object = list_entry(gray_list.next, typeof(*object), gray_list);
-    while (&object->gray_list != &gray_list) {
+    list_for_each_entry_safe(object, tmp, &gray_list, gray_list) {
         cond_resched();
 
         /* may add new objects to the list */
         if (!scan_should_stop())
             scan_object(object);
 
-        tmp = list_entry(object->gray_list.next, typeof(*object),
-                 gray_list);
-
         /* remove the object from the list and release it */
         list_del(&object->gray_list);
         put_object(object);
-
-        object = tmp;
     }
     WARN_ON(!list_empty(&gray_list));
 }
-- 
1.8.3.rc1.44.gb387c77


--------------020009070502010607090301
Content-Type: text/x-patch;
 name="0002-mm-kmemleak.c-Use-list_for_each_entry_safe-to-recons.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-mm-kmemleak.c-Use-list_for_each_entry_safe-to-recons.pa";
 filename*1="tch"


--------------020009070502010607090301--
