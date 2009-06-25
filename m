Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9AE6B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 22:55:14 -0400 (EDT)
Date: Wed, 24 Jun 2009 19:56:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] video: arch specific page protection support for
 deferred io
Message-Id: <20090624195647.9d0064c7.akpm@linux-foundation.org>
In-Reply-To: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, lethal@linux-sh.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009 19:54:13 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:

> From: Magnus Damm <damm@igel.co.jp>
> 
> This patch adds arch specific page protection support to deferred io.
> 
> Instead of overwriting the info->fbops->mmap pointer with the
> deferred io specific mmap callback, modify fb_mmap() to include
> a #ifdef wrapped call to fb_deferred_io_mmap().  The function
> fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
> case of non-vmalloc() frame buffers.
> 
> With this patch uncached deferred io can be used together with
> the sh_mobile_lcdcfb driver. Without this patch arch specific
> page protection code in fb_pgprotect() never gets invoked with
> deferred io.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  For proper runtime operation with uncached vmas make sure
>  "[PATCH][RFC] mm: uncached vma support with writenotify"
>  is applied. There are no merge order dependencies.

So this is dependent upon a patch which is in your tree, which is in
linux-next?

Tricky.  Perhaps we should merge this via your tree, should it survive
review.


>  drivers/video/fb_defio.c |   10 +++++++---
>  drivers/video/fbmem.c    |    6 ++++++
>  include/linux/fb.h       |    2 ++
>  3 files changed, 15 insertions(+), 3 deletions(-)
> 
> --- 0001/drivers/video/fb_defio.c
> +++ work/drivers/video/fb_defio.c	2009-06-24 19:07:11.000000000 +0900
> @@ -19,6 +19,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/fb.h>
>  #include <linux/list.h>
> +#include <asm/fb.h>

Microblaze doesn't have an asm/fb.h.

>  /* to support deferred IO */
>  #include <linux/rmap.h>
> @@ -141,11 +142,16 @@ static const struct address_space_operat
>  	.set_page_dirty = fb_deferred_io_set_page_dirty,
>  };
>  
> -static int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
> +			struct vm_area_struct *vma, unsigned long off)
>  {
>  	vma->vm_ops = &fb_deferred_io_vm_ops;
>  	vma->vm_flags |= ( VM_IO | VM_RESERVED | VM_DONTEXPAND );
>  	vma->vm_private_data = info;
> +
> +	if (!is_vmalloc_addr(info->screen_base))
> +		fb_pgprotect(file, vma, off);

Add a comment explaining what's going on here?

>  	return 0;
>  }
>  
> @@ -182,7 +188,6 @@ void fb_deferred_io_init(struct fb_info 
>  
>  	BUG_ON(!fbdefio);
>  	mutex_init(&fbdefio->lock);
> -	info->fbops->fb_mmap = fb_deferred_io_mmap;
>  	INIT_DELAYED_WORK(&info->deferred_work, fb_deferred_io_work);
>  	INIT_LIST_HEAD(&fbdefio->pagelist);
>  	if (fbdefio->delay == 0) /* set a default of 1 s */
> @@ -214,7 +219,6 @@ void fb_deferred_io_cleanup(struct fb_in
>  		page->mapping = NULL;
>  	}
>  
> -	info->fbops->fb_mmap = NULL;
>  	mutex_destroy(&fbdefio->lock);
>  }
>  EXPORT_SYMBOL_GPL(fb_deferred_io_cleanup);
> --- 0001/drivers/video/fbmem.c
> +++ work/drivers/video/fbmem.c	2009-06-24 19:12:29.000000000 +0900
> @@ -1325,6 +1325,12 @@ __releases(&info->lock)
>  	off = vma->vm_pgoff << PAGE_SHIFT;
>  	if (!fb)
>  		return -ENODEV;
> +
> +#ifdef CONFIG_FB_DEFERRED_IO
> +	if (info->fbdefio)
> +		return fb_deferred_io_mmap(file, info, vma, off);
> +#endif

We can remove the ifdefs here...

> +extern int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
> +			       struct vm_area_struct *vma, unsigned long off);

if we do

#else	/* CONFIG_FB_DEFERRED_IO */
static inline int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
				struct vm_area_struct *vma, unsigned long off)
{
	return 0;
}
#endif	/* CONFIG_FB_DEFERRED_IO */

here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
