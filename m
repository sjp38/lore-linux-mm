Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B261F6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 05:16:59 -0400 (EDT)
Date: Fri, 29 Jul 2011 11:16:25 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] vmscan: Remove if statement that will never trigger
In-Reply-To: <4E3252E2.1030101@jp.fujitsu.com>
Message-ID: <alpine.LNX.2.00.1107291115080.22532@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1107282302580.20477@swampdragon.chaosbits.net> <4E3252E2.1030101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, minchan.kim@gmail.com, mgorman@suse.de, akpm@linux-foundation.org, kanoj@sgi.com, sct@redhat.com

On Fri, 29 Jul 2011, KOSAKI Motohiro wrote:

> (2011/07/29 6:05), Jesper Juhl wrote:
> > We have this code in mm/vmscan.c:shrink_slab() :
> > ...
> > 		if (total_scan < 0) {
> > 			printk(KERN_ERR "shrink_slab: %pF negative objects to "
> > 			       "delete nr=%ld\n",
> > 			       shrinker->shrink, total_scan);
> > 			total_scan = max_pass;
> > 		}
> > ...
> > but since 'total_scan' is of type 'unsigned long' it will never be
> > less than zero, so there is no way we'll ever enter the true branch of
> > this if statement - so let's just remove it.
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  mm/vmscan.c |    6 ------
> >  1 files changed, 0 insertions(+), 6 deletions(-)
> > 
> > 	Compile tested only.
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7ef6912..c07d9b1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -271,12 +271,6 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >  		delta *= max_pass;
> >  		do_div(delta, lru_pages + 1);
> >  		total_scan += delta;
> > -		if (total_scan < 0) {
> > -			printk(KERN_ERR "shrink_slab: %pF negative objects to "
> > -			       "delete nr=%ld\n",
> > -			       shrinker->shrink, total_scan);
> > -			total_scan = max_pass;
> > -		}
> >  
> >  		/*
> >  		 * We need to avoid excessive windup on filesystem shrinkers
> 
> Good catch.
> 
> However this seems intended to catch a overflow. So, I'd suggest to make proper
> overflow check instead.
> 
Right. We probably shouldn't just remove it.

I'll cook a new version of the patch tonight that properly checks for 
overflow.


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
