Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B909144059E
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:39:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so1884746wjy.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:39:34 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id f127si6711012wmg.72.2017.02.09.08.39.33
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 08:39:33 -0800 (PST)
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 5/8] ARM: sun8i: a33: Add shared display memory pool
Date: Thu,  9 Feb 2017 17:39:19 +0100
Message-Id: <cbbbc887fcebed08f60c5424c8cbd65a3467ce96.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

The memory buffers might need to be allocated and shared from both the
scanout and the GPU.

Create a memory region reserved for their own usage so that each can
allocate from it, and get the informations on the region that is going to
be used (size and offset).

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun8i-a33.dtsi | 17 +++++++++++++++++
 1 file changed, 17 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/sun8i-a33.dtsi b/arch/arm/boot/dts/sun8i-a33.dtsi
index 5a9ba43ccb07..043b1b017276 100644
--- a/arch/arm/boot/dts/sun8i-a33.dtsi
+++ b/arch/arm/boot/dts/sun8i-a33.dtsi
@@ -97,6 +97,7 @@
 	de: display-engine {
 		compatible = "allwinner,sun8i-a33-display-engine";
 		allwinner,pipelines = <&fe0>;
+		memory-region = <&display_pool>;
 		status = "disabled";
 	};
 
@@ -104,6 +105,18 @@
 		reg = <0x40000000 0x80000000>;
 	};
 
+	reserved-memory {
+		#address-cells = <1>;
+		#size-cells = <1>;
+		ranges;
+
+		display_pool: cma {
+			compatible = "shared-dma-pool";
+			size = <0x1000000>;
+			reusable;
+		};
+	};
+
 	soc@01c00000 {
 		tcon0: lcd-controller@01c0c000 {
 			compatible = "allwinner,sun8i-a33-tcon";
@@ -267,6 +280,10 @@
 	compatible = "allwinner,sun8i-a33-ccu";
 };
 
+&mali {
+	memory-region = <&display_pool>;
+};
+
 &pio {
 	compatible = "allwinner,sun8i-a33-pinctrl";
 	interrupts = <GIC_SPI 15 IRQ_TYPE_LEVEL_HIGH>,
-- 
git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
