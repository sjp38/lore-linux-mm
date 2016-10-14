Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A668B6B025E
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 15:25:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o81so4054861wma.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 12:25:49 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id q6si14295845wjr.172.2016.10.14.12.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 12:25:48 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id 191so1035222wmr.0
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 12:25:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1476452125-22059-1-git-send-email-zhongjiang@huawei.com>
References: <1476452125-22059-1-git-send-email-zhongjiang@huawei.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 14 Oct 2016 21:25:47 +0200
Message-ID: <CAMJBoFN7VzLYckHL-Zp7onRBvkrx2T-VsVxK3uyqVii3kLpS0A@mail.gmail.com>
Subject: Re: [PATCH] z3fold: remove the unnecessary limit in z3fold_compact_page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 14, 2016 at 3:35 PM, zhongjiang <zhongjiang@huawei.com> wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> z3fold compact page has nothing with the last_chunks. even if
> last_chunks is not free, compact page will proceed.
>
> The patch just remove the limit without functional change.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/z3fold.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e8fc216..4668e1c 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -258,8 +258,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>
>
>         if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
> -           zhdr->middle_chunks != 0 &&
> -           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +           zhdr->middle_chunks != 0 && zhdr->first_chunks == 0) {
>                 memmove(beg + ZHDR_SIZE_ALIGNED,
>                         beg + (zhdr->start_middle << CHUNK_SHIFT),
>                         zhdr->middle_chunks << CHUNK_SHIFT);

This check is actually important because if we move the middle chunk
to the first and leave the last chunk, handles will become invalid and
there won't be any easy way to fix that.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
