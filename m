Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 0902A6B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 12:36:58 -0400 (EDT)
Message-ID: <1376584540.10300.416.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug: Remove stop_machine() from
 try_offline_node()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 15 Aug 2013 10:35:40 -0600
In-Reply-To: <520C2D04.8060408@gmail.com>
References: <1376336071-9128-1-git-send-email-toshi.kani@hp.com>
	 <520C2D04.8060408@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, tangchen@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, liwanp@linux.vnet.ibm.com

On Wed, 2013-08-14 at 21:21 -0400, KOSAKI Motohiro wrote:
> (8/12/13 3:34 PM), Toshi Kani wrote:
> > lock_device_hotplug() serializes hotplug & online/offline operations.
> > The lock is held in common sysfs online/offline interfaces and ACPI
> > hotplug code paths.
> > 
> > try_offline_node() off-lines a node if all memory sections and cpus
> > are removed on the node.  It is called from acpi_processor_remove()
> > and acpi_memory_remove_memory()->remove_memory() paths, both of which
> > are in the ACPI hotplug code.
> > 
> > try_offline_node() calls stop_machine() to stop all cpus while checking
> > all cpu status with the assumption that the caller is not protected from
> > CPU hotplug or CPU online/offline operations.  However, the caller is
> > always serialized with lock_device_hotplug().  Also, the code needs to
> > be properly serialized with a lock, not by stopping all cpus at a random
> > place with stop_machine().
> > 
> > This patch removes the use of stop_machine() in try_offline_node() and
> > adds comments to try_offline_node() and remove_memory() that
> > lock_device_hotplug() is required.
> 
> This patch need more verbose explanation. check_cpu_on_node() traverse cpus
> and cpu hotplug seems to use cpu_hotplug_driver_lock() instead of lock_device_hotplug().

As described: 

| lock_device_hotplug() serializes hotplug & online/offline operations.
| The lock is held in common sysfs online/offline interfaces and ACPI
| hotplug code paths.

And here are their code paths.

- CPU & Mem online/offline via sysfs online
	store_online()->lock_device_hotplug()

- Mem online via sysfs state:
	store_mem_state()->lock_device_hotplug()

- ACPI CPU & Mem hot-add:
	acpi_scan_bus_device_check()->lock_device_hotplug()

- ACPI CPU & Mem hot-delete:
	acpi_scan_hot_remove()->lock_device_hotplug()

> That said, the race is not happen against another memeory happen. It's likely happen
> another cpu hotplug. So commenting remove_memory() doesn't make much sense.

This lock scheme protects from both CPU and memory hotplug, and requires
the caller to call lock_device_hotplug().

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
