Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id EF4EA6B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 18:01:01 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH *5/5] Memory hotplug / ACPI: Simplify memory removal (was: Re: [PATCH 5/5] ACPI / memhotplug: Drop unnecessary code)
Date: Thu, 23 May 2013 00:09:46 +0200
Message-ID: <13857057.cWE1koxP0r@vostro.rjw.lan>
In-Reply-To: <1369079733.5673.58.camel@misato.fc.hp.com>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan> <1726699.Z30ifEcQDQ@vostro.rjw.lan> <1369079733.5673.58.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

On Monday, May 20, 2013 01:55:33 PM Toshi Kani wrote:
> On Mon, 2013-05-20 at 21:47 +0200, Rafael J. Wysocki wrote:
> > On Monday, May 20, 2013 11:27:56 AM Toshi Kani wrote:
> > > On Sun, 2013-05-19 at 01:34 +0200, Rafael J. Wysocki wrote:
> > > > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
>  :
> 
> > > > -	lock_memory_hotplug();
> > > > -
> > > > -	/*
> > > > -	 * we have offlined all memory blocks like this:
> > > > -	 *   1. lock memory hotplug
> > > > -	 *   2. offline a memory block
> > > > -	 *   3. unlock memory hotplug
> > > > -	 *
> > > > -	 * repeat step1-3 to offline the memory block. All memory blocks
> > > > -	 * must be offlined before removing memory. But we don't hold the
> > > > -	 * lock in the whole operation. So we should check whether all
> > > > -	 * memory blocks are offlined.
> > > > -	 */
> > > > -
> > > > -	ret = walk_memory_range(start_pfn, end_pfn, NULL,
> > > > -				is_memblock_offlined_cb);
> > > > -	if (ret) {
> > > > -		unlock_memory_hotplug();
> > > > -		return ret;
> > > > -	}
> > > > -
> > > 
> > > I think the above procedure is still useful for safe guard.
> > 
> > But then it shoud to BUG_ON() instead of returning an error (which isn't very
> > useful for anything now).
> 
> Right since we cannot fail at that state.
> 
> > > > -	/* remove memmap entry */
> > > > -	firmware_map_remove(start, start + size, "System RAM");
> > > > -
> > > > -	arch_remove_memory(start, size);
> > > > -
> > > > -	try_offline_node(nid);
> > > 
> > > The above procedure performs memory hot-delete specific operations and
> > > is necessary.
> > 
> > OK, I see.  I'll replace this patch with something simpler, then.
> 
> Thanks.

The replacement patch is appended.

Thanks,
Rafael

---
From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Subject: Memory hotplug / ACPI: Simplify memory removal

Now that the memory offlining should be taken care of by the
companion device offlining code in acpi_scan_hot_remove(), the
ACPI memory hotplug driver doesn't need to offline it in
remove_memory() any more.  Moreover, since the return value of
remove_memory() is not used, it's better to make it be a void
function and trigger a BUG() if the memory scheduled for removal is
not offline.

Change the code in accordance with the above observations.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/acpi/acpi_memhotplug.c |   13 +------
 include/linux/memory_hotplug.h |    2 -
 mm/memory_hotplug.c            |   71 ++++-------------------------------------
 3 files changed, 12 insertions(+), 74 deletions(-)

