Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E62CC6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 19:56:22 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id ta17so1333566obb.32
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 16:56:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130823215243.GD11391@mtj.dyndns.org>
References: <1377202292.10300.693.camel@misato.fc.hp.com>
	<20130822202158.GD3490@mtj.dyndns.org>
	<1377205598.10300.715.camel@misato.fc.hp.com>
	<20130822212111.GF3490@mtj.dyndns.org>
	<1377209861.10300.756.camel@misato.fc.hp.com>
	<20130823130440.GC10322@mtj.dyndns.org>
	<1377274448.10300.777.camel@misato.fc.hp.com>
	<521793BB.9080605@gmail.com>
	<1377282543.10300.820.camel@misato.fc.hp.com>
	<CAD11hGzaK1Y1J7vQUOCQg8O767479qXQnYWm_72nPEK+E+TrHg@mail.gmail.com>
	<20130823215243.GD11391@mtj.dyndns.org>
Date: Sat, 24 Aug 2013 07:56:21 +0800
Message-ID: <CAD11hGyuT9s9LnEnBjaw9hZH+ABicUC-krP7AupJg8PXjOm=LQ@mail.gmail.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: chen tang <imtangchen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

Hi tj,

2013/8/24 Tejun Heo <tj@kernel.org>:
> Hello,
>
> On Sat, Aug 24, 2013 at 05:37:48AM +0800, chen tang wrote:
>> We have read the comments from Yinghai. Reordering relocated_initrd and
>> reserve_crashkernel is doable, and the most difficult part is change the page
>> tables initialization logic. And as Zhang has mentioned above, we are not sure
>> if this could be acceptable.
>
> Maybe I'm missing something but why is that so hard?  All it does is
> allocating memory in a different place.  Why is that so complicated?
> Can somebody please elaborate the issues here?  If it is actually
> hairy, where does the hairiness come from?  Is it an inherent problem
> or just an issue with how the code is organized currently?

Your idea is doable, and we are doing it now. I think it is just an issue
with how to organize the code.

The main problem is like Yinghai said, memory hotplug kernel and regular
kernel won't be able to share the code. We use a boot option to control it.

And I'll send a patch-set next week and then we can see how it goes.

......
>> And as tj concerned about the stability of the kernel boot sequence, then how
>> about this:
>
> I guess my answer remains the same.  Why?  What actual benefits does
> doing so buy us and why is changing the allocation direction, which
> conceptually is extremely simple, so complicated?  What you guys are
> trying to do adds significant amount of complexity and convolution,
> which in itself doesn't necessarily disqualify the changes but it
> needs good enough justifications.
>
> I get that you guys want it but I still fail to see why.  It *can't*
> be proper solution to the hotplug issue.  We don't want earlyprintk to
> involve huge chunk of logic and the benefits of node-affine page
> tables for kernel linear mapping seem dubious.  So, what do we gain by
> doing this?  What am I missing here?
>

Sorry for the unclear description. To summaries, the whole picture is:

We are going to provide a system with some nodes hotpluggable, not all.
These nodes are movable nodes, with only ZONE_MOVABLE. So we need
a way to ensure the movable nodes have ZONE_MOVABLE only.

We want SRAT earlier because before it is parsed, memblock starts to
allocate memory for kernel, which won't be in ZONE_MOVABLE.

It is just that simple. You are not missing anything here, I think.

My suggestion is parsing SRAT earlier:
1. The nodes kernel resides in will be un-movable.
2. The nodes with un-hotpluggable memory in SRAT will be un-movable.
3. The nodes full of hotpluggable memory in SRAT will be movable nodes.

No offence, but seeing from me, it is a solution. The only thing it could buy
me is that I can achieve the goal. I was trying my best to avoid bad influence
to other code.
And other things, early_printk, and local node page table are some other
cases that also need acpi tables earlier.

That is exactly all the things I want to do. That is all I have, and I
don't have
anything new here.

I read the whole series, and I understand your points:
1. Even if move SRAT earlier, it is too late. It should be done in
bootloader and
    kexec/kdump.
2. Doing so will make boot sequence more complicated and error-prone.
3. early_printk and local node page table won't by us so much when
using huge page.

...maybe some other points, I won't elaborate them all.

Since we have discussed so much, I don't want debate more. We are working on
patch-set according to your idea, and I also agree it is doable. I
have no objection to
your idea. Sending this patch-set is just one of my another try. So,
let's see how
it will go next week. :)

Thank you all for your comments and patient. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
