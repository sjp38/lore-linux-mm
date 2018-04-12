Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34CD36B0006
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 17:16:25 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id t6so4518943ual.4
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:16:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s132sor2308901vkb.216.2018.04.12.14.16.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 14:16:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180412211036.GB18364@bombadil.infradead.org>
References: <20180313132639.17387-1-willy@infradead.org> <20180313132639.17387-8-willy@infradead.org>
 <CAOxpaSXDX1fyrOnnsehEoRgQz2_K1OmOn9TikZzJcXmwMLEfnA@mail.gmail.com> <20180412211036.GB18364@bombadil.infradead.org>
From: Ross Zwisler <zwisler@gmail.com>
Date: Thu, 12 Apr 2018 15:16:23 -0600
Message-ID: <CAOxpaSV5L_O9zO_+JLXk9e3SMjm0Gc90ZxSEHaJmvN5YsYpjMA@mail.gmail.com>
Subject: Re: [PATCH v9 07/61] xarray: Add the xa_lock to the radix_tree_root
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, Apr 12, 2018 at 3:10 PM, Matthew Wilcox <willy@infradead.org> wrote=
:
> On Thu, Apr 12, 2018 at 02:59:32PM -0600, Ross Zwisler wrote:
>> This is causing build breakage in the radix tree test suite in the
>> current linux/master:
>>
>> ./linux/../../../../include/linux/idr.h: In function =E2=80=98idr_init_b=
ase=E2=80=99:
>> ./linux/../../../../include/linux/radix-tree.h:129:2: warning:
>> implicit declaration of function =E2=80=98spin_lock_init=E2=80=99; did y=
ou mean
>> =E2=80=98spinlock_t=E2=80=99? [-Wimplicit-function-declaration]
>
> Argh.  That was added two patches later in
> "xarray: Add definition of struct xarray":
>
> diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinloc=
k.h
> index b21b586b9854..4ec4d2cbe27a 100644
> --- a/tools/include/linux/spinlock.h
> +++ b/tools/include/linux/spinlock.h
> @@ -6,8 +6,9 @@
>  #include <stdbool.h>
>
>  #define spinlock_t             pthread_mutex_t
> -#define DEFINE_SPINLOCK(x)     pthread_mutex_t x =3D PTHREAD_MUTEX_INITI=
ALIZER;
> +#define DEFINE_SPINLOCK(x)     pthread_mutex_t x =3D PTHREAD_MUTEX_INITI=
ALIZER
>  #define __SPIN_LOCK_UNLOCKED(x)        (pthread_mutex_t)PTHREAD_MUTEX_IN=
ITIALIZER
> +#define spin_lock_init(x)      pthread_mutex_init(x, NULL)
>
>  #define spin_lock_irqsave(x, f)                (void)f, pthread_mutex_lo=
ck(x)
>  #define spin_unlock_irqrestore(x, f)   (void)f, pthread_mutex_unlock(x)
>
> I didn't pick up that it was needed this early on in the patch series.

Hmmm..I don't know if it's a patch ordering issue, because this
happens with the current linux/master where presumably all the patches
are present?
