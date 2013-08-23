Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 3603E6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 17:37:49 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id o17so1382009oag.7
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 14:37:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1377282543.10300.820.camel@misato.fc.hp.com>
References: <20130821204041.GC2436@htj.dyndns.org>
	<1377124595.10300.594.camel@misato.fc.hp.com>
	<20130822033234.GA2413@htj.dyndns.org>
	<1377186729.10300.643.camel@misato.fc.hp.com>
	<20130822183130.GA3490@mtj.dyndns.org>
	<1377202292.10300.693.camel@misato.fc.hp.com>
	<20130822202158.GD3490@mtj.dyndns.org>
	<1377205598.10300.715.camel@misato.fc.hp.com>
	<20130822212111.GF3490@mtj.dyndns.org>
	<1377209861.10300.756.camel@misato.fc.hp.com>
	<20130823130440.GC10322@mtj.dyndns.org>
	<1377274448.10300.777.camel@misato.fc.hp.com>
	<521793BB.9080605@gmail.com>
	<1377282543.10300.820.camel@misato.fc.hp.com>
Date: Sat, 24 Aug 2013 05:37:48 +0800
Message-ID: <CAD11hGzaK1Y1J7vQUOCQg8O767479qXQnYWm_72nPEK+E+TrHg@mail.gmail.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: chen tang <imtangchen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

Hi Toshi, tj,

Really sorry for the delay. There were so many discussions in this thread and
it took me a lot of time to read and follow them.

2013/8/24 Toshi Kani <toshi.kani@hp.com>:
......
> On Sat, 2013-08-24 at 00:54 +0800, Zhang Yanfei wrote:
>> > Tang, what do you think?  Are you OK to try Tejun's suggestion as well?
>> >

We have been working on this for a while. And will send the patches soon.
We are trying this idea and will see how it goes.

>>
>> By saying TJ's suggestion, you mean, we will let memblock to control the
>> behaviour, that said, we will do early allocations near the kernel image
>> range before we get the SRAT info?
>
> Right.
>
>> If so, yeah, we have been working on this direction.
>
> Great!
>
>> By doing this, we may
>> have two main changes:
>>
>> 1. change some of memblock's APIs to make it have the ability to allocate
>>    memory from low address.
>> 2. setup kernel page table down-top. Concretely, we first map the memory
>>    just after the kernel image to the top, then, we map 0 - kernel image end.
>>
>> Do you guys think this is reasonable and acceptable?
>
> Have you also looked at Yinghai's comments below?
>
> http://www.spinics.net/lists/linux-mm/msg61362.html
>

We have read the comments from Yinghai. Reordering relocated_initrd and
reserve_crashkernel is doable, and the most difficult part is change the page
tables initialization logic. And as Zhang has mentioned above, we are not sure
if this could be acceptable.

Actually I also stand with Toshi that we should get SRAT earlier. This
will solve
memory hotplug issue, and also the following local page table problem.

And as tj concerned about the stability of the kernel boot sequence, then how
about this:

We don't do acpi_initrd_override() that early in head_32.S and head_64.c. We do
it after early_ioremap is available. I have mentioned this before.

With the help of early_ioremap, which is used by many others, we can copy all
override tables into memory. In my understanding, the page tables setup by
early_ioremap will work just like direct mapping page tables, right ?
Then we unmap
the memory, it is done. And we don't need to split the whole procedure
into fnd & copy.

So to tj, this approach won't affect acpica and very early boot
sequence. Are you OK
with this ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
