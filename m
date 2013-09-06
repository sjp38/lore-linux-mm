Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 377BF6B0031
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 04:58:26 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 6 Sep 2013 14:18:50 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 52CF2394004E
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 14:28:02 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r868wC6h47775846
	for <linux-mm@kvack.org>; Fri, 6 Sep 2013 14:28:12 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r868wCGJ000367
	for <linux-mm@kvack.org>; Fri, 6 Sep 2013 14:28:13 +0530
Date: Fri, 6 Sep 2013 16:58:11 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130906085811.GA31315@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130904192215.GG26609@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130904192215.GG26609@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Tejun,
On Wed, Sep 04, 2013 at 03:22:15PM -0400, Tejun Heo wrote:
>Hello,
>
>On Tue, Aug 27, 2013 at 05:37:37PM +0800, Tang Chen wrote:
>> 1. Make memblock be able to allocate memory from low address to high address.
>>    Also introduce low limit to prevent memblock allocating memory too low.
>> 
>> 2. Improve init_mem_mapping() to support allocate page tables from low address 
>>    to high address.
>> 
>> 3. Introduce "movablenode" boot option to enable and disable this functionality.
>> 
>> PS: Reordering of relocate_initrd() and reserve_crashkernel() has not been done 
>>     yet. acpi_initrd_override() needs to access initrd with virtual address. So 
>>     relocate_initrd() must be done before acpi_initrd_override().
>
>I'm expectedly happier with this approach but some overall review
>points.
>
>* I think patch splitting went a bit too far.  e.g. it doesn't make
>  much sense or helps anything to split "introduction of a param" from
>  "the param doing something".
>
>* I think it's a lot more complex than necessary.  Just implement a
>  single function - memblock_alloc_bottom_up(@start) where specifying
>  MEMBLOCK_ALLOC_ANYWHERE restores top down behavior and do
>  memblock_alloc_bottom_up(end_of_kernel) early during boot.  If the
>  bottom up mode is set, just try allocating bottom up from the
>  specified address and if that fails do normal top down allocation.
>  No need to meddle with the callers.  The only change necessary
>  (well, aside from the reordering) outside memblock is adding two
>  calls to the above function.
>
>* I don't think "order" is the right word here.  "direction" probably
>  fits a lot better.

What's the root reason memblock alloc from high to low? To reduce 
fragmentation or ...

Regards,
Wanpeng Li 

>
>Thanks.
>
>-- 
>tejun
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
