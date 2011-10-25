Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 308DF6B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 03:51:29 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p9P7pLXt004161
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 00:51:23 -0700
Received: from vcbfo14 (vcbfo14.prod.google.com [10.220.205.14])
	by wpaz37.hot.corp.google.com with ESMTP id p9P7nW9X027567
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 00:51:20 -0700
Received: by vcbfo14 with SMTP id fo14so321378vcb.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 00:51:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLGuHZG9pvx5bCp9tOLA40uDz+U_ZY=_xOddtR9423-Jww@mail.gmail.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<CAOJsxLGuHZG9pvx5bCp9tOLA40uDz+U_ZY=_xOddtR9423-Jww@mail.gmail.com>
Date: Tue, 25 Oct 2011 00:51:19 -0700
Message-ID: <CAMbhsRQs+P9djqW_62ajfZTHE3yxsOs0agek81aZrBzZ2-5-Fg@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 12:40 AM, Pekka Enberg <penberg@cs.helsinki.fi> wro=
te:
> On Tue, Oct 25, 2011 at 9:39 AM, Colin Cross <ccross@android.com> wrote:
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
>
> Why does it do that? Why don't we fix the gfp mask instead?
It disables __GFP_IO and __GFP_FS because the IO drivers may be suspended.

>> The oom killer is not run because gfp_mask & __GFP_FS is false,
>> but should_alloc_retry will always return true when order is less
>> than PAGE_ALLOC_COSTLY_ORDER.
>>
>> Fix __alloc_pages_slowpath to skip retrying when oom killer is
>> not allowed by the GFP flags, the same way it would skip if the
>> oom killer was allowed but disabled.
>>
>> Signed-off-by: Colin Cross <ccross@android.com>
>> ---
>>
>> An alternative patch would add a did_some_progress argument to
>> __alloc_pages_may_oom, and remove the checks in
>> __alloc_pages_slowpath that require knowledge of when
>> __alloc_pages_may_oom chooses to run out_of_memory. If
>> did_some_progress was still zero, it would goto nopage whether
>> or not __alloc_pages_may_oom was actually called.
>>
>> =A0mm/page_alloc.c | =A0 =A04 ++++
>> =A01 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index fef8dc3..dcd99b3 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2193,6 +2193,10 @@ rebalance:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If we aren't going to t=
ry the OOM killer, give up */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfp_mask & __GFP_NOF=
AIL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nopag=
e;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0}
>
> I don't quite understand how __GFP_WAIT is involved here. Which path
> is causing the infinite loop?
GFP_KERNEL is __GFP_WAIT | __GFP_IO | __GFP_FS.  Once driver suspend
has started, gfp_allowed_mask is ~(__GFP_IO | GFP_FS), so any call to
__alloc_pages_nodemask(GFP_KERNEL, ...) gets masked to effectively
__alloc_pages_nodemask(__GFP_WAIT, ...).

The loop is in __alloc_pages_slowpath, from the rebalance label to
should_alloc_retry.  Under the conditions I listed in the commit
message, there is no path to the nopage label, because all the
relevant "goto nopage" lines that would normally allow a GFP_KERNEL
allocation to fail are inside a check for __GFP_FS.

Modifying the gfp_allowed_mask would not completely fix the issue, a
GFP_NOIO allocation can meet the conditions outside of suspend.
gfp_allowed_mask just makes the issue more likely, by converting
GFP_KERNEL into GFP_NOIO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
