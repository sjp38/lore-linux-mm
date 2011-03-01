Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2AF548D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 11:19:34 -0500 (EST)
Date: Tue, 1 Mar 2011 17:19:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110301161900.GA21860@random.random>
References: <20110301153558.GA2031@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301153558.GA2031@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Mar 02, 2011 at 12:35:58AM +0900, Minchan Kim wrote:
> On Tue, Mar 01, 2011 at 01:49:25PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 1 Mar 2011 13:11:46 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > On Tue, Mar 01, 2011 at 08:42:09AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Mon, 28 Feb 2011 10:18:27 +0000
> > > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > > 
> > > > > > BTW, can't we drop disable_irq() from all lru_lock related codes ?
> > > > > > 
> > > > > 
> > > > > I don't think so - at least not right now. Some LRU operations such as LRU
> > > > > pagevec draining are run from IPI which is running from an interrupt so
> > > > > minimally spin_lock_irq is necessary.
> > > > > 
> > > > 
> > > > pagevec draining is done by workqueue(schedule_on_each_cpu()). 
> > > > I think only racy case is just lru rotation after writeback.
> > > 
> > > put_page still need irq disable.
> > > 
> > 
> > Aha..ok. put_page() removes a page from LRU via __page_cache_release().
> > Then, we may need to remove a page from LRU under irq context.
> > Hmm...
> 
> But as __page_cache_release's comment said, normally vm doesn't release page in
> irq context. so it would be rare.
> If we can remove it, could we change all of spin_lock_irqsave with spin_lock?
> If it is right, I think it's very desirable to reduce irq latency.
> 
> How about this? It's totally a quick implementation and untested. 
> I just want to hear opinions of you guys if the work is valuable or not before
> going ahead.

pages freed from irq shouldn't be PageLRU.

deferring freeing to workqueue doesn't look ok. firewall loads runs
only from irq and this will cause some more work and a delay in the
freeing. I doubt it's worhwhile especially for the lru_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
