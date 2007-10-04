Message-Id: <20071004223141.599952000@sgi.com>
References: <20071004223141.413776000@sgi.com>
Date: Thu, 04 Oct 2007 15:31:42 -0700
From: travis@sgi.com
Subject: [PATCH 1/1] ia64: Convert cpu_sibling_map to a per_cpu data array FIX
Content-Disposition: inline; filename=convert-cpu_sibling_map-to-a-per_cpu-data-array-ia64-fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

There are two versions of per_cpu_init() for ia64.  This patch corrects
the problem that one of the versions did not insert the boot cpu
into the cpu sibling and core maps.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/ia64/kernel/setup.c |    8 ++++++++
 arch/ia64/mm/contig.c    |    6 ------
 2 files changed, 8 insertions(+), 6 deletions(-)

--- linux.orig/arch/ia64/kernel/setup.c	2007-10-04 14:38:53.000000000 -0700
+++ linux/arch/ia64/kernel/setup.c	2007-10-04 14:51:46.289055433 -0700
@@ -873,6 +873,14 @@ cpu_init (void)
 	void *cpu_data;
 
 	cpu_data = per_cpu_init();
+	/*
+	 * insert boot cpu into sibling and core mapes
+	 * (must be done after per_cpu area is setup)
+	 */
+	if (smp_processor_id() == 0) {
+		cpu_set(0, per_cpu(cpu_sibling_map, 0));
+		cpu_set(0, cpu_core_map[0]);
+	}
 
 	/*
 	 * We set ar.k3 so that assembly code in MCA handler can compute
--- linux.orig/arch/ia64/mm/contig.c	2007-10-04 14:38:53.000000000 -0700
+++ linux/arch/ia64/mm/contig.c	2007-10-04 14:50:12.699513748 -0700
@@ -212,12 +212,6 @@ per_cpu_init (void)
 			cpu_data += PERCPU_PAGE_SIZE;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 		}
-		/*
-		 * cpu_sibling_map is now a per_cpu variable - it needs to
-		 * be accessed after per_cpu_init() sets up the per_cpu area.
-		 */
-		cpu_set(0, per_cpu(cpu_sibling_map, 0));
-		cpu_set(0, cpu_core_map[0]);
 	}
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
