Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2C03F6B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:41:25 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so5249067qgf.21
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 05:41:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g2si3171348qab.153.2014.04.11.05.41.22
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 05:41:23 -0700 (PDT)
Date: Thu, 10 Apr 2014 21:35:51 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5347e2f3.c214e00a.02fa.ffff8c61SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com>
References: <87eh1ix7g0.fsf@x240.local.i-did-not-set--mail-host-address--so-tickle-me>
 <533a1563.ad318c0a.6a93.182bSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAOPLpQc8R2SfTB+=BsMa09tcQ-iBNJHg+tGnPK-9EDH1M47MJw@mail.gmail.com>
 <5343806c.100cc30a.0461.ffffc401SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404091734060.1857@chino.kir.corp.google.com>
 <5345fe27.82dab40a.0831.0af9SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com>
Subject: [PATCH] drivers/base/node.c: export physical address range of given
 node (Re: NUMA node information for pages)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: drepper@gmail.com, anatol.pomozov@gmail.com, jkosina@suse.cz, akpm@linux-foundation.org, xemul@parallels.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(CC:ed linux-mm)

On Thu, Apr 10, 2014 at 03:06:49PM -0700, David Rientjes wrote:
> On Wed, 9 Apr 2014, Naoya Horiguchi wrote:
> 
> > >  [ And that block_size_bytes file is absolutely horrid, why are we
> > >    exporting all this information in hex and not telling anybody? ]
> > 
> > Indeed, this kind of implicit hex numbers are commonly used in many place.
> > I guess that it's maybe for historical reasons.
> > 
> 
> I think it was meant to be simple to that you could easily add the length 
> to the start, but it should at least prefix this with `0x'.  That code has 
> been around for years, though, so we probably can't fix it now.
> 
> > > I'd much prefer a single change that works for everybody and userspace can 
> > > rely on exporting accurate information as long as sysfs is mounted, and 
> > > not even need to rely on getpagesize() to convert from pfn to physical 
> > > address: just simple {start,end}_phys_addr files added to 
> > > /sys/devices/system/node/nodeN/ for node N.  Online information can 
> > > already be parsed for these ranges from /sys/devices/system/node/online.
> > 
> > OK, so what if some node has multiple address ranges?  I don't think that
> > start(end)_phys_addr simply returns minimum (maximum) possible address is optimal,
> > because users can't know about void range between valid address ranges
> > (non-exist pfn should not belong to any node).
> > Are printing multilined (or comma-separated) ranges preferable for example
> > like below?
> > 
> >   $ cat /sys/devices/system/node/nodeN/phys_addr
> >   0x0-0x80000000
> >   0x100000000-0x180000000
> > 
> 
> What the...?  nodeN should represent the pgdat for that node and a pgdat 
> can only have a single range.

Yes, that's right, but it seems to me that just node_start_pfn and node_end_pfn
is not enough because there can be holes (without any page struct backed) inside
[node_start_pfn, node_end_pfn), and it's not aware of memory hotplug.

> I'm suggesting that 
> /sys/devices/system/node/nodeN/start_phys_addr returns 
> node_start_pfn(N) << PAGE_SHIFT and 
> /sys/devices/system/node/nodeN/end_phys_addr returns
> node_end_pfn(N) << PAGE_SHIFT and prefix them correctly this time with 
> `0x'.

Yes, we should have '0x' prefix for new interfaces.

I wrote a patch, so could you take a look?

I tested !CONFIG_MEMORY_HOTPLUG_SPARSE case too, and it works fine.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 10 Apr 2014 20:59:59 -0400
Subject: [PATCH] drivers/base/node.c: export physical address range of given
 node

Userspace applications sometimes want to know which node a give page belongs to,
so this patch adds a new interface /sys/devices/system/node/nodeN/phys_addr
which gives the physical address ranges of node N. A reader gets multilined
physical address ranges backed by valid pfn (neither holes within the zone nor
offlined range are not included in the output.)

