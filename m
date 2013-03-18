Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7F8AB6B0039
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 03:02:11 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id j6so5167609oag.22
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 00:02:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363525456-10448-4-git-send-email-mgorman@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-4-git-send-email-mgorman@suse.de>
Date: Mon, 18 Mar 2013 15:02:10 +0800
Message-ID: <CAJd=RBAnEeC5D17AmQJHhbo-ST0fZ6+dmYSBzSnN8v4wtm6STQ@mail.gmail.com>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Mi@jasper.es

On Sun, Mar 17, 2013 at 9:04 PM, Mel Gorman <mgorman@suse.de> wrote:
>
> +               /* If no reclaim progress then increase scanning priority */
> +               if (sc.nr_reclaimed - nr_reclaimed == 0)
> +                       raise_priority = true;
>
>                 /*
> -                * Fragmentation may mean that the system cannot be
> -                * rebalanced for high-order allocations in all zones.
> -                * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
> -                * it means the zones have been fully scanned and are still
> -                * not balanced. For high-order allocations, there is
> -                * little point trying all over again as kswapd may
> -                * infinite loop.
> -                *
> -                * Instead, recheck all watermarks at order-0 as they
> -                * are the most important. If watermarks are ok, kswapd will go
> -                * back to sleep. High-order users can still perform direct
> -                * reclaim if they wish.
> +                * Raise priority if scanning rate is too low or there was no
> +                * progress in reclaiming pages
2) this comment is already included also in the above one?

>                  */
> -               if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> -                       order = sc.order = 0;
> -
> -               goto loop_again;
> -       }
> +               if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)
1) duplicated reclaim check with the above one, merge error?

> +                       sc.priority--;
> +       } while (sc.priority >= 0 &&
> +                !pgdat_balanced(pgdat, order, *classzone_idx));
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
