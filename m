Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC496B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 04:14:21 -0400 (EDT)
Date: Thu, 4 Aug 2011 10:14:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
Message-ID: <20110804081407.GF21516@cmpxchg.org>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <20110804075730.GF31039@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110804075730.GF31039@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 04, 2011 at 09:57:30AM +0200, Michal Hocko wrote:
> On Thu 04-08-11 11:09:48, Bob Liu wrote:
> > This patch also add checking whether alloc frontswap_map memory
> > failed.
> > 
> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > ---
> >  mm/swapfile.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index ffdd06a..8fe9e88 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -2124,9 +2124,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
> >  	}
> >  	/* frontswap enabled? set up bit-per-page map for frontswap */
> >  	if (frontswap_enabled) {
> > -		frontswap_map = vmalloc(maxpages / sizeof(long));
> > -		if (frontswap_map)
> > -			memset(frontswap_map, 0, maxpages / sizeof(long));
> > +		frontswap_map = vzalloc(maxpages / sizeof(long));
> > +		if (!frontswap_map)
> > +			goto bad_swap;
> 
> vzalloc part looks good but shouldn't we disable frontswap rather than
> fail?

Silently dropping explicitely enabled features is not a good idea,
IMO.  But from a quick look, this seems to be actually happening as
frontswap's bitmap tests check for whether there is even a bitmap
allocated and it should essentially never do anything for real if
there isn't.

How about printing a warning as to why the swapon fails and give the
admin a choice to disable it on her own?

It's outside this patch's scope, though, just as changing the
behaviour to fail swapon is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
