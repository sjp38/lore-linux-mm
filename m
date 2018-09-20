Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 704DD8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:30:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id h1-v6so341711pld.21
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:30:18 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k8-v6si3030247plt.176.2018.09.20.15.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 15:30:17 -0700 (PDT)
Subject: [PATCH v4 5/5] nvdimm: Schedule device registration on node local
 to the device
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 20 Sep 2018 15:29:57 -0700
Message-ID: <20180920222951.19464.39241.stgit@localhost.localdomain>
In-Reply-To: <20180920215824.19464.8884.stgit@localhost.localdomain>
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

This patch is meant to force the device registration for nvdimm devices to
be closer to the actual device. This is achieved by using either the NUMA
node ID of the region, or of the parent. By doing this we can have
everything above the region based on the region, and everything below the
region based on the nvdimm bus.

One additional change I made is that we hold onto a reference to the parent
while we are going through registration. By doing this we can guarantee we
can complete the registration before we have the parent device removed.

By guaranteeing NUMA locality I see an improvement of as high as 25% for
per-node init of a system with 12TB of persistent memory.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/nvdimm/bus.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 8aae6dcc839f..ca935296d55e 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -487,7 +487,9 @@ static void nd_async_device_register(void *d, async_cookie_t cookie)
 		dev_err(dev, "%s: failed\n", __func__);
 		put_device(dev);
 	}
+
 	put_device(dev);
+	put_device(dev->parent);
 }
 
 static void nd_async_device_unregister(void *d, async_cookie_t cookie)
@@ -504,12 +506,25 @@ static void nd_async_device_unregister(void *d, async_cookie_t cookie)
 
 void __nd_device_register(struct device *dev)
 {
+	int node;
+
 	if (!dev)
 		return;
+
 	dev->bus = &nvdimm_bus_type;
+	get_device(dev->parent);
 	get_device(dev);
-	async_schedule_domain(nd_async_device_register, dev,
-			&nd_async_domain);
+
+	/*
+	 * For a region we can break away from the parent node,
+	 * otherwise for all other devices we just inherit the node from
+	 * the parent.
+	 */
+	node = is_nd_region(dev) ? to_nd_region(dev)->numa_node :
+				   dev_to_node(dev->parent);
+
+	async_schedule_on_domain(nd_async_device_register, dev, node,
+				 &nd_async_domain);
 }
 
 void nd_device_register(struct device *dev)
