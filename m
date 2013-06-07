Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5F6DE6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 13:36:38 -0400 (EDT)
Date: Fri, 7 Jun 2013 13:36:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 09/10] mm: thrash detection-based file cache sizing
Message-ID: <20130607173618.GN15721@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
 <1369937046-27666-10-git-send-email-hannes@cmpxchg.org>
 <51B1EB25.9000509@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B1EB25.9000509@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Fri, Jun 07, 2013 at 06:16:05PM +0400, Roman Gushchin wrote:
> On 30.05.2013 22:04, Johannes Weiner wrote:
> >+/*
> >+ * Monotonic workingset clock for non-resident pages.
> >+ *
> >+ * The refault distance of a page is the number of ticks that occurred
> >+ * between that page's eviction and subsequent refault.
> >+ *
> >+ * Every page slot that is taken away from the inactive list is one
> >+ * more slot the inactive list would have to grow again in order to
> >+ * hold the current non-resident pages in memory as well.
> >+ *
> >+ * As the refault distance needs to reflect the space missing on the
> >+ * inactive list, the workingset time is advanced every time the
> >+ * inactive list is shrunk.  This means eviction, but also activation.
> >+ */
> >+static atomic_long_t workingset_time;
> 
> It seems strange to me, that workingset_time is global.
> Don't you want to make it per-cgroup?

Yes, we need to go there and the code is structured so that it will be
possible to adapt memcg in the future.

But we will still need to maintain a global view of the workingset
time as memory and data are not exclusive resources, or at least can't
be guaranteed to be, so refault distances always need to be applicable
to all containers in the system.  But in response to Peter's feedback,
I changed the workingset_time global variable to a per-zone one and
then use the per-zone floating proportions that I used to break down
global speed in reverse to scale up the zone time to global time.

> Two more questions:
> 1) do you plan to take fadvise's into account somehow?

DONTNEED is honored, shadow entries will be dropped in the fadvised
region.  Is that what you meant?

> 2) do you plan to use workingset information to enhance
> 	the readahead mechanism?

I don't have any specific plans for this and I'm not sure if detecting
thrashing alone would be a good predicate.  It would make more sense
to adjust readahead windows if readahead pages are reclaimed before
they are used, and that may happen even in the absence of refaults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
