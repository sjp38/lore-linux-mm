Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1A3CF6B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 02:06:16 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1105751gxk.14
        for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:06:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090624195647.9d0064c7.akpm@linux-foundation.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
	 <20090624195647.9d0064c7.akpm@linux-foundation.org>
Date: Thu, 25 Jun 2009 15:06:24 +0900
Message-ID: <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com>
Subject: Re: [PATCH] video: arch specific page protection support for deferred
	io
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, lethal@linux-sh.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 11:56 AM, Andrew
Morton<akpm@linux-foundation.org> wrote:
> On Wed, 24 Jun 2009 19:54:13 +0900 Magnus Damm <magnus.damm@gmail.com> wr=
ote:
>
>> From: Magnus Damm <damm@igel.co.jp>
>>
>> This patch adds arch specific page protection support to deferred io.
>>
>> Instead of overwriting the info->fbops->mmap pointer with the
>> deferred io specific mmap callback, modify fb_mmap() to include
>> a #ifdef wrapped call to fb_deferred_io_mmap(). =A0The function
>> fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
>> case of non-vmalloc() frame buffers.
>>
>> With this patch uncached deferred io can be used together with
>> the sh_mobile_lcdcfb driver. Without this patch arch specific
>> page protection code in fb_pgprotect() never gets invoked with
>> deferred io.
>>
>> Signed-off-by: Magnus Damm <damm@igel.co.jp>
>> ---
>>
>> =A0For proper runtime operation with uncached vmas make sure
>> =A0"[PATCH][RFC] mm: uncached vma support with writenotify"
>> =A0is applied. There are no merge order dependencies.
>
> So this is dependent upon a patch which is in your tree, which is in
> linux-next?

I tried to say that there were _no_ dependencies merge wise. =3D)

There are 3 levels of dependencies:
1: pgprot_noncached() patches from Arnd
2: mm: uncached vma support with writenotify
3: video: arch specfic page protection support for deferred io

2 depends on 1 to compile, but 3 (this one) is disconnected from 2 and
1. So this patch can be merged independently.

>
>> =A0drivers/video/fb_defio.c | =A0 10 +++++++---
>> =A0drivers/video/fbmem.c =A0 =A0| =A0 =A06 ++++++
>> =A0include/linux/fb.h =A0 =A0 =A0 | =A0 =A02 ++
>> =A03 files changed, 15 insertions(+), 3 deletions(-)
>>
>> --- 0001/drivers/video/fb_defio.c
>> +++ work/drivers/video/fb_defio.c =A0 =A0 2009-06-24 19:07:11.000000000 =
+0900
>> @@ -19,6 +19,7 @@
>> =A0#include <linux/interrupt.h>
>> =A0#include <linux/fb.h>
>> =A0#include <linux/list.h>
>> +#include <asm/fb.h>
>
> Microblaze doesn't have an asm/fb.h.

Right, but fbmem.c includes asm/fb.h as well (for fb_pgprotect()), so
framebuffer isn't supported on Microblaze. So I think this is a
separate issue.

>> =A0/* to support deferred IO */
>> =A0#include <linux/rmap.h>
>> @@ -141,11 +142,16 @@ static const struct address_space_operat
>> =A0 =A0 =A0 .set_page_dirty =3D fb_deferred_io_set_page_dirty,
>> =A0};
>>
>> -static int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_str=
uct *vma)
>> +int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_struct *vma, un=
signed long off)
>> =A0{
>> =A0 =A0 =A0 vma->vm_ops =3D &fb_deferred_io_vm_ops;
>> =A0 =A0 =A0 vma->vm_flags |=3D ( VM_IO | VM_RESERVED | VM_DONTEXPAND );
>> =A0 =A0 =A0 vma->vm_private_data =3D info;
>> +
>> + =A0 =A0 if (!is_vmalloc_addr(info->screen_base))
>> + =A0 =A0 =A0 =A0 =A0 =A0 fb_pgprotect(file, vma, off);
>
> Add a comment explaining what's going on here?

Good idea!

>> @@ -1325,6 +1325,12 @@ __releases(&info->lock)
>> =A0 =A0 =A0 off =3D vma->vm_pgoff << PAGE_SHIFT;
>> =A0 =A0 =A0 if (!fb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> +
>> +#ifdef CONFIG_FB_DEFERRED_IO
>> + =A0 =A0 if (info->fbdefio)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return fb_deferred_io_mmap(file, info, vma, of=
f);
>> +#endif
>
> We can remove the ifdefs here...
>
>> +extern int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_area_=
struct *vma, unsigned long off);
>
> if we do
>
> #else =A0 /* CONFIG_FB_DEFERRED_IO */
> static inline int fb_deferred_io_mmap(struct file *file, struct fb_info *=
info,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_=
area_struct *vma, unsigned long off)
> {
> =A0 =A0 =A0 =A0return 0;
> }
> #endif =A0/* CONFIG_FB_DEFERRED_IO */
>
> here.

The code is fbmem.c is currently filled with #ifdefs today, want me
create inline versions for fb_deferred_io_open() and
fb_deferred_io_fsync() as well?

Thanks for your comments!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
