Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3567E6E0002
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:46:47 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 24/25] lmb: Make lmb_alloc_try_nid() fallback to LMB_ALLOC_ANYWHERE
Date: Mon, 10 May 2010 19:46:04 +1000
Message-Id: <1273484765-29055-24-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484765-29055-23-git-send-email-benh@kernel.crashing.org>
References: <1273484765-29055-1-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-2-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-3-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-4-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-5-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-6-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-7-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-8-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-9-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-10-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-11-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-12-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-13-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-14-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-15-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-16-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-17-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-18-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-19-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-20-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-21-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-22-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-23-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

lmb_alloc_nid() used to fallback to allocating anywhere by using
lmb_alloc() as a fallback.

However, some of my previous patches limit lmb_alloc() to the region
covered by LMB_ALLOC_ACCESSIBLE which is not quite what we want
for lmb_alloc_try_nid().

So we fix it by explicitely using LMB_ALLOC_ANYWHERE.

Not that so far only sparc uses lmb_alloc_nid() and it hasn't been updated
to clamp the accessible zone yet. Thus the temporary "breakage" should have
no effect.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index fd98261..6c38c87 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -531,7 +531,7 @@ phys_addr_t __init lmb_alloc_try_nid(phys_addr_t size, phys_addr_t align, int ni
 
 	if (res)
 		return res;
-	return lmb_alloc(size, align);
+	return lmb_alloc_base(size, align, LMB_ALLOC_ANYWHERE);
 }
 
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
