Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C70DF6B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 10:04:49 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so5080142wid.0
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 07:04:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si10180908wiy.53.2014.12.08.07.04.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 07:04:47 -0800 (PST)
Date: Mon, 8 Dec 2014 16:04:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in the
 memory hot-add code
Message-ID: <20141208150445.GB29102@dhcp22.suse.cz>
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-2-git-send-email-kys@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417826498-21172-2-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com

On Fri 05-12-14 16:41:38, K. Y. Srinivasan wrote:
> Andy Whitcroft <apw@canonical.com> initially saw this deadlock. We
> have seen this as well. Here is the original description of the
> problem (and a potential solution) from Andy:
> 
> https://lkml.org/lkml/2014/3/14/451
> 
> Here is an excerpt from that mail:
> 
> "We are seeing machines lockup with what appears to be an ABBA
> deadlock in the memory hotplug system.  These are from the 3.13.6 based Ubuntu kernels.
> The hv_balloon driver is adding memory using add_memory() which takes
> the hotplug lock

Do you mean mem_hotplug_begin?

> and then emits a udev event, and then attempts to
> lock the sysfs device.  In response to the udev event udev opens the
> sysfs device and locks it, then attempts to grab the hotplug lock to online the memory.

Cannot we simply teach online_pages to fail with EBUSY when the memory
hotplug is on the way. We shouldn't try to online something that is not
initialized yet, no? The memory hotplug log is global so we can get
false positives but that should be easier to deal with than exporting
lock_device_hotplug and adding yet another lock dependency.

> This seems to be inverted nesting in the two cases, leading to the hangs below:
> 
> [  240.608612] INFO: task kworker/0:2:861 blocked for more than 120 seconds.
> [  240.608705] INFO: task systemd-udevd:1906 blocked for more than 120 seconds.
> 
> I note that the device hotplug locking allows complete retries (via
> ERESTARTSYS) and if we could detect this at the online stage it could
> be used to get us out.

I am not sure I understand this but it suggests EBUSY above?

> But before I go down this road I wanted to
> make sure I am reading this right.  Or indeed if the hv_balloon driver
> is just doing this wrong."
> 
> This patch is based on the suggestion from
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

This changelog doesn't explain us much. And boy this whole thing is so
convoluted. E.g. I have hard time to see why ACPI hotplug is working
correctly. My trail got lost at acpi_memory_device_add level which is
a callback while acpi_device_hotplug is holding lock_device_hotplug but
then again the rest is hidden by callbacks. I cannot seem to find any
documentation which would explain all the locking here.

So why other callers of add_memory don't need the same treatment and if
they do then why don't we use the lock at add_memory level?
 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Nak to this without proper explanation and I really think that it should
be the onlining code which should deal with the parallel add_memory and
back off until the full initialization is done.

> ---
>  drivers/hv/hv_balloon.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index afdb0d5..f525a62 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -22,6 +22,7 @@
>  #include <linux/jiffies.h>
>  #include <linux/mman.h>
>  #include <linux/delay.h>
> +#include <linux/device.h>
>  #include <linux/init.h>
>  #include <linux/module.h>
>  #include <linux/slab.h>
> @@ -649,8 +650,11 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  
>  		release_region_mutex(false);
>  		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
> +
> +		lock_device_hotplug();
>  		ret = add_memory(nid, PFN_PHYS((start_pfn)),
>  				(HA_CHUNK << PAGE_SHIFT));
> +		unlock_device_hotplug();
>  
>  		if (ret) {
>  			pr_info("hot_add memory failed error is %d\n", ret);
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
