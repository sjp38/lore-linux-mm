Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C915A6B000E
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:09:41 -0500 (EST)
Date: Tue, 29 Jan 2013 23:58:30 -0500
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130130045830.GH30002@kroah.com>
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
> +/*
> + * Hot-plug device information
> + */

Again, stop it with the "generic" hotplug term here, and everywhere
else.  You are doing a very _specific_ type of hotplug devices, so spell
it out.  We've worked hard to hotplug _everything_ in Linux, you are
going to confuse a lot of people with this type of terms.

> +union shp_dev_info {
> +	struct shp_cpu {
> +		u32		cpu_id;
> +	} cpu;

What is this?  Why not point to the system device for the cpu?

> +	struct shp_memory {
> +		int		node;
> +		u64		start_addr;
> +		u64		length;
> +	} mem;

Same here, why not point to the system device?

> +	struct shp_hostbridge {
> +	} hb;
> +
> +	struct shp_node {
> +	} node;

What happened here with these?  Empty structures?  Huh?

> +};
> +
> +struct shp_device {
> +	struct list_head	list;
> +	struct device		*device;

No, make it a "real" device, embed the device into it.

But, again, I'm going to ask why you aren't using the existing cpu /
memory / bridge / node devices that we have in the kernel.  Please use
them, or give me a _really_ good reason why they will not work.

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
> +	u32			event;		/* FW event */

What is this?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
