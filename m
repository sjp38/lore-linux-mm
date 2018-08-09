Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4924C6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 22:14:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so2436917pfb.9
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 19:14:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r59-v6si4628620plb.39.2018.08.08.19.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 19:14:13 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V3 1/4] kvm: remove redundant reserved page check
Date: Thu,  9 Aug 2018 18:52:55 +0800
Message-Id: <d2345e628a697ee17fdd6e360f7a6790caab10d5.1533811181.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

PageReserved() is already checked inside kvm_is_reserved_pfn(),
remove it from kvm_set_pfn_dirty().

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
---
 virt/kvm/kvm_main.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 8b47507f..c44c406 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1690,12 +1690,8 @@ EXPORT_SYMBOL_GPL(kvm_release_pfn_dirty);
 
 void kvm_set_pfn_dirty(kvm_pfn_t pfn)
 {
-	if (!kvm_is_reserved_pfn(pfn)) {
-		struct page *page = pfn_to_page(pfn);
-
-		if (!PageReserved(page))
-			SetPageDirty(page);
-	}
+	if (!kvm_is_reserved_pfn(pfn))
+		SetPageDirty(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_set_pfn_dirty);
 
-- 
2.7.4
