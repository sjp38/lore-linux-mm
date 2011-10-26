Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA7E56B0039
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:36:51 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9Q6amRh014519
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:36:49 -0700
Received: from vws14 (vws14.prod.google.com [10.241.21.142])
	by hpaq12.eem.corp.google.com with ESMTP id p9Q6ZqVD023027
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:36:44 -0700
Received: by vws14 with SMTP id 14so1935247vws.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:36:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110252327270.20273@chino.kir.corp.google.com>
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
Date: Tue, 25 Oct 2011 23:36:44 -0700
Message-ID: <CAMbhsRR0z-aJ848gq6ZQATZOgz=EybVsRtaQbjCr42PtCubCzw@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 11:33 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Tue, 25 Oct 2011, Colin Cross wrote:
>
>> Makes sense. =A0What about this? =A0Official patch to follow.
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index fef8dc3..59cd4ff 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1786,6 +1786,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int o=
rder,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* If PM has disabled I/O, OOM is disabled and reclaim i=
s unlikely
>> + =A0 =A0 =A0 =A0* to make any progress. =A0To prevent a livelock, don't=
 retry.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 if (!(gfp_allowed_mask & __GFP_FS))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0* In this implementation, order <=3D PAGE_ALLOC_COSTL=
Y_ORDER
>> =A0 =A0 =A0 =A0 =A0* means __GFP_NOFAIL, but that may not be true in oth=
er
>> =A0 =A0 =A0 =A0 =A0* implementations.
>
> Eek, this is precisely what we don't want and is functionally the same as
> what you initially proposed except it doesn't care about __GFP_NOFAIL.

This is checking against gfp_allowed_mask, not gfp_mask.

> You're trying to address a suspend issue where nothing on the system can
> logically make progress because __GFP_FS seriously restricts the ability
> of reclaim to do anything useful if it doesn't succeed the first time and
> kswapd isn't effective. =A0That's why I suggested a hook into
> pm_restrict_gfp_mask() to set a variable and then treat it exactly as
> __GFP_NORETRY in should_alloc_retry().
>
> Consider if nobody is using suspend and they are allocating with GFP_NOFS=
.
> There's potentially a lot of candidates:
>
> =A0 =A0 =A0 =A0$ grep -r GFP_NOFS * | wc -l
> =A0 =A0 =A0 =A01016
>
> and now we've just introduced a regression where the allocation would
> eventually succeed because of either kswapd, a backing device that is no
> longer congested, or an allocation on another cpu in a context where
> direct reclaim can be more aggressive or the oom killer can at least free
> some memory.
>
> So you definitely want to localize your change to only suspend and
> pm_restrict_gfp_mask() is a very easy way to do it. =A0So I'd suggest add=
ing
> a static bool that can be tested in should_alloc_retry() and identify suc=
h
> situations and tag it as __read_mostly.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
