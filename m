Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id F02786B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 16:17:49 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Fri, 11 Jan 2013 22:23:34 +0100
Message-ID: <5036592.TuXAnGzk4M@vostro.rjw.lan>
In-Reply-To: <1357861230-29549-2-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <1357861230-29549-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Thursday, January 10, 2013 04:40:19 PM Toshi Kani wrote:
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
> +/*
> + * Hot-plug request types
> + */
> +#define SHP_REQ_ADD		0x000000
> +#define SHP_REQ_DELETE		0x000001
> +#define SHP_REQ_MASK		0x0000ff
> +
> +/*
> + * Hot-plug phase types
> + */
> +#define SHP_PH_VALIDATE		0x000000
> +#define SHP_PH_EXECUTE		0x000100
> +#define SHP_PH_COMMIT		0x000200
> +#define SHP_PH_MASK		0x00ff00
> +
> +/*
> + * Hot-plug operation types
> + */
> +#define SHP_OP_HOTPLUG		0x000000
> +#define SHP_OP_ONLINE		0x010000
> +#define SHP_OP_MASK		0xff0000
> +
> +/*
> + * Hot-plug phases
> + */
> +enum shp_phase {
> +	SHP_ADD_VALIDATE	= (SHP_REQ_ADD|SHP_PH_VALIDATE),
> +	SHP_ADD_EXECUTE		= (SHP_REQ_ADD|SHP_PH_EXECUTE),
> +	SHP_ADD_COMMIT		= (SHP_REQ_ADD|SHP_PH_COMMIT),
> +	SHP_DEL_VALIDATE	= (SHP_REQ_DELETE|SHP_PH_VALIDATE),
> +	SHP_DEL_EXECUTE		= (SHP_REQ_DELETE|SHP_PH_EXECUTE),
> +	SHP_DEL_COMMIT		= (SHP_REQ_DELETE|SHP_PH_COMMIT)
> +};
> +
> +/*
> + * Hot-plug operations
> + */
> +enum shp_operation {
> +	SHP_HOTPLUG_ADD		= (SHP_OP_HOTPLUG|SHP_REQ_ADD),
> +	SHP_HOTPLUG_DEL		= (SHP_OP_HOTPLUG|SHP_REQ_DELETE),
> +	SHP_ONLINE_ADD		= (SHP_OP_ONLINE|SHP_REQ_ADD),
> +	SHP_ONLINE_DEL		= (SHP_OP_ONLINE|SHP_REQ_DELETE)
> +};
> +
> +/*
> + * Hot-plug device classes
> + */
> +enum shp_class {
> +	SHP_CLS_INVALID		= 0,
> +	SHP_CLS_CPU		= 1,
> +	SHP_CLS_MEMORY		= 2,
> +	SHP_CLS_HOSTBRIDGE	= 3,
> +	SHP_CLS_CONTAINER	= 4,
> +};
> +
> +/*
> + * Hot-plug device information
> + */
> +union shp_dev_info {
> +	struct shp_cpu {
> +		u32		cpu_id;
> +	} cpu;
> +
> +	struct shp_memory {
> +		int		node;
> +		u64		start_addr;
> +		u64		length;
> +	} mem;
> +
> +	struct shp_hostbridge {
> +	} hb;
> +
> +	struct shp_node {
> +	} node;
> +};
> +
> +struct shp_device {
> +	struct list_head	list;
> +	struct device		*device;
> +	enum shp_class		class;
> +	union shp_dev_info	info;
> +};
> +
> +/*
> + * Hot-plug request
> + */
> +struct shp_request {
> +	/* common info */
> +	enum shp_operation	operation;	/* operation */
> +
> +	/* hot-plug event info: only valid for hot-plug operations */
> +	void			*handle;	/* FW handle */

What's the role of handle here?


> +	u32			event;		/* FW event */
> +
> +	/* device resource info */
> +	struct list_head	dev_list;	/* shp_device list */
> +};
> +
> +/*
> + * Inline Utility Functions
> + */
> +static inline bool shp_is_hotplug_op(enum shp_operation operation)
> +{
> +	return (operation & SHP_OP_MASK) == SHP_OP_HOTPLUG;
> +}
> +
> +static inline bool shp_is_online_op(enum shp_operation operation)
> +{
> +	return (operation & SHP_OP_MASK) == SHP_OP_ONLINE;
> +}
> +
> +static inline bool shp_is_add_op(enum shp_operation operation)
> +{
> +	return (operation & SHP_REQ_MASK) == SHP_REQ_ADD;
> +}
> +
> +static inline bool shp_is_add_phase(enum shp_phase phase)
> +{
> +	return (phase & SHP_REQ_MASK) == SHP_REQ_ADD;
> +}
> +
> +/*
> + * Externs
> + */
> +typedef int (*shp_func)(struct shp_request *req, int rollback);
> +extern int shp_register_handler(enum shp_phase phase, shp_func func, u32 order);
> +extern int shp_unregister_handler(enum shp_phase phase, shp_func func);
> +extern int shp_submit_req(struct shp_request *req);
> +extern struct shp_request *shp_alloc_request(enum shp_operation operation);
> +extern void shp_add_dev_info(struct shp_request *shp_req,
> +		struct shp_device *shp_dev);
> +
> +#endif	/* _LINUX_SYS_HOTPLUG_H */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
