Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5C57B6B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 00:50:32 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so1355447pab.3
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 21:50:32 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id uz1si32792721pac.182.2014.09.16.21.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 21:50:31 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 17 Sep 2014 12:50:15 +0800
Subject: [RFC resend] arm:fdt:free the fdt reserved memory
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491614@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB491610@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491610@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Jiang Liu' <jiang.liu@huawei.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'grant.likely@linaro.org'" <grant.likely@linaro.org>, "'robh+dt@kernel.org'" <robh+dt@kernel.org>, "'devicetree@vger.kernel.org'" <devicetree@vger.kernel.org>, "'pawel.moll@arm.com'" <pawel.moll@arm.com>, "'mark.rutland@arm.com'" <mark.rutland@arm.com>, "'ijc+devicetree@hellion.org.uk'" <ijc+devicetree@hellion.org.uk>, "'galak@codeaurora.org'" <galak@codeaurora.org>

this patch make some change to fdt driver, so that we can
free the reserved memory which is reserved by fdt blob for
unflatten device tree, we free it in free_initmem, this memory
will not be used after init calls.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/mm/init.c     |  5 +++--
 arch/arm64/mm/init.c   |  4 +++-
 drivers/of/fdt.c       | 27 +++++++++++++++++++++++----
 include/linux/of_fdt.h |  2 ++
 4 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 907dee1..de4dfa1 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -615,7 +615,7 @@ void __init mem_init(void)
 	}
 }
=20
-void free_initmem(void)
+void __init_refok free_initmem(void)
 {
 #ifdef CONFIG_HAVE_TCM
 	extern char __tcm_start, __tcm_end;
@@ -623,7 +623,8 @@ void free_initmem(void)
 	poison_init_mem(&__tcm_start, &__tcm_end - &__tcm_start);
 	free_reserved_area(&__tcm_start, &__tcm_end, -1, "TCM link");
 #endif
-
+	/*this function must be called before init memory are freed*/
+	free_early_init_fdt_scan_reserved_mem();
 	poison_init_mem(__init_begin, __init_end - __init_begin);
 	if (!machine_is_integrator() && !machine_is_cintegrator())
 		free_initmem_default(-1);
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 7268d57..6ad21ef 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -323,8 +323,10 @@ void __init mem_init(void)
 	}
 }
=20
-void free_initmem(void)
+void __init_refok free_initmem(void)
 {
+	/*this function must be called before init memory are freed*/
+	free_early_init_fdt_scan_reserved_mem();
 	free_initmem_default(0);
 }
=20
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 79cb831..e891ef6 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -240,6 +240,7 @@ static void * unflatten_dt_node(void *blob,
 	     (offset =3D fdt_next_property_offset(blob, offset))) {
 		const char *pname;
 		u32 sz;
+		int name_len;
=20
 		if (!(p =3D fdt_getprop_by_offset(blob, offset, &pname, &sz))) {
 			offset =3D -FDT_ERR_INTERNAL;
@@ -250,10 +251,12 @@ static void * unflatten_dt_node(void *blob,
 			pr_info("Can't find property name in list !\n");
 			break;
 		}
+		name_len =3D strlen(pname);
 		if (strcmp(pname, "name") =3D=3D 0)
 			has_name =3D 1;
-		pp =3D unflatten_dt_alloc(&mem, sizeof(struct property),
-					__alignof__(struct property));
+		pp =3D unflatten_dt_alloc(&mem,
+				ALIGN(sizeof(struct property) + name_len + 1, 4)
+				+ sz, __alignof__(struct property));
 		if (allnextpp) {
 			/* We accept flattened tree phandles either in
 			 * ePAPR-style "phandle" properties, or the
@@ -270,9 +273,11 @@ static void * unflatten_dt_node(void *blob,
 			 * stuff */
 			if (strcmp(pname, "ibm,phandle") =3D=3D 0)
 				np->phandle =3D be32_to_cpup(p);
-			pp->name =3D (char *)pname;
+			pp->name =3D (char *)memcpy(pp + 1, pname, name_len + 1);
 			pp->length =3D sz;
-			pp->value =3D (__be32 *)p;
+			pp->value =3D (__be32 *)memcpy((void *)pp +
+					ALIGN(sizeof(struct property) +
+						name_len + 1, 4), p, sz);
 			*prev_pp =3D pp;
 			prev_pp =3D &pp->next;
 		}
@@ -564,6 +569,20 @@ void __init early_init_fdt_scan_reserved_mem(void)
 	fdt_init_reserved_mem();
 }
=20
+void __init free_early_init_fdt_scan_reserved_mem(void)
+{
+	unsigned long start, end, size;
+	if (!initial_boot_params)
+		return;
+
+	size =3D fdt_totalsize(initial_boot_params);
+	memblock_free(__pa(initial_boot_params), size);
+	start =3D round_down((unsigned long)initial_boot_params, PAGE_SIZE);
+	end =3D round_up((unsigned long)initial_boot_params + size, PAGE_SIZE);
+	free_reserved_area((void *)start, (void *)end, 0, "fdt");
+	initial_boot_params =3D 0;
+}
+
 /**
  * of_scan_flat_dt - scan flattened tree blob and call callback on each.
  * @it: callback function
diff --git a/include/linux/of_fdt.h b/include/linux/of_fdt.h
index 0ff360d..21d51ce 100644
--- a/include/linux/of_fdt.h
+++ b/include/linux/of_fdt.h
@@ -62,6 +62,7 @@ extern int early_init_dt_scan_chosen(unsigned long node, =
const char *uname,
 extern int early_init_dt_scan_memory(unsigned long node, const char *uname=
,
 				     int depth, void *data);
 extern void early_init_fdt_scan_reserved_mem(void);
+extern void free_early_init_fdt_scan_reserved_mem(void);
 extern void early_init_dt_add_memory_arch(u64 base, u64 size);
 extern int early_init_dt_reserve_memory_arch(phys_addr_t base, phys_addr_t=
 size,
 					     bool no_map);
@@ -89,6 +90,7 @@ extern u64 fdt_translate_address(const void *blob, int no=
de_offset);
 extern void of_fdt_limit_memory(int limit);
 #else /* CONFIG_OF_FLATTREE */
 static inline void early_init_fdt_scan_reserved_mem(void) {}
+static inline void free_early_init_fdt_scan_reserved_mem(void) {}
 static inline const char *of_flat_dt_get_machine_name(void) { return NULL;=
 }
 static inline void unflatten_device_tree(void) {}
 static inline void unflatten_and_copy_device_tree(void) {}
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
