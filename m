Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8651B6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 21:07:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r83so35052360pfj.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 18:07:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r16sor72008pfb.76.2017.10.05.18.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 18:07:30 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] kvm, mm: account kvm related kmem slabs to kmemcg
Date: Thu,  5 Oct 2017 18:07:24 -0700
Message-Id: <20171006010724.186563-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, x86@kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The kvm slabs can consume a significant amount of system memory
and indeed in our production environment we have observed that
a lot of machines are spending significant amount of memory that
can not be left as system memory overhead. Also the allocations
from these slabs can be triggered directly by user space applications
which has access to kvm and thus a buggy application can leak
such memory. So, these caches should be accounted to kmemcg.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 arch/x86/kvm/mmu.c  | 4 ++--
 virt/kvm/kvm_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index eca30c1eb1d9..87c5db9e644d 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -5475,13 +5475,13 @@ int kvm_mmu_module_init(void)
 
 	pte_list_desc_cache = kmem_cache_create("pte_list_desc",
 					    sizeof(struct pte_list_desc),
-					    0, 0, NULL);
+					    0, SLAB_ACCOUNT, NULL);
 	if (!pte_list_desc_cache)
 		goto nomem;
 
 	mmu_page_header_cache = kmem_cache_create("kvm_mmu_page_header",
 						  sizeof(struct kvm_mmu_page),
-						  0, 0, NULL);
+						  0, SLAB_ACCOUNT, NULL);
 	if (!mmu_page_header_cache)
 		goto nomem;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 9deb5a245b83..3d73299e05f2 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -4010,7 +4010,7 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 	if (!vcpu_align)
 		vcpu_align = __alignof__(struct kvm_vcpu);
 	kvm_vcpu_cache = kmem_cache_create("kvm_vcpu", vcpu_size, vcpu_align,
-					   0, NULL);
+					   SLAB_ACCOUNT, NULL);
 	if (!kvm_vcpu_cache) {
 		r = -ENOMEM;
 		goto out_free_3;
-- 
2.14.2.920.gcf0c67979c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
