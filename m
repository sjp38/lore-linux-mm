Date: Fri, 30 Jun 2000 12:38:19 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: get_page_map in 2.2 vs 2.4
Message-Id: <20000630175015Z131177-21002+72@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In 2.2, the function get_page_map is this:

/* 
 * Given a physical address, is there a useful struct page pointing to it?
 */

static struct page * get_page_map(unsigned long page)
{
	struct page *map;
	
	if (MAP_NR(page) >= max_mapnr)
		return 0;
	if (page == ZERO_PAGE(page))
		return 0;
	map = mem_map + MAP_NR(page);
	if (PageReserved(map))
		return 0;
	return map;
}

In 2.4, it's been changed to this:

/* 
 * Given a physical address, is there a useful struct page pointing to
 * it?  This may become more complex in the future if we start dealing
 * with IO-aperture pages in kiobufs.
 */

static inline struct page * get_page_map(struct page *page)
{
	if (page > (mem_map + max_mapnr))
		return 0;
	return page;
}

It appears that although the comment is no longer correct.  In 2.2, the
function took an unsigned long and returned a pointer to a mem_map_t.  In 2.4,
it takes a mem_map_t and returns it.  This is hardly useful.

Am I missing something?  What was wrong with the original implementation?  And
why hasn't the comment changed?




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
