Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 808206B0008
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:09:29 -0500 (EST)
Date: Tue, 29 Jan 2013 23:53:30 -0500
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130130045330.GF30002@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <1357861230-29549-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357861230-29549-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Thu, Jan 10, 2013 at 04:40:19PM -0700, Toshi Kani wrote:
> Added include/linux/sys_hotplug.h, which defines the system device
> hotplug framework interfaces used by the framework itself and
> handlers.
> 
> The order values define the calling sequence of handlers.  For add
> execute, the ordering is ACPI->MEM->CPU.  Memory is onlined before
> CPU so that threads on new CPUs can start using their local memory.
> The ordering of the delete execute is symmetric to the add execute.
> 
> struct shp_request defines a hot-plug request information.  The
> device resource information is managed with a list so that a single
> request may target to multiple devices.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  include/linux/sys_hotplug.h |  181 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 181 insertions(+)
>  create mode 100644 include/linux/sys_hotplug.h
> 
> diff --git a/include/linux/sys_hotplug.h b/include/linux/sys_hotplug.h
> new file mode 100644
> index 0000000..86674dd
> --- /dev/null
> +++ b/include/linux/sys_hotplug.h
> @@ -0,0 +1,181 @@
> +/*
> + * sys_hotplug.h - System device hot-plug framework
> + *
> + * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
> + *	Toshi Kani <toshi.kani@hp.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#ifndef _LINUX_SYS_HOTPLUG_H
> +#define _LINUX_SYS_HOTPLUG_H
> +
> +#include <linux/list.h>
> +#include <linux/device.h>
> +
> +/*
> + * System device hot-plug operation proceeds in the following order.
> + *   Validate phase -> Execute phase -> Commit phase
> + *
> + * The order values below define the calling sequence of platform
> + * neutral handlers for each phase in ascending order.  The order
> + * values of firmware-specific handlers are defined in sys_hotplug.h
> + * under firmware specific directories.
> + */
> +
> +/* All order values must be smaller than this value */
> +#define SHP_ORDER_MAX				0xffffff
> +
> +/* Add Validate order values */
> +
> +/* Add Execute order values */
> +#define SHP_MEM_ADD_EXECUTE_ORDER		100
> +#define SHP_CPU_ADD_EXECUTE_ORDER		110
> +
> +/* Add Commit order values */
> +
> +/* Delete Validate order values */
> +#define SHP_CPU_DEL_VALIDATE_ORDER		100
> +#define SHP_MEM_DEL_VALIDATE_ORDER		110
> +
> +/* Delete Execute order values */
> +#define SHP_CPU_DEL_EXECUTE_ORDER		10
> +#define SHP_MEM_DEL_EXECUTE_ORDER		20
> +
> +/* Delete Commit order values */
> +

Empty value?

Anyway, as I said before, don't use "values", just call things directly
in the order you need to.

This isn't like other operating systems, we don't need to be so
"flexible", we can modify the core code as much as we want and need to
if future things come along :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
