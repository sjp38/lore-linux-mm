Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id ED5BA6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:12:46 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so5060828pab.1
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:12:46 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so3739600pad.16
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:12:44 -0700 (PDT)
Message-ID: <52419DC6.4030800@gmail.com>
Date: Tue, 24 Sep 2013 22:12:22 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] memblock: Introduce bottom-up allocation mode
References: <524162DA.30004@cn.fujitsu.com> <524163CF.3010303@cn.fujitsu.com> <20130924121725.GC2366@htj.dyndns.org> <524190DC.4060605@gmail.com> <20130924132327.GH2366@htj.dyndns.org>
In-Reply-To: <20130924132327.GH2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 09/24/2013 09:23 PM, Tejun Heo wrote:
> On Tue, Sep 24, 2013 at 09:17:16PM +0800, Zhang Yanfei wrote:
>>> Maybe just print warning only on the first failure?
>>
>> Hmmm... This message is for each memblock allocation, that said, if the
>> allocation this time fails, it prints the message and we use so called top-down.
>> But next time, we still use bottom up first again.
>>
>> Did you mean if we fail on one bottom-up allocation, then we never try
>> bottom-up again and will always use top-down? 
> 
> Nope, it's just that it might end up printing something for each alloc
> which can end up flooding console / log.  The first failure is the
> most interesting and pretty much defeats the purpose of the whole
> thing after all.  If it's expected to fail very rarely, I'd just stick
> in WARN_ONCE() there as the stack trace would be interesting too.
> 

I see. I think it is rarely to fail. But here is case that it must
fail in the current bottom-up implementation. For example, we allocate
memory in reserve_real_mode() by calling this: 
memblock_find_in_range(0, 1<<20, size, PAGE_SIZE);

Both the start and end is below the kernel, so trying bottom-up for
this must fail. So I am now thinking that if we should take this as
the special case for bottom-up. That said, if we limit start and end
both below the kernel, we should allocate memory below the kernel instead
of make it fail. The cases are also rare, in early boot time, only
these two:

 |->early_reserve_e820_mpc_new()   /* allocate memory under 1MB */
 |->reserve_real_mode()            /* allocate memory under 1MB */

How do you think?

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
