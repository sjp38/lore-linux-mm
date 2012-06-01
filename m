Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CB8606B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:12:10 -0400 (EDT)
Date: Fri, 1 Jun 2012 12:12:05 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120601161205.GA1918@redhat.com>
References: <20120530163317.GA13189@redhat.com>
 <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com>
 <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 01, 2012 at 01:44:44AM -0700, Hugh Dickins wrote:

 > Please give this patch a try (preferably on current git), and let us know.
 > 
 > Thanks,
 > Hugh
 > 
 > --- 3.4.0+/mm/migrate.c	2012-05-27 10:01:43.104049010 -0700
 > +++ linux/mm/migrate.c	2012-06-01 00:10:58.080098749 -0700
 > @@ -436,7 +436,10 @@ void migrate_page_copy(struct page *newp
 >  		 * is actually a signal that all of the page has become dirty.
 >  		 * Whereas only part of our page may be dirty.
 >  		 */
 > -		__set_page_dirty_nobuffers(newpage);
 > +		if (PageSwapBacked(page))
 > +			SetPageDirty(newpage);
 > +		else
 > +			__set_page_dirty_nobuffers(newpage);
 >   	}
 >  
 >  	mlock_migrate_page(newpage, page);
 > --- 3.4.0+/mm/page-writeback.c	2012-05-29 08:09:58.304806782 -0700
 > +++ linux/mm/page-writeback.c	2012-06-01 00:23:43.984116973 -0700
 > @@ -1987,7 +1987,10 @@ int __set_page_dirty_nobuffers(struct pa
 >  		mapping2 = page_mapping(page);
 >  		if (mapping2) { /* Race with truncate? */
 >  			BUG_ON(mapping2 != mapping);
 > -			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 > +			if (WARN_ON(!PagePrivate(page) && !PageUptodate(page)))
 > +				print_symbol(KERN_WARNING
 > +				    "mapping->a_ops->writepage: %s\n",
 > +				    (unsigned long)mapping->a_ops->writepage);
 >  			account_page_dirtied(page, mapping);
 >  			radix_tree_tag_set(&mapping->page_tree,
 >  				page_index(page), PAGECACHE_TAG_DIRTY);

So with this applied, I don't seem to be able to trigger it. It's been running two hours
so far. I'll leave it running, but right now I don't know what to make of this.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
