From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20060505173606.9030.49873.sendpatchset@skynet>
In-Reply-To: <20060505173446.9030.42837.sendpatchset@skynet>
References: <20060505173446.9030.42837.sendpatchset@skynet>
Subject: [PATCH 4/8] ppc64 - Specify amount of kernel memory at boot time
Date: Fri,  5 May 2006 18:36:07 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This patch adds the kernelcore= parameter for ppc64.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.17-rc3-mm1-zonesizing-103_x86coremem/arch/powerpc/kernel/prom.c linux-2.6.17-rc3-mm1-zonesizing-104_ppc64coremem/arch/powerpc/kernel/prom.c
--- linux-2.6.17-rc3-mm1-zonesizing-103_x86coremem/arch/powerpc/kernel/prom.c	2006-05-03 09:41:31.000000000 +0100
+++ linux-2.6.17-rc3-mm1-zonesizing-104_ppc64coremem/arch/powerpc/kernel/prom.c	2006-05-03 09:48:06.000000000 +0100
@@ -1064,6 +1064,15 @@ static int __init early_init_dt_scan_cho
 		}
 	}
 
+	/* Check if ZONE_EASYRCLM should be populated */
+	if (strstr(cmd_line, "kernelcore=")) {
+		unsigned long core_pages;
+		char *opt = strstr(cmd_line, "kernelcore=");
+		opt += 11;
+		core_pages = memparse(opt, &opt) >> PAGE_SHIFT;
+		set_required_kernelcore(core_pages);
+	}
+
 	/* break now */
 	return 1;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.17-rc3-mm1-zonesizing-103_x86coremem/arch/ppc/mm/init.c linux-2.6.17-rc3-mm1-zonesizing-104_ppc64coremem/arch/ppc/mm/init.c
--- linux-2.6.17-rc3-mm1-zonesizing-103_x86coremem/arch/ppc/mm/init.c	2006-05-03 09:42:16.000000000 +0100
+++ linux-2.6.17-rc3-mm1-zonesizing-104_ppc64coremem/arch/ppc/mm/init.c	2006-05-03 09:48:06.000000000 +0100
@@ -213,6 +213,15 @@ void MMU_setup(void)
 		}
 		__max_memory = maxmem;
 	}
+
+	/* Check if ZONE_EASYRCLM should be populated */
+	if (strstr(cmd_line, "kernelcore=")) {
+		unsigned long core_pages;
+		char *opt = strstr(cmd_line, "kernelcore=");
+		opt += 11;
+		core_pages = memparse(opt, &opt) >> PAGE_SHIFT;
+		set_required_kernelcore(core_pages);
+	}
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
