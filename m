Date: Fri, 12 Aug 2005 20:08:25 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Zoned CART
Message-ID: <20050812230825.GB11168@dmt.cnet>
References: <1123857429.14899.59.camel@twins> <42FCC359.20200@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42FCC359.20200@andrew.cmu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Iyer <rni@andrew.cmu.edu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 12, 2005 at 11:42:17AM -0400, Rahul Iyer wrote:
> Hi Peter,
> I have recently released another patch...
> both patches are at http://www.cs.cmu.edu/~412/projects/CART/
> Thanks
> Rahul

Hi Rahul,

Have some comments on the CART v2 patch

I find it a very interesting idea to split the active list in two!  

+#define EVICTED_ACTIVE                 1
+#define EVICTED_LONGTERM       2
+#define ACTIVE                 3
+#define ACTIVE_LONGTERM                4

You have different definitions using the same bit positions.
Those values should be 1, 2, 4 and 8.

+#define EvictedActive(location)                location & EVICTED_ACTIVE
+#define EvictedLongterm(location)      location & EVICTED_LONGTERM
+#define Active(location)               location & ACTIVE
+#define ActiveLongterm(location)       location & ACTIVE_LONGTERM

(location  & xxxx) looks nicer.

+struct non_res_list_node {
+	struct list_head list;
+	struct list_head hash;
+	unsigned long mapping;
+	unsigned long offset;
+	unsigned long inode;
+}; 

+	node->offset = page->index;
+	node->mapping = (unsigned long) page->mapping;
+	node->inode = get_inode_num(page->mapping);

You can compress these tree fields into a single one with a hash function.

+/* The replace function. This function serches the active and longterm
+lists and looks for a candidate for replacement. This function selects
+the candidate and returns the corresponding structpage or returns
+NULL in case no page can be freed. The *where argument is used to
+indicate the parent list of the page so that, in case it cannot be
+written back, it can be placed back on the correct list */ 
+struct page *replace(struct zone *zone, int *where)

+	list = list->next;
+	while (list !=&zone->active_longterm) {
+		page = list_entry(list, struct page, lru);
+
+		if (!PageReferenced(page))
+			break;
+		
+		ClearPageReferenced(page);
+		del_page_from_active_longterm(zone, page);
+		add_page_to_active_list_tail(zone, page);

This sounds odd. If a page is referenced you remove it from the longterm list
"unpromoting" it to the active list? Shouldnt be the other way around?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
