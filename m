Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id B1B296B00FE
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 13:42:58 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id eb12so4527131oac.32
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 10:42:58 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id be9si15370961obb.49.2014.03.23.10.42.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 10:42:58 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id wo20so4633251obc.36
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 10:42:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395436655-21670-3-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-3-git-send-email-john.stultz@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 23 Mar 2014 10:42:37 -0700
Message-ID: <CAHGf_=pBUW1Za862NGeN2u2D8B9hjTk5DgP4SYqoM34KUnMMhQ@mail.gmail.com>
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory non-volatile
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
> Users of volatile ranges will need to know if memory was discarded.
> This patch adds the purged state tracking required to inform userland
> when it marks memory as non-volatile that some memory in that range
> was purged and needs to be regenerated.
>
> This simplified implementation which uses some of the logic from
> Minchan's earlier efforts, so credit to Minchan for his work.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/swap.h    | 15 ++++++++--
>  include/linux/swapops.h | 10 +++++++
>  include/linux/vrange.h  |  3 ++
>  mm/vrange.c             | 75 +++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 101 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 46ba0c6..18c12f9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -70,8 +70,19 @@ static inline int current_is_kswapd(void)
>  #define SWP_HWPOISON_NUM 0
>  #endif
>
> -#define MAX_SWAPFILES \
> -       ((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +
> +/*
> + * Purged volatile range pages
> + */
> +#define SWP_VRANGE_PURGED_NUM 1
> +#define SWP_VRANGE_PURGED (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
> +
> +
> +#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)      \
> +                               - SWP_MIGRATION_NUM     \
> +                               - SWP_HWPOISON_NUM      \
> +                               - SWP_VRANGE_PURGED_NUM \
> +                       )

This change hwpoison and migration tag number. maybe ok, maybe not.
I'd suggest to use younger number than hwpoison.
(That's why hwpoison uses younger number than migration)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
