Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA09742
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 20:33:58 -0500
Subject: Re: Removing swap lockmap...
References: <87iue47gy4.fsf@atlas.CARNet.hr> <199901182146.VAA09942@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 19 Jan 1999 02:33:42 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 18 Jan 1999 21:46:40 GMT"
Message-ID: <874spoqc5l.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> In article <87iue47gy4.fsf@atlas.CARNet.hr>, Zlatko Calusic
> <Zlatko.Calusic@CARNet.hr> writes:
> 
> > I removed swap lockmap all together and, to my surprise, I can't
> > produce any ill behaviour on my system, not even under very heavy
> > swapping (in low memory condition).
> 
> Just because you can't reproduce it doesn't mean it works perfectly.
> There was a very good reason why the swap lock map was still required
> until recently.  The race condition it fixed wass an obscure one but
> still important.  However, very recent VM changes make me wonder if it
> is still absolutely necessary.  
> 
> The problem was that if we swapped out a page, we might sometimes remove
> the swap cache for the page before the IO was complete.  If we can
> _guarantee_ that the swap cache will persist until after the IO is
> complete, then any future attempt to use that swap page will find that
> the page is locked and will wait for the IO to complete.
> 
> However, if in fact the swap cache for the page _ever_ gets removed
> before the IO completes, then a future read in of the page might start
> before the current write had completed.  This has been observed in
> practice.  The swap lock protects against this.

Yes, this is what I observed by reading some older articles from
linux-mm list (mostly conversation between you and Eric). So, I
decided to remove swap lockmap, reproduce problems and then try to fix
them. There is even one Eric's useful comment (removed in my patch)
that is useful in deciding what should be done to prevent problems.

But, interesting thing is that whatever I do, I CAN'T get into trouble 
and that is interesting part. :-)

> 
> Now that we always keep the swap cache intact in mm/vmscan.c and only
> reclaim it in mm/filemap.c, we might in fact be safe omiting the swap
> lock.  I'd be nervous about it without a _thorough_ audit of the code,
> though, as this particular race is hard to reproduce.
> 

Yes, I have the same worries now so close to real 2.2.0, that's why I
see this patch strictly experimental (it is not sent to Linus,
directly!). Maybe, someone of you could try it for yourself, and if
enough people test it, and if we try hard to understand why it seems
to not make thing worse, maybe there's a slight chance it could go in
for 2.2, or at least as a first thing in 2.3.0, so it gets heavily
tested and debugged.

But, I'm also nervous about it...
I rememeber there really were some nasty silent deaths while lockmap was
removed in some revisions during 2.1.x. :-(

Thanks for comments.
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
