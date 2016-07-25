Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4C06B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:20:17 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r97so111810397lfi.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:20:17 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id n64si23185415wmd.41.2016.07.25.02.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 02:20:16 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id A20921C1B63
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:20:15 +0100 (IST)
Date: Mon, 25 Jul 2016 10:20:14 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160725092014.GL10438@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
 <20160725080456.GB1660@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160725080456.GB1660@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 25, 2016 at 05:04:56PM +0900, Minchan Kim wrote:
> > @@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  			continue;
> >  		}
> >  
> > +		/* Pages skipped do not contribute to scan */
> > +		scan++;
> > +
> 
> As I mentioned in previous version, under irq-disabled-spin-lock, such
> unbounded operation would make the latency spike worse if there are
> lot of pages we should skip.
> 
> Don't we take care it?

It's not unbounded, it's bound by the size of the LRU list and it's not
going to be enough to trigger a warning. While the lock hold time may be
undesirable, unlocking it every SWAP_CLUSTER_MAX pages may increase overall
contention. There also is the question of whether skipped pages should be
temporarily putback before unlocking the LRU to avoid isolated pages being
unavailable for too long. It also cannot easily just return early without
prematurely triggering OOM due to a lack of progress. I didn't feel the
complexity was justified.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
