Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 700916B00D4
	for <linux-mm@kvack.org>; Tue,  7 May 2013 08:02:53 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online callbacks for memory blocks
Date: Tue, 07 May 2013 14:11:14 +0200
Message-ID: <7132174.AKkXX1jln2@vostro.rjw.lan>
In-Reply-To: <20130507105945.GA4354@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1809544.1r1JBXrr0i@vostro.rjw.lan> <20130507105945.GA4354@dhcp-192-168-178-175.profitbricks.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org, wency@cn.fujitsu.com

On Tuesday, May 07, 2013 12:59:45 PM Vasilis Liaskovitis wrote:
> Hi,
> 
> On Tue, May 07, 2013 at 02:59:05AM +0200, Rafael J. Wysocki wrote:
> > On Monday, May 06, 2013 06:28:12 PM Vasilis Liaskovitis wrote:
> > > On Sat, May 04, 2013 at 01:21:16PM +0200, Rafael J. Wysocki wrote:
> > > > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > > > 
> > > > Introduce .offline() and .online() callbacks for memory_subsys
> > > > that will allow the generic device_offline() and device_online()
> > > > to be used with device objects representing memory blocks.  That,
> > > > in turn, allows the ACPI subsystem to use device_offline() to put
> > > > removable memory blocks offline, if possible, before removing
> > > > memory modules holding them.
> > > > 
> > > > The 'online' sysfs attribute of memory block devices will attempt to
> > > > put them offline if 0 is written to it and will attempt to apply the
> > > > previously used online type when onlining them (i.e. when 1 is
> > > > written to it).
> > > > 
> > > > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > > > ---
> > > >  drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
> > > >  include/linux/memory.h |    1 
> > > >  2 files changed, 81 insertions(+), 25 deletions(-)
> > > >
> > > [...]
> > > 
> > > > @@ -686,10 +735,16 @@ int offline_memory_block(struct memory_b
> > > >  {
> > > >  	int ret = 0;
> > > >  
> > > > +	lock_device_hotplug();
> > > >  	mutex_lock(&mem->state_mutex);
> > > > -	if (mem->state != MEM_OFFLINE)
> > > > -		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
> > > > +	if (mem->state != MEM_OFFLINE) {
> > > > +		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
> > > > +							 MEM_ONLINE, -1);
> > > > +		if (!ret)
> > > > +			mem->dev.offline = true;
> > > > +	}
> > > >  	mutex_unlock(&mem->state_mutex);
> > > > +	unlock_device_hotplug();
> > > 
> > > (Testing with qemu...)
> > 
> > Thanks!
> > 
> > > offline_memory_block is called from remove_memory, which in turn is called from
> > > acpi_memory_device_remove (detach operation) during acpi_bus_trim. We already
> > > hold the device_hotplug lock when we trim (acpi_scan_hot_remove), so we
> > > don't need to lock/unlock_device_hotplug in offline_memory_block.
> > 
> > Indeed.
> > 
> > First, it looks like offline_memory_block_cb() is the only place calling
> > offline_memory_block(), is that right?  I'm wondering if it would make
> 
> correct.

Great!

> > sense to use device_offline() in there and remove offline_memory_block()
> > entirely?
> 
> possibly. Not sure if we can get hold of the struct device from
> mm/memory_hotplug.c, maybe we still need the helper function that operates
> directly on the memory block.

We can pass mem->dev to device_offline() and the locking should be fine.

> > Second, if you ran into this issue during testing, that would mean that patch
> > [1/2] actually worked for you, which would be nice. :-)  Was that really the
> > case?
> 
> yes, the patchset works fine once the extra lock/unlock_device_hotplug is
> removed. For various dimm hot-remove operations, I saw either successfull
> offlining and removal, or failed offlining and aborted removal.
> You can add this to 1/2 (or, once the extra lock is removed, to 2/2 as well):
> 
> Tested-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

Thanks!

Updated patch is appended for completness.

