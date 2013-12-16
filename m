Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 576E16B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:12:10 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id c10so4236078igq.4
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:12:10 -0800 (PST)
Date: Mon, 16 Dec 2013 11:12:15 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131216171214.GA15663@sgi.com>
References: <20131212180037.GA134240@sgi.com>
 <20131213214437.6fdbf7f2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213214437.6fdbf7f2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

> Please cc Andrea on this.

I'm going to clean up a few small things for a v2 pretty soon, I'll be
sure to cc Andrea there.

> > My proposed solution to the problem is to allow users to set a
> > threshold at which THPs will be handed out.  The idea here is that, when
> > a user faults in a page in an area where they would usually be handed a
> > THP, we pull 512 pages off the free list, as we would with a regular
> > THP, but we only fault in single pages from that chunk, until the user
> > has faulted in enough pages to pass the threshold we've set.  Once they
> > pass the threshold, we do the necessary work to turn our 512 page chunk
> > into a proper THP.  As it stands now, if the user tries to fault in
> > pages from different nodes, we completely give up on ever turning a
> > particular chunk into a THP, and just fault in the 4K pages as they're
> > requested.  We may want to make this tunable in the future (i.e. allow
> > them to fault in from only 2 different nodes).
> 
> OK.  But all 512 pages reside on the same node, yes?  Whereas with thp
> disabled those 512 pages would have resided closer to the CPUs which
> instantiated them.  

As it stands right now, yes, since we're pulling a 512 page contiguous
chunk off the free list, everything from that chunk will reside on the
same node, but as I (stupidly) forgot to mention in my original e-mail,
one piece I have yet to add is the functionality to put the remaining
unfaulted pages from our chunk *back* on the free list after we give up
on handing out a THP.  Once this is in there, things will behave more
like they do when THP is turned completely off, i.e. pages will get
faulted in closer to the CPU that first referenced them once we give up
on handing out the THP.

> So the expected result will be somewhere in between
> the 93 secs and the 76 secs?

Yes.  Due to the time it takes to search for the temporary THP, I'm sure
we won't get down to 76 secs, but hopefully we'll get close.  I'm also
considering switching the linked list that stores the temporary THPs
over to an rbtree to make that search faster, just fyi.

> That being said, I don't see a downside to the idea, apart from some
> additional setup cost in kernel code.

Good to hear.  I still need to address some of the issues that others
have raised, and finish up the few pieces that aren't fully
working/finished.  I'll get things polished up and get some more
informative test results out soon.

Thanks for looking at the patch!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
