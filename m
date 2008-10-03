From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 1/3] Increase default reserve percpu area
Date: Fri, 03 Oct 2008 08:24:37 -0700
Message-ID: <20081003152459.747408808@quilx.com>
References: <20081003152436.089811999@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_increase_percpu_default
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

SLUB now requires a portion of the per cpu reserve. There are on average
about 70 real slabs on a system (aliases do not count) and each needs 12 bytes
of per cpu space. Thats 840 bytes. In debug mode all slabs will be real slabs
which will make us end up with 150 -> 1800.

Things work fine without this patch but then slub will reduce the percpu reserve
for modules.

Percpu data must be available regardless if modules are in use or not. So get
rid of the #ifdef CONFIG_MODULES.

Make the size of the percpu area dependant on the size of a machine word. That
way we have larger sizes for 64 bit machines. 64 bit machines need more percpu
memory since the pointer and counters may have double the size. Plus there is
lots of memory available on 64 bit.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2008-09-29 13:10:33.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2008-09-29 13:13:21.000000000 -0500
@@ -37,11 +37,7 @@
 extern unsigned int percpu_reserve;
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
 #ifndef PERCPU_AREA_SIZE
-#ifdef CONFIG_MODULES
-#define PERCPU_RESERVE_SIZE	8192
-#else
-#define PERCPU_RESERVE_SIZE	0
-#endif
+#define PERCPU_RESERVE_SIZE	(sizeof(unsigned long) * 2500)
 
 #define PERCPU_AREA_SIZE						\
 	(__per_cpu_end - __per_cpu_start + percpu_reserve)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
