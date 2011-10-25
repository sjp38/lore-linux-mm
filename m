Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 96B636B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 13:09:04 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p9PH920f022786
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 10:09:02 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by wpaz9.hot.corp.google.com with ESMTP id p9PH8xRH012208
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 10:09:01 -0700
Received: by gyf1 with SMTP id 1so1041770gyf.8
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 10:08:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111025112300.GB10797@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
	<20111025112300.GB10797@suse.de>
Date: Tue, 25 Oct 2011 10:08:58 -0700
Message-ID: <CAMbhsRTFWoEaWXQi7vKc3XVqDv3qVBVx8Ax5TfncJF8A4Txj_w@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 4:23 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Oct 25, 2011 at 02:26:56AM -0700, Colin Cross wrote:
>> On Tue, Oct 25, 2011 at 2:09 AM, Mel Gorman <mgorman@suse.de> wrote:
>> > On Mon, Oct 24, 2011 at 11:39:49PM -0700, Colin Cross wrote:
>> >> Under the following conditions, __alloc_pages_slowpath can loop
>> >> forever:
>> >> gfp_mask & __GFP_WAIT is true
>> >> gfp_mask & __GFP_FS is false
>> >> reclaim and compaction make no progress
>> >> order <=3D PAGE_ALLOC_COSTLY_ORDER
>> >>
>> >> These conditions happen very often during suspend and resume,
>> >> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
>> >> allocations into __GFP_WAIT.
>> > b>
>> >> The oom killer is not run because gfp_mask & __GFP_FS is false,
>> >> but should_alloc_retry will always return true when order is less
>> >> than PAGE_ALLOC_COSTLY_ORDER.
>> >>
>> >> Fix __alloc_pages_slowpath to skip retrying when oom killer is
>> >> not allowed by the GFP flags, the same way it would skip if the
>> >> oom killer was allowed but disabled.
>> >>
>> >> Signed-off-by: Colin Cross <ccross@android.com>
>> >
>> > Hi Colin,
>> >
>> > Your patch functionally seems fine. I see the problem and we certainly
>> > do not want to have the OOM killer firing during suspend. I would pref=
er
>> > that the IO devices would not be suspended until reclaim was completed
>> > but I imagine that would be a lot harder.
>> >
>> > That said, it will be difficult to remember why checking __GFP_NOFAIL =
in
>> > this case is necessary and someone might "optimitise" it away later. I=
t
>> > would be preferable if it was self-documenting. Maybe something like
>> > this? (This is totally untested)
>>
>> This issue is not limited to suspend, any GFP_NOIO allocation could
>> end up in the same loop. =A0Suspend is the most likely case, because it
>> effectively converts all GFP_KERNEL allocations into GFP_NOIO.
>>
>
> I see what you mean with GFP_NOIO but there is an important difference
> between GFP_NOIO and suspend. =A0A GFP_NOIO low-order allocation currentl=
y
> implies __GFP_NOFAIL as commented on in should_alloc_retry(). If no progr=
ess
> is made, we call wait_iff_congested() and sleep for a bit. As the system
> is running, kswapd and other process activity will proceed and eventually
> reclaim enough pages for the GFP_NOIO allocation to succeed. In a running
> system, GFP_NOIO can stall for a period of time but your patch will cause
> the allocation to fail. While I expect callers return ENOMEM or handle
> the situation properly with a wait-and-retry loop, there will be
> operations that fail that used to succeed. This is why I'd prefer it was
> a suspend-specific fix unless we know there is a case where a machine
> livelocks due to a GFP_NOIO allocation looping forever and even then I'd
> wonder why kswapd was not helping.

OK, I see the change in behavior you are trying to avoid.  With your
patch GFP_NOIO allocations can still fail during suspend, is that OK?
I'm also worried about GFP_NOIO allocations looping forever when swap
is not enabled, but I've never seen it happen, and it would probably
recover eventually when another tried tried a GFP_KERNEL allocation
and oom killed something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
