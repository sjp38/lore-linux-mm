Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7DD46B000C
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v10-v6so1561067pgs.15
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r15-v6si34776466pgh.88.2018.10.22.13.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:42 -0700 (PDT)
Subject: [PATCH 4/9] dax/kmem: allow PMEM devices to bind to KMEM driver
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:24 -0700
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Message-Id: <20181022201324.EBB64302@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com


Currently, a persistent memory device's mode must be coordinated
with the driver to which it needs to bind.  To change it from the
fsdax to the device-dax driver, you first change the mode of the
device itself.

Instead of adding a new device mode, allow the PMEM mode to also
bind to the KMEM driver.

As I write this, I'm realizing that it might have just been
better to add a new device mode, rather than hijacking the PMEM
eode.  If this is the case, please speak up, NVDIMM folks.  :)

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>

---

 b/drivers/nvdimm/bus.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff -puN drivers/nvdimm/bus.c~dax-kmem-try-again-2018-3-bus-match-override drivers/nvdimm/bus.c
--- a/drivers/nvdimm/bus.c~dax-kmem-try-again-2018-3-bus-match-override	2018-10-22 13:12:22.522930391 -0700
+++ b/drivers/nvdimm/bus.c	2018-10-22 13:12:22.525930391 -0700
@@ -464,11 +464,24 @@ static struct nd_device_driver nd_bus_dr
 static int nvdimm_bus_match(struct device *dev, struct device_driver *drv)
 {
 	struct nd_device_driver *nd_drv = to_nd_device_driver(drv);
+	bool match;
 
 	if (is_nvdimm_bus(dev) && nd_drv == &nd_bus_driver)
 		return true;
 
-	return !!test_bit(to_nd_device_type(dev), &nd_drv->type);
+	match = !!test_bit(to_nd_device_type(dev), &nd_drv->type);
+
+	/*
+	 * We allow PMEM devices to be bound to the KMEM driver.
+	 * Force a match if we detect a PMEM device type but
+	 * a KMEM device driver.
+	 */
+	if (!match &&
+	    (to_nd_device_type(dev) == ND_DEVICE_DAX_PMEM) &&
+	    (nd_drv->type == ND_DRIVER_DAX_KMEM))
+		match = true;
+
+	return match;
 }
 
 static ASYNC_DOMAIN_EXCLUSIVE(nd_async_domain);
_
