Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB73D6B0003
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 19:34:36 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so18819004pfn.3
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 16:34:36 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k63-v6si18389639pge.175.2018.10.08.16.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 16:34:35 -0700 (PDT)
Subject: [mm PATCH] memremap: Fix reference count for pgmap in
 devm_memremap_pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 08 Oct 2018 16:34:33 -0700
Message-ID: <20181008233404.1909.37302.stgit@localhost.localdomain>
In-Reply-To: <CAPcyv4jX5WYmMYzGCBrnaqT7tqHGSVPwm7Dpi-XpuM9ns84+0w@mail.gmail.com>
References: <CAPcyv4jX5WYmMYzGCBrnaqT7tqHGSVPwm7Dpi-XpuM9ns84+0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, dan.j.williams@intel.com
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, jglisse@redhat.com, alexander.h.duyck@linux.intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

In the earlier patch "mm: defer ZONE_DEVICE page initialization to the
point where we init pgmap" I had overlooked the reference count that was
being held per page on the pgmap. As a result on running the ndctl test
"create.sh" we would call into devm_memremap_pages_release and encounter
the following percpu reference count error and hang:
  WARNING: CPU: 30 PID: 0 at lib/percpu-refcount.c:155
  percpu_ref_switch_to_atomic_rcu+0xf3/0x120

This patch addresses that by performing an update for all of the device
PFNs in a single call. In my testing this seems to resolve the issue while
still allowing us to retain the improvements seen in memory initialization.

Reported-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 kernel/memremap.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6ec81e0d7a33..9eced2cc9f94 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -218,6 +218,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 				align_start >> PAGE_SHIFT,
 				align_size >> PAGE_SHIFT, pgmap);
+	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 
 	devm_add_action(dev, devm_memremap_pages_release, pgmap);
 
