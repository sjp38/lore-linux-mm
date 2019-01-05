Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BB47C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:27:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACD46206B6
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:27:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="C4n/lF8T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACD46206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F16E8E011D; Sat,  5 Jan 2019 10:27:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A12D8E00F9; Sat,  5 Jan 2019 10:27:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344B98E011D; Sat,  5 Jan 2019 10:27:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 093678E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 10:27:55 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d31so47896879qtc.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 07:27:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=T42aXqHiwWdcO4VDlqQ7H7Y9dNgNnHUI7XpKr1FV5Bc=;
        b=B/hXkVMgAynncbFbMUw+xtLfW7sZ9jZAAhcvJ37nSSqstwR1PAgaEc8eO6Xj8rpETy
         +AadAZBpehLGgdENiTjlkrakjxp6rwWncVxMoClzlxoeUzEo6nqr9m073bcm4LFqXZGw
         VrFLpFL7+me6w4i2t4xQ+olFX17bkBFRhV6U4Vc3gK/vn26dopaNQlRVBXqnjF9mF4zB
         pS6oAXaFftJ+ZOcZewKfEV4onN8FVrPtpTCbcysxytO9h+hdyUMQI+WThq+MA0WM22Eq
         Rzyr3dkUsGROKUhRUclmtYzJBvOzphgyYDppeqGZ+2XVXZweyvcVYA4u+trbfLiSorEJ
         k4Kw==
X-Gm-Message-State: AA+aEWYyWlbmdoJm5DffhBQlEpogDOEsU0d0oTPu8yfWHwnxiScyYFkq
	Q6hXQVjTagSPrvSl4XWB/6JRvGQh2PJaRTTYIN0D2l+By9JiTmq2DZWgr3E3PT054txwCTACGmp
	XT0p9DOFnO9gKtdMu1hl/qlZT4p432Zgw5RDUOX2foDX/Lz6OYKeTf/YyYKJ93dI=
X-Received: by 2002:aed:33e3:: with SMTP id v90mr53245517qtd.261.1546702074730;
        Sat, 05 Jan 2019 07:27:54 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XPp/NUxrAyg4dXar4XiIE/iAbxN57BhTU5hxOgG5DSuqCvRwklCtfj9VuDjk5/ApCLMaR2
X-Received: by 2002:aed:33e3:: with SMTP id v90mr53245489qtd.261.1546702074132;
        Sat, 05 Jan 2019 07:27:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546702074; cv=none;
        d=google.com; s=arc-20160816;
        b=ubE75GKYyu0J5YkfBOMMkJ0RDN+2dPMQvv0IAu5FVJ+avF4q2XS21uOjqr5Dr0dYEU
         1Gh9PRlYDv5Q6Ojp6Z31/IKvbNs+qxfW7G3PQW+z34EC8lZ1YCfw38IKcd7W61KRASjJ
         B59Qh0vc1oZghoBwyYhHB6koEMG9fKLM9229GTnN2HRZiBt36A8FMCfh4PQVsKk2JZSm
         T8lp819GsbU4RBd43/eaE086Q2MV0Dc4oDPhgjq+WH31ur9PZMCGbwo/aNoMhw9HAHkT
         FAtqevFvVoFtop1Z5aI+QIDHv62Y8jj9leFahY2ljH6SaSHW34oXoVdI+an6hBSMyz+r
         yA1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=T42aXqHiwWdcO4VDlqQ7H7Y9dNgNnHUI7XpKr1FV5Bc=;
        b=V4kafQq26Zluuua8g27B3f7mdpqGikPgIyyZZgV4iktoF5B8vNAML4fAGNGSr+fsRO
         C1U30EzQ8d2xRBXegb2hSHJks18XeBDXRE9fWL66THNGsD1fcR7FZrm/mLhljpnByFyN
         Vm82FzhAHWuGNRRz6PBqQYs1V7JMW7s0gDIiH6UKpd/u6eQCbJNQUEfhOU5o2Xw4XV5X
         ir2DDKdRy2pHvbSuwD1WJbdE7IgDy6ZRZufnZqFcs0QJ3jjoZPiP3EH3R/8C8/paEJmd
         r5Tsu7eWAZ8H4YeMeEEdKSJ5HJKeeddjsjoo6jdPu0+ZkKF1rSMIDMdk9vuEqYjokvR+
         yLVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="C4n/lF8T";
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id d15si132622qkj.41.2019.01.05.07.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 07:27:54 -0800 (PST)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="C4n/lF8T";
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id D6C5621B5A;
	Sat,  5 Jan 2019 10:27:53 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Sat, 05 Jan 2019 10:27:53 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:message-id:mime-version:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=T42aXq
	HiwWdcO4VDlqQ7H7Y9dNgNnHUI7XpKr1FV5Bc=; b=C4n/lF8Tl8mjdFFZE3vLdG
	IbBu3xCNTfGGq/vghpBIoO/Sg+dVQCpGBwTfVarMpoOOi7Iynm4f7axF3ts+JSSm
	9z1u40auNHfAfYzkYPUM4wavPdrcGKGoLuZfl9HUBX+DMRWvUuMMurXarOP5DJY0
	g9oYQnhOtzKOewB2dK8oHSNfpW1hWFy++BmUZZFuedvqULKO24IQq3LajD+H/9kZ
	hBJo8OVHa45QiM+AzoqP96/zWnlX+oGL6FtZQE9zIxuveXoGW/T74oyRE9B5PhAW
	aoH7FhgoNdhvcZ0fdDW48BDw05Xkknv0VWpT08+GhpaIu6cRTt58Wnh818GxuMlA
	==
X-ME-Sender: <xms:-cwwXHe39rGUhv4AdVSDws10iA8H1FEukIkyA8DiY7cXngJ1GMFqBg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrvdefgdejkeculddtuddrgedtkedrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucenucfjughrpefuvffhfffkgggtgfesthekredttd
    dtlfenucfhrhhomhepoehgrhgvghhkhheslhhinhhugihfohhunhgurghtihhonhdrohhr
    gheqnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepudekkedrkeelrddufe
    ehrdekjeenucfrrghrrghmpehmrghilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhm
    necuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:-cwwXAk9NlVehrbk3lKZJToTmZqiqvSGdytPIuGNeeziDR6tE9ufvg>
    <xmx:-cwwXHKoYUqpvELiz5OGJE3nyhme25ufSRVtemnsxXCon4dGzVoU8Q>
    <xmx:-cwwXBSUyNck0I7A5tQU5BM0tI3s_EH8udmUHMg_RJ_hMeu-xLYDXA>
    <xmx:-cwwXJOOi6XC9vWJ5pNu2upjKhZ6XGpf0K4fqiIMpZfl1ftEhvr85g>
Received: from localhost (unknown [188.89.135.87])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2943910087;
	Sat,  5 Jan 2019 10:27:53 -0500 (EST)
Subject: FAILED: patch "[PATCH] x86/speculation/l1tf: Drop the swap storage limit restriction" failed to apply to 4.4-stable tree
To: mhocko@suse.com,ak@linux.intel.com,bp@suse.de,dave.hansen@intel.com,jkosina@suse.cz,linux-mm@kvack.org,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Sat, 05 Jan 2019 16:27:51 +0100
Message-ID: <1546702071210176@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105152751.gUJEh8UweFKSkGMI9_yOYcY6OSzXRX-66Wr0Ipx-hD8@z>


The patch below does not apply to the 4.4-stable tree.
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

