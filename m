Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3E5558D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:26:13 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:26:05 +0800
Subject: [PATCH 7/7,v10] NUMA Hotplug Emulator: Implement per-node
 add_memory debugfs interface
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C45@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

Add add_memory interface to support to memory hotplug emulation for each on=
line
node under debugfs. The reserved memory can be added into desired node with
this interface.

The layout on debugfs:
        node_hotplug/node0/add_memory
        node_hotplug/node1/add_memory
        node_hotplug/node2/add_memory
        ...

Add a memory section(128M) to node 3(boots with mem=3D1024m)

        echo 0x40000000 > node_hotplug/node3/add_memory

CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@Intel.com>
---
 Documentation/memory-hotplug.txt |   24 ++++++++++++
 mm/memory_hotplug.c              |   77 ++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/Documentation/memory-hotplug.txt linux-hpe4/Documentation/memo=
ry-hotplug.txt
index bc8c99e..9fa8fc7 100644
--- a/Documentation/memory-hotplug.txt
+++ linux-hpe4/Documentation/memory-hotplug.txt
@@ -19,6 +19,7 @@ be changed often.
   4.1 Hardware(Firmware) Support
   4.2 Notify memory hot-add event by hand
   4.3 Node hotplug emulation
+  4.4 Memory hotplug emulation
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -254,6 +255,29 @@ Where "size" can be represented in megabytes or gigaby=
tes (for example,
 Once the new node has been added, it is possible to online the memory by
 toggling the "state" of its memory section(s) as described in section 5.1.

+4.4 Memory hotplug emulation
+------------
+With debugfs, it is possible to test memory hotplug with software method, =
we
+can add memory section to desired node with add_memory interface. It is a =
much
+more powerful interface than "probe" described in section 4.2.
+
+There is an add_memory interface for each online node at the debugfs mount
+point.
+       mem_hotplug/node0/add_memory
+       mem_hotplug/node1/add_memory
+       mem_hotplug/node2/add_memory
+       ...
+
+Add a memory section(128M) to node 3(boots with mem=3D1024m)
+
+       echo 0x40000000 > mem_hotplug/node3/add_memory
+
+And more we make it friendly, it is possible to add memory to do
+
+       echo 1024m > mem_hotplug/node3/add_memory
+
+Once the new memory section has been added, it is possible to online the m=
emory
+by toggling the "state" described in section 5.1.

 ------------------------------
 5. Logical Memory hot-add phase
diff --git a/mm/memory_hotplug.c linux-hpe4/mm/memory_hotplug.c
index f0be4b4..0193e96 100644
--- a/mm/memory_hotplug.c
+++ linux-hpe4/mm/memory_hotplug.c
@@ -942,6 +942,81 @@ static struct dentry *node_hp_debug_root;
 extern char *emu_cmdline;
 extern int emu_nid_to_phys[MAX_NUMNODES];

+#ifdef CONFIG_ARCH_MEMORY_PROBE
+
+static ssize_t add_memory_store(struct file *file, const char __user *buf,
+                               size_t count, loff_t *ppos)
+{
+       u64 phys_addr =3D 0;
+       int nid =3D file->private_data - NULL;
+       int ret;
+
+       printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
+       phys_addr =3D simple_strtoull(buf, NULL, 0);
+
+       ret =3D add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT)=
;
+       if (ret)
+               count =3D ret;
+
+       return count;
+}
+
+static int add_memory_open(struct inode *inode, struct file *file)
+{
+       file->private_data =3D inode->i_private;
+       return 0;
+}
+
+static const struct file_operations add_memory_file_ops =3D {
+       .open           =3D add_memory_open,
+       .write          =3D add_memory_store,
+       .llseek         =3D generic_file_llseek,
+};
+
+/*
+ * Create add_memory debugfs entry under specified node
+ */
+static int debugfs_create_add_memory_entry(int nid)
+{
+       char buf[32];
+       static struct dentry *node_debug_root;
+
+       snprintf(buf, sizeof(buf), "node%d", nid);
+       node_debug_root =3D debugfs_create_dir(buf, memhp_debug_root);
+       if (!node_debug_root)
+               return -ENOMEM;
+
+       /* the nid information was represented by the offset of pointer(NUL=
L+nid) */
+       if (!debugfs_create_file("add_memory", S_IWUSR, node_debug_root,
+                       NULL + nid, &add_memory_file_ops))
+               return -ENOMEM;
+
+       return 0;
+}
+
+static int __init memory_debug_init(void)
+{
+       int nid;
+
+       if (!memhp_debug_root)
+               memhp_debug_root =3D debugfs_create_dir("mem_hotplug", NULL=
);
+       if (!memhp_debug_root)
+               return -ENOMEM;
+
+       for_each_online_node(nid)
+                debugfs_create_add_memory_entry(nid);
+
+       return 0;
+}
+
+module_init(memory_debug_init);
+#else
+static debugfs_create_add_memory_entry(int nid)
+{
+       return 0;
+}
+#endif /* CONFIG_ARCH_MEMORY_PROBE */
+
 static ssize_t add_node_store(struct file *file, const char __user *buf,
                                size_t count, loff_t *ppos)
 {
@@ -973,6 +1048,8 @@ static ssize_t add_node_store(struct file *file, const=
 char __user *buf,
        emu_nid_to_phys[nid] =3D nid;

        ret =3D add_memory(nid, start, size);
+
+       debugfs_create_add_memory_entry(nid);
        return ret ? ret : count;
 }

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
