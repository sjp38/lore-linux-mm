Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6326B005C
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 03:22:28 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p9Q7MFfM031736
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:22:15 -0700
Received: from ywa8 (ywa8.prod.google.com [10.192.1.8])
	by wpaz37.hot.corp.google.com with ESMTP id p9Q7JTSi021236
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:22:14 -0700
Received: by ywa8 with SMTP id 8so1983890ywa.9
        for <linux-mm@kvack.org>; Wed, 26 Oct 2011 00:22:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110260006470.23227@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
	<CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
	<alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com>
	<CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com>
	<alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
	<CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com>
	<alpine.DEB.2.00.1110252327270.20273@chino.kir.corp.google.com>
	<CAMbhsRR0z-aJ848gq6ZQATZOgz=EybVsRtaQbjCr42PtCubCzw@mail.gmail.com>
	<alpine.DEB.2.00.1110252347330.20273@chino.kir.corp.google.com>
	<CAMbhsRScgfokDOiT7c9RbmqC7E_ZXrwLEYXE7JZWFGoePjAXvg@mail.gmail.com>
	<alpine.DEB.2.00.1110260006470.23227@chino.kir.corp.google.com>
Date: Wed, 26 Oct 2011 00:22:14 -0700
Message-ID: <CAMbhsRRZBUcfv5kT4aYm=Z3+kc-usYJVqyc_+1gAEy-4yH_nPQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Wed, Oct 26, 2011 at 12:10 AM, David Rientjes <rientjes@google.com> wrot=
e:
> On Tue, 25 Oct 2011, Colin Cross wrote:
>
>> > gfp_allowed_mask is initialized to GFP_BOOT_MASK to start so that __GF=
P_FS
>> > is never allowed before the slab allocator is completely initialized, =
so
>> > you've now implicitly made all early boot allocations to be __GFP_NORE=
TRY
>> > even though they may not pass it.
>>
>> Only before interrupts are enabled, and then isn't it vulnerable to
>> the same livelock? =A0Interrupts are off, single cpu, kswapd can't run.
>> If an allocation ever failed, which seems unlikely, why would retrying
>> help?
>>
>
> If you want to claim gfp_allowed_mask as a pm-only entity, then I see no
> problem with this approach. =A0However, if gfp_allowed_mask would be allo=
wed
> to temporarily change after init for another purpose then it would make
> sense to retry because another allocation with __GFP_FS on another cpu or
> kswapd could start making progress could allow for future memory freeing.
>
> The suggestion to add a hook directly into a pm-interface was so that we
> could isolate it only to suspend and, to me, is the most maintainable
> solution.
>

pm_restrict_gfp_mask seems to claim gfp_allowed_mask as owned by pm at runt=
ime:
"gfp_allowed_mask also should only be modified with pm_mutex held,
unless the suspend/hibernate code is guaranteed not to run in parallel
with that modification"

I think we've wrapped around to Mel's original patch, which adds a
pm_suspending() helper that is implemented next to
pm_restrict_gfp_mask.  His patch puts the check inside
!did_some_progress instead of should_alloc_retry, which I prefer as it
at least keeps trying until reclaim isn't working.  Pekka was trying
to avoid adding pm-specific checks into the allocator, which is why I
stuck to the symptom (__GFP_FS is clear) rather than the cause (PM).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
