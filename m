Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 960DE6B002F
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 05:27:03 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p9P9R0Fq024841
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 02:27:00 -0700
Received: from vwm42 (vwm42.prod.google.com [10.241.20.42])
	by hpaq11.eem.corp.google.com with ESMTP id p9P9QOQ6011306
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 02:26:59 -0700
Received: by vwm42 with SMTP id 42so407180vwm.8
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 02:26:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111025090956.GA10797@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
Date: Tue, 25 Oct 2011 02:26:56 -0700
Message-ID: <CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 2:09 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, Oct 24, 2011 at 11:39:49PM -0700, Colin Cross wrote:
>> Under the following conditions, __alloc_pages_slowpath can loop
>> forever:
>> gfp_mask & __GFP_WAIT is true
>> gfp_mask & __GFP_FS is false
>> reclaim and compaction make no progress
>> order <=3D PAGE_ALLOC_COSTLY_ORDER
>>
>> These conditions happen very often during suspend and resume,
>> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
>> allocations into __GFP_WAIT.
> b>
>> The oom killer is not run because gfp_mask & __GFP_FS is false,
>> but should_alloc_retry will always return true when order is less
>> than PAGE_ALLOC_COSTLY_ORDER.
>>
>> Fix __alloc_pages_slowpath to skip retrying when oom killer is
>> not allowed by the GFP flags, the same way it would skip if the
>> oom killer was allowed but disabled.
>>
>> Signed-off-by: Colin Cross <ccross@android.com>
>
> Hi Colin,
>
> Your patch functionally seems fine. I see the problem and we certainly
> do not want to have the OOM killer firing during suspend. I would prefer
> that the IO devices would not be suspended until reclaim was completed
> but I imagine that would be a lot harder.
>
> That said, it will be difficult to remember why checking __GFP_NOFAIL in
> this case is necessary and someone might "optimitise" it away later. It
> would be preferable if it was self-documenting. Maybe something like
> this? (This is totally untested)

This issue is not limited to suspend, any GFP_NOIO allocation could
end up in the same loop.  Suspend is the most likely case, because it
effectively converts all GFP_KERNEL allocations into GFP_NOIO.

> =A0mm/page_alloc.c | =A0 22 ++++++++++++++++++++++
> =A01 files changed, 22 insertions(+), 0 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..ad8f376 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
> =A0 =A0 =A0 =A0saved_gfp_mask =3D gfp_allowed_mask;
> =A0 =A0 =A0 =A0gfp_allowed_mask &=3D ~GFP_IOFS;
> =A0}
> +
> +static bool pm_suspending(void)
> +{
> + =A0 =A0 =A0 if ((gfp_allowed_mask & GFP_IOFS) =3D=3D GFP_IOFS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 return true;
> +}
> +
> +#else
> +
> +static bool pm_suspending(void)
> +{
> + =A0 =A0 =A0 return false;
> +}
> =A0#endif /* CONFIG_PM_SLEEP */
>
> =A0#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
> @@ -2207,6 +2221,14 @@ rebalance:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Suspend converts GFP_KERNEL to __GFP_W=
AIT which can
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* prevent reclaim making forward progres=
s without
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invoking OOM. Bail if we are suspendin=
g
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pm_suspending())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nopage;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Check if we should retry the allocation */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
