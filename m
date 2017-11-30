Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E22C46B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 15:47:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y23so4558263wra.16
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:47:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k82si3526745wmf.103.2017.11.30.12.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 12:47:38 -0800 (PST)
Date: Thu, 30 Nov 2017 12:47:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-Id: <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
In-Reply-To: <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
	<20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
	<20171130004252.GR4094@dastard>
	<209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 30 Nov 2017 08:54:04 -0500 Waiman Long <longman@redhat.com> wrote:

> > And, from that perspective, the racy shortcut in the proposed patch
> > is wrong, too. Prefetch is fine, but in general shortcutting list
> > empty checks outside the internal lock isn't.
> 
> For the record, I add one more list_empty() check at the beginning of
> list_lru_del() in the patch for 2 purpose:
> 1. it allows the code to bail out early.
> 2. It make sure the cacheline of the list_head entry itself is loaded.
> 
> Other than that, I only add a likely() qualifier to the existing
> list_empty() check within the lock critical region.

But it sounds like Dave thinks that unlocked check should be removed?

How does this adendum look?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix

include prefetch.h, remove unlocked list_empty() test, per Dave

Cc: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Waiman Long <longman@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/list_lru.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -puN mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix mm/list_lru.c
--- a/mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
+++ a/mm/list_lru.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/list_lru.h>
+#include <linux/prefetch.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
@@ -135,13 +136,11 @@ bool list_lru_del(struct list_lru *lru,
 	/*
 	 * Prefetch the neighboring list entries to reduce lock hold time.
 	 */
-	if (unlikely(list_empty(item)))
-		return false;
 	prefetchw(item->prev);
 	prefetchw(item->next);
 
 	spin_lock(&nlru->lock);
-	if (likely(!list_empty(item))) {
+	if (!list_empty(item)) {
 		l = list_lru_from_kmem(nlru, item);
 		list_del_init(item);
 		l->nr_items--;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
