Received: from [127.0.0.1] (helo=logos.cnet)
	by www.linux.org.uk with esmtp (Exim 4.33)
	id 1C0ntV-0006bO-Us
	for linux-mm@kvack.org; Fri, 27 Aug 2004 22:04:22 +0100
Date: Fri, 27 Aug 2004 16:07:14 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: refill_inactive_zone question
Message-ID: <20040827190714.GB3332@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi MM gurus, 

Reading refill_inactive_zone(), while looping on pages grabbed from the inactive list (l_hold), 
refill_inactive_zone() it does:

                                                                                                                                                                                  
        while (!list_empty(&l_hold)) {
                page = lru_to_page(&l_hold);
                list_del(&page->lru);
                if (page_mapped(page)) {
                        if (!reclaim_mapped) {
                                list_add(&page->lru, &l_active);
                                continue;
                        }
                        page_map_lock(page);
                        if (page_referenced(page)) {
                                page_map_unlock(page);
                                list_add(&page->lru, &l_active);
                                continue;
                        }
                        page_map_unlock(page);
                }
                /*
                 * FIXME: need to consider page_count(page) here if/when we
                 * reap orphaned pages via the LRU (Daniel's locking stuff)
                 */
                if (total_swap_pages == 0 && PageAnon(page)) { 
                        list_add(&page->lru, &l_active);
                        continue;
                }
                list_add(&page->lru, &l_inactive);
        }


Is it possible to have AnonPages without a mapping to them? I dont think so.

Can't the check "if (total_swap_pages == 0 && PageAnon(page))" be moved
inside "if (page_mapped(page))" ? 

TIA!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
