Date: Tue, 15 Jan 2008 08:57:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080111104651.3ebea5ea@bree.surriel.com>
References: <20080111162320.FD6A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080111104651.3ebea5ea@bree.surriel.com>
Message-Id: <20080115084534.116A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi

> > Why drop (total_swap_pages == 0 && PageAnon(page)) condition?
> > in embedded sysmtem, 
> > CONFIG_NORECLAIM is OFF (because almost embedded cpu is 32bit) and
> > that anon move to inactive list is meaningless because it doesn't have swap.
> 
> That was a mistake, kind of.  Since all swap backed pages are on their
> own LRU lists, we should not scan those lists at all any more if we are
> out of swap space.
> 
> The patch that fixes get_scan_ratio() adds that test.
> 
> Having said that, with the nr_swap_pages==0 test in get_scan_ratio(),
> we no longer need to test for that condition in shrink_active_list().

Oh I see!
thank you for your kindful lecture.

your implementation is very cute.


> > below code is more good, may be.
> > but I don't understand yet why ignore page_referenced() result at anon page ;-)
> 
> On modern systems, swapping out anonymous pages is a relatively rare
> event.  All anonymous pages start out as active and referenced, so
> testing for that condition does (1) not add any information and (2)
> mean we need to scan ALL of the anonymous pages, in order to find one
> candidate to swap out (since they are all referenced).
> 
> Simply deactivating a few pages and checking whether they were referenced
> again while on the (smaller) inactive_anon_list means we can find candidates
> to page out with a lot less CPU time used.

thanks, I understand, may be.


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
