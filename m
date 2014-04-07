Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 318D56B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 18:14:22 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i11so94360oag.20
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 15:14:21 -0700 (PDT)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id be9si53916obb.103.2014.04.07.15.14.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 15:14:21 -0700 (PDT)
Received: by mail-ob0-f176.google.com with SMTP id wp18so88622obc.35
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 15:14:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5342F083.5020509@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <1395436655-21670-3-git-send-email-john.stultz@linaro.org>
 <CAHGf_=pBUW1Za862NGeN2u2D8B9hjTk5DgP4SYqoM34KUnMMhQ@mail.gmail.com> <5342F083.5020509@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 7 Apr 2014 18:14:01 -0400
Message-ID: <CAHGf_=pRy-8XjMjE4Kk9AgO2oeRcy+DiMLiN-rBhuWOexxbXJw@mail.gmail.com>
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory non-volatile
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> This change hwpoison and migration tag number. maybe ok, maybe not.
>
> Though depending on config can't these tag numbers change anyway?

I don't think distro disable any of these.


>> I'd suggest to use younger number than hwpoison.
>> (That's why hwpoison uses younger number than migration)
>
> So I can, but the way these are defined makes the results seem pretty
> terrible:
>
> #define SWP_MIGRATION_WRITE    (MAX_SWAPFILES + SWP_HWPOISON_NUM \
>                     + SWP_MVOLATILE_PURGED_NUM + 1)
>
> Particularly when:
> #define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)        \
>                 - SWP_MIGRATION_NUM        \
>                 - SWP_HWPOISON_NUM        \
>                 - SWP_MVOLATILE_PURGED_NUM    \
>             )
>
> Its a lot of unnecessary mental gymnastics. Yuck.
>
> Would a general cleanup like the following be ok to try to make this
> more extensible?
>
> thanks
> -john
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 3507115..21387df 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -49,29 +49,38 @@ static inline int current_is_kswapd(void)
>   * actions on faults.
>   */
>
> +enum {
> +       /*
> +        * NOTE: We use the high bits here (subtracting from
> +        * 1<<MAX_SWPFILES_SHIFT), so to preserve the values insert
> +        * new entries here at the top of the enum, not at the bottom
> +        */
> +#ifdef CONFIG_MEMORY_FAILURE
> +       SWP_HWPOISON_NR,
> +#endif
> +#ifdef CONFIG_MIGRATION
> +       SWP_MIGRATION_READ_NR,
> +       SWP_MIGRATION_WRITE_NR,
> +#endif
> +       SWP_MAX_NR,
> +};
> +#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT) - SWP_MAX_NR)
> +

I don't see any benefit of this code. At least, SWP_MAX_NR is suck.
The name doesn't match the actual meanings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
