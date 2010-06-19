Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D5516B01B5
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 08:36:31 -0400 (EDT)
Received: by fxm15 with SMTP id 15so1190255fxm.14
        for <linux-mm@kvack.org>; Sat, 19 Jun 2010 05:36:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091208211647.9B032B151F@basil.firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
	<20091208211647.9B032B151F@basil.firstfloor.org>
Date: Sat, 19 Jun 2010 14:36:28 +0200
Message-ID: <AANLkTimBhQAYn7BDXd1ykSN90v0ClWybIe2Pe1qv_6vA@mail.gmail.com>
Subject: Re: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft page
	offlining
From: Michael Kerrisk <mtk.manpages@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Tue, Dec 8, 2009 at 11:16 PM, Andi Kleen <andi@firstfloor.org> wrote:
>
> Process based injection is much easier to handle for test programs,
> who can first bring a page into a specific state and then test.
> So add a new MADV_SOFT_OFFLINE to soft offline a page, similar
> to the existing hard offline injector.

I see that this made its way into 2.6.33. Could you write a short
piece on it for the madvise.2 man page?

Thanks,

Michael


> Signed-off-by: Andi Kleen <ak@linux.intel.com>
>
> ---
> =A0include/asm-generic/mman-common.h | =A0 =A01 +
> =A0mm/madvise.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 15 +++++=
+++++++---
> =A02 files changed, 13 insertions(+), 3 deletions(-)
>
> Index: linux/include/asm-generic/mman-common.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/include/asm-generic/mman-common.h
> +++ linux/include/asm-generic/mman-common.h
> @@ -35,6 +35,7 @@
> =A0#define MADV_DONTFORK =A010 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* don't inheri=
t across fork */
> =A0#define MADV_DOFORK =A0 =A011 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* do inherit=
 across fork */
> =A0#define MADV_HWPOISON =A0100 =A0 =A0 =A0 =A0 =A0 =A0 /* poison a page =
for testing */
> +#define MADV_SOFT_OFFLINE 101 =A0 =A0 =A0 =A0 =A0/* soft offline page fo=
r testing */
>
> =A0#define MADV_MERGEABLE =A0 12 =A0 =A0 =A0 =A0 =A0 =A0/* KSM may merge =
identical pages */
> =A0#define MADV_UNMERGEABLE 13 =A0 =A0 =A0 =A0 =A0 =A0/* KSM may not merg=
e identical pages */
> Index: linux/mm/madvise.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/mm/madvise.c
> +++ linux/mm/madvise.c
> @@ -9,6 +9,7 @@
> =A0#include <linux/pagemap.h>
> =A0#include <linux/syscalls.h>
> =A0#include <linux/mempolicy.h>
> +#include <linux/page-isolation.h>
> =A0#include <linux/hugetlb.h>
> =A0#include <linux/sched.h>
> =A0#include <linux/ksm.h>
> @@ -222,7 +223,7 @@ static long madvise_remove(struct vm_are
> =A0/*
> =A0* Error injection support for memory error handling.
> =A0*/
> -static int madvise_hwpoison(unsigned long start, unsigned long end)
> +static int madvise_hwpoison(int bhv, unsigned long start, unsigned long =
end)
> =A0{
> =A0 =A0 =A0 =A0int ret =3D 0;
>
> @@ -233,6 +234,14 @@ static int madvise_hwpoison(unsigned lon
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret =3D get_user_pages_fast(start, 1, =
0, &p);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret !=3D 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bhv =3D=3D MADV_SOFT_OFFLINE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "Soft offl=
ining page %lx at %lx\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_to_pfn=
(p), start);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D soft_offline_page(p=
, MF_COUNT_INCREASED);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_INFO "Injecting memory failure=
 for page %lx at %lx\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_to_pfn(p), start);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Ignore return value for now */
> @@ -333,8 +342,8 @@ SYSCALL_DEFINE3(madvise, unsigned long,
> =A0 =A0 =A0 =A0size_t len;
>
> =A0#ifdef CONFIG_MEMORY_FAILURE
> - =A0 =A0 =A0 if (behavior =3D=3D MADV_HWPOISON)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return madvise_hwpoison(start, start+len_in=
);
> + =A0 =A0 =A0 if (behavior =3D=3D MADV_HWPOISON || behavior =3D=3D MADV_S=
OFT_OFFLINE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return madvise_hwpoison(behavior, start, st=
art+len_in);
> =A0#endif
> =A0 =A0 =A0 =A0if (!madvise_behavior_valid(behavior))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return error;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
