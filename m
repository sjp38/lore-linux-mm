Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 854626B0118
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:51:34 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9818782lbj.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:51:32 -0700 (PDT)
Message-ID: <4FE9780E.5050403@openvz.org>
Date: Tue, 26 Jun 2012 12:51:26 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: ashmem_shrink with long term stable kernel [3.0.36]
References: <CADArhcAxf3g=SLgDaJJMpzNpL_X7fbVbL1jzBYiyjPQFxXLYTA@mail.gmail.com>
In-Reply-To: <CADArhcAxf3g=SLgDaJJMpzNpL_X7fbVbL1jzBYiyjPQFxXLYTA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akhilesh Kumar <akhilesh.lxr@gmail.com>
Cc: "david@fromorbit.com" <david@fromorbit.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Akhilesh Kumar wrote:
> Hi All,
>
> During mm performance testing sometimes we observed below kernel messages
>
> shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=-2133936901
> shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=-2139256767
> shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=-2079333971
> shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=-2096156269
> shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=-20658392
>
>   After debugging is we fount below patch mm/vmscan
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commitdiff;h=635697c663f38106063d5659f0cf2e45afcd4bb5
> Since patch fix critical issue and same is not integrated with long term stable kernel (3.0.36)
> and  we are using below patch with long term stable kernel (3.0.36) is there any side effects ?

Nothing special, your patch should work fine.

> @@ -248,10 +248,12 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>
>          list_for_each_entry(shrinker, &shrinker_list, list) {
>                  unsigned long long delta;
> -               unsigned long total_scan;
> -               unsigned long max_pass;
> +               long total_scan;
> +               long max_pass;
>
>                  max_pass = do_shrinker_shrink(shrinker, shrink, 0);
> +               if (max_pass <= 0)
> +                       continue;
>                  delta = (4 * nr_pages_scanned) / shrinker->seeks;
>                  delta *= max_pass;
>                  do_div(delta, lru_pages + 1);
> --
> Please review and share ur comments.
> Thanks,
> Akhilesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
