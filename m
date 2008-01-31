Date: Thu, 31 Jan 2008 17:54:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix PageUptodate data race
In-Reply-To: <20080131125817.GD10469@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0801311713530.13636@blonde.site>
References: <20080122040114.GA18450@wotan.suse.de>
 <20080126220356.0b77f0e9.akpm@linux-foundation.org> <20080131125817.GD10469@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Nick Piggin wrote:

> Sorry, way behind on email here. I'll get through it slowly...

You're certainly not the only one, and certainly not the worst offender.

> On Sat, Jan 26, 2008 at 10:03:56PM -0800, Andrew Morton wrote:
> > 
> > So...  it's two patches in one.
> 
> I guess so. Hmm, at least I appreciate it (them) getting testing in -mm
> for now. I guess I should break it in two, do you agree Hugh?

I do agree: I recommended that same split on a previous occasion.
Actually, it's three patches: you seem to prefer one style over
another in cow_user_page, I don't care either way, go ahead and
make the change, but it's nothing to do with the rest of it.

> Do you like/dislike the anonymous page change?

Like would be a little strong, but I certainly don't dislike:
you're right that the current old-established way is somewhat
contingent, do go ahead and make these Uptodates more consistent.

> > What kernel is this against?  Looks like mainline.  Is it complete and
> > correct when applied against the large number of pending MM changes?
> 
> Uh, I forget. But luckily this one should be quite correct reglardless
> of pending mm changes... unless something there has fundamentally changed
> the semantics or locking of PG_uptodate... which wouldn't be too surprising
> actually ;)

So far as I could tell, it's correct on top of -rc8-mm1 despite the
fuzz - unless we've added more places where a mod is needed, but I
don't think so.

I'm testing with that now, mainly because an earlier version hit a
BUG or WARNing with shmem: I wanted to check that no longer happens.
It doesn't, but then I got curious why not: I believe the problem
line was shmem_getpage's
	(!PageUptodate(filepage) || TestSetPageLocked(filepage)))
which gave trouble when you had a PageLocked check inside PageUptodate.
You don't have that now because you're not at this point trying to push
the PageLocked shortcuts; but worth noting if you resurrect those later.

I do like this version _so_ much more than your earlier attempts to
avoid the overhead wherever you could argue it.  Those might become
more acceptable once we've grown accustomed to this initial set.

Thanks for doing the FAQs: I think in the meantime I'd already
persuaded myself that you're right that PageUptodate is the
proper place for this stuff, even if I regret the complication.

Four little points.  In the comments, "preceding" not "preceeding"
and I presume "wmb" not "smb".  You've carried over several "(page)"s
from the macros which would better be "page"s in inline functions.

And do we really need that smp_wmb in __SetPageUptodate?  It seems
to me that when you're in a position to use __SetPageUptodate, the
page cannot yet be visible, and the necessary barrier will be
provided later when the page is made visible.

I suspect the answer is that I'm confusing two different kinds of
visibility; and that although it's true that we don't actually need
that smp_wmb in the places where __SetPageUptodate is being used,
it'd be hard to write and remember the rules to justify its removal.
But mention it because you may well see this more clearly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
