Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 462C96B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 18:28:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k1so41774315pgp.14
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 15:28:02 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id n65si17970023pga.157.2017.06.04.15.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 15:28:01 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 9so74103491pfj.1
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 15:28:01 -0700 (PDT)
Date: Sun, 4 Jun 2017 15:27:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
In-Reply-To: <20170602133637.7f6b49fbb740fb70e3b2307d@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1706041520410.21195@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com> <20170418013659.GD21354@bbox> <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com> <20170419001405.GA13364@bbox> <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox> <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com> <20170602133637.7f6b49fbb740fb70e3b2307d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Jun 2017, Andrew Morton wrote:

> On Mon, 1 May 2017 14:34:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> > not swap anon pages just because free+file is low'") reintroduces is to
> > prefer swapping anonymous memory rather than trashing the file lru.
> > 
> > If the anonymous inactive lru for the set of eligible zones is considered
> > low, however, or the length of the list for the given reclaim priority
> > does not allow for effective anonymous-only reclaiming, then avoid
> > forcing SCAN_ANON.  Forcing SCAN_ANON will end up thrashing the small
> > list and leave unreclaimed memory on the file lrus.
> > 
> > If the inactive list is insufficient, fallback to balanced reclaim so the
> > file lru doesn't remain untouched.
> > 
> 
> --- a/mm/vmscan.c~mm-vmscan-avoid-thrashing-anon-lru-when-free-file-is-low-fix
> +++ a/mm/vmscan.c
> @@ -2233,7 +2233,7 @@ static void get_scan_count(struct lruvec
>  			 * anonymous pages on the LRU in eligible zones.
>  			 * Otherwise, the small LRU gets thrashed.
>  			 */
> -			if (!inactive_list_is_low(lruvec, false, sc, false) &&
> +			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
>  			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
>  					>> sc->priority) {
>  				scan_balance = SCAN_ANON;
> 
> Worried.  Did you send the correct version?
> 

The patch was written before commit 2a2e48854d70 ("mm: vmscan: fix 
IO/refault regression in cache workingset transition") was merged and 
changed inactive_list_is_low().

Your rebase looks good.  It could have used NULL instead of memcg since 
this is only for global_reclaim() and memcg will always be NULL here, but 
that's just personal preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
