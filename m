Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 90F216B0088
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:49:19 -0400 (EDT)
Date: Thu, 9 Aug 2012 11:48:36 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v6 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120809144835.GA2719@t510.redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
 <efb9756c5d6de8952a793bfc99a9db9cdd66b12f.1344463786.git.aquini@redhat.com>
 <20120809090019.GB10288@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120809090019.GB10288@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 09, 2012 at 10:00:19AM +0100, Mel Gorman wrote:
> On Wed, Aug 08, 2012 at 07:53:19PM -0300, Rafael Aquini wrote:
> > Memory fragmentation introduced by ballooning might reduce significantly
> > the number of 2MB contiguous memory blocks that can be used within a guest,
> > thus imposing performance penalties associated with the reduced number of
> > transparent huge pages that could be used by the guest workload.
> > 
> > This patch introduces the helper functions as well as the necessary changes
> > to teach compaction and migration bits how to cope with pages which are
> > part of a guest memory balloon, in order to make them movable by memory
> > compaction procedures.
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> 
> Mostly looks ok but I have one question;
> 
> > <SNIP>
> >
> > +/* putback_lru_page() counterpart for a ballooned page */
> > +bool putback_balloon_page(struct page *page)
> > +{
> > +	if (WARN_ON(!movable_balloon_page(page)))
> > +		return false;
> > +
> > +	if (likely(trylock_page(page))) {
> > +		if (movable_balloon_page(page)) {
> > +			__putback_balloon_page(page);
> > +			put_page(page);
> > +			unlock_page(page);
> > +			return true;
> > +		}
> > +		unlock_page(page);
> > +	}
> 
> You might have answered this already as I skipped over a few revisions
> and if you have, sorry about that and please add a comment :)
> 
> This trylock_page looks risky as it looks like it can fail if another
> process running compaction tries to isolate this page. It locks the page,
> finds it cant and releases the lock but in the meantime this trylock can
> fail. It triggers a WARN_ON so we'll get a bug report but it leaves the
> reference count elevated and this page has now leaked.
>
Good catch!
I had those bits changed to follow the same logics you had suggested for
isolate_balloon_page(), but I ended up completely missing this potential page
leak case you spotted. Thanks a lot!
 
> Why not just lock_page(page)? As you have already isolated this page you
> know that the lock is only going to be held by a parallel compacting
> process checking the reference count and the delay will be short. As a
> bonus you can drop the WARN_ON check in the caller and make this void as
> the WARN_ON check in the caller becomes redundant.
> 
Sure! 
what do you think of:

+/* putback_lru_page() counterpart for a ballooned page */
+void putback_balloon_page(struct page *page)
+{
+   lock_page(page);
+   if (!WARN_ON(!movable_balloon_page(page))) {
+           __putback_balloon_page(page);
+           put_page(page);
+   }
+   unlock_page(page);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
