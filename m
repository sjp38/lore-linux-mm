Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB2C6B0261
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:37:08 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so6120685pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:37:08 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id cg6si1517230pad.123.2015.09.22.03.37.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 03:37:07 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH v2 12/12] ARCv2: Add a DT which enables THP
Date: Tue, 22 Sep 2015 16:04:56 +0530
Message-ID: <1442918096-17454-13-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

* Enable THP at bootup
* More than 512M RAM (kernel auto-disabled THP for smaller systems)

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/boot/dts/hs_thp.dts | 59 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 arch/arc/boot/dts/hs_thp.dts

diff --git a/arch/arc/boot/dts/hs_thp.dts b/arch/arc/boot/dts/hs_thp.dts
new file mode 100644
index 000000000000..818a8c968330
--- /dev/null
+++ b/arch/arc/boot/dts/hs_thp.dts
@@ -0,0 +1,59 @@
+/*
+ * Copyright (C) 2015 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+/dts-v1/;
+
+/include/ "skeleton.dtsi"
+
+/ {
+	compatible = "snps,nsim_hs";
+	interrupt-parent = <&core_intc>;
+
+	chosen {
+		bootargs = "earlycon=arc_uart,mmio32,0xc0fc1000,115200n8 console=ttyARC0,115200n8 transparent_hugepage=always";
+	};
+
+	aliases {
+		serial0 = &arcuart0;
+	};
+
+	memory {
+		device_type = "memory";
+		/* reg = <0x00000000 0x28000000>; */
+		reg = <0x00000000 0x40000000>;
+	};
+
+	fpga {
+		compatible = "simple-bus";
+		#address-cells = <1>;
+		#size-cells = <1>;
+
+		/* child and parent address space 1:1 mapped */
+		ranges;
+
+		core_intc: core-interrupt-controller {
+			compatible = "snps,archs-intc";
+			interrupt-controller;
+			#interrupt-cells = <1>;
+		};
+
+		arcuart0: serial@c0fc1000 {
+			compatible = "snps,arc-uart";
+			reg = <0xc0fc1000 0x100>;
+			interrupts = <24>;
+			clock-frequency = <80000000>;
+			current-speed = <115200>;
+			status = "okay";
+		};
+
+		arcpct0: pct {
+			compatible = "snps,archs-pct";
+			#interrupt-cells = <1>;
+			interrupts = <20>;
+		};
+	};
+};
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
