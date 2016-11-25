Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86E866B0038
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:00:39 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id o20so27461034lfg.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:00:39 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id h74si20856891lfh.146.2016.11.25.08.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 08:00:38 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id p100so3665067lfg.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:00:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161115170030.f0396011fa00423ff711a3b4@gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com> <20161115170030.f0396011fa00423ff711a3b4@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 25 Nov 2016 10:59:56 -0500
Message-ID: <CALZtONDVC+9s7G0MsXTYB8ZRjO1jJrT64F+O4i5t_dpV-6UCbQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] z3fold: don't fail kernel build if z3fold_header is
 too big
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 15, 2016 at 11:00 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Currently the whole kernel build will be stopped if the size of
> struct z3fold_header is greater than the size of one chunk, which
> is 64 bytes by default. This may stand in the way of automated
> test/debug builds so let's remove that and just fail the z3fold
> initialization in such case instead.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 7ad70fa..ffd9353 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -870,10 +870,15 @@ MODULE_ALIAS("zpool-z3fold");
>
>  static int __init init_z3fold(void)
>  {
> -       /* Make sure the z3fold header will fit in one chunk */
> -       BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);

Nak.  this is the wrong way to handle this.  The build bug is there to
indicate to you that your patch makes the header too large, not as a
runtime check to disable everything.

The right way to handle it is to change the hardcoded assumption that
the header fits into a single chunk; e.g.:

#define ZHDR_SIZE_ALIGNED round_up(sizeof(struct z3fold_header), CHUNK_SIZE)
#define ZHDR_CHUNKS (ZHDR_SIZE_ALIGNED >> CHUNK_SHIFT)

then use ZHDR_CHUNKS in all places where it's currently assumed the
header is 1 chunk, e.g. in num_free_chunks:

  if (zhdr->middle_chunks != 0) {
    int nfree_before = zhdr->first_chunks ?
-      0 : zhdr->start_middle - 1;
+      0 : zhdr->start_middle - ZHDR_CHUNKS;

after changing all needed places like that, the build bug isn't needed
anymore (unless we want to make sure the header isn't larger than some
arbitrary number N chunks)

> -       zpool_register_driver(&z3fold_zpool_driver);
> +       /* Fail the initialization if z3fold header won't fit in one chunk */
> +       if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
> +               pr_err("z3fold: z3fold_header size (%d) is bigger than "
> +                       "the chunk size (%d), can't proceed\n",
> +                       sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
> +               return -E2BIG;
> +       }
>
> +       zpool_register_driver(&z3fold_zpool_driver);
>         return 0;
>  }
>
> --
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
