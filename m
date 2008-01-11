Date: Fri, 11 Jan 2008 10:46:51 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080111104651.3ebea5ea@bree.surriel.com>
In-Reply-To: <20080111162320.FD6A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080111162320.FD6A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 16:35:24 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Why drop (total_swap_pages == 0 && PageAnon(page)) condition?
> in embedded sysmtem, 
> CONFIG_NORECLAIM is OFF (because almost embedded cpu is 32bit) and
> that anon move to inactive list is meaningless because it doesn't have swap.

That was a mistake, kind of.  Since all swap backed pages are on their
own LRU lists, we should not scan those lists at all any more if we are
out of swap space.

The patch that fixes get_scan_ratio() adds that test.

Having said that, with the nr_swap_pages==0 test in get_scan_ratio(),
we no longer need to test for that condition in shrink_active_list().

> below code is more good, may be.
> but I don't understand yet why ignore page_referenced() result at anon page ;-)

On modern systems, swapping out anonymous pages is a relatively rare
event.  All anonymous pages start out as active and referenced, so
testing for that condition does (1) not add any information and (2)
mean we need to scan ALL of the anonymous pages, in order to find one
candidate to swap out (since they are all referenced).

Simply deactivating a few pages and checking whether they were referenced
again while on the (smaller) inactive_anon_list means we can find candidates
to page out with a lot less CPU time used.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
