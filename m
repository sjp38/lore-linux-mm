Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 434836B0006
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 19:51:50 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id l131so9489971pga.2
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 16:51:50 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x15-v6si21980538pll.41.2018.11.13.16.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 16:51:49 -0800 (PST)
From: "Isaac J. Manjarres" <isaacm@codeaurora.org>
Subject: [PATCH] mm/usercopy: Use memory range to be accessed for wraparound check
Date: Tue, 13 Nov 2018 16:51:26 -0800
Message-Id: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, crecklin@redhat.com
Cc: "Isaac J. Manjarres" <isaacm@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, psodagud@codeaurora.org, tsoni@codeaurora.org, stable@vger.kernel.org

Currently, when checking to see if accessing n bytes starting at
address "ptr" will cause a wraparound in the memory addresses,
the check in check_bogus_address() adds an extra byte, which is
incorrect, as the range of addresses that will be accessed is
[ptr, ptr + (n - 1)].

This can lead to incorrectly detecting a wraparound in the
memory address, when trying to read 4 KB from memory that is
mapped to the the last possible page in the virtual address
space, when in fact, accessing that range of memory would not
cause a wraparound to occur.

Use the memory range that will actually be accessed when
considering if accessing a certain amount of bytes will cause
the memory address to wrap around.

Change-Id: I2563a5988e41122727ede17180f365e999b953e6
Fixes: f5509cc18daa ("mm: Hardened usercopy")
Co-Developed-by: Prasad Sodagudi <psodagud@codeaurora.org>
Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
Signed-off-by: Isaac J. Manjarres <isaacm@codeaurora.org>
Cc: stable@vger.kernel.org
---
 mm/usercopy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 852eb4e..0293645 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -151,7 +151,7 @@ static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
 				       bool to_user)
 {
 	/* Reject if object wraps past end of memory. */
-	if (ptr + n < ptr)
+	if (ptr + (n - 1) < ptr)
 		usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
 
 	/* Reject if NULL or ZERO-allocation. */
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
