Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E0C0B6B0035
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 11:38:53 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id e14so7541355iej.26
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 08:38:53 -0800 (PST)
Date: Wed, 25 Dec 2013 10:38:45 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131225163845.GA195633@sgi.com>
References: <20131212180037.GA134240@sgi.com> <20131213214437.6fdbf7f2.akpm@linux-foundation.org> <20131216171214.GA15663@sgi.com> <20131219152906.GQ11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219152906.GQ11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Dec 19, 2013 at 03:29:06PM +0000, Mel Gorman wrote:
> On Mon, Dec 16, 2013 at 11:12:15AM -0600, Alex Thorlton wrote:
> > > Please cc Andrea on this.
> > 
> > I'm going to clean up a few small things for a v2 pretty soon, I'll be
> > sure to cc Andrea there.
> > 
> > > > My proposed solution to the problem is to allow users to set a
> > > > threshold at which THPs will be handed out.  The idea here is that, when
> > > > a user faults in a page in an area where they would usually be handed a
> > > > THP, we pull 512 pages off the free list, as we would with a regular
> > > > THP, but we only fault in single pages from that chunk, until the user
> > > > has faulted in enough pages to pass the threshold we've set.  Once they
> > > > pass the threshold, we do the necessary work to turn our 512 page chunk
> > > > into a proper THP.  As it stands now, if the user tries to fault in
> > > > pages from different nodes, we completely give up on ever turning a
> > > > particular chunk into a THP, and just fault in the 4K pages as they're
> > > > requested.  We may want to make this tunable in the future (i.e. allow
> > > > them to fault in from only 2 different nodes).
> > > 
> > > OK.  But all 512 pages reside on the same node, yes?  Whereas with thp
> > > disabled those 512 pages would have resided closer to the CPUs which
> > > instantiated them.  
> > 
> > As it stands right now, yes, since we're pulling a 512 page contiguous
> > chunk off the free list, everything from that chunk will reside on the
> > same node, but as I (stupidly) forgot to mention in my original e-mail,
> > one piece I have yet to add is the functionality to put the remaining
> > unfaulted pages from our chunk *back* on the free list after we give up
> > on handing out a THP. 
> 
> You don't necessarily have to take it off in the
> first place either. Heavy handed approach is to create
> MIGRATE_MOVABLE_THP_RESERVATION_BECAUSE_WHO_NEEDS_SNAPPY_NAMES and put it
> at the bottom of the fallback lists in the page allocator. Allocate one
> base page, move the other 511 to that list. On the second fault, use the
> correctly aligned page if it's still on the buddy lists and local to the
> current NUMA node, otherwise fallback to a normal allocation. On promotion,
> you're checking first if all the faulted page are on the same node and
> second if the correctly aligned pages are on the free lists or not.
> 
> The addition of a migrate type would very heavy handed but you could
> just create a special cased linked list of pages that are potentially
> reserved that is drained before the page allocator wakes kswapd.
> 
> Order the pages such that the oldest one on the new free list is the
> first allocated. That way you do not have to worry about scanning tasks
> for pages to put back on the free list.

Thanks for the input, Mel.  While I agree that the addition of a migrate
type might be a bit heavy handed, I think that would also get rid of the
problem that Kirill pointed out with forking processes, i.e. the current
behavior tracks temporary huge pages in a per-mm freelist, which falls
apart for forked processes (only useful in the threaded case).  I'll
take a look into this soon.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
