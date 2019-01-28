Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6098E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:54:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so14351153pfs.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:54:16 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 2si16135342pgj.104.2019.01.28.07.54.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 07:54:15 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.20 214/304] percpu: convert spin_lock_irq to spin_lock_irqsave.
Date: Mon, 28 Jan 2019 10:42:11 -0500
Message-Id: <20190128154341.47195-214-sashal@kernel.org>
In-Reply-To: <20190128154341.47195-1-sashal@kernel.org>
References: <20190128154341.47195-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Dennis Zhou <dennis@kernel.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Dennis Zhou <dennis@kernel.org>

[ Upstream commit 6ab7d47bcbf0144a8cb81536c2cead4cde18acfe ]

>From Michael Cree:
  "Bisection lead to commit b38d08f3181c ("percpu: restructure
   locking") as being the cause of lockups at initial boot on
   the kernel built for generic Alpha.

   On a suggestion by Tejun Heo that:

   So, the only thing I can think of is that it's calling
   spin_unlock_irq() while irq handling isn't set up yet.
   Can you please try the followings?

   1. Convert all spin_[un]lock_irq() to
      spin_lock_irqsave/unlock_irqrestore()."

Fixes: b38d08f3181c ("percpu: restructure locking")
Reported-and-tested-by: Michael Cree <mcree@orcon.net.nz>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Dennis Zhou <dennis@kernel.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/percpu-km.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 38de70ab1a0d..0f643dc2dc65 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -50,6 +50,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
 	struct pcpu_chunk *chunk;
 	struct page *pages;
+	unsigned long flags;
 	int i;
 
 	chunk = pcpu_alloc_chunk(gfp);
@@ -68,9 +69,9 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	chunk->data = pages;
 	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
 
-	spin_lock_irq(&pcpu_lock);
+	spin_lock_irqsave(&pcpu_lock, flags);
 	pcpu_chunk_populated(chunk, 0, nr_pages, false);
-	spin_unlock_irq(&pcpu_lock);
+	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	pcpu_stats_chunk_alloc();
 	trace_percpu_create_chunk(chunk->base_addr);
-- 
2.19.1
