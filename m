Date: Fri, 10 Jul 1998 00:37:47 +0100
Message-Id: <199807092337.AAA07652@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980709205619.28236F-100000@mirkwood.dummy.home>
References: <199807091442.PAA01020@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980709205619.28236F-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Andrea Arcangeli <arcangeli@mbox.queen.it>Stephen Tweedie <sct@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 9 Jul 1998 20:59:57 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Thu, 9 Jul 1998, Stephen C. Tweedie wrote:
>> 
>> There's a fundamentally nice property about the multi-level cache
>> which we _cannot_ easily emulate with page aging, and that is the
>> ability to avoid aging any hot pages at all while we are just
>> consuming cold pages.  

> Then I'd better incorporate a design for this in the zone
> allocator (we could add this to the page_struct, but in
> the zone_struct we can make a nice bitmap of it).

It's nothing to do with the allocator per se; it's really a different
solution to a different problem.  That helps, actually, as it means
we're not forced to stick with one allocator if we want to use such a
scheme.

> OTOH, is it really _that_ much different from an aging
> scheme with an initial age of 1?

Yes, it is: the aging scheme pretty much forces us to age all pages on
an equal basis, so a lot of transient pages hitting the cache has the
side effect of prematurely aging and evicting a lot of existing,
potentially far more valuable pages.  A multilevel cache is pretty much
essential if you're going to let any cached data survive a grep flood.
Whether you _want_ that, or whether you'd rather just let the cache
drain and repopulate it after the IO has calmed, is a different
question; there are situations where one or other decision might be
best, so it's not a guaranteed win.  But the multilevel cache does have
some nice properties which aren't so easy to get with page aging.  It
also tends to be faster at finding pages to evict, since we don't
require multiple passes to flush the transient page queue.

--Stephen.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
