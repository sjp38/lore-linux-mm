Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E84806B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:27:33 -0500 (EST)
Date: Tue, 23 Feb 2010 15:26:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 36/36] khugepaged
Message-ID: <20100223142634.GO11504@random.random>
References: <20100221141009.581909647@redhat.com>
 <20100221141758.658303189@redhat.com>
 <20100223165807.ade20de6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100223165807.ade20de6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 23, 2010 at 04:58:07PM +0900, KAMEZAWA Hiroyuki wrote:
> I'm not sure but....where this *hpage is chareged to proper memcg ?
> I think it's good to charge this newpage in the top of this function.
> (And cancel it at failure, of course.)

That is just a temporary page owned by khugepaged, not owned by any
memcg user. Who should I account it against? If allocation fails
khugepaged just waits alloc_sleep_msec and tries again later.

When the allocated page is actually used to collapse an hugepage, an
amount of memory equal to the size of the hpage is released. In turn
khugepaged changes nothing in the memcg accounting. There's just this
hpage temporary page that is also released if you turn off khugepaged
via sysctl, and I wouldn't know who to account it against. While it's
true it takes 512 more space than the khugepaged kernel stack,
conceptually it's the same thing as the kernel stack of the kernel
thread, so by that argument we should account khugepaged 4k of kernel
stack too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
