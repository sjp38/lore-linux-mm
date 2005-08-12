Received: by zproxy.gmail.com with SMTP id x7so463224nzc
        for <linux-mm@kvack.org>; Fri, 12 Aug 2005 07:54:57 -0700 (PDT)
Message-ID: <aa863ca80508120754655f3200@mail.gmail.com>
Date: Fri, 12 Aug 2005 22:54:57 +0800
From: ren zhy <zhyu.ren@gmail.com>
Subject: page->_count in shrink_cache() and shrink_list() ??
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,I am a kernel newbie and have a question about page_count in
shrink_list() ( 2.6.11 source code ).
  When kswapd began to shrink_cache(),it will first collect the pages
in zone->inactive_list which are not about to free into a temp
list:page_list .
565 if (get_page_testone(page)) { 
569 __put_page(page); 
570 SetPageLRU(page); 
571 list_add(&page->lru, &zone->inactive_list); 
572 continue; 
573 } 
574 list_add(&page->lru, &page_list); 
...
Then shrink_list() will check and try to free some fit pages.
589 nr_freed = shrink_list(&page_list, sc); 

in shrink_list(),I dont know why kernel will judge the expression
if(page_count(page)!=2) before doing something with this page.
After a page is allocated ,its page_count() is 1 and again  kernel add
1  in shrink_cache (line 565).So I think if the page is in page cache
or swap cache ,its page_count() is at least 3 and line 485 will not
satisfied.
480 /* 
481 * The non-racy check for busy page. It is critical to check 
482 * PageDirty _after_ making sure that the page is freeable and 
483 * not in use by anybody. (pagecache + us == 2) 
484 */ 
485 if (page_count(page) != 2 || PageDirty(page)) { 
486 spin_unlock_irq(&mapping->tree_lock); 
487 goto keep_locked; 
488 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
