Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF226B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 11:41:39 -0500 (EST)
Message-Id: <4CFD20370200007800026269@vpn.id2.novell.com>
Date: Mon, 06 Dec 2010 16:41:11 +0000
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (core)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

For those (large) table allocations that come only from lowmem, the
total amount of memory shouldn't really matter.

For vfs_caches_init(), in the same spirit also replace the use of
nr_free_pages() by nr_free_buffer_pages().

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 fs/dcache.c                       |    4 ++--
 init/main.c                       |    5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

--- linux-2.6.37-rc4/fs/dcache.c
+++ 2.6.37-rc4-use-totalhigh_pages/fs/dcache.c
@@ -2474,10 +2474,10 @@ void __init vfs_caches_init(unsigned lon
 {
 	unsigned long reserve;
=20
-	/* Base hash sizes on available memory, with a reserve equal to
+	/* Base hash sizes on available lowmem memory, with a reserve =
equal to
            150% of current kernel size */
=20
-	reserve =3D min((mempages - nr_free_pages()) * 3/2, mempages - 1);
+	reserve =3D min((mempages - nr_free_buffer_pages()) * 3/2, =
mempages - 1);
 	mempages -=3D reserve;
=20
 	names_cachep =3D kmem_cache_create("names_cache", PATH_MAX, 0,
--- linux-2.6.37-rc4/init/main.c
+++ 2.6.37-rc4-use-totalhigh_pages/init/main.c
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/initrd.h>
 #include <linux/bootmem.h>
+#include <linux/highmem.h>
 #include <linux/acpi.h>
 #include <linux/tty.h>
 #include <linux/percpu.h>
@@ -673,13 +674,13 @@ asmlinkage void __init start_kernel(void
 #endif
 	thread_info_cache_init();
 	cred_init();
-	fork_init(totalram_pages);
+	fork_init(totalram_pages - totalhigh_pages);
 	proc_caches_init();
 	buffer_init();
 	key_init();
 	security_init();
 	dbg_late_init();
-	vfs_caches_init(totalram_pages);
+	vfs_caches_init(totalram_pages - totalhigh_pages);
 	signals_init();
 	/* rootfs populating might need page-writeback */
 	page_writeback_init();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
