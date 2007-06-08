Date: Fri, 8 Jun 2007 14:58:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory unplug v4  [2/6] lru isolation race fix
Message-Id: <20070608145818.980ec5b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706072248310.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608143953.93719b3e.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072248310.28618@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 22:52:15 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:
> 
> > release_pages() in mm/swap.c changes page_count() to be 0
> > without clearing PageLRU flag...
> > This means isolate_lru_page() can see a page, PageLRU() && page_count(page)==0..
> > This is BUG. (get_page() will be called against count=0 page.)
> 
> Use get_page_unless_zero?
> 
Oh, its better macro. thank you.

Then, the whole code will be....
==
 		if (PageLRU(page)) {
                        if (get_page_unless_zero(page)) {
				ret = 0;
	                        ClearPageLRU(page);
        	                if (PageActive(page))
                	                del_page_from_active_list(zone, page);
                        	else
                                	del_page_from_inactive_list(zone, page);
                        	list_add_tail(&page->lru, pagelist);
                	}
		}
==
Is this ok ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
