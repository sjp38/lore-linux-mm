Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 82C356B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:25:33 -0400 (EDT)
Date: Tue, 17 Mar 2009 11:19:59 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random>
 <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random> <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain>
 <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Linus Torvalds wrote:
> 
> This problem is actually pretty easy to fix for anonymous pages: since the 
> act of pinning (for writes) should have done all the COW stuff and made 
> sure the page is not in the swap cache, we only need to avoid adding it 
> back.

An alternative approach would have been to just count page pinning as 
being a "referenced", which to some degree would be even more logical (we 
don't set the referenced flag when we look those pages up). That would 
also affect pages that were get_user_page'd just for reading, which might 
be seen as an additional bonus.

The "don't turn pinned pages into swap cache pages" is a somewhat more 
direct patch, though. It gives more obvious guarantees about the lifetime 
behaviour of anon pages wrt get_user_pages[_fast]().. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
