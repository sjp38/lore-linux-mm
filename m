Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26D4C6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:02:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t5-v6so3953999pgt.18
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:02:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l27-v6sor283057pfk.134.2018.06.29.07.02.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 07:02:35 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] kvm, mm: account shadow page tables to kmemcg
Date: Fri, 29 Jun 2018 07:02:24 -0700
Message-Id: <20180629140224.205849-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, stable@vger.kernel.org

The size of kvm's shadow page tables corresponds to the size of the
guest virtual machines on the system. Large VMs can spend a significant
amount of memory as shadow page tables which can not be left as system
memory overhead. So, account shadow page tables to the kmemcg.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Peter Feiner <pfeiner@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
---
Changelog since v1:
- replaced (GFP_KERNEL|__GFP_ACCOUNT) with GFP_KERNEL_ACCOUNT

 arch/x86/kvm/mmu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index d594690d8b95..6b8f11521c41 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -890,7 +890,7 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
 	if (cache->nobjs >= min)
 		return 0;
 	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
-		page = (void *)__get_free_page(GFP_KERNEL);
+		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
 		if (!page)
 			return -ENOMEM;
 		cache->objects[cache->nobjs++] = page;
-- 
2.18.0.rc2.346.g013aa6912e-goog
