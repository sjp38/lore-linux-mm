Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id E95456B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:32:21 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so4520837pbc.7
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:32:21 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so3697555pab.3
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:32:19 -0700 (PDT)
Message-ID: <5241944B.4050103@gmail.com>
Date: Tue, 24 Sep 2013 21:31:55 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mem-hotplug: Introduce movablenode boot option
References: <524162DA.30004@cn.fujitsu.com> <5241655E.1000007@cn.fujitsu.com> <20130924124121.GG2366@htj.dyndns.org>
In-Reply-To: <20130924124121.GG2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 09/24/2013 08:41 PM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 24, 2013 at 06:11:42PM +0800, Zhang Yanfei wrote:
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index 36cfce3..2cf04fd 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -1132,6 +1132,14 @@ void __init setup_arch(char **cmdline_p)
>>  	early_acpi_boot_init();
>>  
>>  	initmem_init();
>> +
>> +	/*
>> +	 * When ACPI SRAT is parsed, which is done in initmem_init(),
>> +	 * set memblock back to the top-down direction.
>> +	 */
>> +	if (memblock_bottom_up())
>> +		memblock_set_bottom_up(false);
> 
> I don't think you need the if ().  Just call
> memblock_set_bottom_up(false).

OK, will remove it.

> 
>> +static int __init cmdline_parse_movablenode(char *p)
>> +{
>> +	/*
>> +	 * Memory used by the kernel cannot be hot-removed because Linux
>> +	 * cannot migrate the kernel pages. When memory hotplug is
>> +	 * enabled, we should prevent memblock from allocating memory
>> +	 * for the kernel.
>> +	 *
>> +	 * ACPI SRAT records all hotpluggable memory ranges. But before
>> +	 * SRAT is parsed, we don't know about it.
>> +	 *
>> +	 * The kernel image is loaded into memory at very early time. We
>> +	 * cannot prevent this anyway. So on NUMA system, we set any
>> +	 * node the kernel resides in as un-hotpluggable.
>> +	 *
>> +	 * Since on modern servers, one node could have double-digit
>> +	 * gigabytes memory, we can assume the memory around the kernel
>> +	 * image is also un-hotpluggable. So before SRAT is parsed, just
>> +	 * allocate memory near the kernel image to try the best to keep
>> +	 * the kernel away from hotpluggable memory.
>> +	 */
>> +	memblock_set_bottom_up(true);
>> +	return 0;
>> +}
>> +early_param("movablenode", cmdline_parse_movablenode);
> 
> This came up during earlier review but never was addressed.  Is
> "movablenode" the right name?  Shouldn't it be something which
> explicitly shows that it's to prepare for memory hotplug?  Also, maybe
> the above param should generate warning if CONFIG_MOVABLE_NODE isn't
> enabled?

hmmm...as for the option name, if this option is set, it means, the kernel
could support the functionality that a whole node is the so called
movable node, which only has ZONE MOVABLE zone in it. So we choose
to name the parameter "movablenode".

As for the warning, will add it.

Thanks

> 
> Thanks.
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
