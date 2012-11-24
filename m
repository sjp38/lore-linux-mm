Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1323F6B0044
	for <linux-mm@kvack.org>; Sat, 24 Nov 2012 11:20:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so3169873pad.14
        for <linux-mm@kvack.org>; Sat, 24 Nov 2012 08:20:52 -0800 (PST)
Message-ID: <50B0F3DF.4000802@gmail.com>
Date: Sun, 25 Nov 2012 00:20:47 +0800
From: Wen Congyang <wencongyang@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <1353693037-21704-4-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1353693037-21704-4-git-send-email-vasilis.liaskovitis@profitbricks.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

At 2012/11/24 1:50, Vasilis Liaskovitis Wrote:
> Consider the following sequence of operations for a hotplugged memory device:
> 
> 1. echo "PNP0C80:XX">  /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> 2. echo "PNP0C80:XX">  /sys/bus/acpi/drivers/acpi_memhotplug/bind
> 3. echo 1>/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> The driver is successfully re-bound to the device in step 2. However step 3 will
> not attempt to remove the memory. This is because the acpi_memory_info enabled
> bit for the newly bound driver has not been set to 1. This bit needs to be set
> in the case where the memory is already used by the kernel (add_memory returns
> -EEXIST)

Hmm, I think the reason is that we don't offline/remove memory when
unbinding it
from the driver. I have sent a patch to fix this problem, and this patch
is in
pm tree now. With this patch, we will offline/remove memory when
unbinding it from
the drriver.

Consider the following sequence of operations for a hotplugged memory
device:

1. echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

If we don't offline/remove the memory, we have no chance to do it in
step 2. After
step2, the memory is used by the kernel, but we have powered off it. It
is very
dangerous.

So this patch is unnecessary now.

Thanks
Wen Congyang

> 
> Setting the enabled bit in this case (in acpi_memory_enable_device) makes the
> driver function properly after a rebind of the driver i.e. eject operation
> attempts to remove memory after a successful rebind.
> 
> I am not sure if this breaks some other usage of the enabled bit (see commit
> 65479472). When is it possible for the memory to be in use by the kernel but
> not managed by the acpi driver, apart from a driver unbind scenario?
> 
> Perhaps the patch is not needed, depending on expected semantics of re-binding.
> Is the newly bound driver supposed to manage the device, if it was earlier
> managed by the same driver?
> 
> This patch is only specific to this scenario, and can be dropped from the patch
> series if needed.
> 
> Signed-off-by: Vasilis Liaskovitis<vasilis.liaskovitis@profitbricks.com>
> ---
>   drivers/acpi/acpi_memhotplug.c |    3 +--
>   1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index d0cfbd9..0562cb4 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -271,12 +271,11 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   			continue;
>   		}
> 
> -		if (!result)
> -			info->enabled = 1;
>   		/*
>   		 * Add num_enable even if add_memory() returns -EEXIST, so the
>   		 * device is bound to this driver.
>   		 */
> +		info->enabled = 1;
>   		num_enabled++;
>   	}
>   	if (!num_enabled) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
