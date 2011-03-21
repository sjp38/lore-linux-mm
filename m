Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F1948D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 11:23:47 -0400 (EDT)
Message-ID: <4D876D43.3020409@fiec.espol.edu.ec>
Date: Mon, 21 Mar 2011 10:22:43 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <4D80D65C.5040504@fiec.espol.edu.ec> <20110316150208.7407c375.akpm@linux-foundation.org> <4D827CC1.4090807@fiec.espol.edu.ec> <20110317144727.87a461f9.akpm@linux-foundation.org> <20110318111300.GF707@csn.ul.ie> <4D839EDB.9080703@fiec.espol.edu.ec> <20110319134628.GG707@csn.ul.ie> <4D84D3F2.4010200@fiec.espol.edu.ec> <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random>
In-Reply-To: <20110321134832.GC5719@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 21/03/11 08:48, Andrea Arcangeli escribio:
>
> ===
> Subject: mm: compaction: Use async migration for __GFP_NO_KSWAPD and enforce no writeback
>
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> __GFP_NO_KSWAPD allocations are usually very expensive and not mandatory
> to succeed as they have graceful fallback. Waiting for I/O in those, tends
> to be overkill in terms of latencies, so we can reduce their latency by
> disabling sync migrate.
>
> Unfortunately, even with async migration it's still possible for the
> process to be blocked waiting for a request slot (e.g. get_request_wait
> in the block layer) when ->writepage is called. To prevent __GFP_NO_KSWAPD
> blocking, this patch prevents ->writepage being called on dirty page cache
> for asynchronous migration.
>
> [mel@csn.ul.ie: Avoid writebacks for NFS, retry locked pages, use bool]
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
> ---
>   mm/migrate.c    |   48 +++++++++++++++++++++++++++++++++---------------
>   mm/page_alloc.c |    2 +-
>   2 files changed, 34 insertions(+), 16 deletions(-)
The latest patch fails to apply in vanilla 2.6.38:

[alex@srv64 linux-2.6.38]$ patch -p1 --dry-run < ../\[Bug\ 31142\]\ Large\ write\ to\ USB\ stick\ freezes\ unrelated\ tasks\ for\ a\ long\ time.eml
(Stripping trailing CRs from patch.)
patching file mm/migrate.c
Hunk #1 FAILED at 564.
Hunk #2 FAILED at 586.
Hunk #3 FAILED at 641.
Hunk #4 FAILED at 686.
Hunk #5 FAILED at 757.
Hunk #6 FAILED at 850.
6 out of 6 hunks FAILED -- saving rejects to file mm/migrate.c.rej
(Stripping trailing CRs from patch.)
patching file mm/page_alloc.c
Hunk #1 FAILED at 2085.
1 out of 1 hunk FAILED -- saving rejects to file mm/page_alloc.c.rej

I will try to apply the patch manually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
