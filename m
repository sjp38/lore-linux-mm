Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 00BE66B005A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 20:01:00 -0500 (EST)
Date: Wed, 25 Jan 2012 17:00:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: fix malused nr_reclaimed in shrinking zone
Message-Id: <20120125170054.affb676b.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBByNhLSiBtyaYOHeMRQpXmAO=hEKTOanPTzrb2gRZTOSg@mail.gmail.com>
References: <CAJd=RBDVxT5Pc2HZjz15LUb7xhFbztpFmXqLXVB3nCoQLKHiHg@mail.gmail.com>
	<20120123170354.82b9f127.akpm@linux-foundation.org>
	<CAJd=RBByNhLSiBtyaYOHeMRQpXmAO=hEKTOanPTzrb2gRZTOSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 24 Jan 2012 19:00:19 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Tue, Jan 24, 2012 at 9:03 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> >
> > - The names of these things are terrible! __Why not
> > __reclaimed_this_pass and reclaimed_total or similar?
> >
> > - It would be cleaner to do the "reclaimed += nr_reclaimed" at the
> > __end of the loop, if we've decided to goto restart. __(But better
> > __to do it within the loop!)
> >
> > - Only need to update sc->nr_reclaimed at the end of the function
> > __(assumes that callees of this function aren't interested in
> > __sc->nr_reclaimed, which seems a future-safe assumption to me).
> >
> > - Should be able to avoid the temporary addition of nr_reclaimed to
> > __reclaimed inside the loop by updating `reclaimed' at an appropriate
> > __place.
> >
> >
> > Or whatever. __That code's handling of `reclaimed' and `nr_reclaimed' is
> > a twisty mess. __Please clean it up! __If it is done correctly,
> > `nr_reclaimed' can (and should) be local to the internal loop.
> 
> Hi Andrew
> 
> The mess is cleaned up, please review again.

umph.  It's still not exactly a thing of beautiful clarity :(

> The value of nr_reclaimed is the amount of pages reclaimed in the current
> round of loop, whereas nr_to_reclaim should be compared with pages reclaimed
> in all rounds.
> 
> In each round of loop, reclaimed pages are cut off from the reclaim goal,
> and loop stops once goal achieved.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/vmscan.c	Mon Jan 23 00:23:10 2012
> +++ b/mm/vmscan.c	Tue Jan 24 17:10:34 2012
> @@ -2113,7 +2113,12 @@ restart:
>  		 * with multiple processes reclaiming pages, the total
>  		 * freeing target can get unreasonably large.
>  		 */
> -		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
> +		if (nr_reclaimed >= nr_to_reclaim)
> +			nr_to_reclaim = 0;
> +		else
> +			nr_to_reclaim -= nr_reclaimed;
> +
> +		if (!nr_to_reclaim && priority < DEF_PRIORITY)
>  			break;
>  	}
>  	blk_finish_plug(&plug);

So local variable nr_to_reclaim has had its meaning changed.  It used
to be a function-wide constant (should have actually been marked
"const") telling us how many pages we are asked to reclaim.

But now it becomes "remaining number of pages to reclaim".  And the
name happens to still be sufficiently appropriate, so fair enough.


I'm thinking we have a bit of code rot happening here.  This comment:

		/*
		 * On large memory systems, scan >> priority can become
		 * really large. This is fine for the starting priority;
		 * we want to put equal scanning pressure on each zone.
		 * However, if the VM has a harder time of freeing pages,
		 * with multiple processes reclaiming pages, the total
		 * freeing target can get unreasonably large.
		 */

seems to have little to do with the code which it is trying to
describe.  Or at least, I'm not sure this is the best we can possibly
do :(


Also, your email client is adding MIME goop to the emails which mine
(sylpheed) is unable to decrypt.  It turns "=" into "=3D" everywhere. 
This:

MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I blame sylpheed for this, but if you can make it stop, that would make
my life easier, and perhaps others.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
