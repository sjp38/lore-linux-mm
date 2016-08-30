Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 983BB6B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:35:18 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id d205so62873646ybh.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:35:18 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id s124si27898449qkh.196.2016.08.30.11.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 11:35:17 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id q11so940534qtb.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:35:16 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Avoid soft lockup due to possible attempt of double locking object's lock in __delete_object
Date: Tue, 30 Aug 2016 14:35:12 -0400
Message-Id: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This fixes a issue in the current locking logic of the function,
__delete_object where we are trying to attempt to lock the passed
object structure's spinlock again after being previously held
elsewhere by the kmemleak code. Fix this by instead of assuming
we are the only one contending for the object's lock their are
possible other users and create two branches, one where we get
the lock when calling spin_trylock_irqsave on the object's lock
and the other when the lock is held else where by kmemleak.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/kmemleak.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 086292f..ad4828f 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -631,12 +631,19 @@ static void __delete_object(struct kmemleak_object *object)
 
 	/*
 	 * Locking here also ensures that the corresponding memory block
-	 * cannot be freed when it is being scanned.
+	 * cannot be freed when it is being scanned. Further more the
+	 * object's lock may have been previously holded by another holder
+	 * in the kmemleak code, therefore attempt to lock the object's lock
+	 * before holding it and unlocking it.
 	 */
-	spin_lock_irqsave(&object->lock, flags);
-	object->flags &= ~OBJECT_ALLOCATED;
-	spin_unlock_irqrestore(&object->lock, flags);
-	put_object(object);
+	if (spin_trylock_irqsave(&object->lock, flags)) {
+		object->flags &= ~OBJECT_ALLOCATED;
+		spin_unlock_irqrestore(&object->lock, flags);
+		put_object(object);
+	} else {
+		object->flags &= ~OBJECT_ALLOCATED;
+		put_object(object);
+	}
 }
 
 /*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
