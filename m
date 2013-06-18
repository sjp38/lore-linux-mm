Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 366706B003D
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 20:07:31 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id f10so1261077yha.25
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:07:30 -0700 (PDT)
Date: Mon, 17 Jun 2013 17:07:22 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 08/22] x86, ACPI: Make acpi_initrd_override_find
 work with 32bit flat mode
Message-ID: <20130618000722.GR32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-9-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-9-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

On Thu, Jun 13, 2013 at 09:02:55PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> For finding procedure, it would be easy to access initrd in 32bit flat
> mode, as we don't need to setup page table. That is from head_32.S, and
> microcode updating already use this trick.

It'd be really great if you can give a brief explanation of why this
is happening at the beginning of the commit description so that when
someone lands on this commit later on, [s]he can orient oneself.  It
doesn't have to be long.  Open with something like,

 To make NUMA info available early during boot for memory hotplug
 support, acpi_initrd_override_find() needs to be used very early
 during boot.

and then continue to describe what's happening.  It'll make the commit
a lot more approachable to people who just encountered it.

> This patch does the following:
> 
> 1. Change acpi_initrd_override_find to use phys to access global variables.
> 
> 2. Pass a bool parameter "is_phys" to acpi_initrd_override_find() because
>    we cannot tell if it is a pa or a va through the address itself with
>    32bit. Boot loader could load initrd above max_low_pfn.

Do you mean "from 32bit address boundary"?  Maybe "from 4G boundary"
is clearer?

> 
> 3. Put table_sigs[] on stack, otherwise it is too messy to change string
>    array to physaddr and still keep offset calculating correct. The size is
>    about 36x4 bytes, and it is small to settle in stack.
> 
> 4. Also rewrite the MACRO INVALID_TABLE to be in a do {...} while(0) loop
>    so that it is more readable.

The important part is taking "continue" out of it, right?

> +/*
> + * acpi_initrd_override_find() is called from head_32.S and head64.c.
> + * head_32.S calling path is with 32bit flat mode, so we can access

When called from head_32.S, the CPU is in 32bit flat mode and the
kernel virtual address space isn't available yet.

> + * initrd early without setting pagetable or relocating initrd. For
> + * global variables accessing, we need to use phys address instead of

As initrd is in phys_addr, it can be accessed directly; however,
global variables must be accessed by explicitly obtaining their
physical addresses.

> + * kernel virtual address, try to put table_sigs string array in stack,
> + * so avoid switching for it.

Note that table_sigs array is built on stack to avoid such address
translations while accessing its members.

> + * Also don't call printk as it uses global variables.
> + */
> +void __init acpi_initrd_override_find(void *data, size_t size, bool is_phys)

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
