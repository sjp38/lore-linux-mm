Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2EEE46B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 15:39:28 -0400 (EDT)
Date: Thu, 9 Aug 2012 21:39:21 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH 1/5] [RFC] Add volatile range management code
Message-ID: <20120809193921.GA1999@thinkpad>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
 <1343447832-7182-2-git-send-email-john.stultz@linaro.org>
 <CANN689HWYO5DD_p7yY39ethcFu_JO9hudMcDHd=K8FUfhpHZOg@mail.gmail.com>
 <20120809133544.GA2086@thinkpad>
 <5024107D.8070109@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5024107D.8070109@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Michel Lespinasse <walken@google.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Aug 09, 2012 at 12:33:17PM -0700, John Stultz wrote:
> On 08/09/2012 06:35 AM, Andrea Righi wrote:
> >On Thu, Aug 09, 2012 at 02:46:37AM -0700, Michel Lespinasse wrote:
> >>On Fri, Jul 27, 2012 at 8:57 PM, John Stultz <john.stultz@linaro.org> wrote:
> >>>v5:
> >>>* Drop intervaltree for prio_tree usage per Michel &
> >>>   Dmitry's suggestions.
> >>Actually, I believe the ranges you need to track are non-overlapping, correct ?
> >>
> >>If that is the case, a simple rbtree, sorted by start-of-range
> >>address, would work best.
> >>(I am trying to remove prio_tree users... :)
> >>
> >John,
> >
> >JFYI, if you want to try a possible rbtree-based implementation, as
> >suggested by Michel you could try this one:
> >https://github.com/arighi/kinterval
> >
> >This implementation supports insertion, deletion and transparent merging
> >of adjacent ranges, as well as splitting ranges when chunks removed or
> >different chunk types are added in the middle of an existing range; so
> >if I'm not wrong probably you should be able to use this code as is,
> >without any modification.
> I do appreciate the suggestion, and considered this earlier when you
> posted this before.
> 
> Unfotunately the transparent merging/splitting/etc is actually not
> useful for me, since I manage other data per-range. The earlier
> generic rangetree/intervaltree implementations I tried limiting the
> interface to basically add(), remove(), search(), and search_next(),
> since when we coalesce intervals, we need to free the data in the
> structure referencing the interval being deleted (and similarly
> create new structures to reference new intervals created when we
> remove an interval). So the coalescing/splitting logic can't be
> pushed into the interval management code cleanly.
> 
> So while I might be able to make use of your kinterval in a fairly
> simple manner (only using add/del/lookup), I'm not sure it wins
> anything over just using an rbtree.  Especially since I'd have to do
> my own coalesce/splitting logic anyway, it would actually be more
> expensive as on add() it would still scan to check for overlapping
> ranges to merge.
> 
> I ended up dropping my generic intervaltree implementation because
> folks objected that it was so trivial (basically just wrapping an
> rbtree) and didn't handle some of the more complex intervaltree use
> cases (ie: allowing for overlapping intervals). The priotree seemed
> to match fairly closely the interface I was using, but apparently
> its on its way out as well, so unless anyone further objects, I
> think I'll just fall back to a simple rbtree implementation.

OK, everything makes sense now, thanks for the clarifications, and sorry
for suggesting yet another range/interval tree implementation. :)

I'll look at your patch set more in details and try to test/review it
closely.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
