Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9345D6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:36:52 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so5090511igc.12
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:36:52 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id s11si2336512ich.19.2014.07.16.17.36.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 17:36:51 -0700 (PDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so5041809igb.9
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:36:51 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:36:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, writeback: prevent race when calculating dirty limits
Message-ID: <alpine.DEB.2.02.1407161733200.23892@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Setting vm_dirty_bytes and dirty_background_bytes is not protected by any 
serialization.

Therefore, it's possible for either variable to change value after the 
test in global_dirty_limits() to determine whether available_memory needs 
to be initialized or not.

Always ensure that available_memory is properly initialized.

Cc: stable@vger.kernel.org
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page-writeback.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -261,14 +261,11 @@ static unsigned long global_dirtyable_memory(void)
  */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
+	const unsigned long available_memory = global_dirtyable_memory();
 	unsigned long background;
 	unsigned long dirty;
-	unsigned long uninitialized_var(available_memory);
 	struct task_struct *tsk;
 
-	if (!vm_dirty_bytes || !dirty_background_bytes)
-		available_memory = global_dirtyable_memory();
-
 	if (vm_dirty_bytes)
 		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
