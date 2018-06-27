Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE076B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:13:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so1401466pfn.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:13:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b23-v6sor1152071pgn.1.2018.06.27.11.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 11:13:56 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] kvm, mm: account shadow page tables to kmemcg
Date: Wed, 27 Jun 2018 11:13:49 -0700
Message-Id: <20180627181349.149778-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

The size of kvm's shadow page tables corresponds to the size of the
guest virtual machines on the system. Large VMs can spend a significant
amount of memory as shadow page tables which can not be left as system
memory overhead. So, account shadow page tables to the kmemcg.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 arch/x86/kvm/mmu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index d594690d8b95..c79a398300f5 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -890,7 +890,7 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
 	if (cache->nobjs >= min)
 		return 0;
 	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
-		page = (void *)__get_free_page(GFP_KERNEL);
+		page = (void *)__get_free_page(GFP_KERNEL|__GFP_ACCOUNT);
 		if (!page)
 			return -ENOMEM;
 		cache->objects[cache->nobjs++] = page;
-- 
2.18.0.rc2.346.g013aa6912e-goog
