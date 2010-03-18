Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E77CB6B00D7
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 07:14:56 -0400 (EDT)
Date: Thu, 18 Mar 2010 11:14:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100318111436.GK12388@csn.ul.ie>
References: <20100317104734.4C8E.A69D9226@jp.fujitsu.com> <20100317115133.GG12388@csn.ul.ie> <20100318094720.872F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100318094720.872F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 09:48:08AM +0900, KOSAKI Motohiro wrote:
> > > > +		/*
> > > > +		 * If the page has no mappings any more, just bail. An
> > > > +		 * unmapped anon page is likely to be freed soon but worse,
> > > > +		 * it's possible its anon_vma disappeared between when
> > > > +		 * the page was isolated and when we reached here while
> > > > +		 * the RCU lock was not held
> > > > +		 */
> > > > +		if (!page_mapcount(page)) {
> > > > +			rcu_read_unlock();
> > > > +			goto uncharge;
> > > > +		}
> > > 
> > > I haven't understand what prevent this check. Why don't we need following scenario?
> > > 
> > >  1. Page isolated for migration
> > >  2. Passed this if (!page_mapcount(page)) check
> > >  3. Process exits
> > >  4. page_mapcount(page) drops to zero so anon_vma was no longer reliable
> > > 
> > > Traditionally, page migration logic is, it can touch garbarge of anon_vma, but
> > > SLAB_DESTROY_BY_RCU prevent any disaster. Is this broken concept?
> > 
> > The check is made within the RCU read lock. If the count is positive at
> > that point but goes to zero due to a process exiting, the anon_vma will
> > still be valid until rcu_read_unlock() is called.
> 
> Thank you!
> 
> then, this logic depend on SLAB_DESTROY_BY_RCU, not refcount.
> So, I think we don't need your [1/11] patch.
> 
> Am I missing something?
> 

The refcount is still needed. The anon_vma might be valid, but the
refcount is what ensures that the anon_vma is not freed and reused.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
