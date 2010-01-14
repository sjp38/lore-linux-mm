Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D22D96B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 07:32:12 -0500 (EST)
Date: Thu, 14 Jan 2010 13:32:09 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] sysdev: fix prototype for memory_sysdev_class
	show/store functions
Message-ID: <20100114123209.GM12241@basil.fritz.box>
References: <20100114115956.GA2512@localhost> <20100114120419.GA3538@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114120419.GA3538@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 08:04:19PM +0800, Wu Fengguang wrote:
> The function prototype mismatches in call stack:
> 
>                 [<ffffffff81494268>] print_block_size+0x58/0x60
>                 [<ffffffff81487e3f>] sysdev_class_show+0x1f/0x30
>                 [<ffffffff811d629b>] sysfs_read_file+0xcb/0x1f0
>                 [<ffffffff81176328>] vfs_read+0xc8/0x180
> 
> Due to prototype mismatch, print_block_size() will sprintf() into
> *attribute instead of *buf, hence user space will read the initial
> zeros from *buf:
> 	$ hexdump /sys/devices/system/memory/block_size_bytes
> 	0000000 0000 0000 0000 0000
> 	0000008
> 
> After patch:
> 	cat /sys/devices/system/memory/block_size_bytes
> 	0x8000000
> 
> This complements commits c29af9636 and 4a0b2b4dbe.

Hmm, this was already fixed in my patch in the original series

SYSFS: Fix type of sysdev class attribute in memory driver

This attribute is really a sysdev_class attribute, not a plain class attribute.

They are identical in layout currently, but this might not always be 
the case.

And with the final patches they were identical in layout again anyways.

I don't know why Greg didn't merge that one. Greg, did you forget
some patches?

For the record the full series was:

SYSFS: Pass attribute in sysdev_class attributes show/store
SYSFS: Convert node driver class attributes to be data driven
SYSDEV: Convert cpu driver sysdev class attributes 
SYSFS: Add sysfs_add/remove_files utility functions
SYSFS: Add attribute array to sysdev classes
SYSDEV: Convert node driver 
SYSDEV: Use sysdev_class attribute arrays in node driver
SYSFS: Add sysdev_create/remove_files
SYSFS: Fix type of sysdev class attribute in memory driver
SYSDEV: Add attribute argument to class_attribute show/store
SYSFS: Add class_attr_string for simple read-only string
SYSFS: Convert some drivers to CLASS_ATTR_STRING

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
