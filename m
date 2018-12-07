Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id F280E6B7EB0
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 16:19:30 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id p131so2480437oia.21
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 13:19:30 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h64si1865551oif.143.2018.12.07.13.19.29
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 13:19:30 -0800 (PST)
Subject: Re: [PATCH v3 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
References: <20181206184227.GA28656@jordon-HP-15-Notebook-PC>
 <ca1779ea-7a87-971c-24c4-4a1c77a72e92@arm.com>
 <CAFqt6zbMbvB1ckwhSsBATrq5M-HQ6qk95sCWCoTTFFnwzBAnng@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <fd6b10d7-de66-f16a-f500-29a13b909f46@arm.com>
Date: Fri, 7 Dec 2018 21:19:24 +0000
MIME-Version: 1.0
In-Reply-To: <CAFqt6zbMbvB1ckwhSsBATrq5M-HQ6qk95sCWCoTTFFnwzBAnng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-rockchip@lists.infradead.org

On 2018-12-07 8:30 pm, Souptick Joarder wrote:
> On Fri, Dec 7, 2018 at 8:20 PM Robin Murphy <robin.murphy@arm.com> wrote:
>>
>> On 06/12/2018 18:42, Souptick Joarder wrote:
>>> Convert to use vm_insert_range() to map range of kernel
>>> memory to user vma.
>>>
>>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>>> Tested-by: Heiko Stuebner <heiko@sntech.de>
>>> Acked-by: Heiko Stuebner <heiko@sntech.de>
>>> ---
>>>    drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 20 ++------------------
>>>    1 file changed, 2 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
>>> index a8db758..2cb83bb 100644
>>> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
>>> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
>>> @@ -221,26 +221,10 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
>>>                                              struct vm_area_struct *vma)
>>>    {
>>>        struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
>>> -     unsigned int i, count = obj->size >> PAGE_SHIFT;
>>>        unsigned long user_count = vma_pages(vma);
>>> -     unsigned long uaddr = vma->vm_start;
>>> -     unsigned long offset = vma->vm_pgoff;
>>> -     unsigned long end = user_count + offset;
>>> -     int ret;
>>> -
>>> -     if (user_count == 0)
>>> -             return -ENXIO;
>>> -     if (end > count)
>>> -             return -ENXIO;
>>>
>>> -     for (i = offset; i < end; i++) {
>>> -             ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
>>> -             if (ret)
>>> -                     return ret;
>>> -             uaddr += PAGE_SIZE;
>>> -     }
>>> -
>>> -     return 0;
>>> +     return vm_insert_range(vma, vma->vm_start, rk_obj->pages,
>>> +                             user_count);
>>
>> We're losing vm_pgoff handling here, which given the implication in
>> 57de50af162b, may well be a regression for at least some combination of
>> GPU and userspace driver (I assume that commit was in the context of
>> some version of the Arm Mali driver, possibly on RK3288).
> 
> In commit  57de50af162b, vma->vm_pgoff = 0 for GEM mmap handler context
> and removing it from common path which means if call stack looks like
> rockchip_gem_mmap_buf() -> rockchip_drm_gem_object_mmap() ->
> rockchip_drm_gem_object_mmap_iommu(), then we might have a non zero
> vma->vm_pgoff context which is not handled.
> 
> This is the problem you are pointing ? right ?

Exactly - if unconditionally zeroing the offset in the PRIME mmap() path 
was a problem, then the implication is that there are callers of that 
path who expect the offset to be honoured here.

Robin.
