Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id B57CA6B068F
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:39 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id b5-v6so4294625otf.8
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t92-v6si1324626otb.227.2018.05.11.12.08.38
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:08:38 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 12/40] mm: export symbol mmput_async
Date: Fri, 11 May 2018 20:06:13 +0100
Message-Id: <20180511190641.23008-13-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, akpm@linux-foundation.org

In some cases releasing a mm bound to a device might invoke an exit
handler, that takes a lock already held by the function calling mmput().
This is the case for VFIO, which needs to call mmput_async to avoid a
deadlock. Other drivers using SVA might follow. Since they can be built as
modules, export the mmput_async symbol.

Cc: akpm@linux-foundation.org
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 kernel/fork.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index 1062f7450e97..bf05d188c8de 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -999,6 +999,7 @@ void mmput_async(struct mm_struct *mm)
 		schedule_work(&mm->async_put_work);
 	}
 }
+EXPORT_SYMBOL_GPL(mmput_async);
 #endif
 
 /**
-- 
2.17.0
