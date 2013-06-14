Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 1B73F6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 19:04:28 -0400 (EDT)
Date: Fri, 14 Jun 2013 16:04:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
Message-Id: <20130614160425.237b0fe0cb3f711740734b32@linux-foundation.org>
In-Reply-To: <CALSv+Dht=1ghRmiXdLwkFcXgRTwV=erSeoXc2AEh7+8XmHh1xQ@mail.gmail.com>
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
	<20130614111034.GA306@gmail.com>
	<CALSv+Dht=1ghRmiXdLwkFcXgRTwV=erSeoXc2AEh7+8XmHh1xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HeeSub Shin <heesub@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com

On Sat, 15 Jun 2013 03:13:26 +0900 HeeSub Shin <heesub@gmail.com> wrote:

> Hello,
> 
> On Fri, Jun 14, 2013 at 8:10 PM, Minchan Kim <minchan@kernel.org> wrote:
> 
> >
> > Hello,
> >
> > On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
> > > shrink_slab() queries each slab cache to get the number of
> > > elements in it. In most cases such queries are cheap but,
> > > on some caches. For example, Android low-memory-killer,
> > > which is operates as a slab shrinker, does relatively
> > > long calculation once invoked and it is quite expensive.
> >
> > LMK as shrinker is really bad, which everybody didn't want
> > when we reviewed it a few years ago so that's a one of reason
> > LMK couldn't be promoted to mainline yet. So your motivation is
> > already not atrractive. ;-)
> >
> > >
> > > This patch removes redundant queries to shrinker function
> > > in the loop of shrink batch.
> >
> > I didn't review the patch and others don't want it, I guess.
> > Because slab shrink is under construction and many patches were
> > already merged into mmtom. Please look at latest mmotm tree.
> >
> >         git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> 
> 
> >
> > If you concern is still in there and it's really big concern of MM
> > we should take care, NOT LMK, plese, resend it.
> >
> >
> I've noticed that there are huge changes there in the recent mmotm and you
> guys already settled the issue of my concern. I usually keep track changes
> in recent mm-tree, but this time I didn't. My bad :-)
> 

I'm not averse to merging an improvement like this even if it gets
rubbed out by forthcoming changes.  The big changes may never get
merged or may be reverted.  And by merging this patch, others are more
likely to grab it, backport it into earlier kernels and benefit from
it.

Also, the problem which this simple patch fixes might be present in a
different form after the large patchset has been merged.  That does not
appear to be the case this time.

So I'd actually like to merge Heesub's patch.  Problem is, I don't have
a way to redistribute it for testing - I'd need to effectively revert
the whole thing when integrating Glauber's stuff on top, so nobody who
is using linux-next would test Heesub's change.  Drat.




However I'm a bit sceptical about the description here.  The shrinker
is supposed to special-case the "nr_to_scan == 0" case and AFAICT
drivers/staging/android/lowmemorykiller.c:lowmem_shrink() does do this,
and it looks like the function will be pretty quick in this case.

In other words, the behaviour of lowmem_shrink(nr_to_scan == 0) does
not match Heesub's description.  What's up with that?



Also, there is an obvious optimisation which we could make to
lowmem_shrink().  All this stuff:

	if (lowmem_adj_size < array_size)
		array_size = lowmem_adj_size;
	if (lowmem_minfree_size < array_size)
		array_size = lowmem_minfree_size;
	for (i = 0; i < array_size; i++) {
		if (other_free < lowmem_minfree[i] &&
		    other_file < lowmem_minfree[i]) {
			min_score_adj = lowmem_adj[i];
			break;
		}
	}

does nothing useful in the nr_to_scan==0 case and should be omitted for
this special case.  But this problem was fixed in the large shrinker
rework in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
