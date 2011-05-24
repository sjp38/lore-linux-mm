Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 785AA6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 06:57:52 -0400 (EDT)
Date: Tue, 24 May 2011 11:57:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
Message-ID: <20110524105746.GF5279@suse.de>
References: <4DD2991B.5040707@cray.com>
 <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>
 <20110520164924.GB2386@barrios-desktop>
 <4DDB3A1E.6090206@jp.fujitsu.com>
 <20110524083008.GA5279@suse.de>
 <4DDB6DF6.2050700@jp.fujitsu.com>
 <20110524084915.GC5279@suse.de>
 <4DDB74F7.9020109@jp.fujitsu.com>
 <20110524091611.GD5279@suse.de>
 <4DDB7D0F.3060204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4DDB7D0F.3060204@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2011 at 06:40:31PM +0900, KOSAKI Motohiro wrote:
> (2011/05/24 18:16), Mel Gorman wrote:
> > On Tue, May 24, 2011 at 06:05:59PM +0900, KOSAKI Motohiro wrote:
> >>>>> Why?
> >>>>
> >>>> Otherwise, we don't have good PCP dropping trigger. Big machine might have
> >>>> big pcp cache.
> >>>>
> >>>
> >>> Big machines also have a large cost for sending IPIs.
> >>
> >> Yes. But it's only matter if IPIs are frequently happen.
> >> But, drain_all_pages() is NOT only IPI source. some vmscan function (e.g.
> >> try_to_umap) makes a lot of IPIs.
> >>
> >> Then, it's _relatively_ not costly. I have a question. Do you compare which
> >> operation and drain_all_pages()? IOW, your "costly" mean which scenario suspect?
> >>
> > 
> > I am concerned that if the machine gets into trouble and we are failing
> > to reclaim that sending more IPIs is not going to help any. There is no
> > evidence at the moment that sending extra IPIs here will help anything.
> 
> In old days, we always call drain_all_pages() if did_some_progress!=0. But
> current kernel only call it when get_page_from_freelist() fail. So,
> wait_iff_congested() may help but no guarantee to help us.
> 
> If you still strongly worry about IPI cost, I'm concern to move drain_all_pages()
> to more unfrequently point. but to ignore pcp makes less sense, IMHO.
> 

Yes, I'm worried about it because excessive time
spent in drain_all_pages() has come up on the past
http://lkml.org/lkml/2010/8/23/81 . The PCP lists are not being
ignored at the moment. They are drained when direct reclaim makes
forward progress but still fails to allocate a page.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
