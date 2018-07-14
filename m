Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13FE76B026B
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:00:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id cf17-v6so13481828plb.2
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:00:12 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a1-v6si13170360pgq.387.2018.07.13.22.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:00:10 -0700 (PDT)
Subject: [PATCH v6 06/13] mm,
 dev_pagemap: Do not clear ->mapping on final put
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 21:50:01 -0700
Message-ID: <153154380137.34503.3754023882460956800.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: stable@vger.kernel.org, Jan Kara <jack@suse.cz>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

MEMORY_DEVICE_FS_DAX relies on typical page semantics whereby ->mapping
is only ever cleared by truncation, not final put.

Without this fix dax pages may forget their mapping association at the
end of every page pin event.

Move this atypical behavior that HMM wants into the HMM ->page_free()
callback.

Cc: <stable@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Fixes: d2c997c0f145 ("fs, dax: use page->mapping...")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    1 -
 mm/hmm.c          |    2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5857267a4af5..62603634a1d2 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -339,7 +339,6 @@ void __put_devmap_managed_page(struct page *page)
 		__ClearPageActive(page);
 		__ClearPageWaiters(page);
 
-		page->mapping = NULL;
 		mem_cgroup_uncharge(page);
 
 		page->pgmap->page_free(page, page->pgmap->data);
diff --git a/mm/hmm.c b/mm/hmm.c
index de7b6bf77201..f9d1d89dec4d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -963,6 +963,8 @@ static void hmm_devmem_free(struct page *page, void *data)
 {
 	struct hmm_devmem *devmem = data;
 
+	page->mapping = NULL;
+
 	devmem->ops->free(devmem, page);
 }
 
