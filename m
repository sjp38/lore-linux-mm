Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4162A6B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 18:57:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l13so22239932qtc.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 15:57:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r190si1798373qkf.190.2017.08.08.15.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 15:57:24 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/mmu_notifier: fix deadlock from typo vm_lock_anon_vma()
Date: Tue,  8 Aug 2017 18:57:19 -0400
Message-Id: <20170808225719.20723-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Davidlohr Bueso <dbueso@suse.de>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Fix typo introduced by 0c67e6038580e343bd5af12b7ac6548634f05f0d
which result in dead lock when mm_take_all_locks() is call (only
user being mmu_notifier at this time)

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Davidlohr Bueso <dbueso@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 74abfd382478..2d906a8f67ac 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3314,7 +3314,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->rb_root.rb_root.rb_node)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->root->rb_root.rb_root.rb_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
