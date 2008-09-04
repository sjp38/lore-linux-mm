Date: Thu, 04 Sep 2008 16:59:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
In-Reply-To: <1220475206-23684-1-git-send-email-apw@shadowen.org>
References: <1220467452-15794-5-git-send-email-apw@shadowen.org> <1220475206-23684-1-git-send-email-apw@shadowen.org>
Message-Id: <20080904162900.B262.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> When a process enters direct reclaim it will expend effort identifying
> and releasing pages in the hope of obtaining a page.  However as these
> pages are released asynchronously there is every possibility that the
> pages will have been consumed by other allocators before the reclaimer
> gets a look in.  This is particularly problematic where the reclaimer is
> attempting to allocate a higher order page.  It is highly likely that
> a parallel allocation will consume lower order constituent pages as we
> release them preventing them coelescing into the higher order page the
> reclaimer desires.
> 
> This patch set attempts to address this for allocations above
> ALLOC_COSTLY_ORDER by temporarily collecting the pages we are releasing
> onto a local free list.  Instead of freeing them to the main buddy lists,
> pages are collected and coelesced on this per direct reclaimer free list.
> Pages which are freed by other processes are also considered, where they
> coelesce with a page already under capture they will be moved to the
> capture list.  When pressure has been applied to a zone we then consult
> the capture list and if there is an appropriatly sized page available
> it is taken immediatly and the remainder returned to the free pool.
> Capture is only enabled when the reclaimer's allocation order exceeds
> ALLOC_COSTLY_ORDER as free pages below this order should naturally occur
> in large numbers following regular reclaim.


Hi Andy,

I like almost part of your patch.
(at least, I can ack patch 1/4 - 3/4)

So, I worry about OOM risk.
Can you remember desired page size to capture list (or any other location)?
if possible, __capture_on_page can avoid to capture unnecessary pages.

So, if __capture_on_page() can make desired size page by buddy merging, 
it can free other pages on capture_list.

In worst case, shrink_zone() is called by very much process at the same time.
Then, if each process doesn't back few pages, very many pages doesn't be backed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
