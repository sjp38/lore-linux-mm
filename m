Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF356B21ED
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 22:16:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l65-v6so287942pge.17
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:16:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id az1-v6si381379plb.456.2018.08.21.19.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 19:16:47 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V4 1/4] kvm: remove redundant reserved page check
Date: Wed, 22 Aug 2018 18:55:37 +0800
Message-Id: <26f79872e78cc643937059003763b5cfc1333167.1534934405.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
References: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

PageReserved() is already checked inside kvm_is_reserved_pfn(),
remove it from kvm_set_pfn_dirty().

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Pankaj Gupta <pagupta@redhat.com>
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
