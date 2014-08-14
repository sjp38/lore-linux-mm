Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E18966B0038
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 16:13:01 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2249347pad.13
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:13:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yp8si5216063pac.193.2014.08.14.13.13.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 13:13:00 -0700 (PDT)
Date: Thu, 14 Aug 2014 13:12:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for Aug 14 (mm/memory_hotplug.c and
 drivers/base/memory.c)
Message-Id: <20140814131259.0e56829123ba1123bbe1685a@linux-foundation.org>
In-Reply-To: <53ECCF7E.2090305@infradead.org>
References: <20140814152749.24d43663@canb.auug.org.au>
	<53ECCF7E.2090305@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux MM <linux-mm@kvack.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>

On Thu, 14 Aug 2014 08:02:22 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 08/13/14 22:27, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Please do not add code intended for v3.18 until after v3.17-rc1 is
> > released.
> > 
> > Changes since 20140813:
> > 
> 
> on x86_64:
> 
> drivers/built-in.o: In function `show_zones_online_to':
> memory.c:(.text+0x13f306): undefined reference to `test_pages_in_a_zone'
> 
> in drivers/base/memory.c
> 
> when CONFIG_MEMORY_HOTREMOVE is not enabled.
> 
> The function implementation in mm/memory_hotplug.c is only built if
> CONFIG_MEMORY_HOTREMOVE is enabled.

Thanks.   This way, I suppose.

--- a/drivers/base/memory.c~memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2
+++ a/drivers/base/memory.c
@@ -373,6 +373,7 @@ static ssize_t show_phys_device(struct d
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static int __zones_online_to(unsigned long end_pfn,
 				struct page *first_page, unsigned long nr_pages)
 {
@@ -432,12 +433,13 @@ static ssize_t show_zones_online_to(stru
 
 	return sprintf(buf, "%s\n", zone->name);
 }
+static DEVICE_ATTR(zones_online_to, 0444, show_zones_online_to, NULL);
+#endif
 
 static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
 static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
 static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
 static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
-static DEVICE_ATTR(zones_online_to, 0444, show_zones_online_to, NULL);
 
 /*
  * Block size attribute stuff
@@ -584,7 +586,9 @@ static struct attribute *memory_memblk_a
 	&dev_attr_state.attr,
 	&dev_attr_phys_device.attr,
 	&dev_attr_removable.attr,
+#ifdef CONFIG_MEMORY_HOTREMOVE
 	&dev_attr_zones_online_to.attr,
+#endif
 	NULL
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
