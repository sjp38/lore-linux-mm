Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 752028E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 15:32:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so34236489edc.6
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 12:32:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r24si2932543edp.187.2019.01.03.12.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 12:31:59 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 03 Jan 2019 21:31:58 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
In-Reply-To: <20190103194054.GB31793@dhcp22.suse.cz>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
 <20190103151357.GR31793@dhcp22.suse.cz>
 <dba7cb2c2882e034c8c99b09a432313a@suse.de>
 <20190103194054.GB31793@dhcp22.suse.cz>
Message-ID: <5502b64d6c508f5432386d2cfe999844@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R." Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org," linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 2019-01-03 20:40, Michal Hocko wrote:
> On Thu 03-01-19 20:27:26, Roman Penyaev wrote:
>> On 2019-01-03 16:13, Michal Hocko wrote:
>> > On Thu 03-01-19 15:59:52, Roman Penyaev wrote:
>> > > area->size can include adjacent guard page but get_vm_area_size()
>> > > returns actual size of the area.
>> > >
>> > > This fixes possible kernel crash when userspace tries to map area
>> > > on 1 page bigger: size check passes but the following
>> > > vmalloc_to_page()
>> > > returns NULL on last guard (non-existing) page.
>> >
>> > Can this actually happen? I am not really familiar with all the callers
>> > of this API but VM_NO_GUARD is not really used wildly in the kernel.
>> 
>> Exactly, by default (VM_NO_GUARD is not set) each area has guard page,
>> thus the area->size will be bigger.  The bug is not reproduced if
>> VM_NO_GUARD is set.
>> 
>> > All I can see is kasan na arm64 which doesn't really seem to use it
>> > for vmalloc.
>> >
>> > So is the problem real or this is a mere cleanup?
>> 
>> This is the real problem, try this hunk for any file descriptor which
>> provides
>> mapping, or say modify epoll as example:
> 
> OK, my response was more confusing than I intended. I meant to say. Is
> there any in kernel code that would allow the bug have had in mind?
> In other words can userspace trick any existing code?

In theory any existing caller of remap_vmalloc_range() which does
not have an explicit size check should trigger an oops, e.g. this is
a good candidate:

*** drivers/media/usb/stkwebcam/stk-webcam.c:
v4l_stk_mmap[789]              ret = remap_vmalloc_range(vma, 
sbuf->buffer, 0);

According to the code no explicit size check, should be easy to 
reproduce:
mmap the frame buffer and you are done.

Other callers are not so easy to follow. But wait, here is another 
example:

(drivers/video/fbdev/core/fbmem.c)
static int
fb_mmap(struct file *file, struct vm_area_struct * vma)
         ...
    	res = fb->fb_mmap(info, vma);

(drivers/video/fbdev/vfb.c)
static int vfb_mmap(struct fb_info *info,
		    struct vm_area_struct *vma)
{
	return remap_vmalloc_range(vma, (void *)info->fix.smem_start, 
vma->vm_pgoff);
}

No checks, naked calls, should be also the candidate.


--
Roman
