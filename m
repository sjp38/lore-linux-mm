Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0345B6B0085
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:48:15 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so21185404pdj.12
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:48:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tt8si13695970pbc.138.2013.12.03.15.48.14
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 15:48:14 -0800 (PST)
Date: Tue, 3 Dec 2013 15:48:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND part2 v2 0/8] Arrange hotpluggable memory as
 ZONE_MOVABLE
Message-Id: <20131203154811.90113f91ddd23413dd92b768@linux-foundation.org>
In-Reply-To: <529D3FC0.6000403@cn.fujitsu.com>
References: <529D3FC0.6000403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, 03 Dec 2013 10:19:44 +0800 Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:

> The current Linux cannot migrate pages used by the kerenl because
> of the kernel direct mapping. In Linux kernel space, va = pa + PAGE_OFFSET.
> When the pa is changed, we cannot simply update the pagetable and
> keep the va unmodified. So the kernel pages are not migratable.
> 
> There are also some other issues will cause the kernel pages not migratable.
> For example, the physical address may be cached somewhere and will be used.
> It is not to update all the caches.
> 
> When doing memory hotplug in Linux, we first migrate all the pages in one
> memory device somewhere else, and then remove the device. But if pages are
> used by the kernel, they are not migratable. As a result, memory used by
> the kernel cannot be hot-removed.
> 
> Modifying the kernel direct mapping mechanism is too difficult to do. And
> it may cause the kernel performance down and unstable. So we use the following
> way to do memory hotplug.
> 
> 
> [What we are doing]
> 
> In Linux, memory in one numa node is divided into several zones. One of the
> zones is ZONE_MOVABLE, which the kernel won't use.
> 
> In order to implement memory hotplug in Linux, we are going to arrange all
> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use these memory.

How does the user enable this?  I didn't spot a Kconfig variable which
enables it.  Is there a boot option?

Or is it always enabled?  If so, that seems incautious - if it breaks
in horrid ways we want people to be able to go back to the usual
behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
