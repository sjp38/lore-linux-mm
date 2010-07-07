Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5016B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 02:06:54 -0400 (EDT)
Date: Wed, 7 Jul 2010 15:05:13 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100707060513.GA20221@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100705095927.GC8510@basil.fritz.box>
 <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
 <20100706071337.GA20403@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100706071337.GA20403@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 09:13:37AM +0200, Andi Kleen wrote:
> On Tue, Jul 06, 2010 at 12:33:42PM +0900, Naoya Horiguchi wrote:
> > > There's more code that handles LRU in this file. Do they all handle huge pages
> > > correctly?
> > > 
> > > I also noticed we do not always lock all sub pages in the huge page. Now if
> > > IO happens it will lock on subpages, not the head page. But this code
> > > handles all subpages as a unit. Could this cause locking problems?
> > > Perhaps it would be safer to lock all sub pages always? Or would 
> > > need  to audit other page users to make sure they always lock on the head
> > > and do the same here.
> > > 
> > > Hmm page reference counts may have the same issue?
> > 
> > If we try to implement paging out of hugepage in the future, we need to
> > solve all these problems straightforwardly. But at least for now we can
> > skirt them by not touching LRU code for hugepage extension.
> 
> We need the page lock to avoid migrating pages that are currently
> under IO. This can happen even without swapping when the process 
> manually starts IO. 

I see.  I understood we should work on locking problem in now.
I digged and learned hugepage IO can happen in direct IO from/to
hugepage or coredump of hugepage user.

We can resolve race between memory failure and IO by checking
page lock and writeback flag, right?

BTW I surveyed direct IO code, but page lock seems not to be taken.
Am I missing something?
(Before determining whether we lock all subpages or only headpage,
I want to clarify how current code for non-hugepage resolves this problem.)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
