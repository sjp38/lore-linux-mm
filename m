Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B46D56B007B
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:35 -0400 (EDT)
Received: by wgin8 with SMTP id n8so75273254wgi.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7si2113622wib.9.2015.04.13.03.17.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:21 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/14] x86: mm: Enable deferred memory initialisation on x86-64
Date: Mon, 13 Apr 2015 11:17:02 +0100
Message-Id: <1428920226-18147-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch adds the Kconfig logic to add deferred memory initialisation
to x86-64 if NUMA is enabled. Other architectures should enable on a
case-by-case basis once the users of early_pfn_to_nid are audited and it
is tested.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig |  2 ++
 mm/Kconfig       | 19 +++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca55187..830ad8450bbd 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -32,6 +32,8 @@ config X86
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
+	select ARCH_SUPPORTS_DEFERRED_MEM_INIT if X86_64 && NUMA
+	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
diff --git a/mm/Kconfig b/mm/Kconfig
index a03131b6ba8e..463c7005c3d9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -629,3 +629,22 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+# For architectures that was to support deferred memory initialisation
+config ARCH_SUPPORTS_DEFERRED_MEM_INIT
+	bool
+
+config DEFERRED_MEM_INIT
+	bool "Defer initialisation of memory to kswapd"
+	default n
+	depends on ARCH_SUPPORTS_DEFERRED_MEM_INIT
+	depends on MEMORY_HOTPLUG
+	help
+	  Ordinarily all struct pages are initialised during early boot in a
+	  single thread. On very large machines this can take a considerable
+	  amount of time. If this option is set, large machines will bring up
+	  a small amount of memory at boot and then initialise the rest when
+	  kswapd starts. Boot times are reduced but very early in the lifetime
+	  of the system it will still be busy initialising struct pages. This
+	  has a potential performance impact on processes until kswapd finishes
+	  the initialisation.
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
