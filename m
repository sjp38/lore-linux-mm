Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 438786B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 13:47:17 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x142so15787147lfd.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:47:17 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id a69si9942846ljb.97.2017.02.20.10.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 10:47:15 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id h67so1509124lfg.1
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:47:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA5enKbkwP0P1sC4WAMf_SP2QM6-Vg8YMXs_=CkNzav4yTm1ow@mail.gmail.com>
References: <20161101194337.24015-1-lstoakes@gmail.com> <CAA5enKai6Gq7gCf6mmuXJwZrds5N8s9JAtNGxy1vAJD1zSmb2Q@mail.gmail.com>
 <CAA5enKbkwP0P1sC4WAMf_SP2QM6-Vg8YMXs_=CkNzav4yTm1ow@mail.gmail.com>
From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Mon, 20 Feb 2017 18:46:54 +0000
Message-ID: <CAA5enKYhsACE+LFdjQexEOnOVLAC+soXs4kEtT4fxm2W7MiU=g@mail.gmail.com>
Subject: Re: [PATCH] drm/via: use get_user_pages_unlocked()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>

On 6 January 2017 at 07:09, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>
> Adding Andrew, as this may be another less active corner of the corner, thanks!

Hi all,

Thought I'd also give this one a gentle nudge now the merge window has
re-opened, Andrew - are you ok to pick this up? I've checked the patch
and it still applies, for convenience the raw patch is available at
https://marc.info/?l=linux-mm&m=147802942832515&q=raw - let me know if
there's anything else I can do on this or if you'd prefer a re-send.

Best, Lorenzo

> On 3 January 2017 at 20:23, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>> Hi All,
>>
>> Just a gentle ping on this one :)
>>
>> Cheers, Lorenzo
>>
>> On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>>> Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
>>> and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
>>>
>>> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
>>> ---
>>>  drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
>>>  1 file changed, 3 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
>>> index 1a3ad76..98aae98 100644
>>> --- a/drivers/gpu/drm/via/via_dmablit.c
>>> +++ b/drivers/gpu/drm/via/via_dmablit.c
>>> @@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
>>>         vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
>>>         if (NULL == vsg->pages)
>>>                 return -ENOMEM;
>>> -       down_read(&current->mm->mmap_sem);
>>> -       ret = get_user_pages((unsigned long)xfer->mem_addr,
>>> -                            vsg->num_pages,
>>> -                            (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
>>> -                            vsg->pages, NULL);
>>> -
>>> -       up_read(&current->mm->mmap_sem);
>>> +       ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
>>> +                       vsg->num_pages, vsg->pages,
>>> +                       (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
>>>         if (ret != vsg->num_pages) {
>>>                 if (ret < 0)
>>>                         return ret;
>>> --
>>> 2.10.2
>>>

-- 
Lorenzo Stoakes
https://ljs.io

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
