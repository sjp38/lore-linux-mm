Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAE75C43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:27:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D5AF206B6
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:27:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LvkZsu5l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D5AF206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0F68E011C; Sat,  5 Jan 2019 10:27:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C910E8E00F9; Sat,  5 Jan 2019 10:27:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D9B8E011C; Sat,  5 Jan 2019 10:27:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90F0F8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 10:27:52 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w19so47907513qto.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 07:27:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=3cKLJllDG2sKIkbak+RNsHy89gqGRx4p3ljcIfv8jaA=;
        b=INYvRhWe5a8s0pgCR4mGTKWk9xanlCVbrh1fqHFfT4Yhjf+wvcpzMWt0tBS0Ex3gD/
         2WiPZleTCpEp+mPQyLCrOFSsasi8aAXq4CwXcWiG7c907/5z6L5GMKNfzpzKRoELlpoP
         BoQkJo38beWJww4pTjjmf1TT1G+eXRBQans4hgVYT7KqyzzpESDVyM+2a7xOMlj2FEae
         +b/9ZE1ixTp08QQ3IUv5oVIlyUD+5EpQJ7CBnim7JyGDsxIbrjKE/MiiOWWTyXNq21XB
         QeJtBC1uegzn9oCpjz9cRPlSLS3f4aKN/yLXjLNIvAbbPzGNQ3dyXHXRBsQErJvnXbMc
         y3tA==
X-Gm-Message-State: AJcUukcNIB8I9314j9IJhm/W6WdjmAf8ss3OMuMgt6CrkuEfzXW0WSXe
	WdpIj3kmjtZW8FmQRP8YfUtaF6pjuwxJq6q9tGWY0OvdpGXD1ltT2Bgowq4JQzNujOmybKUX/2V
	vJF3dBktnjy700cPLbHYa9UARGqLyEX7B47NnB4s5ho2jHNknm9vlfKYuy1DIjrE=
X-Received: by 2002:aed:3084:: with SMTP id 4mr53114789qtf.30.1546702072223;
        Sat, 05 Jan 2019 07:27:52 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VnQUoo0eX0g80pXqrVlWRxxdRcEKKVVxdtjy9ibYExcwot0Of5V3C0h6jHnBKGvyenKAvZ
X-Received: by 2002:aed:3084:: with SMTP id 4mr53114763qtf.30.1546702071435;
        Sat, 05 Jan 2019 07:27:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546702071; cv=none;
        d=google.com; s=arc-20160816;
        b=QaUdCMFVMk7GdKhspQB8ukkfqBzLYX3ZE9sdC4F5b78oOnIObHpvm7z6VDHm6icwKC
         aNHs7vhAtaqftjePU7jexMHYtsKYAPZzc25yy55u54raeOo3X/oYwLWoNXQ1Aj9iYK+x
         kprmCJXTYrNa64yvYuZa29L8pi+Nu6JEMwk987QbCgB7anYiA7IwawqC5zpQ6ahcwn9j
         wvl+JnnM4jmKZuG0qlG2LZpPRZ6VA62Tl9tiMJUgwk+y9kooU92QTzgyzjjdDW9Ep0D0
         5wndla09bRe4tvnFZppggqN66klAm6+OFHeNYo8IUTW+vvWCz7ApPX6YuJAXrb7mxXfu
         Jdcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=3cKLJllDG2sKIkbak+RNsHy89gqGRx4p3ljcIfv8jaA=;
        b=Ixdnv7icGTJTOjW0bDzsdjPrD5JFaoZ1zW+R/hnXzeBQEjNtS8hvy7Ns2PjdfKJOrZ
         xSsWbbmIa4NDVdcBYWZsMOrCrEBujRH+mmvO2dm1kiXVohIStzkFq5+SGpbAsa8mV6Xa
         kac8IJ97KMBgoktUpMTB8AXxojM+SsZo7Q4UfFnP0SObpdMRLBDc8IGS2h/vPQ5wxHhg
         +R5XL6hEZvn+ao/M0f1O6b4Ol8Ih+9VpLo5w42yyiL6RHj/i4UxcJAHhbF1nAgn/DxBm
         LhWTdw8euHCPfSBT7uJ1GsF1PjTKVxo4LWk5BeeUB8jFExEFqyfJDDHREM2bDWSfNxrt
         MQ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=LvkZsu5l;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l45si704895qtc.21.2019.01.05.07.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 07:27:51 -0800 (PST)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=LvkZsu5l;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 0345422070;
	Sat,  5 Jan 2019 10:27:51 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Sat, 05 Jan 2019 10:27:51 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:message-id:mime-version:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=3cKLJl
	lDG2sKIkbak+RNsHy89gqGRx4p3ljcIfv8jaA=; b=LvkZsu5l81Lz0b0bayvZqz
	nq/N0mTHaFE18YmVkJzBFMnLgsVoCkqpPFKRRGlRdYzzbdg4pczJnnK3wLkmBaLa
	6Ser2bM+od9p1nZASbjbb3kbi7MxIDAzM8BLzopdDHBVqbP4IyiyYXYZrL5D5fEj
	KelGO9b4yxPiks4pbiWF3U4vj1WKO/JXbGZF61vH4eGmNm7hEPJT82/dcMXciwKc
	SgdSGQbnet3tEmIUGXQOJ3LSCTPWoEWe50yho+72t581WqVHJjGMqmVfL7HGj02J
	FEY70gPxQhtS/RAjcSdAx626zCjWk78XEumpTWiAOo32UsYhATJfAg4nabmgH/Zw
	==
