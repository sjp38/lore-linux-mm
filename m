Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id AE7286B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 03:49:37 -0400 (EDT)
Received: by wijp11 with SMTP id p11so16060863wij.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 00:49:37 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id y10si15907464wjx.70.2015.10.15.00.49.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 00:49:36 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so260359127wic.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 00:49:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <561F4EEA.60203@huawei.com>
References: <561F4EEA.60203@huawei.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 15 Oct 2015 09:49:16 +0200
Message-ID: <CACT4Y+Yy=HeTMzB-HanDHfF4K-WdsZ0wD+4wP0D36o7fxQ2VgQ@mail.gmail.com>
Subject: Re: some problems about kasan
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Xishi Qiu <qiuxishi@huawei.com>, guohanjun@huawei.com, zhangdianfang@huawei.com

On Thu, Oct 15, 2015 at 8:59 AM, zhong jiang <zhongjiang@huawei.com> wrote:
> 1=E3=80=81 I feel confused about one of the cases when  testing the cases=
  kasan can solve . the function come from the kernel in the /lib/test_kasa=
n.c.
>
>   static noinline void __init kmalloc_uaf2(void)
> {
>         char *ptr1, *ptr2;
>         size_t size =3D 43;
>
>         pr_info("use-after-free after another kmalloc\n");
>         ptr1 =3D kmalloc(size, GFP_KERNEL);
>         if (!ptr1) {
>                 pr_err("Allocation failed\n");
>                 return;
>         }
>
>         kfree(ptr1);
>         ptr2 =3D kmalloc(size, GFP_KERNEL);
>         if (!ptr2) {
>                 pr_err("Allocation failed\n");
>                 return;
>         }
>
>         ptr1[40] =3D 'x';
>         kfree(ptr2);
> }
>
> In the above function, the point ptr1 are probably  the same as the ptr2 =
. so the error not certain to occur.

Hi Zhong,

You are right that ptr1 and ptr2 are most likely will be equal.
To detect such bugs KASAN it meant to use "quarantine" and delay reuse
of heap objects. We have quarantine implementation in the following
branch:

https://github.com/google/kasan/blob/dmitryc-patches-original/mm/kasan/quar=
antine.c

It is not committed upstream yet.


> 2=E3=80=81Is the stack local variable out of bound access set by the GCC =
 ? I don't see any operate in the kernel

Yes, stack redzones and code to poison/unpoison them is emitted by compiler=
.
You can use objdump to look at generated machine code, you should see
instructions that poison/unpoison stack redzones.



> 3=E3=80=81I want to know that the global variable size include redzone is=
 allocated by the module_alloc().

I don't understand the question. Please re-phrase it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
