Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 24F9E6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 06:02:51 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id c11so1298927lbj.17
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:02:50 -0700 (PDT)
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
        by mx.google.com with ESMTPS id w1si1212586lbo.10.2014.06.19.03.02.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 03:02:49 -0700 (PDT)
Received: by mail-lb0-f173.google.com with SMTP id s7so1304426lbd.32
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:02:48 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm: percpu: micro-optimize round-to-even
Date: Thu, 19 Jun 2014 12:02:29 +0200
Message-Id: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rasmus Villemoes <linux@rasmusvillemoes.dk>

This change shaves a few bytes off the generated code.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/percpu.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 2ddf9a9..978097f 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -720,8 +720,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	if (unlikely(align < 2))
 		align = 2;
 
-	if (unlikely(size & 1))
-		size++;
+	size += size & 1;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
