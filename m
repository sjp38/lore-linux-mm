Message-ID: <3DF5BB06.A6F6AFFD@scs.ch>
Date: Tue, 10 Dec 2002 10:59:34 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Question on set_page_dirty()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

Looking at the function set_page_dirty() (in linux 2.4.18-3 - see below) I noticed, that it not only sets the pages PG_dirty bit (as the SetPageDirty() macro does), but
additionnally may link the page onto a queue (more precisely the dirty queue of it's 'mapping').
What is the meaning of this dirty queue, what is the effect of linking a page onto that queue, and when should the set_page_dirty() function be used rather than the
SetPageDirty() macro?

Thanks in advance for any help
with best regards
Martin Maletinsky

P.S. Please put me on CC: in your reply, since I am not in the mailing list.

*
153  * Add a page to the dirty page list.
154  */
155 void set_page_dirty(struct page *page)
156 {
157         if (!test_and_set_bit(PG_dirty, &page->flags)) {
158                 struct address_space *mapping = page->mapping;
159 
160                 if (mapping) {
161                         spin_lock(&pagecache_lock);
162                         list_del(&page->list);
163                         list_add(&page->list, &mapping->dirty_pages);
164                         spin_unlock(&pagecache_lock);
165 
166                         if (mapping->host)
167                                 mark_inode_dirty_pages(mapping->host);
168                 }
169         }
170 }


--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
