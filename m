Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA2A98D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:19:11 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:18:43 +0800
Subject: [PATCH 2/7,v10] NUMA Hotplug Emulator: Add numa=possible option
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C3A@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

From:  David Rientjes <rientjes@google.com>

Adds a numa=3Dpossible=3D<N> command line option to set an additional N nod=
es
as being possible for memory hotplug.  This set of possible nodes
controls nr_node_ids and the sizes of several dynamically allocated node
arrays.

This allows memory hotplug to create new nodes for newly added memory
rather than binding it to existing nodes.

The first use-case for this will be node hotplug emulation which will use
these possible nodes to create new nodes to test the memory hotplug
callbacks and surrounding memory hotplug code.

CC: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@Intel.com>
---
 arch/x86/mm/numa.c           |    3 +++
 arch/x86/mm/numa_64.c        |    2 +-
 arch/x86/mm/numa_emulation.c |   33 +++++++++++++++++++++++++--------
 arch/x86/mm/numa_internal.h  |    1 +
 4 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/numa.c linux-hpe4/arch/x86/mm/numa.c
index 9559d36..633f1a5 100644
--- a/arch/x86/mm/numa.c
+++ linux-hpe4/arch/x86/mm/numa.c
@@ -6,6 +6,7 @@
 #include <asm/acpi.h>

 int __initdata numa_off;
+int __initdata numa_possible_nodes;

 static __init int numa_setup(char *opt)
 {
@@ -16,6 +17,8 @@ static __init int numa_setup(char *opt)
 #ifdef CONFIG_NUMA_EMU
        if (!strncmp(opt, "fake=3D", 5))
                numa_emu_cmdline(opt + 5);
+       if (!strncmp(opt, "possible=3D", 9))
+               numa_possible_nodes =3D simple_strtoul(opt + 9, NULL, 0);
 #endif
 #ifdef CONFIG_ACPI_NUMA
        if (!strncmp(opt, "noacpi", 6))
diff --git a/arch/x86/mm/numa_64.c linux-hpe4/arch/x86/mm/numa_64.c
index 9ec0f20..c3f8050 100644
--- a/arch/x86/mm/numa_64.c
+++ linux-hpe4/arch/x86/mm/numa_64.c
@@ -522,7 +522,7 @@ static int __init numa_register_memblks(struct numa_mem=
info *mi)
        int i, nid;

        /* Account for nodes with cpus and no memory */
-       node_possible_map =3D numa_nodes_parsed;
+       nodes_or(node_possible_map, node_possible_map, numa_nodes_parsed);
        numa_nodemask_from_meminfo(&node_possible_map, mi);
        if (WARN_ON(nodes_empty(node_possible_map)))
                return -EINVAL;
diff --git a/arch/x86/mm/numa_emulation.c linux-hpe4/arch/x86/mm/numa_emula=
tion.c
index 3696be0..c2309e5 100644
--- a/arch/x86/mm/numa_emulation.c
+++ linux-hpe4/arch/x86/mm/numa_emulation.c
@@ -305,7 +305,7 @@ void __init numa_emulation(struct numa_meminfo *numa_me=
minfo, int numa_dist_cnt)
        int i, j, ret;

        if (!emu_cmdline)
-               goto no_emu;
+               goto check_dynamic_emu;

        memset(&ei, 0, sizeof(ei));
        pi =3D *numa_meminfo;
@@ -331,11 +331,11 @@ void __init numa_emulation(struct numa_meminfo *numa_=
meminfo, int numa_dist_cnt)
        }

        if (ret < 0)
-               goto no_emu;
+               goto out;

        if (numa_cleanup_meminfo(&ei) < 0) {
                pr_warning("NUMA: Warning: constructed meminfo invalid, dis=
abling emulation\n");
-               goto no_emu;
+               goto out;
        }

        /* copy the physical distance table */
@@ -347,7 +347,7 @@ void __init numa_emulation(struct numa_meminfo *numa_me=
minfo, int numa_dist_cnt)
                                              phys_size, PAGE_SIZE);
                if (phys =3D=3D MEMBLOCK_ERROR) {
                        pr_warning("NUMA: Warning: can't allocate copy of d=
istance table, disabling emulation\n");
-                       goto no_emu;
+                       goto out;
                }
                memblock_x86_reserve_range(phys, phys + phys_size, "TMP NUM=
A DIST");
                phys_dist =3D __va(phys);
@@ -368,7 +368,7 @@ void __init numa_emulation(struct numa_meminfo *numa_me=
minfo, int numa_dist_cnt)
        }
        if (dfl_phys_nid =3D=3D NUMA_NO_NODE) {
                pr_warning("NUMA: Warning: can't determine default physical=
 node, disabling emulation\n");
-               goto no_emu;
+               goto out;
        }

        /* commit */
@@ -418,10 +418,27 @@ void __init numa_emulation(struct numa_meminfo *numa_=
meminfo, int numa_dist_cnt)
        /* free the copied physical distance table */
        if (phys_dist)
                memblock_x86_free_range(__pa(phys_dist), __pa(phys_dist) + =
phys_size);
-       return;

-no_emu:
-       /* No emulation.  Build identity emu_nid_to_phys[] for numa_add_cpu=
() */
+check_dynamic_emu:
+       if (!numa_possible_nodes)
+               goto out;
+       for (i =3D 0; i < numa_possible_nodes; i++) {
+               int nid;
+
+               nid =3D first_unset_node(node_possible_map);
+               if (nid =3D=3D MAX_NUMNODES)
+                       break;
+               node_set(nid, node_possible_map);
+       }
+       /* static emulation have built the emu_nid_to_phys[] */
+       if (emu_cmdline)
+               return;
+
+out:
+       /*
+        * No emulation or using dynamic emulation. Build
+        * identity emu_nid_to_phys[] for numa_add_cpu()
+        */
        for (i =3D 0; i < ARRAY_SIZE(emu_nid_to_phys); i++)
                emu_nid_to_phys[i] =3D i;
 }
diff --git a/arch/x86/mm/numa_internal.h linux-hpe4/arch/x86/mm/numa_intern=
al.h
index ef2d973..7766f04 100644
--- a/arch/x86/mm/numa_internal.h
+++ linux-hpe4/arch/x86/mm/numa_internal.h
@@ -18,6 +18,7 @@ struct numa_meminfo {
 void __init numa_remove_memblk_from(int idx, struct numa_meminfo *mi);
 int __init numa_cleanup_meminfo(struct numa_meminfo *mi);
 void __init numa_reset_distance(void);
+extern int numa_possible_nodes;

 #ifdef CONFIG_NUMA_EMU
 void __init numa_emulation(struct numa_meminfo *numa_meminfo,
--
1.7.1.1
--
best regards
yang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