> > 
> > > A more general issue is that there are now two memory offlining efforts:
> > > 
> > > 1) from acpi_bus_offline_companions during device offline
> > > 2) from mm: remove_memory during device detach (offline_memory_block_cb)
> > > 
> > > The 2nd is only called if the device offline operation was already succesful, so
> > > it seems ineffective or redundant now, at least for x86_64/acpi_memhotplug machine
> > > (unless the blocks were re-onlined in between).
> > 
> > Sure, and that should be OK for now.  Changing the detach behavior is not
> > essential from the patch [2/2] perspective, we can do it later.
> 
> yes, ok.
> 
> > 
> > > On the other hand, the 2nd effort has some more intelligence in offlining, as it
> > > tries to offline twice in the precense of memcg, see commits df3e1b91 or
> > > reworked 0baeab16. Maybe we need to consolidate the logic.
> > 
> > Hmm.  Perhaps it would make sense to implement that logic in
> > memory_subsys_offline(), then?
> 
> the logic tries to offline the memory blocks of the device twice, because the
> first memory block might be storing information for the subsequent memblocks.
> 
> memory_subsys_offline operates on one memory block at a time. Perhaps we can get
> the same effect if we do an acpi_walk of acpi_bus_offline_companions twice in
> acpi_scan_hot_remove but it's probably not a good idea, since that would
> affect non-memory devices as well. 
> 
> I am not sure how important this intelligence is in practice (I am not using
> mem cgroups in my guest kernel tests yet).  Maybe Wen (original author) has
> more details on 2-pass offlining effectiveness.

OK

It may be added in a separate patch in any case.

> > > remove_memory is called from device_detach, during trim that can't fail, so it
> > > should not fail. However this function can still fail in 2 cases:
> > > - offline_memory_block_cb
> > > - is_memblock_offlined_cb
> > > in the case of re-onlined memblocks in between device-offline and device detach.
> > > This seems possible I think, since we do not hold lock_memory_hotplug for the
> > > duration of the hot-remove operation.
> > 
> > But we do hold device_hotplug_lock, so every code path that may race with
> > acpi_scan_hot_remove() needs to take device_hotplug_lock as well.  Now,
> > question is whether or not there are any code paths like that calling one of
> > the two functions above without holding device_hotplug_lock?
> 
> I think you are right. The other code path I had in mind was userspace initiated
> online/offline operations from store_mem_state in drivers/base/memory.c. But we
> also do lock_device_hotplug in that case too. So it seems safe. If I find
> something else with stress testing the paths simultaneously (or another code
> path) I 'll update.

OK

Thanks,
Rafael


---
From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Subject: Driver core: Introduce offline/online callbacks for memory blocks

Introduce .offline() and .online() callbacks for memory_subsys
that will allow the generic device_offline() and device_online()
to be used with device objects representing memory blocks.  That,
in turn, allows the ACPI subsystem to use device_offline() to put
removable memory blocks offline, if possible, before removing
memory modules holding them.

The 'online' sysfs attribute of memory block devices will attempt to
put them offline if 0 is written to it and will attempt to apply the
previously used online type when onlining them (i.e. when 1 is
written to it).

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Tested-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
 include/linux/memory.h |    1 
 2 files changed, 81 insertions(+), 25 deletions(-)

Index: linux-pm/drivers/base/memory.c
===================================================================
--- linux-pm.orig/drivers/base/memory.c
+++ linux-pm/drivers/base/memory.c
@@ -37,9 +37,14 @@ static inline int base_memory_block_id(i
 	return section_nr / sections_per_block;
 }
 
+static int memory_subsys_online(struct device *dev);
+static int memory_subsys_offline(struct device *dev);
+
 static struct bus_type memory_subsys = {
 	.name = MEMORY_CLASS_NAME,
 	.dev_name = MEMORY_CLASS_NAME,
+	.online = memory_subsys_online,
+	.offline = memory_subsys_offline,
 };
 
 static BLOCKING_NOTIFIER_HEAD(memory_chain);
