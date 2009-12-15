Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B5396B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:56:57 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF0usTG025625
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 09:56:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B27A45DE6E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:56:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1917345DE60
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:56:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0169E1DB8037
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:56:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88A7A1DB8043
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] Use io_schedule() instead schedule()
In-Reply-To: <20091215084636.c7790658.minchan.kim@barrios-desktop>
References: <20091214213026.BBBD.A69D9226@jp.fujitsu.com> <20091215084636.c7790658.minchan.kim@barrios-desktop>
Message-Id: <20091215090441.CDB0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 09:56:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Mon, 14 Dec 2009 21:30:54 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > All task sleeping point in vmscan (e.g. congestion_wait) use
> > io_schedule. then shrink_zone_begin use it too.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 3562a2d..0880668 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1624,7 +1624,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
> >  		    max_zone_concurrent_reclaimers)
> >  			break;
> >  
> > -		schedule();
> > +		io_schedule();
> 
> Hmm. We have many cond_resched which is not io_schedule in vmscan.c.

cond_resched don't mean sleep on wait queue. it's similar to yield.

> In addition, if system doesn't have swap device space and out of page cache 
> due to heavy memory pressue, VM might scan & drop pages until priority is zero
> or zone is unreclaimable. 
> 
> I think it would be not a IO wait.

two point.
1. For long time, Administrator usually watch iowait% at heavy memory pressure. I
don't hope change this without reasonable reason. 2. iowait makes scheduler
bonus a bit, vmscan task should have many time slice than memory consume
task. it improve VM stabilization.

but I agree the benefit isn't so big. if we have reasonable reason, I
don't oppose use schedule().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
