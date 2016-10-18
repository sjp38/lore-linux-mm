Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 032636B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:58:35 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id 130so161083269vkg.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:58:34 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id q187si5615243vkd.76.2016.10.18.06.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 06:58:34 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id b186so9752020vkb.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:58:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1476776569-29504-1-git-send-email-zhongjiang@huawei.com>
References: <1476776569-29504-1-git-send-email-zhongjiang@huawei.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 18 Oct 2016 09:57:53 -0400
Message-ID: <CALZtONDMMWX7ST_2DNijmAu3mJOmw21XTJZqNPD1wbZWBGjdew@mail.gmail.com>
Subject: Re: [PATCH] z3fold: limit first_num to the actual range of possible
 buddy indexes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Vitaly Wool <vitalywool@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Oct 18, 2016 at 3:42 AM, zhongjiang <zhongjiang@huawei.com> wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> At present, Tying the first_num size to NCHUNKS_ORDER is confusing.
> the number of chunks is completely unrelated to the number of buddies.
>
> The patch limit the first_num to actual range of possible buddy indexes.
> and that is more reasonable and obvious without functional change.
>
> Suggested-by: Dan Streetman <ddstreet@ieee.org>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> --->  mm/z3fold.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 8f9e89c..207e5dd 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -50,7 +50,7 @@
>  #define ZHDR_SIZE_ALIGNED CHUNK_SIZE
>  #define NCHUNKS                ((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
>
> -#define BUDDY_MASK     ((1 << NCHUNKS_ORDER) - 1)
> +#define BUDDY_MASK     (0x3)
>
>  struct z3fold_pool;
>  struct z3fold_ops {
> @@ -109,7 +109,7 @@ struct z3fold_header {
>         unsigned short middle_chunks;
>         unsigned short last_chunks;
>         unsigned short start_middle;
> -       unsigned short first_num:NCHUNKS_ORDER;
> +       unsigned short first_num:2;
>  };
>
>  /*
> @@ -179,7 +179,11 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
>         return (struct z3fold_header *)(handle & PAGE_MASK);
>  }
>
> -/* Returns buddy number */
> +/*
> + * (handle & BUDDY_MASK) < zhdr->first_num is possible in encode_handle
> + *  but that doesn't matter. because the masking will result in the
> + *  correct buddy number.
> + */
>  static enum buddy handle_to_buddy(unsigned long handle)
>  {
>         struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
