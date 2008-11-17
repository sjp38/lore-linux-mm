From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Date: Mon, 17 Nov 2008 17:19:31 +1100
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org>
In-Reply-To: <20081116204720.1b8cbe18.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811171719.31936.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Monday 17 November 2008 15:47, Andrew Morton wrote:
> On Sun, 16 Nov 2008 16:20:26 -0500 Rik van Riel <riel@redhat.com> wrote:

> > I will take a look at producing smoother self tuning behaviour
> > in get_scan_ratio(), with logic along these lines:
> > - the more file pages are inactive, the more eviction should
> >    focus on file pages, because we are not eating away at the
> >    working set yet
> > - the more file pages are active, the more there needs to be
> >    a balance between file and anon scanning, because we are
> >    starting to get to the working sets for both
>
> hm.  I wonder if it would be prohibitive to say "hey, we did the wrong
> thing in that scanning pass - rewind and try it again".  Probably it
> would be.
>
> Anyway, we need to do something.
>
> Shouldn't get_scan_ratio() be handling this case already?

I have a patch that was actually for the old vmscan logic that I
found really helps prevent working set get paged out. Actually
the old vmscan behaviour wasn't any good either at preventing
unmapped pagecache from being evicted, which is the main thing I
was trying to fix (eg. keep git tree in cache while doing other
use-once IO).

It ended up working really well, but I suspect it would still fall
over in the case where you were trying to populate your caches with
the git tree *while* the streaming IO is happening (if those pages
don't have a chance to get touched again for a while, they'll look
like use-once IO to the vm)... but still no worse than current
behaviour.

I need to forward port it to the new system, however...

But this would be a pretty big change and I can't see how it could
be appropriate for -rc6. Aren't we allergic to even single-line
changes in vmscan without seemingly multi-year "testing" phases? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
