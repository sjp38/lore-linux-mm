Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC76C6B02B4
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 21:20:05 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id c13so13258722ywa.13
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:20:05 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id r188si291405ywr.170.2017.07.19.18.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 18:20:04 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id a12so620443ywh.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:20:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGWkznFjz_gsMxPD9QkPb930gvne0O2nGpguD7qLhVHUa+fU6Q@mail.gmail.com>
References: <1500461043-7414-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20170719135014.fdc882d1e28fd130104eff5d@linux-foundation.org> <CAGWkznFjz_gsMxPD9QkPb930gvne0O2nGpguD7qLhVHUa+fU6Q@mail.gmail.com>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Thu, 20 Jul 2017 09:20:04 +0800
Message-ID: <CAGWkznHSMDjQUkzQj0_Y9d-dszctL4ZfhCkQxuJYwFcPOzDSOA@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: add vm_struct for vm_map_ram area
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhaoyang.huang@spreadtrum.com, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com, ming.ling@spreadtrum.com

update the comment bellow as ...'s/by one driver's allocating/because
one driver has allocated/'..., sorry
for the confusion


On Thu, Jul 20, 2017 at 9:15 AM, Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
> On Thu, Jul 20, 2017 at 4:50 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Wed, 19 Jul 2017 18:44:03 +0800 Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
>>
>>> /proc/vmallocinfo will not show the area allocated by vm_map_ram, which
>>> will make confusion when debug. Add vm_struct for them and show them in
>>> proc.
>>>
>>
>> Please provide sample /proc/vmallocinfo so we can better understand the
>> proposal.  Is there a means by which people can determine that a
>> particular area is from vm_map_ram()?  I don't think so.  Should there
>> be?
> Here is the part of vmallocinfo, the line start with '>' are the ones
> allocated by vm_map_ram.
> xxxx:/ # cat /proc/vmallocinfo
> 0xffffff8000a5f000-0xffffff8000abb000  376832
> load_module+0x1004/0x1e98 pages=91 vmalloc
> 0xffffff8000ac6000-0xffffff8000ad2000   49152
> load_module+0x1004/0x1e98 pages=11 vmalloc
> 0xffffff8000ad8000-0xffffff8000ade000   24576
> load_module+0x1004/0x1e98 pages=5 vmalloc
> 0xffffff8008000000-0xffffff8008002000    8192 of_iomap+0x4c/0x68
> phys=12001000 ioremap
> 0xffffff8008002000-0xffffff8008004000    8192 of_iomap+0x4c/0x68
> phys=40356000 ioremap
> 0xffffff8008004000-0xffffff8008007000   12288 of_iomap+0x4c/0x68
> phys=12002000 ioremap
> 0xffffff8008008000-0xffffff800800d000   20480
> of_sprd_gates_clk_setup_with_ops+0x88/0x2a8 phys=402b0000 ioremap
> 0xffffff800800e000-0xffffff8008010000    8192 of_iomap+0x4c/0x68
> phys=40356000 ioremap
> ...
>>0xffffff800c5a3000-0xffffff800c5ec000  299008 shmem_ram_vmap+0xe8/0x1a0
> 0xffffff800c5fe000-0xffffff800c600000    8192
> kbasep_js_policy_ctx_has_priority+0x254/0xdb0 [mali_kbase] pages=1
> vmalloc
> 0xffffff800c600000-0xffffff800c701000 1052672 of_iomap+0x4c/0x68
> phys=60d00000 ioremap
>>0xffffff800c701000-0xffffff800c742000  266240 shmem_ram_vmap+0xe8/0x1a0
> 0xffffff800c74e000-0xffffff800c750000    8192
> kbasep_js_policy_ctx_has_priority+0x2cc/0xdb0 [mali_kbase] pages=1
> vmalloc
> ...
>>
>>>
>>> ...
>>>
>>> @@ -1173,6 +1178,12 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
>>>               addr = (unsigned long)mem;
>>>       } else {
>>>               struct vmap_area *va;
>>> +             struct vm_struct *area;
>>> +
>>> +             area = kzalloc_node(sizeof(*area), GFP_KERNEL, node);
>>> +             if (unlikely(!area))
>>> +                     return NULL;
>>
>> Allocating a vm_struct for each vm_map_ram area is a cost.  And we're
>> doing this purely for /proc/vmallocinfo.  I think I'll need more
>> persuading to convince me that this is a good tradeoff, given that
>> *every* user will incur this cost, and approximately 0% of them will
>> ever use /proc/vmallocinfo.
>>
>> So... do we *really* need this?  If so, why?
> The motivation of this commit comes from one practical debug, that is,
> vmalloc failed 's/by one driver's allocating/because one driver has allocated/' a
> huge area by vm_map_ram, which can not be traced by cat
> /proc/vmallocinfo. We have to add a lot of printk and
> dump_stack to get more information.
> I don't think the vm_struct cost too much memory, just imagine that
> the area got by vmalloc or ioremap instead, you have
> to pay for it as well.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
