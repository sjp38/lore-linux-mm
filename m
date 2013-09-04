Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4D0886B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 22:07:07 -0400 (EDT)
Message-ID: <5226957F.2060704@cn.fujitsu.com>
Date: Wed, 04 Sep 2013 10:05:51 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/11] x86, memblock: Set lowest limit for memblock_alloc_base_nid().
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>  <1377596268-31552-8-git-send-email-tangchen@cn.fujitsu.com> <1378255041.10300.931.camel@misato.fc.hp.com>
In-Reply-To: <1378255041.10300.931.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 09/04/2013 08:37 AM, Toshi Kani wrote:
> On Tue, 2013-08-27 at 17:37 +0800, Tang Chen wrote:
>> memblock_alloc_base_nid() is a common API of memblock. And it calls
>> memblock_find_in_range_node() with %start = 0, which means it has no
>> limit for the lowest address by default.
>>
>> 	memblock_find_in_range_node(0, max_addr, size, align, nid);
>>
>> Since we introduced current_limit_low to memblock, if we have no limit
>> for the lowest address or we are not sure, we should pass
>> MEMBLOCK_ALLOC_ACCESSIBLE to %start so that it will be limited by the
>> default low limit.
>>
>> dma_contiguous_reserve() and setup_log_buf() will eventually call
>> memblock_alloc_base_nid() to allocate memory. So if the allocation order
>> is from low to high, they will allocate memory from the lowest limit
>> to higher memory.
>
> This requires the callers to use MEMBLOCK_ALLOC_ACCESSIBLE instead of 0.
> Is there a good way to make sure that all callers will follow this rule
> going forward?  Perhaps, memblock_find_in_range_node() should emit some
> message if 0 is passed when current_order is low to high and the boot
> option is specified?

How about set this as the default rule:

	When using from low to high order, always allocate memory from
	current_limit_low.

So far, I think only movablenode boot option will use this order.

>
> Similarly, I wonder if we should have a check to the allocation size to
> make sure that all allocations will stay small in this case.
>

We can check the size. But what is the stragety after we found that the 
size
is too large ?  Do we refuse to allocate memory ?  I don't think so.

I think only relocate_initrd() and reserve_crachkernel() could allocate 
large
memory. reserve_crachkernel() is easy to reorder, but reordering 
relocate_initrd()
is difficult because acpi_initrd_override() need to access to it with va.

I think on most servers, we don't need to do relocate_initrd(). initrd 
will be
loaded to mapped memory in normal situation. Can we just leave it there ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
