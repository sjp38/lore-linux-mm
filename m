Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 39A6C8D0007
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:52 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 54 of 66] transparent hugepage config choice
Message-Id: <a987d47a94fb9c39e540.1288798109@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Allow to choose between the always|madvise default for page faults and
khugepaged at config time. madvise guarantees zero risk of higher memory
footprint for applications (applications using madvise(MADV_HUGEPAGE) won't
risk to use any more memory by backing their virtual regions with hugepages).

Initially set the default to N and don't depend on EMBEDDED.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -303,9 +303,8 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  See Documentation/nommu-mmap.txt for more information.
 
 config TRANSPARENT_HUGEPAGE
-	bool "Transparent Hugepage Support" if EMBEDDED
+	bool "Transparent Hugepage Support"
 	depends on X86 && MMU
-	default y
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
 	  huge tlb transparently to the applications whenever possible.
@@ -316,6 +315,30 @@ config TRANSPARENT_HUGEPAGE
 
 	  If memory constrained on embedded, you may want to say N.
 
+choice
+	prompt "Transparent Hugepage Support sysfs defaults"
+	depends on TRANSPARENT_HUGEPAGE
+	default TRANSPARENT_HUGEPAGE_ALWAYS
+	help
+	  Selects the sysfs defaults for Transparent Hugepage Support.
+
+	config TRANSPARENT_HUGEPAGE_ALWAYS
+		bool "always"
+	help
+	  Enabling Transparent Hugepage always, can increase the
+	  memory footprint of applications without a guaranteed
+	  benefit but it will work automatically for all applications.
+
+	config TRANSPARENT_HUGEPAGE_MADVISE
+		bool "madvise"
+	help
+	  Enabling Transparent Hugepage madvise, will only provide a
+	  performance improvement benefit to the applications using
+	  madvise(MADV_HUGEPAGE) but it won't risk to increase the
+	  memory footprint of applications without a guaranteed
+	  benefit.
+endchoice
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -27,7 +27,12 @@
  * allocations.
  */
 unsigned long transparent_hugepage_flags __read_mostly =
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
 	(1<<TRANSPARENT_HUGEPAGE_FLAG)|
+#endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
+	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
+#endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
