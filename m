Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 145F06B6AC0
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 14:25:39 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s27so7439656pgm.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:25:39 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g184si15031204pfb.288.2018.12.03.11.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 11:25:37 -0800 (PST)
Subject: [PATCH RFC 3/3] kvm: Add additional check to determine if a page is
 refcounted
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 03 Dec 2018 11:25:36 -0800
Message-ID: <154386513636.27193.9038916677163713072.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, pbonzini@redhat.com, yi.z.zhang@linux.intel.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

The function kvm_is_refcounted_page is used primarily to determine if KVM
is allowed to take a reference on the page. It was using the PG_reserved
flag to determine this previously, however in the case of DAX the page has
the PG_reserved flag set, but supports pinning by taking a reference on
the page. As such I have updated the check to add a special case for
ZONE_DEVICE pages that have the new support_refcount_pinning flag set.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 virt/kvm/kvm_main.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 5e666df5666d..2e7e9fbb67bf 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -148,8 +148,20 @@ __weak int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 
 bool kvm_is_refcounted_pfn(kvm_pfn_t pfn)
 {
-	if (pfn_valid(pfn))
-		return !PageReserved(pfn_to_page(pfn));
+	if (pfn_valid(pfn)) {
+		struct page *page = pfn_to_page(pfn);
+
+		/*
+		 * The reference count for MMIO pages are not updated.
+		 * Previously this was being tested for with just the
+		 * PageReserved check, however now ZONE_DEVICE pages may
+		 * also allow for the refcount to be updated for the sake
+		 * of pinning the pages so use the additional check provided
+		 * to determine if the reference count on the page can be
+		 * used to pin it.
+		 */
+		return !PageReserved(page) || is_device_pinnable_page(page);
+	}
 
 	return false;
 }