@@ -278,33 +283,64 @@ static int __memory_block_change_state(s
 {
 	int ret = 0;
 
-	if (mem->state != from_state_req) {
-		ret = -EINVAL;
-		goto out;
-	}
+	if (mem->state != from_state_req)
+		return -EINVAL;
 
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
 	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
-
 	if (ret) {
 		mem->state = from_state_req;
-		goto out;
+	} else {
+		mem->state = to_state;
+		if (to_state == MEM_ONLINE)
+			mem->last_online = online_type;
 	}
+	return ret;
+}
 
-	mem->state = to_state;
-	switch (mem->state) {
-	case MEM_OFFLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
-		break;
-	case MEM_ONLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
-		break;
-	default:
-		break;
+static int memory_subsys_online(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+	int ret;
+
+	mutex_lock(&mem->state_mutex);
+	ret = __memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE,
+					  mem->last_online);
+	mutex_unlock(&mem->state_mutex);
+	return ret;
+}
+
+static int memory_subsys_offline(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+	int ret;
+
+	mutex_lock(&mem->state_mutex);
+	ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+	mutex_unlock(&mem->state_mutex);
+	return ret;
+}
+
+static int __memory_block_change_state_uevent(struct memory_block *mem,
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type)
+{
+	int ret = __memory_block_change_state(mem, to_state, from_state_req,
+					      online_type);
+	if (!ret) {
+		switch (mem->state) {
+		case MEM_OFFLINE:
+			kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
+			break;
+		case MEM_ONLINE:
+			kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
+			break;
+		default:
+			break;
+		}
 	}
-out:
 	return ret;
 }
 
@@ -315,8 +351,8 @@ static int memory_block_change_state(str
 	int ret;
 
 	mutex_lock(&mem->state_mutex);
-	ret = __memory_block_change_state(mem, to_state, from_state_req,
-					  online_type);
+	ret = __memory_block_change_state_uevent(mem, to_state, from_state_req,
+						 online_type);
 	mutex_unlock(&mem->state_mutex);
 
 	return ret;
@@ -326,22 +362,34 @@ store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct memory_block *mem;
+	bool offline;
 	int ret = -EINVAL;
 
 	mem = container_of(dev, struct memory_block, dev);
 
-	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
+	lock_device_hotplug();
+
+	if (!strncmp(buf, "online_kernel", min_t(int, count, 13))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_KERNEL);
-	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
+	} else if (!strncmp(buf, "online_movable", min_t(int, count, 14))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_MOVABLE);
-	else if (!strncmp(buf, "online", min_t(int, count, 6)))
+	} else if (!strncmp(buf, "online", min_t(int, count, 6))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_KEEP);
-	else if(!strncmp(buf, "offline", min_t(int, count, 7)))
+	} else if(!strncmp(buf, "offline", min_t(int, count, 7))) {
+		offline = true;
 		ret = memory_block_change_state(mem, MEM_OFFLINE,
 						MEM_ONLINE, -1);
+	}
+	if (!ret)
+		dev->offline = offline;
+
+	unlock_device_hotplug();
 
 	if (ret)
 		return ret;
@@ -563,6 +611,7 @@ static int init_memory_block(struct memo
 			base_memory_block_id(scn_nr) * sections_per_block;
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
+	mem->last_online = ONLINE_KEEP;
 	mem->section_count++;
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
@@ -681,14 +730,20 @@ int unregister_memory_section(struct mem
 
 /*
  * offline one memory block. If the memory block has been offlined, do nothing.
+ *
+ * Call under device_hotplug_lock.
  */
 int offline_memory_block(struct memory_block *mem)
 {
 	int ret = 0;
 
 	mutex_lock(&mem->state_mutex);
-	if (mem->state != MEM_OFFLINE)
-		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+	if (mem->state != MEM_OFFLINE) {
+		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
+							 MEM_ONLINE, -1);
+		if (!ret)
+			mem->dev.offline = true;
+	}
 	mutex_unlock(&mem->state_mutex);
 
 	return ret;
Index: linux-pm/include/linux/memory.h
===================================================================
--- linux-pm.orig/include/linux/memory.h
+++ linux-pm/include/linux/memory.h
@@ -26,6 +26,7 @@ struct memory_block {
 	unsigned long start_section_nr;
 	unsigned long end_section_nr;
 	unsigned long state;
+	int last_online;
 	int section_count;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
