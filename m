Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 238826B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 05:59:09 -0400 (EDT)
Date: Wed, 18 May 2011 10:58:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110518095859.GR5279@suse.de>
References: <1305295404-12129-5-git-send-email-mgorman@suse.de>
 <4DCFAA80.7040109@jp.fujitsu.com>
 <1305519711.4806.7.camel@mulgrave.site>
 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
 <20110516084558.GE5279@suse.de>
 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
 <20110516102753.GF5279@suse.de>
 <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
 <4DD31B6E.8040502@jp.fujitsu.com>
 <BANLkTikLuWPEt7MitUYdJtzqyBSOkz2zxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikLuWPEt7MitUYdJtzqyBSOkz2zxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Wed, May 18, 2011 at 02:44:48PM +0900, Minchan Kim wrote:
> On Wed, May 18, 2011 at 10:05 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> It would be better to put cond_resched after balance_pgdat?
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 292582c..61c45d0 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -2753,6 +2753,7 @@ static int kswapd(void *p)
> >>                 if (!ret) {
> >>                         trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> >> order);
> >>                         order = balance_pgdat(pgdat,
> >> order,&classzone_idx);
> >> +                       cond_resched();
> >>                 }
> >>         }
> >>         return 0;
> >>
> >>>>> While it appears unlikely, there are bad conditions which can result
> >>>
> >>> in cond_resched() being avoided.
> >
> > Every reclaim priority decreasing or every shrink_zone() calling makes more
> > fine grained preemption. I think.
> 
> It could be.
> But in direct reclaim case, I have a concern about losing pages
> reclaimed to other tasks by preemption.
> 
> Hmm,, anyway, we also needs test.
> Hmm,, how long should we bother them(Colins and James)?
> First of all, Let's fix one just between us and ask test to them and
> send the last patch to akpm.
> 
> 1. shrink_slab
> 2. right after balance_pgdat
> 3. shrink_zone
> 4. reclaim priority decreasing routine.
> 
> Now, I vote 1) and 2).
> 

I've already submitted a pair of patches for option 1. I don't think
option 2 gains us anything. I think it's more likely we should worry
about all_unreclaimable being set when shrink_slab is returning 0 and we
are encountering so many dirty pages that pages_scanned is high enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