Index: linux-pm/include/linux/memory_hotplug.h
===================================================================
--- linux-pm.orig/include/linux/memory_hotplug.h
+++ linux-pm/include/linux/memory_hotplug.h
@@ -252,7 +252,7 @@ extern int add_memory(int nid, u64 start
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern int remove_memory(int nid, u64 start, u64 size);
+extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
Index: linux-pm/drivers/acpi/acpi_memhotplug.c
===================================================================
--- linux-pm.orig/drivers/acpi/acpi_memhotplug.c
+++ linux-pm/drivers/acpi/acpi_memhotplug.c
@@ -271,13 +271,11 @@ static int acpi_memory_enable_device(str
 	return 0;
 }
 
-static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
+static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
 {
 	acpi_handle handle = mem_device->device->handle;
-	int result = 0, nid;
 	struct acpi_memory_info *info, *n;
-
-	nid = acpi_get_node(handle);
+	int nid = acpi_get_node(handle);
 
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (!info->enabled)
@@ -287,15 +285,10 @@ static int acpi_memory_remove_memory(str
 			nid = memory_add_physaddr_to_nid(info->start_addr);
 
 		acpi_unbind_memory_blocks(info, handle);
-		result = remove_memory(nid, info->start_addr, info->length);
-		if (result)
-			return result;
-
+		remove_memory(nid, info->start_addr, info->length);
 		list_del(&info->list);
 		kfree(info);
 	}
-
-	return result;
 }
 
 static void acpi_memory_device_free(struct acpi_memory_device *mem_device)
Index: linux-pm/mm/memory_hotplug.c
===================================================================
--- linux-pm.orig/mm/memory_hotplug.c
+++ linux-pm/mm/memory_hotplug.c
@@ -1670,24 +1670,6 @@ int walk_memory_range(unsigned long star
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/**
- * offline_memory_block_cb - callback function for offlining memory block
- * @mem: the memory block to be offlined
- * @arg: buffer to hold error msg
- *
- * Always return 0, and put the error msg in arg if any.
- */
-static int offline_memory_block_cb(struct memory_block *mem, void *arg)
-{
-	int *ret = arg;
-	int error = device_offline(&mem->dev);
-
-	if (error != 0 && *ret == 0)
-		*ret = error;
-
-	return 0;
-}
-
 static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
 {
 	int ret = !is_memblock_offlined(mem);
@@ -1813,54 +1795,22 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
-int __ref remove_memory(int nid, u64 start, u64 size)
+void __ref remove_memory(int nid, u64 start, u64 size)
 {
-	unsigned long start_pfn, end_pfn;
-	int ret = 0;
-	int retry = 1;
-
-	start_pfn = PFN_DOWN(start);
-	end_pfn = PFN_UP(start + size - 1);
-
-	/*
-	 * When CONFIG_MEMCG is on, one memory block may be used by other
-	 * blocks to store page cgroup when onlining pages. But we don't know
-	 * in what order pages are onlined. So we iterate twice to offline
-	 * memory:
-	 * 1st iterate: offline every non primary memory block.
-	 * 2nd iterate: offline primary (i.e. first added) memory block.
-	 */
-repeat:
-	walk_memory_range(start_pfn, end_pfn, &ret,
-			  offline_memory_block_cb);
-	if (ret) {
-		if (!retry)
-			return ret;
-
-		retry = 0;
-		ret = 0;
-		goto repeat;
-	}
+	int ret;
 
 	lock_memory_hotplug();
 
 	/*
-	 * we have offlined all memory blocks like this:
-	 *   1. lock memory hotplug
-	 *   2. offline a memory block
-	 *   3. unlock memory hotplug
-	 *
-	 * repeat step1-3 to offline the memory block. All memory blocks
-	 * must be offlined before removing memory. But we don't hold the
-	 * lock in the whole operation. So we should check whether all
-	 * memory blocks are offlined.
+	 * All memory blocks must be offlined before removing memory.  Check
+	 * whether all memory blocks in question are offline and trigger a BUG()
+	 * if this is not the case.
 	 */
-
-	ret = walk_memory_range(start_pfn, end_pfn, NULL,
+	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
 				is_memblock_offlined_cb);
 	if (ret) {
 		unlock_memory_hotplug();
-		return ret;
+		BUG();
 	}
 
 	/* remove memmap entry */
@@ -1871,17 +1821,12 @@ repeat:
 	try_offline_node(nid);
 
 	unlock_memory_hotplug();
-
-	return 0;
 }
 #else
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return -EINVAL;
 }
-int remove_memory(int nid, u64 start, u64 size)
-{
-	return -EINVAL;
-}
+void remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 EXPORT_SYMBOL_GPL(remove_memory);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
