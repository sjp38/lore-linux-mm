Received: from [127.0.0.1] (helo=logos.cnet)
	by www.linux.org.uk with esmtp (Exim 4.33)
	id 1Bvhiu-00007w-KY
	for linux-mm@kvack.org; Fri, 13 Aug 2004 20:28:21 +0100
Date: Fri, 13 Aug 2004 15:05:04 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: __set_page_dirty_nobuffers superfluous check
Message-ID: <20040813180504.GB29875@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

While wandering through mm/page-writeback.c I noticed
__set_page_dirty_nobuffers does:

int __set_page_dirty_nobuffers(struct page *page)
{
        int ret = 0;
                                                                                         
        if (!TestSetPageDirty(page)) {
                struct address_space *mapping = page_mapping(page);
                                                                                         
                if (mapping) {
                        spin_lock_irq(&mapping->tree_lock);
                        mapping = page_mapping(page);
                        if (page_mapping(page)) { /* Race with truncate? */
                                BUG_ON(page_mapping(page) != mapping);    <------------------
                                if (!mapping->backing_dev_info->memory_backed)
                                        inc_page_state(nr_dirty);
                                radix_tree_tag_set(&mapping->page_tree,
                                        page_index(page), PAGECACHE_TAG_DIRTY);
                        }

How could the mapping ever change if we have tree_lock?

Its basically a check which assumes there might be 
buggy page->mapping writers who do so without the lock, yes?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
