Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 10A886B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 20:06:00 -0400 (EDT)
Date: Wed, 22 Aug 2012 03:06:51 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120822000651.GH9027@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
 <20120821135223.GA7117@redhat.com>
 <20120821175502.GC12294@t510.redhat.com>
 <20120821191612.GA9027@redhat.com>
 <20120821193438.GE12294@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120821193438.GE12294@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 21, 2012 at 04:34:39PM -0300, Rafael Aquini wrote:
> On Tue, Aug 21, 2012 at 10:16:12PM +0300, Michael S. Tsirkin wrote:
> > On Tue, Aug 21, 2012 at 02:55:03PM -0300, Rafael Aquini wrote:
> > > On Tue, Aug 21, 2012 at 04:52:23PM +0300, Michael S. Tsirkin wrote:
> > > > > + * address_space_operations utilized methods for ballooned pages:
> > > > > + *   .migratepage    - used to perform balloon's page migration (as is)
> > > > > + *   .launder_page   - used to isolate a page from balloon's page list
> > > > > + *   .freepage       - used to reinsert an isolated page to balloon's page list
> > > > > + */
> > > > 
> > > > It would be a good idea to document the assumptions here.
> > > > Looks like .launder_page and .freepage are called in rcu critical
> > > > section.
> > > > But migratepage isn't - why is that safe?
> > > > 
> > > 
> > > The migratepage callback for virtio_balloon can sleep, and IIUC we cannot sleep
> > > within a RCU critical section. 
> > > 
> > > Also, The migratepage callback is called at inner migration's circle function
> > > move_to_new_page(), and I don't think embedding it in a RCU critical section
> > > would be a good idea, for the same understanding aforementioned.
> > 
> > Yes but this means it is still exposed to the module unloading
> > races that RCU was supposed to fix.
> > So need to either rework that code so it won't sleep
> > or switch to some other synchronization.
> >
> Can you refactor tell_host() to not sleep? Or, can I get rid of calling it at
> virtballoon_migratepage()? If 'no' is the answer for both questions, that's the
> way that code has to remain, even if we find a way around to hack the
> migratepage callback and have it embedded into a RCU crit section.
> 
> That's why I believe once the balloon driver is commanded to unload, we must
> flag virtballoon_migratepage to skip it's work. By doing this, the thread
> performing memory compaction will have to recur to the 'putback' path which is
> RCU protected. (IMHO).
> 
> As the module will not uload utill it leaks all pages on its list, that unload
> race you pointed before will be covered.


It can not be: nothing callback does can prevent it from
running after module unload: you must have some synchronization
in the calling code.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
