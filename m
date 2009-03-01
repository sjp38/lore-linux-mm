Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 249806B00A2
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 05:37:44 -0500 (EST)
Date: Sun, 1 Mar 2009 19:37:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
In-Reply-To: <20090227132726.GE1482@ucw.cz>
References: <20090206130009.99400d43.akpm@linux-foundation.org> <20090227132726.GE1482@ucw.cz>
Message-Id: <20090228154120.6FC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, rjw@sisk.pl, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > hm?  And if this approach leads to less-than-optimum performance after
> > resume then the fault lies with core page reclaim - it reclaimed the
> > wrong pages!
> > 
> > That actually was my thinking when I first worked on
> > shrink_all_memory() and it did turn out to be surprisingly hard to
> > simply reuse the existing reclaim code for this application.  Things
> > kept on going wrong.  IIRC this was because we were freeing pages as we
> > were reclaiming, so the page reclaim logic kept on seeing all these
> > free pages and kept on wanting to bale out.
> > 
> > Now, the simple and obvious fix to this is not to free the pages - just
> > keep on allocating pages and storing them locally until we have
> > "enough" memory.  Then when we're all done, dump them all straight onto
> > to the freelists.
> > 
> > But for some reason which I do not recall, we couldn't do that.
> 
> We used to do that. I remember having loop doing get_free_page and
> doing linklist of them. I believe it was considered quite an hack.
> 
> .....one reason is that ee don't want to OOMkill anything if memory is
> low, we want to abort the hibernation...
> 
> Sorry for being late.....

Not at all.
your information is really helpful.

maybe, I expect we can make simplification without oomkill...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
