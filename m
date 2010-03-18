Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AB8E86B00DC
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:48:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2I0mAXf018355
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Mar 2010 09:48:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20AFB45DE55
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:48:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E61F545DE4F
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:48:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF0F11DB8038
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:48:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 770AC1DB803B
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:48:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped anonymous pages
In-Reply-To: <20100317115133.GG12388@csn.ul.ie>
References: <20100317104734.4C8E.A69D9226@jp.fujitsu.com> <20100317115133.GG12388@csn.ul.ie>
Message-Id: <20100318094720.872F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Mar 2010 09:48:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +		/*
> > > +		 * If the page has no mappings any more, just bail. An
> > > +		 * unmapped anon page is likely to be freed soon but worse,
> > > +		 * it's possible its anon_vma disappeared between when
> > > +		 * the page was isolated and when we reached here while
> > > +		 * the RCU lock was not held
> > > +		 */
> > > +		if (!page_mapcount(page)) {
> > > +			rcu_read_unlock();
> > > +			goto uncharge;
> > > +		}
> > 
> > I haven't understand what prevent this check. Why don't we need following scenario?
> > 
> >  1. Page isolated for migration
> >  2. Passed this if (!page_mapcount(page)) check
> >  3. Process exits
> >  4. page_mapcount(page) drops to zero so anon_vma was no longer reliable
> > 
> > Traditionally, page migration logic is, it can touch garbarge of anon_vma, but
> > SLAB_DESTROY_BY_RCU prevent any disaster. Is this broken concept?
> 
> The check is made within the RCU read lock. If the count is positive at
> that point but goes to zero due to a process exiting, the anon_vma will
> still be valid until rcu_read_unlock() is called.

Thank you!

then, this logic depend on SLAB_DESTROY_BY_RCU, not refcount.
So, I think we don't need your [1/11] patch.

Am I missing something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
