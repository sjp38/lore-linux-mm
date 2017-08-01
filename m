Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA6E6B053B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:40:56 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o19so15305853ito.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:40:56 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id e190si29895583iof.118.2017.08.01.05.40.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:40:55 -0700 (PDT)
Subject: Re: [PATCH v2] vmalloc: show more detail info in vmallocinfo for
 clarify
References: <1496649682-20710-1-git-send-email-xieyisheng1@huawei.com>
 <87o9rzsgcb.fsf@concordia.ellerman.id.au>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <6f3c8e69-b2af-d23c-b226-805faf7efd89@huawei.com>
Date: Tue, 1 Aug 2017 20:36:47 +0800
MIME-Version: 1.0
In-Reply-To: <87o9rzsgcb.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org
Cc: mhocko@suse.com, zijun_hu@htc.com, mingo@kernel.org, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, chris@chris-wilson.co.uk, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

Hi Michael,

Thanks for comment!
On 2017/8/1 19:00, Michael Ellerman wrote:
> Yisheng Xie <xieyisheng1@huawei.com> writes:
> 
>> When ioremap a 67112960 bytes vm_area with the vmallocinfo:
>>  [..]
>>  0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
>>  0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap
>>
>> we get the result:
>>  0xf1000000-0xf5001000 67112960 devm_ioremap+0x38/0x7c phys=40000000 ioremap
>>
>> For the align for ioremap must be less than '1 << IOREMAP_MAX_ORDER':
>> 	if (flags & VM_IOREMAP)
>> 		align = 1ul << clamp_t(int, get_count_order_long(size),
>> 			PAGE_SHIFT, IOREMAP_MAX_ORDER);
>>
>> So it makes idiot like me a litter puzzle why jump the vm_area from
>> 0xec800000-0xecbe1000 to 0xf1000000-0xf5001000, and leave
>> 0xed000000-0xf1000000 as a big hole.
>>
>> This is to show all of vm_area, including which is freeing but still in
>> vmap_area_list, to make it more clear about why we will get
>> 0xf1000000-0xf5001000 int the above case. And we will get the
>> vmallocinfo like:
>>  [..]
>>  0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
>>  0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap
>>  [..]
>>  0xece7c000-0xece7e000    8192 unpurged vm_area
>>  0xece7e000-0xece83000   20480 vm_map_ram
>>  0xf0099000-0xf00aa000   69632 vm_map_ram
> 
> My vmallocinfo is full of these unpurged areas, should I be worried?

The unpurged areas is a lazy free vm area, which maybe free at anytime. e.g. if the
nr_lazy(count in pages) is bigger than lazy_max_pages(), these area will be purged
and free.

So I think you do not have worried about it.

Thanks
Yisheng Xie

> 
> # grep -c "unpurged" /proc/vmallocinfo 
> 311
> 
> cheers
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
