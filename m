From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201848.14792.58117.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/6] Do not use FASTCALL for __alloc_pages_nodemask()
Date: Fri, 17 Aug 2007 21:18:48 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One PPC64 machine using gcc 3.4.6 the machine fails to boot when
__alloc_pages_nodemask() uses the FASTCALL calling convention. It is not
clear why this machine in particular is affected as other PPC64 machines
boot. The only usual aspect of the machine is that it has memoryless nodes
but I couldn't see any problem using them. The error received looks like

Initializing hardware...  storageUnable to handle kernel paging request for data at address 0xffffffff
Faulting instruction address: 0xc0000000001aaa0c
cpu 0x4: Vector: 300 (Data Access) at [c00000000fea7650]
    pc: c0000000001aaa0c: .strnlen+0x10/0x3c
    lr: c0000000001ab880: .vsnprintf+0x378/0x644
    sp: c00000000fea78d0
   msr: 9000000000009032
   dar: ffffffff
 dsisr: 40000000
  current = 0xc00000003fe4d7a0
  paca    = 0xc000000000487300
    pid   = 1178, comm = 05-wait_for_sys
enter ? for help
[link register   ] c0000000001ab880 .vsnprintf+0x378/0x644
[c00000000fea78d0] c0000000003cad35 (unreliable)
[c00000000fea7990] c0000000001abc70 .sprintf+0x3c/0x4c
[c00000000fea7a10] c00000000021d5c0 .show_uevent+0x150/0x1a4
[c00000000fea7bb0] c00000000021cedc .dev_attr_show+0x44/0x60
[c00000000fea7c30] c000000000143874 .sysfs_read_file+0x128/0x208
[c00000000fea7cf0] c0000000000d71bc .vfs_read+0x134/0x1f8
[c00000000fea7d90] c0000000000d75f4 .sys_read+0x4c/0x8c
[c00000000fea7e30] c00000000000852c syscall_exit+0x0/0x40
--- Exception: c01 (System Call) at 000000000ff65894
SP (ff90f730) is in userspace


This patch creates an inline version of __alloc_pages called
__alloc_pages_internal() which allows the machine to boot. Both __alloc_pages
and __alloc_pages_nodemask use this interal function but only __alloc_pages()
uses FASTCALL.

Opinions as to why FASTCALL breaks on one machine are welcome.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/gfp.h |    3 +--
 mm/page_alloc.c     |   13 ++++++++++---
 2 files changed, 11 insertions(+), 5 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-030_filter_nodemask/include/linux/gfp.h linux-2.6.23-rc3-035_nofastcall/include/linux/gfp.h
--- linux-2.6.23-rc3-030_filter_nodemask/include/linux/gfp.h	2007-08-17 16:56:36.000000000 +0100
+++ linux-2.6.23-rc3-035_nofastcall/include/linux/gfp.h	2007-08-17 17:00:37.000000000 +0100
@@ -142,8 +142,7 @@ extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
 extern struct page *
-FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
-				struct zonelist *, nodemask_t *nodemask));
+__alloc_pages_nodemask(gfp_t, unsigned int, struct zonelist *, nodemask_t *);
 
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-030_filter_nodemask/mm/page_alloc.c linux-2.6.23-rc3-035_nofastcall/mm/page_alloc.c
--- linux-2.6.23-rc3-030_filter_nodemask/mm/page_alloc.c	2007-08-17 17:00:27.000000000 +0100
+++ linux-2.6.23-rc3-035_nofastcall/mm/page_alloc.c	2007-08-17 17:00:37.000000000 +0100
@@ -1222,8 +1222,8 @@ try_next_zone:
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
-struct page * fastcall
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+static inline struct page *
+__alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
@@ -1396,11 +1396,18 @@ got_pg:
 	return page;
 }
 
+struct page *
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask)
+{
+	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
+}
+
 struct page * fastcall
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
+	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
