From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/3] record MAP_NORESERVE status on vmas and fix small page mprotect reservations
References: <exportbomb.1210191800@pinky>
Date: Wed, 7 May 2008 21:24:39 +0100
Message-Id: <1210191879.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org
List-ID: <linux-mm.kvack.org>

When a small page mapping is created with mmap() reservations are created
by default for any memory pages required.  When the region is read/write
the reservation is increased for every page, no reservation is needed for
read-only regions (as they implicitly share the zero page).  Reservations
are tracked via the VM_ACCOUNT vma flag which is present when the region
has reservation backing it.  When we convert a region from read-only to
read-write new reservations are aquired and VM_ACCOUNT is set.  However,
when a read-only map is created with MAP_NORESERVE it is indistinguishable
from a normal mapping.  When we then convert that to read/write we are
forced to incorrectly create reservations for it as we have no record of
the original MAP_NORESERVE.

This patch introduces a new vma flag VM_NORESERVE which records the
presence of the original MAP_NORESERVE flag.  This allows us to distinguish
these two circumstances and correctly account the reserve.

As well as fixing this FIXME in the code, this makes it much easier to
introduce MAP_NORESERVE support for huge pages as this flag is available
consistantly for the life of the mapping.  VM_ACCOUNT on the other hand
is heavily used at the generic level in association with small pages.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/mm.h |    1 +
 mm/mmap.c          |    3 +++
 mm/mprotect.c      |    6 ++----
 3 files changed, 6 insertions(+), 4 deletions(-)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 438ee65..71ddb7a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -100,6 +100,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
 #define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
+#define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
diff --git a/mm/mmap.c b/mm/mmap.c
index fac6633..98ab014 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1101,6 +1101,9 @@ munmap_back:
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
+	if (flags & MAP_NORESERVE)
+		vm_flags |= VM_NORESERVE;
+
 	if (accountable && (!(flags & MAP_NORESERVE) ||
 			    sysctl_overcommit_memory == OVERCOMMIT_NEVER)) {
 		if (vm_flags & VM_SHARED) {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 4de5468..b53078d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -148,12 +148,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * If we make a private mapping writable we increase our commit;
 	 * but (without finer accounting) cannot reduce our commit if we
 	 * make it unwritable again.
-	 *
-	 * FIXME? We haven't defined a VM_NORESERVE flag, so mprotecting
-	 * a MAP_NORESERVE private mapping to writable will now reserve.
 	 */
 	if (newflags & VM_WRITE) {
-		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|VM_SHARED))) {
+		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|
+						VM_SHARED|VM_NORESERVE))) {
 			charged = nrpages;
 			if (security_vm_enough_memory(charged))
 				return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
