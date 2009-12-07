Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3E3060021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 11:24:08 -0500 (EST)
Message-Id: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
Date: Mon, 07 Dec 2009 16:24:03 +0000
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] mm/vmalloc: don't use vmalloc_end
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

At least on ia64 vmalloc_end is a global variable that VMALLOC_END
expands to. Hence having a local variable named vmalloc_end and
initialized from VMALLOC_END won't work on such platforms. Rename
these variables, and for consistency also rename vmalloc_start.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>

---
 mm/vmalloc.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- linux-2.6.32/mm/vmalloc.c
+++ 2.6.32-dont-use-vmalloc_end/mm/vmalloc.c
@@ -2060,13 +2060,13 @@ static unsigned long pvm_determine_end(s
 				       struct vmap_area **pprev,
 				       unsigned long align)
 {
-	const unsigned long vmalloc_end =3D VMALLOC_END & ~(align - 1);
+	const unsigned long end =3D VMALLOC_END & ~(align - 1);
 	unsigned long addr;
=20
 	if (*pnext)
-		addr =3D min((*pnext)->va_start & ~(align - 1), vmalloc_end=
);
+		addr =3D min((*pnext)->va_start & ~(align - 1), end);
 	else
-		addr =3D vmalloc_end;
+		addr =3D end;
=20
 	while (*pprev && (*pprev)->va_end > addr) {
 		*pnext =3D *pprev;
@@ -2105,8 +2105,8 @@ struct vm_struct **pcpu_get_vm_areas(con
 				     const size_t *sizes, int nr_vms,
 				     size_t align, gfp_t gfp_mask)
 {
-	const unsigned long vmalloc_start =3D ALIGN(VMALLOC_START, align);
-	const unsigned long vmalloc_end =3D VMALLOC_END & ~(align - 1);
+	const unsigned long vstart =3D ALIGN(VMALLOC_START, align);
+	const unsigned long vend =3D VMALLOC_END & ~(align - 1);
 	struct vmap_area **vas, *prev, *next;
 	struct vm_struct **vms;
 	int area, area2, last_area, term_area;
@@ -2142,7 +2142,7 @@ struct vm_struct **pcpu_get_vm_areas(con
 	}
 	last_end =3D offsets[last_area] + sizes[last_area];
=20
-	if (vmalloc_end - vmalloc_start < last_end) {
+	if (vend - vstart < last_end) {
 		WARN_ON(true);
 		return NULL;
 	}
@@ -2167,7 +2167,7 @@ retry:
 	end =3D start + sizes[area];
=20
 	if (!pvm_find_next_prev(vmap_area_pcpu_hole, &next, &prev)) {
-		base =3D vmalloc_end - last_end;
+		base =3D vend - last_end;
 		goto found;
 	}
 	base =3D pvm_determine_end(&next, &prev, align) - end;
@@ -2180,7 +2180,7 @@ retry:
 		 * base might have underflowed, add last_end before
 		 * comparing.
 		 */
-		if (base + last_end < vmalloc_start + last_end) {
+		if (base + last_end < vstart + last_end) {
 			spin_unlock(&vmap_area_lock);
 			if (!purged) {
 				purge_vmap_area_lazy();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
