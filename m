Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4456B02AC
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 08:29:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k2so18098062wrh.16
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 05:29:11 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id t7si9356485edc.248.2018.01.02.05.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 05:29:09 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 439E61C2EC2
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 13:29:09 +0000 (GMT)
Date: Tue, 2 Jan 2018 13:29:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -V4 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20180102132908.hv3qwxqpz7h2jyqp@techsingularity.net>
References: <20171220012632.26840-1-ying.huang@intel.com>
 <20171221021619.GA27475@bbox>
 <871sjopllj.fsf@yhuang-dev.intel.com>
 <20171221235813.GA29033@bbox>
 <87r2rmj1d8.fsf@yhuang-dev.intel.com>
 <20171223013653.GB5279@bgram>
 <20180102102103.mpah2ehglufwhzle@suse.de>
 <20180102112955.GA29170@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180102112955.GA29170@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, J???r???me Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Tue, Jan 02, 2018 at 12:29:55PM +0100, Jan Kara wrote:
> On Tue 02-01-18 10:21:03, Mel Gorman wrote:
> > On Sat, Dec 23, 2017 at 10:36:53AM +0900, Minchan Kim wrote:
> > > > code path.  It appears that similar situation is possible for them too.
> > > > 
> > > > The file cache pages will be delete from file cache address_space before
> > > > address_space (embedded in inode) is freed.  But they will be deleted
> > > > from LRU list only when its refcount dropped to zero, please take a look
> > > > at put_page() and release_pages().  While address_space will be freed
> > > > after putting reference to all file cache pages.  If someone holds a
> > > > reference to a file cache page for quite long time, it is possible for a
> > > > file cache page to be in LRU list after the inode/address_space is
> > > > freed.
> > > > 
> > > > And I found inode/address_space is freed witch call_rcu().  I don't know
> > > > whether this is related to page_mapping().
> > > > 
> > > > This is just my understanding.
> > > 
> > > Hmm, it smells like a bug of __isolate_lru_page.
> > > 
> > > Ccing Mel:
> > > 
> > > What locks protects address_space destroying when race happens between
> > > inode trauncation and __isolate_lru_page?
> > > 
> > 
> > I'm just back online and have a lot of catching up to do so this is a rushed
> > answer and I didn't read the background of this. However the question is
> > somewhat ambiguous and the scope is broad as I'm not sure which race you
> > refer to. For file cache pages, I wouldnt' expect the address_space to be
> > destroyed specifically as long as the inode exists which is the structure
> > containing the address_space in this case. A page on the LRU being isolated
> > in __isolate_lru_page will have an elevated reference count which will
> > pin the inode until remove_mapping is called which holds the page lock
> > while inode truncation looking at a page for truncation also only checks
> > page_mapping under the page lock. Very broadly speaking, pages avoid being
> > added back to an inode being freed by checking the I_FREEING state.
> 
> So I'm wondering what prevents the following:
> 
> CPU1						CPU2
> 
> truncate(inode)					__isolate_lru_page()
>   ...
>   truncate_inode_page(mapping, page);
>     delete_from_page_cache(page)
>       spin_lock_irqsave(&mapping->tree_lock, flags);
>         __delete_from_page_cache(page, NULL)
>           page_cache_tree_delete(..)
>             ...					  mapping = page_mapping(page);
>             page->mapping = NULL;
>             ...
>       spin_unlock_irqrestore(&mapping->tree_lock, flags);
>       page_cache_free_page(mapping, page)
>         put_page(page)
>           if (put_page_testzero(page)) -> false
> - inode now has no pages and can be freed including embedded address_space
> 
> 						  if (mapping && !mapping->a_ops->migratepage)
> - we've dereferenced mapping which is potentially already free.
> 

Hmm, possible if unlikely.

Before delete_from_page_cache, we called truncate_cleanup_page so the
page is likely to be !PageDirty or PageWriteback which gets skipped by
the only caller that checks the mappping in __isolate_lru_page. The race
is tiny but it does exist. One way of closing it is to check the mapping
under the page lock which will prevent races with truncation. The
overhead is minimal as the calling context (compaction) is quite a heavy
operation anyway.

Build tested only for review


diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850ea349..61bf0bc60d96 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1433,14 +1433,24 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 
 		if (PageDirty(page)) {
 			struct address_space *mapping;
+			bool migrate_dirty;
 
 			/*
 			 * Only pages without mappings or that have a
 			 * ->migratepage callback are possible to migrate
-			 * without blocking
+			 * without blocking. However, we can be racing with
+			 * truncation so it's necessary to lock the page
+			 * to stabilise the mapping as truncation holds
+			 * the page lock until after the page is removed
+			 * from the page cache.
 			 */
+			if (!trylock_page(page))
+				return ret;
+
 			mapping = page_mapping(page);
-			if (mapping && !mapping->a_ops->migratepage)
+			migrate_dirty = mapping && mapping->a_ops->migratepage;
+			unlock_page(page);
+			if (!migrate_dirty)
 				return ret;
 		}
 	}

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
