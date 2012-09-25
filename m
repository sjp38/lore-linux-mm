Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 6D4B96B0068
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 10:01:18 -0400 (EDT)
Date: Tue, 25 Sep 2012 11:00:55 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v10 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120925140054.GA1638@optiplex.redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
 <89c9f4096bbad072e155445fcdf1805d47ddf48e.1347897793.git.aquini@redhat.com>
 <20120917151543.fd523040.akpm@linux-foundation.org>
 <20120918162420.GB1645@optiplex.redhat.com>
 <20120925010549.GA22893@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120925010549.GA22893@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Sep 25, 2012 at 03:05:49AM +0200, Michael S. Tsirkin wrote:
> If these are all under page lock these barriers just confuse things,
> because they are almost never enough by themselves.
> So in that case it would be better to drop them and document
> usage as you are going to.
>

Would the following make more sense (with the proprer comments, as well) ?

---8<---
+static inline void balloon_page_set(struct page *page,
+                                   struct address_space *mapping,
+                                   struct list_head *head)
+{
+       list_add(&page->lru, head);
+       smp_wmb();
+       page->mapping = mapping;
+}
+
+static inline void balloon_page_del(struct page *page)
+{
+       page->mapping = NULL;
+       smp_wmb();
+       list_del(&page->lru);
+}
+
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+       struct address_space *mapping = ACCESS_ONCE(page->mapping);
+       smp_read_barrier_depends();
+       return mapping_balloon(mapping);
+}
+
---8<---

There's still a case where we have to test page->mapping->flags and we cannot
afford to wait for, or grab, the page lock @ isolate_migratepages_range().
The barriers won't avoid leak_ballon() racing against isolate_migratepages_range(),
but they surely will make tests for page->mapping more consistent. And for those
cases where leak_balloon() races against
isolate_migratepages_range->isolate_balloon_page(), we solve the conflict of
interest through page refcounting and page lock. I'm preparing a more extensive
doc to include at Documentation/ to explain the interfaces and how we cope with
these mentioned races, as well.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
