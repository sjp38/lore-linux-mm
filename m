Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23CFF6B000C
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:12:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k2-v6so4708648wrp.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:12:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 126-v6si1220271wmg.214.2018.06.22.08.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 08:12:34 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use locking suffix
Date: Fri, 22 Jun 2018 17:12:20 +0200
Message-Id: <20180622151221.28167-3-bigeasy@linutronix.de>
In-Reply-To: <20180622151221.28167-1-bigeasy@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

shadow_lru_isolate() disables interrupts and acquires a lock. It could
use spin_lock_irq() instead. It also uses local_irq_enable() while it
could use spin_unlock_irq()/xa_unlock_irq().

Use proper suffix for lock/unlock in order to enable/disable interrupts
during release/acquire of a lock.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/workingset.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index ed8151180899..529480c21f93 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -431,7 +431,7 @@ static enum lru_status shadow_lru_isolate(struct list_h=
ead *item,
=20
 	/* Coming from the list, invert the lock order */
 	if (!xa_trylock(&mapping->i_pages)) {
-		spin_unlock(lru_lock);
+		spin_unlock_irq(lru_lock);
 		ret =3D LRU_RETRY;
 		goto out;
 	}
@@ -469,13 +469,11 @@ static enum lru_status shadow_lru_isolate(struct list=
_head *item,
 				 workingset_lookup_update(mapping));
=20
 out_invalid:
-	xa_unlock(&mapping->i_pages);
+	xa_unlock_irq(&mapping->i_pages);
 	ret =3D LRU_REMOVED_RETRY;
 out:
-	local_irq_enable();
 	cond_resched();
-	local_irq_disable();
-	spin_lock(lru_lock);
+	spin_lock_irq(lru_lock);
 	return ret;
 }
=20
--=20
2.18.0