Here is the example.

  # cat /sys/devices/system/node/node0/phys_addr
  0x1000-0x40000000
  # cat /sys/devices/system/node/node3/phys_addr
  0xc0000000-0xe0000000
  0x100000000-0x120000000
  # echo offline > /sys/devices/system/memory/memory33/state
  # cat /sys/devices/system/node/node3/phys_addr
  0xc0000000-0xe0000000
  0x100000000-0x108000000
  0x110000000-0x120000000

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 drivers/base/node.c    | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/memory.h |  4 ++++
 include/linux/mmzone.h |  1 +
 3 files changed, 65 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index bc9f43bf7e29..21e87909ec4f 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -18,6 +18,7 @@
 #include <linux/device.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
+#include <linux/memblock.h>
 
 static struct bus_type node_subsys = {
 	.name = "node",
@@ -185,6 +186,64 @@ static ssize_t node_read_vmstat(struct device *dev,
 }
 static DEVICE_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
 
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+static bool valid_mem_section(unsigned long sec_nr)
+{
+	struct memory_block *memblk;
+	if (!present_section_nr(sec_nr))
+		return false;
+	memblk = find_memory_block(__nr_to_section(sec_nr));
+	if (!memblk || is_memblock_offlined(memblk))
+		return false;
+	return true;
+}
+#endif
+
+static ssize_t node_read_phys_addr(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct pglist_data *pgdat = NODE_DATA(dev->id);
+	unsigned long start, end;
+	int n = 0;
+	unsigned long pfn;
+	unsigned long rstart = 0, rend = 0; /* range's start and end */
+
+	start = pgdat->node_start_pfn;
+	end = pgdat_end_pfn(pgdat);
+	pfn = start;
+	while (pfn < end) {
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+		if (unlikely(!valid_mem_section(pfn_to_section_nr(pfn)))) {
+			if (rstart) {
+				n += sprintf(buf + n, "0x%llx-0x%llx\n",
+					     PFN_PHYS(rstart), PFN_PHYS(rend));
+				rstart = 0;
+				rend = 0;
+			}
+			pfn = SECTION_NEXT_BOUNDARY(pfn);
+			continue;
+		}
+#endif
+		if (pfn_valid(pfn)) {
+			if (!rstart)
+				rstart = pfn;
+			rend = pfn + 1;
+		} else {
+			if (rstart)
+				n += sprintf(buf + n, "0x%llx-0x%llx\n",
+					     PFN_PHYS(rstart), PFN_PHYS(rend));
+			rstart = 0;
+			rend = 0;
+		}
+		pfn++;
+	}
+	if (rstart)
+		n += sprintf(buf + n, "0x%llx-0x%llx\n",
+			     PFN_PHYS(rstart), PFN_PHYS(rend));
+	return n;
+}
+static DEVICE_ATTR(phys_addr, S_IRUGO, node_read_phys_addr, NULL);
+
 static ssize_t node_read_distance(struct device *dev,
 			struct device_attribute *attr, char * buf)
 {
@@ -288,6 +347,7 @@ static int register_node(struct node *node, int num, struct node *parent)
 		device_create_file(&node->dev, &dev_attr_numastat);
 		device_create_file(&node->dev, &dev_attr_distance);
 		device_create_file(&node->dev, &dev_attr_vmstat);
+		device_create_file(&node->dev, &dev_attr_phys_addr);
 
 		scan_unevictable_register_node(node);
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index bb7384e3c3d8..b68e14f8818c 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -103,6 +103,10 @@ static inline int memory_isolate_notify(unsigned long val, void *v)
 {
 	return 0;
 }
+static inline struct memory_block *find_memory_block(struct mem_section *ms)
+{
+	return NULL;
+}
 #else
 extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9b61b9bf81ac..138a7a6684ab 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1084,6 +1084,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 
 #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
+#define SECTION_NEXT_BOUNDARY(pfn)	(SECTION_ALIGN_DOWN(pfn) + PAGES_PER_SECTION)
 
 struct page;
 struct page_cgroup;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
