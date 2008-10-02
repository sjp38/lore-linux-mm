Date: Thu, 2 Oct 2008 15:44:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Reclaim page capture v4
Message-Id: <20081002154446.3695a3b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1222864261-22570-1-git-send-email-apw@shadowen.org>
References: <1222864261-22570-1-git-send-email-apw@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed,  1 Oct 2008 13:30:57 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> For sometime we have been looking at mechanisms for improving the availability
> of larger allocations under load.  One of the options we have explored is
> the capturing of pages freed under direct reclaim in order to increase the
> chances of free pages coelescing before they are subject to reallocation
> by racing allocators.
> 
> Following this email is a patch stack implementing page capture during
> direct reclaim.  It consits of four patches.  The first two simply pull
> out existing code into helpers for reuse.  The third makes buddy's use
> of struct page explicit.  The fourth contains the meat of the changes,
> and its leader contains a much fuller description of the feature.
> 
> This update represents a rebase to -mm and incorporates feedback from
> KOSAKI Motohiro.  It also incorporates an accounting fix which was
> preventing some captures.
> 
> I have done a lot of comparitive testing with and without this patch
> set and in broad brush I am seeing improvements in hugepage allocations
> (worst case size) success on all of my test systems.  These tests consist
> of placing a constant stream of high order allocations on the system,
> at varying rates.  The results for these various runs are then averaged
> to give an overall improvement.
> 
> 		Absolute	Effective
> x86-64		2.48%		 4.58%
> powerpc		5.55%		25.22%
> 
> x86-64 has a relatively small huge page size and so is always much more
> effective at allocating huge pages.  Even there we get a measurable
> improvement.  On powerpc the huge pages are much larger and much harder
> to recover.  Here we see a full 25% increase in page recovery.
> 
> It should be noted that these are worst case testing, and very agressive
> taking every possible page in the system.  It would be helpful to get
> wider testing in -mm.
> 
> Against: 2.6.27-rc1-mm1
> 
> Andrew, please consider for -mm.
> 

Hmm, can't we use "MIGRATE_ISOLATE" pageblock type for this purpose ?
The page allocater skips pageblock marked as MIGRATE_ISOLATE at allocation.
(pageblock-size is equal to HUGEPAGE size in general.)

Of course, "where should be isolated" is a problem.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
