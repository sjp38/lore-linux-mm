Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id DF8276B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 17:12:46 -0400 (EDT)
Date: Wed, 11 Apr 2012 14:12:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove BUG() in possible but rare condition
Message-Id: <20120411141244.2839d9a8.akpm@linux-foundation.org>
In-Reply-To: <4F85EEED.1090906@parallels.com>
References: <1334167824-19142-1-git-send-email-glommer@parallels.com>
	<20120411132635.bfddc6bd.akpm@linux-foundation.org>
	<4F85EEED.1090906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 11 Apr 2012 17:51:57 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 04/11/2012 05:26 PM, Andrew Morton wrote:
> >>
> >> >    failed:
> >> >  -	BUG();
> >> >    	unlock_page(page);
> >> >    	page_cache_release(page);
> >> >    	return NULL;
> > Cute.
> >
> > AFAICT what happened was that in my April 2002 rewrite of this code I
> > put a non-fatal buffer_error() warning in that case to tell us that
> > something bad happened.
> >
> > Years later we removed the temporary buffer_error() and mistakenly
> > replaced that warning with a BUG().  Only it*can*  happen.
> >
> > We can remove the BUG() and fix up callers, or we can pass retry=1 into
> > alloc_page_buffers(), so grow_dev_page() "cannot fail".  Immortal
> > functions are a silly fiction, so we should remove the BUG() and fix up
> > callers.
> >
> Any particular caller you are concerned with ?

Didn't someone see a buggy caller in btrfs?

I'm thinking that we should retain some sort of assertion (a WARN_ON)
if the try_to_free_buffers() failed.  This is a weird case which I
assume handles the situation where a blockdev's blocksize has changed. 
The code tries to throw away the old wrongly-sized buffer_heads and to
then add new correctly-sized ones.  If that discarding of buffers
fails then the kernel is in rather a mess.

It's quite possible that this code is never executed - we _should_ have
invalidated all the pagecache for that device when changing blocksize. 
Or maybe it *is* executed, I dunno.  It's one of those things which has
hung around for decades as code in other places has vastly changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
