Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 803986B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 18:38:04 -0500 (EST)
Date: Tue, 22 Jan 2013 15:38:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Message-Id: <20130122153803.550ddb14.akpm@linux-foundation.org>
In-Reply-To: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
References: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On Mon, 21 Jan 2013 14:15:49 +1100
paul.szabo@sydney.edu.au wrote:

> When calculating amount of dirtyable memory, min_free_kbytes should be
> subtracted because it is not intended for dirty pages.

Makes sense.

> Using an "extern int" because that is the only interface to some such
> sysctl values.

urgh, not that way.  Let's do it properly:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix

fix up min_free_kbytes extern declarations

Cc: Paul Szabo <psz@maths.usyd.edu.au>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm.h  |    3 +++
 kernel/sysctl.c     |    1 -
 mm/huge_memory.c    |    1 -
 mm/page-writeback.c |    1 -
 4 files changed, 3 insertions(+), 3 deletions(-)

--- a/mm/page-writeback.c~page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix
+++ a/mm/page-writeback.c
@@ -233,7 +233,6 @@ static unsigned long highmem_dirtyable_m
 static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
-	extern int min_free_kbytes;
 
 	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
 	x -= min(x, dirty_balance_reserve);
--- a/include/linux/mm.h~page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix
+++ a/include/linux/mm.h
@@ -1387,6 +1387,9 @@ extern void setup_per_cpu_pageset(void);
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
 
+/* page_alloc.c */
+extern int min_free_kbytes;
+
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
 extern int nommu_shrink_inode_mappings(struct inode *, size_t, size_t);
--- a/mm/huge_memory.c~page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix
+++ a/mm/huge_memory.c
@@ -105,7 +105,6 @@ static int set_recommended_min_free_kbyt
 	struct zone *zone;
 	int nr_zones = 0;
 	unsigned long recommended_min;
-	extern int min_free_kbytes;
 
 	if (!khugepaged_enabled())
 		return 0;
--- a/kernel/sysctl.c~page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix
+++ a/kernel/sysctl.c
@@ -104,7 +104,6 @@ extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 #endif
 extern int pid_max;
-extern int min_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
_


> (This patch does not solve the PAE OOM issue.)
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> 
> Reported-by: Paul Szabo <psz@maths.usyd.edu.au>

Reported-by isn't needed in such cases.  It is assumed that finder==fixer.

> Reference: http://bugs.debian.org/695182
> Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>
> 
> --- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
> +++ mm/page-writeback.c	2013-01-21 13:57:05.000000000 +1100

Please prepare patches in `patch -p1' form.  This should be covered in
Documentation/SubmittingPatches, but isn't. 
Documentation/applying-patches.txt mentions it.

> @@ -343,12 +343,16 @@
>  unsigned long determine_dirtyable_memory(void)

You appear to be patching an old kernel.  But the change is still
applicable, to global_dirtyable_memory().

>  {
>  	unsigned long x;
> +	extern int min_free_kbytes;
>  
>  	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>  
>  	if (!vm_highmem_is_dirtyable)
>  		x -= highmem_dirtyable_memory(x);
>  
> +	/* Subtract min_free_kbytes */
> +	x -= min(x, min_free_kbytes >> (PAGE_SHIFT - 10));

Generates

mm/page-writeback.c:244: warning: comparison of distinct pointer types lacks a cast

because of the problematic min(int, unsigned long).  min_free_kbytes
should have an unsigned (long?) type, but I can't be bothered fixing
that right now..

From: Andrew Morton <akpm@linux-foundation.org>
Subject: page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix-fix

fix min() warning

Cc: Paul Szabo <psz@maths.usyd.edu.au>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/page-writeback.c~page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix-fix
+++ a/mm/page-writeback.c
@@ -241,7 +241,7 @@ static unsigned long global_dirtyable_me
 		x -= highmem_dirtyable_memory(x);
 
 	/* Subtract min_free_kbytes */
-	x -= min(x, min_free_kbytes >> (PAGE_SHIFT - 10));
+	x -= min_t(unsigned long, x, min_free_kbytes >> (PAGE_SHIFT - 10));
 
 	return x + 1;	/* Ensure that we never return 0 */
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