X-ME-Sender: <xms:9cwwXEgwZeZHACbY7xWpJACkk2zbooQE8N5pJwSJoZLiimYiI9O1fw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrvdefgdejkeculddtuddrgedtkedrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucenucfjughrpefuvffhfffkgggtgfesthekredttd
    dtlfenucfhrhhomhepoehgrhgvghhkhheslhhinhhugihfohhunhgurghtihhonhdrohhr
    gheqnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepudekkedrkeelrddufe
    ehrdekjeenucfrrghrrghmpehmrghilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhm
    necuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:9cwwXEeMrDF386qcR2ZeogfJFmWEp6FBRe8ad5j1AqJvxQNdmH9M9Q>
    <xmx:9cwwXJnY9pxT-CWXWg1JANVHsiBdlCiWmjsPXs7kIywh-tOVqM4GTw>
    <xmx:9cwwXAzCxica6shsBfuhyIBKbT-Hfsr6tbz01ePbD2p-x37AlV_Nng>
    <xmx:9swwXP1AphqAcAMSVnNVrNdkv9_C-weqHmiYw2H9n-pqC6RxWp4Lmg>
Received: from localhost (unknown [188.89.135.87])
	by mail.messagingengine.com (Postfix) with ESMTPA id D65BEE4802;
	Sat,  5 Jan 2019 10:27:48 -0500 (EST)
Subject: FAILED: patch "[PATCH] x86/speculation/l1tf: Drop the swap storage limit restriction" failed to apply to 4.9-stable tree
To: mhocko@suse.com,ak@linux.intel.com,bp@suse.de,dave.hansen@intel.com,jkosina@suse.cz,linux-mm@kvack.org,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Sat, 05 Jan 2019 16:27:47 +0100
Message-ID: <154670206723833@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105152747.Tn2GCXyfBfPcya1WXDtipSSzjNRIdSaWouV3dR-sU8o@z>


The patch below does not apply to the 4.9-stable tree.
If someone wants it applied there, or to any other stable or longterm
tree, then please email the backport, including the original git commit
id to <stable@vger.kernel.org>.

thanks,

greg k-h

------------------ original commit in Linus's tree ------------------

From 5b5e4d623ec8a34689df98e42d038a3b594d2ff9 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Tue, 13 Nov 2018 19:49:10 +0100
Subject: [PATCH] x86/speculation/l1tf: Drop the swap storage limit restriction
 when l1tf=off

Swap storage is restricted to max_swapfile_size (~16TB on x86_64) whenever
the system is deemed affected by L1TF vulnerability. Even though the limit
is quite high for most deployments it seems to be too restrictive for
deployments which are willing to live with the mitigation disabled.

We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices which is
clearly out of the limit.

Drop the swap restriction when l1tf=off is specified. It also doesn't make
much sense to warn about too much memory for the l1tf mitigation when it is
forcefully disabled by the administrator.

[ tglx: Folded the documentation delta change ]

Fixes: 377eeaa8e11f ("x86/speculation/l1tf: Limit swap file size to MAX_PA/2")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Jiri Kosina <jkosina@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: <linux-mm@kvack.org>
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181113184910.26697-1-mhocko@kernel.org

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 05a252e5178d..835e422572eb 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2095,6 +2095,9 @@
 			off
 				Disables hypervisor mitigations and doesn't
 				emit any warnings.
+				It also drops the swap size and available
+				RAM limit restriction on both hypervisor and
+				bare metal.
 
 			Default is 'flush'.
 
diff --git a/Documentation/admin-guide/l1tf.rst b/Documentation/admin-guide/l1tf.rst
index b85dd80510b0..9af977384168 100644
--- a/Documentation/admin-guide/l1tf.rst
+++ b/Documentation/admin-guide/l1tf.rst
@@ -405,6 +405,9 @@ time with the option "l1tf=". The valid arguments for this option are:
 
   off		Disables hypervisor mitigations and doesn't emit any
 		warnings.
+		It also drops the swap size and available RAM limit restrictions
+		on both hypervisor and bare metal.
+
   ============  =============================================================
 
 The default is 'flush'. For details about L1D flushing see :ref:`l1d_flush`.
@@ -576,7 +579,8 @@ Default mitigations
   The kernel default mitigations for vulnerable processors are:
 
   - PTE inversion to protect against malicious user space. This is done
-    unconditionally and cannot be controlled.
+    unconditionally and cannot be controlled. The swap storage is limited
+    to ~16TB.
 
   - L1D conditional flushing on VMENTER when EPT is enabled for
     a guest.
diff --git a/arch/x86/kernel/cpu/bugs.c b/arch/x86/kernel/cpu/bugs.c
index a68b32cb845a..58689ac64440 100644
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -1002,7 +1002,8 @@ static void __init l1tf_select_mitigation(void)
 #endif
 
 	half_pa = (u64)l1tf_pfn_limit() << PAGE_SHIFT;
-	if (e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
+	if (l1tf_mitigation != L1TF_MITIGATION_OFF &&
+			e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
 		pr_warn("System has more than MAX_PA/2 memory. L1TF mitigation not effective.\n");
 		pr_info("You may make it effective by booting the kernel with mem=%llu parameter.\n",
 				half_pa);
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index ef99f3892e1f..427a955a2cf2 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -931,7 +931,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*

