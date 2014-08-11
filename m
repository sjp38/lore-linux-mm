Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD2AD6B0035
	for <linux-mm@kvack.org>; Sun, 10 Aug 2014 22:06:02 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so9943421pdj.14
        for <linux-mm@kvack.org>; Sun, 10 Aug 2014 19:06:02 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id wv5si12104663pbc.248.2014.08.10.19.06.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 10 Aug 2014 19:06:01 -0700 (PDT)
Message-ID: <53E82488.2030607@huawei.com>
Date: Mon, 11 Aug 2014 10:03:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] memblock, memhotplug: Fix wrong type in memblock_find_in_range_node().
References: <1407651123-10994-1-git-send-email-tangchen@cn.fujitsu.com> <53E70DB4.4000606@cn.fujitsu.com>
In-Reply-To: <53E70DB4.4000606@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tangchen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, fabf@skynet.be, Emilian.Medve@freescale.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2014/8/10 14:14, tangchen wrote:

> Sorry, add Xishi Qiu <qiuxishi@huawei.com>
> 
> On 08/10/2014 02:12 PM, Tang Chen wrote:
>> In memblock_find_in_range_node(), we defeind ret as int. But it shoule
>> be phys_addr_t because it is used to store the return value from
>> __memblock_find_range_bottom_up().
>>
>> The bug has not been triggered because when allocating low memory near
>> the kernel end, the "int ret" won't turn out to be minus. When we started
>> to allocate memory on other nodes, and the "int ret" could be minus.
>> Then the kernel will panic.
>>
>> A simple way to reproduce this: comment out the following code in numa_init(),
>>
>>          memblock_set_bottom_up(false);
>>
>> and the kernel won't boot.
>>
>> Reported-by: Xishi Qiu <qiuxishi@huawei.com>
>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>> ---
>>   mm/memblock.c | 3 +--
>>   1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 6d2f219..70fad0c 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -192,8 +192,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>>                       phys_addr_t align, phys_addr_t start,
>>                       phys_addr_t end, int nid)
>>   {
>> -    int ret;
>> -    phys_addr_t kernel_end;
>> +    phys_addr_t kernel_end, ret;
>>         /* pump up @end */
>>       if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> 
> 

Hi, Tang Chen

It is OK now.

Tested-by: Xishi Qiu <qiuxishi@huawei.com>

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
