Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A66C8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 23:04:53 -0500 (EST)
Received: by iwc10 with SMTP id 10so881448iwc.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 20:04:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110209154606.GJ27110@cmpxchg.org>
References: <20110209154606.GJ27110@cmpxchg.org>
Date: Thu, 10 Feb 2011 13:04:51 +0900
Message-ID: <AANLkTikY8Z5K=ydaN7+1QXi-ofLYgV0Vhw0u-4B=Q9Hg@mail.gmail.com>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 12:46 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> Hi,
>
> I think this should fix the problem of processes getting stuck in
> reclaim that has been reported several times. =C2=A0Kent actually
> single-stepped through this code and noted that it was never exiting
> shrink_zone(), which really narrowed it down a lot, considering the
> tons of nested loops from the allocator down to the list shrinking.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hannes
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: vmscan: fix zone shrinking exit when scan work is done
>
> '3e7d344 mm: vmscan: reclaim order-0 and use compaction instead of
> lumpy reclaim' introduced an indefinite loop in shrink_zone().
>
> It meant to break out of this loop when no pages had been reclaimed
> and not a single page was even scanned. =C2=A0The way it would detect the
> latter is by taking a snapshot of sc->nr_scanned at the beginning of
> the function and comparing it against the new sc->nr_scanned after the
> scan loop. =C2=A0But it would re-iterate without updating that snapshot,
> looping forever if sc->nr_scanned changed at least once since
> shrink_zone() was invoked.
>
> This is not the sole condition that would exit that loop, but it
> requires other processes to change the zone state, as the reclaimer
> that is stuck obviously can not anymore.
>
> This is only happening for higher-order allocations, where reclaim is
> run back to back with compaction.
>
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Kent Overstreet <kent.overstreet@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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
