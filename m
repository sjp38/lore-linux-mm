Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2EABB6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 19:23:17 -0400 (EDT)
Date: Wed, 5 Jun 2013 08:23:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v5][PATCH 6/6] mm: vmscan: drain batch list during long
 operations
Message-ID: <20130604232315.GA31006@blaptop>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200210.259954C3@viggo.jf.intel.com>
 <20130604060553.GF14719@blaptop>
 <51AE06B6.3030009@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51AE06B6.3030009@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

Hello Dave,

On Tue, Jun 04, 2013 at 08:24:38AM -0700, Dave Hansen wrote:
> On 06/03/2013 11:05 PM, Minchan Kim wrote:
> >> > This ensures that we drain the batch if we are about to perform a
> >> > pageout() or congestion_wait(), either of which will take some
> >> > time.  We expect this to help mitigate the worst of the latency
> >> > increase that the batching could cause.
> > Nice idea but I could see drain before pageout but congestion_wait?
> 
> That comment managed to bitrot a bit :(
> 
> The first version of these had the drain before pageout() only.  Then,
> Mel added a congestion_wait() call, and I modified the series to also
> drain there.  But, some other patches took the congestion_wait() back
> out, so I took that drain back out.

I am looking next-20130530 and it has still a congestion_wait.
I'm confusing. :(


                if (PageWriteback(page)) {
			/* Case 1 above */
			if (current_is_kswapd() &&
			    PageReclaim(page) &&
			    zone_is_reclaim_writeback(zone)) {
				congestion_wait(BLK_RW_ASYNC, HZ/10);
				zone_clear_flag(zone, ZONE_WRITEBACK);
> 
> I _believe_ the only congestion_wait() left in there is a cgroup-related
> one that we didn't think would cause very much harm.

The congestion_wait I am seeing is not cgroup-related one.

I'd like to clear this confusing.
Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
