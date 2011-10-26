Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77BA96B0047
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:57:13 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9Q6vASR027076
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:57:11 -0700
Received: from qabg14 (qabg14.prod.google.com [10.224.20.206])
	by hpaq13.eem.corp.google.com with ESMTP id p9Q6t5xs003849
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:57:09 -0700
Received: by qabg14 with SMTP id g14so2675088qab.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:57:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110252347330.20273@chino.kir.corp.google.com>
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
Date: Tue, 25 Oct 2011 23:57:04 -0700
Message-ID: <CAMbhsRScgfokDOiT7c9RbmqC7E_ZXrwLEYXE7JZWFGoePjAXvg@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 11:51 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Tue, 25 Oct 2011, Colin Cross wrote:
>
>> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> >> index fef8dc3..59cd4ff 100644
>> >> --- a/mm/page_alloc.c
>> >> +++ b/mm/page_alloc.c
>> >> @@ -1786,6 +1786,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned in=
t order,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> >>
>> >> =A0 =A0 =A0 =A0 /*
>> >> + =A0 =A0 =A0 =A0* If PM has disabled I/O, OOM is disabled and reclai=
m is unlikely
>> >> + =A0 =A0 =A0 =A0* to make any progress. =A0To prevent a livelock, do=
n't retry.
>> >> + =A0 =A0 =A0 =A0*/
>> >> + =A0 =A0 =A0 if (!(gfp_allowed_mask & __GFP_FS))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> >> +
>> >> + =A0 =A0 =A0 /*
>> >> =A0 =A0 =A0 =A0 =A0* In this implementation, order <=3D PAGE_ALLOC_CO=
STLY_ORDER
>> >> =A0 =A0 =A0 =A0 =A0* means __GFP_NOFAIL, but that may not be true in =
other
>> >> =A0 =A0 =A0 =A0 =A0* implementations.
>> >
>> > Eek, this is precisely what we don't want and is functionally the same=
 as
>> > what you initially proposed except it doesn't care about __GFP_NOFAIL.
>>
>> This is checking against gfp_allowed_mask, not gfp_mask.
>>
>
> gfp_allowed_mask is initialized to GFP_BOOT_MASK to start so that __GFP_F=
S
> is never allowed before the slab allocator is completely initialized, so
> you've now implicitly made all early boot allocations to be __GFP_NORETRY
> even though they may not pass it.

Only before interrupts are enabled, and then isn't it vulnerable to
the same livelock?  Interrupts are off, single cpu, kswapd can't run.
If an allocation ever failed, which seems unlikely, why would retrying
help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
