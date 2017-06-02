Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7010C6B033C
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 16:36:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w91so1644521wrb.13
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 13:36:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j80si58725wmj.91.2017.06.02.13.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 13:36:39 -0700 (PDT)
Date: Fri, 2 Jun 2017 13:36:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free +
 file is low
Message-Id: <20170602133637.7f6b49fbb740fb70e3b2307d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
	<20170418013659.GD21354@bbox>
	<alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
	<20170419001405.GA13364@bbox>
	<alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
	<20170420060904.GA3720@bbox>
	<alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 1 May 2017 14:34:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> not swap anon pages just because free+file is low'") reintroduces is to
> prefer swapping anonymous memory rather than trashing the file lru.
> 
> If the anonymous inactive lru for the set of eligible zones is considered
> low, however, or the length of the list for the given reclaim priority
> does not allow for effective anonymous-only reclaiming, then avoid
> forcing SCAN_ANON.  Forcing SCAN_ANON will end up thrashing the small
> list and leave unreclaimed memory on the file lrus.
> 
> If the inactive list is insufficient, fallback to balanced reclaim so the
> file lru doesn't remain untouched.
> 

--- a/mm/vmscan.c~mm-vmscan-avoid-thrashing-anon-lru-when-free-file-is-low-fix
+++ a/mm/vmscan.c
@@ -2233,7 +2233,7 @@ static void get_scan_count(struct lruvec
 			 * anonymous pages on the LRU in eligible zones.
 			 * Otherwise, the small LRU gets thrashed.
 			 */
-			if (!inactive_list_is_low(lruvec, false, sc, false) &&
+			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
 			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
 					>> sc->priority) {
 				scan_balance = SCAN_ANON;

Worried.  Did you send the correct version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
