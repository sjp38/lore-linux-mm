Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2172E6B0257
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:00:49 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id p187so107329790oia.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:00:49 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0072.outbound.protection.outlook.com. [104.47.1.72])
        by mx.google.com with ESMTPS id t186si862273oig.51.2016.01.26.07.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:00:48 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH V2 RESEND 2/2] make apply_to_page_range() more robust.
Date: Tue, 26 Jan 2016 16:59:53 +0200
Message-ID: <1453820393-31179-3-git-send-email-mika.penttila@nextfour.com>
In-Reply-To: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
References: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, =?UTF-8?q?Mika=20Penttil=C3=A4?= <mika.penttila@nextfour.com>

From: Mika PenttilA? <mika.penttila@nextfour.com>

Now the arm/arm64 don't trigger this BUG_ON() any more,
but WARN_ON() is here enough to catch buggy callers
but still let potential other !size callers pass with warning.

Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
Reviewed-by: Pekka Enberg <penberg@kernel.org>
Acked-by: David Rientjes <rientjes@google.com>

---
 mm/memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 30991f8..9178ee6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1871,7 +1871,9 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 	unsigned long end = addr + size;
 	int err;
 
-	BUG_ON(addr >= end);
+	if (WARN_ON(addr >= end))
+		return -EINVAL;
+
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
