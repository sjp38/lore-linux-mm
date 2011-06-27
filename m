Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 939729000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 02:11:00 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2973387qwa.14
        for <linux-mm@kvack.org>; Sun, 26 Jun 2011 23:10:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308926697-22475-2-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-2-git-send-email-mgorman@suse.de>
Date: Mon, 27 Jun 2011 15:10:57 +0900
Message-ID: <BANLkTikNcWhcxPkPnC4amnrC-bNEUNqGQw@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in sleeping_prematurely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2011 at 11:44 PM, Mel Gorman <mgorman@suse.de> wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
>
> A problem occurs if the highest zone is small. =C2=A0balance_pgdat()
> only considers unreclaimable zones when priority is DEF_PRIORITY
> but sleeping_prematurely considers all zones. It's possible for this
> sequence to occur
>
> =C2=A01. kswapd wakes up and enters balance_pgdat()
> =C2=A02. At DEF_PRIORITY, marks highest zone unreclaimable
> =C2=A03. At DEF_PRIORITY-1, ignores highest zone setting end_zone
> =C2=A04. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
> =C2=A0 =C2=A0 =C2=A0 =C2=A0highest zone, clearing all_unreclaimable. High=
est zone
> =C2=A0 =C2=A0 =C2=A0 =C2=A0is still unbalanced
> =C2=A05. kswapd returns and calls sleeping_prematurely
> =C2=A06. sleeping_prematurely looks at *all* zones, not just the ones
> =C2=A0 =C2=A0 being considered by balance_pgdat. The highest small zone
> =C2=A0 =C2=A0 has all_unreclaimable cleared but but the zone is not
> =C2=A0 =C2=A0 balanced. all_zones_ok is false so kswapd stays awake
>
> This patch corrects the behaviour of sleeping_prematurely to check
> the zones balance_pgdat() checked.
>
> Reported-and-tested-by: P=C3=A1draig Brady <P@draigBrady.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
