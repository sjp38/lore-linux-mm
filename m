Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id EE2DE6B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:18:48 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2301825lbi.37
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:18:48 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [185.26.127.97])
        by mx.google.com with ESMTPS id h7si6222914lae.93.2014.10.24.03.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:18:46 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH v2 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
Date: Fri, 24 Oct 2014 13:18:39 +0300
Message-Id: <1414145922-26042-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
In-Reply-To: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>

If activation of the CMA area fails its mutex won't be initialized,
leading to an oops at allocation time when trying to lock the mutex. Fix
this by setting the cma area count field to 0 when activation fails,
leading to allocation returning NULL immediately.

Cc: <stable@vger.kernel.org>  # v3.17
Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
 mm/cma.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/cma.c b/mm/cma.c
index 963bc4add9af..5aa1a6f74dec 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -124,6 +124,7 @@ static int __init cma_activate_area(struct cma *cma)
 
 err:
 	kfree(cma->bitmap);
+	cma->count = 0;
 	return -EINVAL;
 }
 
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
