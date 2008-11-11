Date: Tue, 11 Nov 2008 22:17:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/4] rmap: add page_wrprotect() function,
Message-ID: <20081111211701.GH10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <20081111113948.f38b9e95.akpm@linux-foundation.org> <20081111203806.GE10818@random.random> <20081111130149.4ee2969c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111130149.4ee2969c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ieidus@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 01:01:49PM -0800, Andrew Morton wrote:
> On Tue, 11 Nov 2008 21:38:06 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > > > + * set all the ptes pointed to a page as read only,
> > > > + * odirect_sync is set to 0 in case we cannot protect against race with odirect
> > > > + * return the number of ptes that were set as read only
> > > > + * (ptes that were read only before this function was called are couned as well)
> > > > + */
> > > 
> > > But it isn't.
> > 
> > What isn't?
> 
> This code comment had the kerneldoc marker ("/**") but it isn't a
> kerneldoc comment.

8) never mind, I thought it was referred to the quoted comment, like
if the comment pretended something the function wasn't doing.

> OK, well can we please update the code so these things are clearer.

Sure. Let's say this o_direct fix was done after confirmation that
this was the agreed fix to solve those kind of problems (same fix that
fork will need as in the third link).

> (It's a permanent problem I have.  I ask "what is this", but I really
> mean "the code should be changed so that readers will know what this is")

Agreed, this deserves much more commentary. But not much effort was
done in this area, because fork (and likely migrate) has the same race
and it isn't fixed yet so this is still a work-in-progress area. The
fix has to be the same for all places that have this bug, and we have
not agreed on a way to fix gup_fast yet (all I provided as suggestion
that will work fine is brlock but surely Nick will try to find a way
that remains non-blocking, which is the core of the problem, if it
can't block, we've to use RCU but we can't wait there as far as I can
tell as all sort of synchronous memory regions are involved).

I think once the problem will get fixed and patches will go in
mainline, more docs will emerge (I hope ;). We'll most certainly need
changes to cover gup_fast (including if we use brlock, the read side
of the lock will have to be taken around it). This was a fix we did at
the last minute just to reflect the latest status.

I CC Nick to this thread btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
