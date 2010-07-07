Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0586B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 05:27:24 -0400 (EDT)
Date: Wed, 7 Jul 2010 11:27:19 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100707092719.GA3900@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100705095927.GC8510@basil.fritz.box>
 <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
 <20100706071337.GA20403@basil.fritz.box>
 <20100707060513.GA20221@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100707060513.GA20221@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> I see.  I understood we should work on locking problem in now.
> I digged and learned hugepage IO can happen in direct IO from/to
> hugepage or coredump of hugepage user.
> 
> We can resolve race between memory failure and IO by checking
> page lock and writeback flag, right?

Yes, but we have to make sure it's in the same page.

As I understand the IO locking does not use the head page, that
means migration may need to lock all the sub pages.

Or fix IO locking to use head pages? 

> 
> BTW I surveyed direct IO code, but page lock seems not to be taken.
> Am I missing something?

That's expected I believe because applications are supposed to coordinate
for direct IO (but then direct IO also drops page cache). 

But page lock is used to coordinate in the page cache for buffered IO.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
