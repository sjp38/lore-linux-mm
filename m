Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 589DF6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 11:13:32 -0500 (EST)
Received: by iaek3 with SMTP id k3so8773772iae.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 08:13:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111114140421.GA27150@suse.de>
References: <20111114140421.GA27150@suse.de>
Date: Wed, 16 Nov 2011 01:13:30 +0900
Message-ID: <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 14, 2011 at 11:04 PM, Mel Gorman <mgorman@suse.de> wrote:
> This patch seems to have gotten lost in the cracks and the discussion
> on alternatives that started here https://lkml.org/lkml/2011/10/25/24
> petered out without any alternative patches being posted. Lacking
> a viable alternative patch, I'm reposting this patch because AFAIK,
> this bug still exists.
>
> Colin Cross reported;
>
> =C2=A0Under the following conditions, __alloc_pages_slowpath can loop for=
ever:
> =C2=A0gfp_mask & __GFP_WAIT is true
> =C2=A0gfp_mask & __GFP_FS is false
> =C2=A0reclaim and compaction make no progress
> =C2=A0order <=3D PAGE_ALLOC_COSTLY_ORDER
>
> =C2=A0These conditions happen very often during suspend and resume,
> =C2=A0when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> =C2=A0allocations into __GFP_WAIT.
>
> =C2=A0The oom killer is not run because gfp_mask & __GFP_FS is false,
> =C2=A0but should_alloc_retry will always return true when order is less
> =C2=A0than PAGE_ALLOC_COSTLY_ORDER.
>
> In his fix, he avoided retrying the allocation if reclaim made no
> progress and __GFP_FS was not set. The problem is that this would
> result in GFP_NOIO allocations failing that previously succeeded
> which would be very unfortunate.
>
> The big difference between GFP_NOIO and suspend converting GFP_KERNEL
> to behave like GFP_NOIO is that normally flushers will be cleaning
> pages and kswapd reclaims pages allowing GFP_NOIO to succeed after
> a short delay. The same does not necessarily apply during suspend as
> the storage device may be suspended. =C2=A0Hence, this patch special case=
s
> the suspend case to fail the page allocation if reclaim cannot make
> progress. This might cause suspend to abort but that is better than
> a livelock.
>
> [mgorman@suse.de: Rework fix to be suspend specific]
> Reported-and-tested-by: Colin Cross <ccross@android.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 22 ++++++++++++++++++++++
> =C2=A01 files changed, 22 insertions(+), 0 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..5402897 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0saved_gfp_mask =3D gfp_allowed_mask;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0gfp_allowed_mask &=3D ~GFP_IOFS;
> =C2=A0}
> +
> +static bool pm_suspending(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if ((gfp_allowed_mask & GFP_IOFS) =3D=3D GFP_IOFS)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 return true;
> +}
> +
> +#else
> +
> +static bool pm_suspending(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return false;
> +}
> =C2=A0#endif /* CONFIG_PM_SLEEP */
>
> =C2=A0#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
> @@ -2214,6 +2228,14 @@ rebalance:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto restart;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Suspend conver=
ts GFP_KERNEL to __GFP_WAIT which can
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* prevent reclai=
m making forward progress without
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* invoking OOM. =
Bail if we are suspending
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pm_suspending())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto nopage;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check if we should retry the allocation */
>


I don't have much time to look into this problem so I miss some things.
But the feeling I have a mind when I faced this problem is why we
should make another special case handling function.
Already we have such thing for hibernation - oom_killer_disabled in vm
Could we use it instead of making new branch for very special case?
Maybe It would be better to rename oom_killer_disabled with
pm_is_going or something.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
