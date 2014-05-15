Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 10A536B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 23:18:31 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wo20so540230obc.7
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:18:30 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id kw3si4549160obc.29.2014.05.14.20.18.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 20:18:30 -0700 (PDT)
Received: by mail-ob0-f179.google.com with SMTP id vb8so548298obc.10
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:18:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c8b0a9a0b8d011a8b273cbb2de88d37190ed2751.1400111179.git.luto@amacapital.net>
References: <c8b0a9a0b8d011a8b273cbb2de88d37190ed2751.1400111179.git.luto@amacapital.net>
Date: Thu, 15 May 2014 11:18:29 +0800
Message-ID: <CAJd=RBC1E9x-zU-zJbNP+zbPgb=nhi39TqrxqpcGdi=OR9duXg@mail.gmail.com>
Subject: Re: [PATCH v2 -next] x86,vdso: Fix an OOPS accessing the hpet mapping
 w/o an hpet
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Stefani Seibold <stefani@seibold.net>

Hi Andy,

On Thu, May 15, 2014 at 7:46 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> The oops can be triggered in qemu using -no-hpet (but not nohpet) by
> reading a couple of pages past the end of the vdso text.  This
> should send SIGBUS instead of OOPSing.
>
> The bug was introduced by:
>
> commit 7a59ed415f5b57469e22e41fc4188d5399e0b194
> Author: Stefani Seibold <stefani@seibold.net>
> Date:   Mon Mar 17 23:22:09 2014 +0100
>
>     x86, vdso: Add 32 bit VDSO time support for 32 bit kernel
>
> which is new in 3.15.
>
> This will be fixed separately in 3.15, but that patch will not apply
> to tip/x86/vdso.  This is the equivalent fix for tip/x86/vdso and,
> presumably, 3.16.
>
> Cc: Stefani Seibold <stefani@seibold.net>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
>  arch/x86/vdso/vma.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
> index e915eae..8ad0081 100644
> --- a/arch/x86/vdso/vma.c
> +++ b/arch/x86/vdso/vma.c
> @@ -90,6 +90,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>         struct vm_area_struct *vma;
>         unsigned long addr;
>         int ret = 0;
> +       static struct page *no_pages[] = {NULL};
>
>         if (calculate_addr) {
>                 addr = vdso_addr(current->mm->start_stack,
> @@ -125,7 +126,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>                                        addr + image->size,
>                                        image->sym_end_mapping - image->size,
>                                        VM_READ,
> -                                      NULL);
> +                                      no_pages);
>
>         if (IS_ERR(vma)) {
>                 ret = PTR_ERR(vma);
> --
> 1.9.0
>
As the comment says,
/*
 * Called with mm->mmap_sem held for writing.
 * Insert a new vma covering the given region, with the given flags.
 * Its pages are supplied by the given array of struct page *.
 * The array can be shorter than len >> PAGE_SHIFT if it's null-terminated.
 * The region past the last page supplied will always produce SIGBUS.
 * The array pointer and the pages it points to are assumed to stay alive
 * for as long as this mapping might exist.
 */
struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
   unsigned long addr, unsigned long len,
   unsigned long vm_flags, struct page **pages)
{

we can send sigbus at fault time if no pages are supplied at install time.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
