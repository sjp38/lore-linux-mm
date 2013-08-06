Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 170336B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 22:51:47 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 RESEND 13/18] x86, numa, mem_hotplug: Skip all the regions the kernel resides in.
Date: Tue, 6 Aug 2013 10:50:21 +0800
Message-Id: <1375757421-354-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <20130805145212.GA19631@mtj.dyndns.org>
References: <20130805145212.GA19631@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

At early time, memblock will reserve some memory for the kernel,
such as the kernel code and data segments, initrd file, and so on=EF=BC=8C
which means the kernel resides in these memory regions.

Even if these memory regions are hotpluggable, we should not
mark them as hotpluggable. Otherwise the kernel won't have enough
memory to boot.

This patch finds out which memory regions the kernel resides in,
and skip them when finding all hotpluggable memory regions.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/memory=5Fhotplug.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/mm/memory=5Fhotplug.c b/mm/memory=5Fhotplug.c
index ef9ccf8..10a30ef 100644
--- a/mm/memory=5Fhotplug.c
+++ b/mm/memory=5Fhotplug.c
@@ -31,6 +31,7 @@
 #include <linux/firmware-map.h>
 #include <linux/stop=5Fmachine.h>
 #include <linux/acpi.h>
+#include <linux/memblock.h>
=20
 #include <asm/tlbflush.h>
=20
@@ -93,6 +94,40 @@ static void release=5Fmemory=5Fresource(struct resource =
*res)
=20
 #ifdef CONFIG=5FACPI=5FNUMA
 /**
+ * kernel=5Fresides=5Fin=5Frange - Check if kernel resides in a memory reg=
ion.
+ * @base: The base address of the memory region.
+ * @length: The length of the memory region.
+ *
+ * This function is used at early time. It iterates memblock.reserved and =
check
+ * if the kernel has used any memory in [@base, @base + @length).
+ *
+ * Return true if the kernel resides in the memory region, false otherwise.
+ */
+static bool =5F=5Finit kernel=5Fresides=5Fin=5Fregion(phys=5Faddr=5Ft base=
, u64 length)
+{
+	int i;
+	phys=5Faddr=5Ft start, end;
+	struct memblock=5Fregion *region;
+	struct memblock=5Ftype *reserved =3D &memblock.reserved;
+
+	for (i =3D 0; i < reserved->cnt; i++) {
+		region =3D &reserved->regions[i];
+
+		if (region->flags !=3D MEMBLOCK=5FHOTPLUG)
+			continue;
+
+		start =3D region->base;
+		end =3D region->base + region->size;
+		if (end <=3D base || start >=3D base + length)
+			continue;
+
+		return true;
+	}
+
+	return false;
+}
+
+/**
  * find=5Fhotpluggable=5Fmemory - Find out hotpluggable memory from ACPI S=
RAT.
  *
  * This function did the following:
@@ -129,6 +164,16 @@ void =5F=5Finit find=5Fhotpluggable=5Fmemory(void)
=20
 	while (ACPI=5FSUCCESS(acpi=5Fhotplug=5Fmem=5Faffinity(srat=5Fvaddr, &base,
 						      &size, &offset))) {
+		/*
+		 * At early time, memblock will reserve some memory for the
+		 * kernel, such as the kernel code and data segments, initrd
+		 * file, and so on=EF=BC=8Cwhich means the kernel resides in these
+		 * memory regions. These regions should not be hotpluggable.
+		 * So do not mark them as hotpluggable.
+		 */
+		if (kernel=5Fresides=5Fin=5Fregion(base, size))
+			continue;
+
 		/* Will mark hotpluggable memory regions here */
 	}
=20
--=20
1.7.1

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
