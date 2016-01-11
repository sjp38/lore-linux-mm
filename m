Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 476DD828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:43:14 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id x67so429650773ykd.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:43:14 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q207si13816642ywg.215.2016.01.11.04.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:43:13 -0800 (PST)
Date: Mon, 11 Jan 2016 13:42:33 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCH v3] memory-hotplug: add automatic onlining policy for the
 newly added memory
Message-ID: <20160111124233.GN3485@olila.local.net-space.pl>
References: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
 <20160108140123.GK3485@olila.local.net-space.pl>
 <87y4c02eqc.fsf@vitty.brq.redhat.com>
 <20160111081013.GM3485@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111081013.GM3485@olila.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Mon, Jan 11, 2016 at 09:10:13AM +0100, Daniel Kiper wrote:
> On Fri, Jan 08, 2016 at 05:55:07PM +0100, Vitaly Kuznetsov wrote:
> > Daniel Kiper <daniel.kiper@oracle.com> writes:
>
> [...]
>
> > >> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> > >> index ce2cfcf..ceaf40c 100644
> > >> --- a/Documentation/memory-hotplug.txt
> > >> +++ b/Documentation/memory-hotplug.txt
> > >> @@ -254,12 +254,23 @@ If the memory block is online, you'll read "online".
> > >>  If the memory block is offline, you'll read "offline".
> > >>
> > >>
> > >> -5.2. How to online memory
> > >> +5.2. Memory onlining
> > >>  ------------
> > >> -Even if the memory is hot-added, it is not at ready-to-use state.
> > >> -For using newly added memory, you have to "online" the memory block.
> > >> +When the memory is hot-added, the kernel decides whether or not to "online"
> > >> +it according to the policy which can be read from "auto_online_blocks" file:
> > >>
> > >> -For onlining, you have to write "online" to the memory block's state file as:
> > >> +% cat /sys/devices/system/memory/auto_online_blocks
> > >> +
> > >> +The default is "offline" which means the newly added memory is not in a
> > >> +ready-to-use state and you have to "online" the newly added memory blocks
> > >> +manually. Automatic onlining can be requested by writing "online" to
> > >> +"auto_online_blocks" file:
> > >> +
> > >> +% echo online > /sys/devices/system/memory/auto_online_blocks
> > >> +
> > >> +If the automatic onlining wasn't requested or some memory block was offlined
> > >> +it is possible to change the individual block's state by writing to the "state"
> > >> +file:
> > >>
> > >>  % echo online > /sys/devices/system/memory/memoryXXX/state
> > >
> > > Please say clearly that offlined blocks are not onlined automatically
> > > when /sys/devices/system/memory/auto_online_blocks is set to online.
> > >
> >
> > You mean the blocks which were manually offlined won't magically come
> > back, right? Ok, I'll try.
>
> Yep, but AIUI it works in that way for all offlined blocks not only for
> earlier manually offlined ones.
>
> > >> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> > >> index 25425d3..44a618d 100644
> > >> --- a/drivers/base/memory.c
> > >> +++ b/drivers/base/memory.c
> > >> @@ -439,6 +439,37 @@ print_block_size(struct device *dev, struct device_attribute *attr,
> > >>  static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
> > >>
> > >>  /*
> > >> + * Memory auto online policy.
> > >> + */
> > >> +
> > >> +static ssize_t
> > >> +show_auto_online_blocks(struct device *dev, struct device_attribute *attr,
> > >> +			char *buf)
> > >> +{
> > >> +	if (memhp_auto_online)
> > >> +		return sprintf(buf, "online\n");
> > >> +	else
> > >> +		return sprintf(buf, "offline\n");
> > >> +}
> > >> +
> > >> +static ssize_t
> > >> +store_auto_online_blocks(struct device *dev, struct device_attribute *attr,
> > >> +			 const char *buf, size_t count)
> > >> +{
> > >> +	if (sysfs_streq(buf, "online"))
> > >> +		memhp_auto_online = true;
> > >> +	else if (sysfs_streq(buf, "offline"))
> > >> +		memhp_auto_online = false;
> > >> +	else
> > >> +		return -EINVAL;
> > >> +
> > >> +	return count;
> > >> +}
> > >> +
> > >> +static DEVICE_ATTR(auto_online_blocks, 0644, show_auto_online_blocks,
> > >> +		   store_auto_online_blocks);
> > >> +
> > >> +/*
> > >>   * Some architectures will have custom drivers to do this, and
> > >>   * will not need to do it from userspace.  The fake hot-add code
> > >>   * as well as ppc64 will do all of their discovery in userspace
> > >> @@ -737,6 +768,7 @@ static struct attribute *memory_root_attrs[] = {
> > >>  #endif
> > >>
> > >>  	&dev_attr_block_size_bytes.attr,
> > >> +	&dev_attr_auto_online_blocks.attr,
> > >>  	NULL
> > >>  };
> > >>
> > >> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> > >> index 12eab50..890c3b5 100644
> > >> --- a/drivers/xen/balloon.c
> > >> +++ b/drivers/xen/balloon.c
> > >> @@ -338,7 +338,7 @@ static enum bp_state reserve_additional_memory(void)
> > >>  	}
> > >>  #endif
> > >>
> > >> -	rc = add_memory_resource(nid, resource);
> > >> +	rc = add_memory_resource(nid, resource, false);
> > >
> > > This is partial solution and does not allow us to use new feature in Xen.
> > > Could you add separate patch which fixes this issue?
> > >
> >
> > Sure, I'd be glad to make this work for Xen too.
>
> Great! Thanks a lot!
>
> > >>  	if (rc) {
> > >>  		pr_warn("Cannot add additional memory (%i)\n", rc);
> > >>  		goto err;
> > >> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > >> index 2ea574f..4b7949a 100644
> > >> --- a/include/linux/memory_hotplug.h
> > >> +++ b/include/linux/memory_hotplug.h
> > >> @@ -99,6 +99,8 @@ extern void __online_page_free(struct page *page);
> > >>
> > >>  extern int try_online_node(int nid);
> > >>
> > >> +extern bool memhp_auto_online;
> > >> +
> > >>  #ifdef CONFIG_MEMORY_HOTREMOVE
> > >>  extern bool is_pageblock_removable_nolock(struct page *page);
> > >>  extern int arch_remove_memory(u64 start, u64 size);
> > >> @@ -267,7 +269,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
> > >>  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> > >>  		void *arg, int (*func)(struct memory_block *, void *));
> > >>  extern int add_memory(int nid, u64 start, u64 size);
> > >> -extern int add_memory_resource(int nid, struct resource *resource);
> > >> +extern int add_memory_resource(int nid, struct resource *resource, bool online);
> > >>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> > >>  		bool for_device);
> > >>  extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> > >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > >> index a042a9d..0ecf860 100644
> > >> --- a/mm/memory_hotplug.c
> > >> +++ b/mm/memory_hotplug.c
> > >> @@ -76,6 +76,9 @@ static struct {
> > >>  #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
> > >>  #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
> > >>
> > >> +bool memhp_auto_online;
> > >> +EXPORT_SYMBOL_GPL(memhp_auto_online);
> > >> +
> > >>  void get_online_mems(void)
> > >>  {
> > >>  	might_sleep();
> > >> @@ -1232,7 +1235,7 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> > >>  }
> > >>
> > >>  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> > >> -int __ref add_memory_resource(int nid, struct resource *res)
> > >> +int __ref add_memory_resource(int nid, struct resource *res, bool online)
> > >>  {
> > >>  	u64 start, size;
> > >>  	pg_data_t *pgdat = NULL;
> > >> @@ -1292,6 +1295,11 @@ int __ref add_memory_resource(int nid, struct resource *res)
> > >>  	/* create new memmap entry */
> > >>  	firmware_map_add_hotplug(start, start + size, "System RAM");
> > >>
> > >> +	/* online pages if requested */
> > >> +	if (online)
> > >> +		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> > >> +			     MMOP_ONLINE_KEEP);
> > >> +
> > >
> > > This way we go in deadlock if auto online feature is enabled in Xen (this was
> > > pointed out by David Vrabel).
> >
> > Yes, but as I said the patch doesn't change anything for Xen guests for
> > now, we always call add_memory_resource() with online = false.
> >
> > > And we want to have it working out of the box.
> > > So, I think that we should find proper solution. I suppose that we can schedule
> > > a task here which auto online attached blocks. Hmmm... Not nice but should work.
> > > Or maybe you have better idea how to fix this issue.
> >
> > I'd like to avoid additional delays and memory allocations between
> > adding new memory and onlining it (and this is the main purpose of the
> > patch). Maybe we can have a tristate online parameter ('online_now',
> > 'online_delay', 'keep_offlined') and handle it
> > accordingly. Alternatively I can suggest we have the onlining in Xen
> > balloon driver code, memhp_auto_online is exported so we can call
> > online_pages() after we release the ballon_mutex.
>
> This is not nice too. I prefer the same code path for every case.
> Give me some time. I will think how to solve that issue.

It looks that we can safely call mutex_unlock() just before add_memory_resource()
call and retake lock immediately after add_memory_resource(). add_memory_resource()
itself does not play with balloon stuff and even if online_pages() does then it
take balloon_mutex in right place. Additionally, only one balloon task can run,
so, I think that we are on safe side. Am I right?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
