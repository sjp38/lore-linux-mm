Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9477A6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 11:49:50 -0400 (EDT)
Date: Mon, 31 Oct 2011 16:49:42 +0100
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [PATCH] oom: fix integer overflow of points in oom_badness
Message-ID: <20111031154942.GB2280@dhcp-26-164.brq.redhat.com>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com>
 <20111031152833.GA31904@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111031152833.GA31904@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com

On Mon, Oct 31, 2011 at 04:28:33PM +0100, Oleg Nesterov wrote:
> On 10/31, Frantisek Hrbata wrote:
> >
> > My understanding is that we may just change the type of points variable from int
> > to long and keep the current imho clearer(better readable) computation. There
> > should not be an overflow on 32bit and there is a plenty of space for 64bit.
> > If you like this solution better I will post the patch as v2.
> 
> Up to maintainer, but personally I think the simple s/int/long/ looks better.
> Everything like get_mm_*/nr_ptes returns long.

Agreed. I will post v2 with the int => long change.

> 
> Anyway good catch. Imho stable needs the fix too.
> 
> Cosmetic nit,
> 
> > -	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
> > -	points += get_mm_counter(p->mm, MM_SWAPENTS);
> > +	points = (int)((get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
>                  ^^^^^
> 
> Why do we need the explicit typecast? It buys nothing and looks a bit confusing.

You are right, it's not needed. I just wanted to make the cast more visible, but
some kind of comment would be probably better here.

> 
> And, if you prefer "int", perhaps something like
> 
> 	- 	points *= 1000;
> 	-	points /= totalpages;
> 	+	/* avoid the possible overflow */
> 	+	points = points * 1000L / totalpages;
> 
> looks a bit more readable with the same effect. But I won't insist, this is
> up to you and David.

Sure, this looks much better than the one line expression in the patch I sent.
If David or others decide to not go with the int=>long change I think we should
use this.

> 
> Oleg.
> 

Many thanks Oleg.

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
