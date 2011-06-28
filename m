Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 61C616B0100
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 19:23:14 -0400 (EDT)
Received: by qwa26 with SMTP id 26so511738qwa.14
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 16:23:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110628125249.GX9396@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-4-git-send-email-mgorman@suse.de>
	<BANLkTinH_EcYUAAsrGmboMywqPcCfye2gg@mail.gmail.com>
	<20110628125249.GX9396@suse.de>
Date: Wed, 29 Jun 2011 08:23:10 +0900
Message-ID: <BANLkTik16=kYyNtK-h-z3Ex64yPHUHFnVQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: vmscan: Evaluate the watermarks against the
 correct classzone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jun 28, 2011 at 9:52 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, Jun 27, 2011 at 03:53:04PM +0900, Minchan Kim wrote:
>> On Fri, Jun 24, 2011 at 11:44 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > When deciding if kswapd is sleeping prematurely, the classzone is
>> > taken into account but this is different to what balance_pgdat() and
>> > the allocator are doing. Specifically, the DMA zone will be checked
>> > based on the classzone used when waking kswapd which could be for a
>> > GFP_KERNEL or GFP_HIGHMEM request. The lowmem reserve limit kicks in,
>> > the watermark is not met and kswapd thinks its sleeping prematurely
>> > keeping kswapd awake in error.
>>
>>
>> I thought it was intentional when you submitted a patch firstly.
>
> It was, it also wasn't right.
>
>> "Kswapd makes sure zones include enough free pages(ie, include reserve
>> limit of above zones).
>> But you seem to see DMA zone can't meet above requirement forever in
>> some situation so that kswapd doesn't sleep.
>> Right?
>>
>
> Right.
>
>> >
>> > Reported-and-tested-by: P=C3=A1draig Brady <P@draigBrady.com>
>> > Signed-off-by: Mel Gorman <mgorman@suse.de>
>> > ---
>> > =C2=A0mm/vmscan.c | =C2=A0 =C2=A02 +-
>> > =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 9cebed1..a76b6cc2 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2341,7 +2341,7 @@ static bool sleeping_prematurely(pg_data_t *pgda=
t, int order, long remaining,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!zone_water=
mark_ok_safe(zone, order, high_wmark_pages(zone),
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 classzone_idx, 0))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i, 0))
>>
>> Isn't it =C2=A0better to use 0 instead of i?
>>
>
> I considered it but went with i to compromise between making sure zones
> included enough free pages without requiring that ZONE_DMA meet an
> almost impossible requirement when under continual memory pressure.

I see.
Thanks, Mel.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
