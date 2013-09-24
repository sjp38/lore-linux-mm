Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 76CF96B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:16:47 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so4665710pdj.3
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:16:47 -0700 (PDT)
Received: by mail-qc0-f172.google.com with SMTP id l13so3140319qcy.3
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:16:44 -0700 (PDT)
Date: Tue, 24 Sep 2013 10:16:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/6] memblock: Introduce bottom-up allocation mode
Message-ID: <20130924141640.GK2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <524163CF.3010303@cn.fujitsu.com>
 <20130924121725.GC2366@htj.dyndns.org>
 <524190DC.4060605@gmail.com>
 <20130924132327.GH2366@htj.dyndns.org>
 <52419DC6.4030800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52419DC6.4030800@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hello,

On Tue, Sep 24, 2013 at 10:12:22PM +0800, Zhang Yanfei wrote:
> I see. I think it is rarely to fail. But here is case that it must
> fail in the current bottom-up implementation. For example, we allocate
> memory in reserve_real_mode() by calling this: 
> memblock_find_in_range(0, 1<<20, size, PAGE_SIZE);
> 
> Both the start and end is below the kernel, so trying bottom-up for
> this must fail. So I am now thinking that if we should take this as
> the special case for bottom-up. That said, if we limit start and end
> both below the kernel, we should allocate memory below the kernel instead
> of make it fail. The cases are also rare, in early boot time, only
> these two:
> 
>  |->early_reserve_e820_mpc_new()   /* allocate memory under 1MB */
>  |->reserve_real_mode()            /* allocate memory under 1MB */
> 
> How do you think?

They need to be special cased regardless, right?  It's wrong to print
out warning messages for things which are expected to behave that way.
Just skip bottom-up allocs if @end is under kernel image?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
