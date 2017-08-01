Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87EEF6B051D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 07:00:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 72so12785162pfl.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:00:24 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k70si17714715pfh.135.2017.08.01.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Aug 2017 04:00:23 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2] vmalloc: show more detail info in vmallocinfo for clarify
In-Reply-To: <1496649682-20710-1-git-send-email-xieyisheng1@huawei.com>
References: <1496649682-20710-1-git-send-email-xieyisheng1@huawei.com>
Date: Tue, 01 Aug 2017 21:00:20 +1000
Message-ID: <87o9rzsgcb.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org
Cc: mhocko@suse.com, zijun_hu@htc.com, mingo@kernel.org, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, chris@chris-wilson.co.uk, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

Yisheng Xie <xieyisheng1@huawei.com> writes:

> When ioremap a 67112960 bytes vm_area with the vmallocinfo:
>  [..]
>  0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
>  0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap
>
> we get the result:
>  0xf1000000-0xf5001000 67112960 devm_ioremap+0x38/0x7c phys=40000000 ioremap
>
> For the align for ioremap must be less than '1 << IOREMAP_MAX_ORDER':
> 	if (flags & VM_IOREMAP)
> 		align = 1ul << clamp_t(int, get_count_order_long(size),
> 			PAGE_SHIFT, IOREMAP_MAX_ORDER);
>
> So it makes idiot like me a litter puzzle why jump the vm_area from
> 0xec800000-0xecbe1000 to 0xf1000000-0xf5001000, and leave
> 0xed000000-0xf1000000 as a big hole.
>
> This is to show all of vm_area, including which is freeing but still in
> vmap_area_list, to make it more clear about why we will get
> 0xf1000000-0xf5001000 int the above case. And we will get the
> vmallocinfo like:
>  [..]
>  0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
>  0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap
>  [..]
>  0xece7c000-0xece7e000    8192 unpurged vm_area
>  0xece7e000-0xece83000   20480 vm_map_ram
>  0xf0099000-0xf00aa000   69632 vm_map_ram

My vmallocinfo is full of these unpurged areas, should I be worried?

# grep -c "unpurged" /proc/vmallocinfo 
311

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
