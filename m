Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <200703041450.02178.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <45E6EEC5.4060902@yahoo.com.au> <200703011633.54625.rjw@sisk.pl>
	 <200703041450.02178.rjw@sisk.pl>
Content-Type: text/plain
Date: Thu, 08 Mar 2007 02:00:25 +0100
Message-Id: <1173315625.3546.32.camel@johannes.berg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-03-04 at 14:50 +0100, Rafael J. Wysocki wrote:

> Okay, the next three messages contain patches that should do the trick.
> 
> They have been tested on x86_64, but not very thoroughly.

Looks nice, but I'm having some trouble with it. Solved too though :)

Thing is that I need to call register_nosave_region for a region
reserved for the IOMMU. Because the region is reserved so early during
boot I cannot call register_nosave_region at that time. However, I also
can't call register_nosave_region during a late initcall because at that
point bootmem can no longer be allocated. I could of course put a hook
somewhere into the arch code to do the marking, but I'd prefer not to.

The easiest solution I came up with is below. Of course, the suspend
patches for powerpc64 are still very much work in progress and I might
end up changing the whole reservation scheme after some feedback... If
nobody else needs this then don't think about it now.

However, would that patch be acceptable to you? What about error
handling? Printing a message and setting a "suspend not permitted"
variable would be great but I don't think such a variable exists. Also,
maybe passing in a gfp mask would be better (and we could use 0 to mean
bootmem too, I'd think)

Actually... I'd never have noticed this if register_nosave_region merged
regions. I have these two regions:
[    0.000000] swsusp: Registered nosave memory region: 0000000080000000 - 0000000100000000
[...]
[   19.406116] swsusp: Registered nosave memory region: 000000007f000000 - 0000000080000000
But they aren't merged, if they were the latter call wouldn't need to do
any allocations. Not that I'd want to rely on these positions!

With this patch and appropriate changes to my suspend code, it works.

johannes

---
Subject: [PATCH] swsusp: introduce register_nosave_region_late
From: Johannes Berg <johannes@sipsolutions.net>

This patch introduces a new register_nosave_region_late function that
can be called from initcalls when register_nosave_region can no longer
be used because it uses bootmem.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 include/linux/suspend.h |   11 ++++++++++-
 kernel/power/snapshot.c |   12 +++++++++---
 2 files changed, 19 insertions(+), 4 deletions(-)

--- linux-2.6-git.orig/include/linux/suspend.h	2007-03-08 01:25:37.248701500 +0100
+++ linux-2.6-git/include/linux/suspend.h	2007-03-08 01:41:49.967826495 +0100
@@ -36,7 +36,15 @@ static inline void pm_restore_console(vo
 /* kernel/power/swsusp.c */
 extern int software_suspend(void);
 /* kernel/power/snapshot.c */
-extern void __init register_nosave_region(unsigned long, unsigned long);
+extern void __register_nosave_region(unsigned long b, unsigned long e, int km);
+static inline void register_nosave_region(unsigned long b, unsigned long e)
+{
+	__register_nosave_region(b, e, 0);
+}
+static inline void register_nosave_region_late(unsigned long b, unsigned long e)
+{
+	__register_nosave_region(b, e, 1);
+}
 extern int swsusp_page_is_forbidden(struct page *);
 extern void swsusp_set_page_free(struct page *);
 extern void swsusp_unset_page_free(struct page *);
@@ -49,6 +57,7 @@ static inline int software_suspend(void)
 }
 
 static inline void register_nosave_region(unsigned long b, unsigned long e) {}
+static inline void register_nosave_region_late(unsigned long b, unsigned long e) {}
 static inline int swsusp_page_is_forbidden(struct page *p) { return 0; }
 static inline void swsusp_set_page_free(struct page *p) {}
 static inline void swsusp_unset_page_free(struct page *p) {}
--- linux-2.6-git.orig/kernel/power/snapshot.c	2007-03-08 01:26:17.680701500 +0100
+++ linux-2.6-git/kernel/power/snapshot.c	2007-03-08 01:42:35.385826495 +0100
@@ -608,7 +608,8 @@ static LIST_HEAD(nosave_regions);
  */
 
 void __init
-register_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
+__register_nosave_region(unsigned long start_pfn, unsigned long end_pfn,
+			 int use_kmalloc)
 {
 	struct nosave_region *region;
 
@@ -624,8 +625,13 @@ register_nosave_region(unsigned long sta
 			goto Report;
 		}
 	}
-	/* This allocation cannot fail */
-	region = alloc_bootmem_low(sizeof(struct nosave_region));
+	if (use_kmalloc) {
+		/* during init, this shouldn't fail */
+		region = kmalloc(sizeof(struct nosave_region), GFP_KERNEL);
+		BUG_ON(!region);
+	} else
+		/* This allocation cannot fail */
+		region = alloc_bootmem_low(sizeof(struct nosave_region));
 	region->start_pfn = start_pfn;
 	region->end_pfn = end_pfn;
 	list_add_tail(&region->list, &nosave_regions);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
