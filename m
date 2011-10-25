Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8421C6B002E
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 03:40:25 -0400 (EDT)
Received: by vws16 with SMTP id 16so218231vws.14
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 00:40:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1319524789-22818-1-git-send-email-ccross@android.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
Date: Tue, 25 Oct 2011 10:40:23 +0300
Message-ID: <CAOJsxLGuHZG9pvx5bCp9tOLA40uDz+U_ZY=_xOddtR9423-Jww@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 9:39 AM, Colin Cross <ccross@android.com> wrote:
> Under the following conditions, __alloc_pages_slowpath can loop
> forever:
> gfp_mask & __GFP_WAIT is true
> gfp_mask & __GFP_FS is false
> reclaim and compaction make no progress
> order <=3D PAGE_ALLOC_COSTLY_ORDER
>
> These conditions happen very often during suspend and resume,
> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> allocations into __GFP_WAIT.

Why does it do that? Why don't we fix the gfp mask instead?

> The oom killer is not run because gfp_mask & __GFP_FS is false,
> but should_alloc_retry will always return true when order is less
> than PAGE_ALLOC_COSTLY_ORDER.
>
> Fix __alloc_pages_slowpath to skip retrying when oom killer is
> not allowed by the GFP flags, the same way it would skip if the
> oom killer was allowed but disabled.
>
> Signed-off-by: Colin Cross <ccross@android.com>
> ---
>
> An alternative patch would add a did_some_progress argument to
> __alloc_pages_may_oom, and remove the checks in
> __alloc_pages_slowpath that require knowledge of when
> __alloc_pages_may_oom chooses to run out_of_memory. If
> did_some_progress was still zero, it would goto nopage whether
> or not __alloc_pages_may_oom was actually called.
>
> =A0mm/page_alloc.c | =A0 =A04 ++++
> =A01 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fef8dc3..dcd99b3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2193,6 +2193,10 @@ rebalance:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If we aren't going to tr=
y the OOM killer, give up */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfp_mask & __GFP_NOFA=
IL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nopage=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}

I don't quite understand how __GFP_WAIT is involved here. Which path
is causing the infinite loop?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
