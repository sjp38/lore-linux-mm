Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABE36B1A72
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 06:02:50 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so6673004edd.11
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:02:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19-v6sor20469359edt.14.2018.11.19.03.02.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 03:02:48 -0800 (PST)
Subject: Re: [Xen-devel] [PATCH 5/9] drm/xen/xen_drm_front_gem.c: Convert to
 use vm_insert_range
References: <20181115154912.GA27969@jordon-HP-15-Notebook-PC>
 <ed294bea-bf07-6a4d-51ec-9e7082703b61@gmail.com>
 <CAFqt6zZ_FnWg2K3Lh=-1KFOk1XteHnroua6QzJrKo+khZTgieg@mail.gmail.com>
From: Oleksandr Andrushchenko <andr2000@gmail.com>
Message-ID: <c76fc2fa-d08b-7db3-5693-d9c303cd7126@gmail.com>
Date: Mon, 19 Nov 2018 13:02:46 +0200
MIME-Version: 1.0
In-Reply-To: <CAFqt6zZ_FnWg2K3Lh=-1KFOk1XteHnroua6QzJrKo+khZTgieg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, oleksandr_andrushchenko@epam.com, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org

On 11/19/18 12:42 PM, Souptick Joarder wrote:
> On Mon, Nov 19, 2018 at 3:22 PM Oleksandr Andrushchenko
> <andr2000@gmail.com> wrote:
>> On 11/15/18 5:49 PM, Souptick Joarder wrote:
>>> Convert to use vm_insert_range() to map range of kernel
>>> memory to user vma.
>>>
>>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>>> Reviewed-by: Matthew Wilcox <willy@infradead.org>
>>> ---
>>>    drivers/gpu/drm/xen/xen_drm_front_gem.c | 20 ++++++--------------
>>>    1 file changed, 6 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
>>> index 47ff019..a3eade6 100644
>>> --- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
>>> +++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
>>> @@ -225,8 +225,7 @@ struct drm_gem_object *
>>>    static int gem_mmap_obj(struct xen_gem_object *xen_obj,
>>>                        struct vm_area_struct *vma)
>>>    {
>>> -     unsigned long addr = vma->vm_start;
>>> -     int i;
>>> +     int err;
>> I would love to keep ret, not err
> Sure, will add it in v2.
> But I think, err is more appropriate here.

I used "ret" throughout the driver, so this is just to remain consistent:

grep -rnw err drivers/gpu/drm/xen/ | wc -l
0
grep -rnw ret drivers/gpu/drm/xen/ | wc -l
204

>>>        /*
>>>         * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
>>> @@ -247,18 +246,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
>>>         * FIXME: as we insert all the pages now then no .fault handler must
>>>         * be called, so don't provide one
>>>         */
>>> -     for (i = 0; i < xen_obj->num_pages; i++) {
>>> -             int ret;
>>> -
>>> -             ret = vm_insert_page(vma, addr, xen_obj->pages[i]);
>>> -             if (ret < 0) {
>>> -                     DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
>>> -                     return ret;
>>> -             }
>>> -
>>> -             addr += PAGE_SIZE;
>>> -     }
>>> -     return 0;
>>> +     err = vm_insert_range(vma, vma->vm_start, xen_obj->pages,
>>> +                             xen_obj->num_pages);
>>> +     if (err < 0)
>>> +             DRM_ERROR("Failed to insert pages into vma: %d\n", err);
>>> +     return err;
>>>    }
>>>
>>>    int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
>> With the above fixed,
>>
>> Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
>>
