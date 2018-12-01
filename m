Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81E236B5B35
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 20:25:10 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so1400147edb.8
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 17:25:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j42sor4231283eda.3.2018.11.30.17.25.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 17:25:08 -0800 (PST)
Date: Sat, 1 Dec 2018 01:25:07 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH RFCv2 1/4] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181201012507.lxfscl6ho3gc6gnn@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181130175922.10425-1-david@redhat.com>
 <20181130175922.10425-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130175922.10425-2-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Banman <andrew.banman@hpe.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Michal Such??nek <msuchanek@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri, Nov 30, 2018 at 06:59:19PM +0100, David Hildenbrand wrote:
>Memory onlining should always be handled by user space, because only user
>space knows which use cases it wants to satisfy. E.g. memory might be
>onlined to the MOVABLE zone even if it can never be removed from the
>system, e.g. to make usage of huge pages more reliable.
>
>However to implement such rules (especially default rules in distributions)
>we need more information about the memory that was added in user space.
>
>E.g. on x86 we want to online memory provided by balloon devices (e.g.
>XEN, Hyper-V) differently (-> will not be unplugged by offlining the whole
>block) than ordinary DIMMs (-> might eventually be unplugged by offlining
>the whole block). This might also become relevat for other architectures.
>
>Also, udev rules right now check if running on s390x and treat all added
>memory blocks as standby memory (-> don't online automatically). As soon as
>we support other memory hotplug mechanism (e.g. virtio-mem) checks would
>have to get more involved (e.g. also check if under KVM) but eventually
>also wrong (e.g. if KVM ever supports standby memory we are doomed).
>
>I decided to allow to specify the type of memory that is getting added
>to the system. Let's start with two types, BOOT and UNSPECIFIED to get the
>basic infrastructure running. We'll introduce and use further types in
>follow-up patches. For now we classify any hotplugged memory temporarily
>as as UNSPECIFIED (which will eventually be dropped later on).
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Oscar Salvador <osalvador@suse.com>
>Cc: Dave Hansen <dave.hansen@linux.intel.com>
>Cc: Michal Hocko <mhocko@kernel.org>
>Cc: Michal Such??nek <msuchanek@suse.de>
>Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
>Cc: Dan Williams <dan.j.williams@intel.com>
>Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 38 +++++++++++++++++++++++++++++++++++---
> include/linux/memory.h | 27 +++++++++++++++++++++++++++
> 2 files changed, 62 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 0c290f86ab20..17f2985c07c5 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -381,6 +381,29 @@ static ssize_t show_phys_device(struct device *dev,
> 	return sprintf(buf, "%d\n", mem->phys_device);
> }
> 
>+static ssize_t type_show(struct device *dev, struct device_attribute *attr,
>+			 char *buf)
>+{
>+	struct memory_block *mem = to_memory_block(dev);
>+	ssize_t len = 0;
>+
>+	switch (mem->type) {
>+	case MEMORY_BLOCK_UNSPECIFIED:
>+		len = sprintf(buf, "unspecified\n");
>+		break;
>+	case MEMORY_BLOCK_BOOT:
>+		len = sprintf(buf, "boot\n");
>+		break;
>+	default:
>+		len = sprintf(buf, "ERROR-UNKNOWN-%ld\n",
>+				mem->state);
>+		WARN_ON(1);
>+		break;
>+	}
>+
>+	return len;
>+}
>+
> #ifdef CONFIG_MEMORY_HOTREMOVE
> static void print_allowed_zone(char *buf, int nid, unsigned long start_pfn,
> 		unsigned long nr_pages, int online_type,
>@@ -442,6 +465,7 @@ static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
> static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
> static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
> static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
>+static DEVICE_ATTR_RO(type);

This is correct, while looks not consistent with other attributes.

Not that beautiful :-)

> 
> /*
>  * Block size attribute stuff
>@@ -620,6 +644,7 @@ static struct attribute *memory_memblk_attrs[] = {
> 	&dev_attr_state.attr,
> 	&dev_attr_phys_device.attr,
> 	&dev_attr_removable.attr,
>+	&dev_attr_type.attr,
> #ifdef CONFIG_MEMORY_HOTREMOVE
> 	&dev_attr_valid_zones.attr,
> #endif
>@@ -657,13 +682,17 @@ int register_memory(struct memory_block *memory)
> }
> 
> static int init_memory_block(struct memory_block **memory,
>-			     struct mem_section *section, unsigned long state)
>+			     struct mem_section *section, unsigned long state,
>+			     int type)
> {
> 	struct memory_block *mem;
> 	unsigned long start_pfn;
> 	int scn_nr;
> 	int ret = 0;
> 
>+	if (type == MEMORY_BLOCK_NONE)
>+		return -EINVAL;

No one will pass in this value. Can we omit this check for now?

>+
> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> 	if (!mem)
> 		return -ENOMEM;
>@@ -675,6 +704,7 @@ static int init_memory_block(struct memory_block **memory,
> 	mem->state = state;
> 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
> 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
>+	mem->type = type;
> 
> 	ret = register_memory(mem);
> 
>@@ -699,7 +729,8 @@ static int add_memory_block(int base_section_nr)
> 
> 	if (section_count == 0)
> 		return 0;
>-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
>+	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE,
>+				MEMORY_BLOCK_BOOT);
> 	if (ret)
> 		return ret;
> 	mem->section_count = section_count;
>@@ -722,7 +753,8 @@ int hotplug_memory_register(int nid, struct mem_section *section)
> 		mem->section_count++;
> 		put_device(&mem->dev);
> 	} else {
>-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
>+		ret = init_memory_block(&mem, section, MEM_OFFLINE,
>+					MEMORY_BLOCK_UNSPECIFIED);
> 		if (ret)
> 			goto out;
> 		mem->section_count++;
>diff --git a/include/linux/memory.h b/include/linux/memory.h
>index d75ec88ca09d..06268e96e0da 100644
>--- a/include/linux/memory.h
>+++ b/include/linux/memory.h
>@@ -34,12 +34,39 @@ struct memory_block {
> 	int (*phys_callback)(struct memory_block *);
> 	struct device dev;
> 	int nid;			/* NID for this memory block */
>+	int type;			/* type of this memory block */
> };
> 
> int arch_get_memory_phys_device(unsigned long start_pfn);
> unsigned long memory_block_size_bytes(void);
> int set_memory_block_size_order(unsigned int order);
> 
>+/*
>+ * Memory block types allow user space to formulate rules if and how to
>+ * online memory blocks. The types are exposed to user space as text
>+ * strings in sysfs.
>+ *
>+ * MEMORY_BLOCK_NONE:
>+ *  No memory block is to be created (e.g. device memory). Not exposed to
>+ *  user space.
>+ *
>+ * MEMORY_BLOCK_UNSPECIFIED:
>+ *  The type of memory block was not further specified when adding the
>+ *  memory block.
>+ *
>+ * MEMORY_BLOCK_BOOT:
>+ *  This memory block was added during boot by the basic system. No
>+ *  specific device driver takes care of this memory block. This memory
>+ *  block type is onlined automatically by the kernel during boot and might
>+ *  later be managed by a different device driver, in which case the type
>+ *  might change.
>+ */
>+enum {
>+	MEMORY_BLOCK_NONE = 0,
>+	MEMORY_BLOCK_UNSPECIFIED,
>+	MEMORY_BLOCK_BOOT,
>+};
>+
> /* These states are exposed to userspace as text strings in sysfs */
> #define	MEM_ONLINE		(1<<0) /* exposed to userspace */
> #define	MEM_GOING_OFFLINE	(1<<1) /* exposed to userspace */
>-- 
>2.17.2

-- 
Wei Yang
Help you, Help me
