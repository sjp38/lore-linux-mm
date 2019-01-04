Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64F0B8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 06:06:48 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so34600917edm.18
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 03:06:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si92452edh.133.2019.01.04.03.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 03:06:46 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 04 Jan 2019 12:06:44 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
In-Reply-To: <20190103145954.16942-2-rpenyaev@suse.de>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
Message-ID: <c41a065f04c89d0a1f0312b1b4fa7b1e@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R." Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org," linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi Andrew,

Could you please update the commit message with something as
the following (I hope it will become a bit clearer now):

-------------
When VM_NO_GUARD is not set area->size includes adjacent guard page,
thus for correct size checking get_vm_area_size() should be used,
but not area->size.

This fixes possible kernel oops when userspace tries to mmap an area
on 1 page bigger than was allocated by vmalloc_user() call: the size
check inside remap_vmalloc_range_partial() accounts non-existing
guard page also, so check successfully passes but vmalloc_to_page()
returns NULL (guard page does not physically exist).

The following code pattern example should trigger an oops:

  static int oops_mmap(struct file *file, struct vm_area_struct *vma)
  {
        void *mem;

        mem = vmalloc_user(4096);
        BUG_ON(!mem);
        /* Do not care about mem leak */

        return remap_vmalloc_range(vma, mem, 0);
  }

And userspace simply mmaps size + PAGE_SIZE:

  mmap(NULL, 8192, PROT_WRITE|PROT_READ, MAP_PRIVATE, fd, 0);

Possible candidates for oops which do not have any explicit size
checks:

   *** drivers/media/usb/stkwebcam/stk-webcam.c:
   v4l_stk_mmap[789]   ret = remap_vmalloc_range(vma, sbuf->buffer, 0);

Or the following one:

   *** drivers/video/fbdev/core/fbmem.c
   static int
   fb_mmap(struct file *file, struct vm_area_struct * vma)
        ...
        res = fb->fb_mmap(info, vma);

Where fb_mmap callback calls remap_vmalloc_range() directly without
any explicit checks:

   *** drivers/video/fbdev/vfb.c
   static int vfb_mmap(struct fb_info *info,
             struct vm_area_struct *vma)
   {
       return remap_vmalloc_range(vma, (void *)info->fix.smem_start, 
vma->vm_pgoff);
   }
--------

--
Roman


On 2019-01-03 15:59, Roman Penyaev wrote:
> area->size can include adjacent guard page but get_vm_area_size()
> returns actual size of the area.
> 
> This fixes possible kernel crash when userspace tries to map area
> on 1 page bigger: size check passes but the following vmalloc_to_page()
> returns NULL on last guard (non-existing) page.
> 
> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c55e23..2cd24186ba84 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2248,7 +2248,7 @@ int remap_vmalloc_range_partial(struct
> vm_area_struct *vma, unsigned long uaddr,
>  	if (!(area->flags & VM_USERMAP))
>  		return -EINVAL;
> 
> -	if (kaddr + size > area->addr + area->size)
> +	if (kaddr + size > area->addr + get_vm_area_size(area))
>  		return -EINVAL;
> 
>  	do {
