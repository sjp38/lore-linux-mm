From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15927.45619.775222.504275@laputa.namesys.com>
Date: Wed, 29 Jan 2003 13:51:31 +0300
Subject: Re: dirty pages path in kernel
In-Reply-To: <3E36F167.7FB37E6B@digeo.com>
References: <3E36BD6B.6080000@shaolinmicro.com>
	<20030128111353.3a104e3d.akpm@digeo.com>
	<3E36F167.7FB37E6B@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: David Chow <davidchow@shaolinmicro.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Andrew Morton wrote:
 > > 
 > > David Chow <davidchow@shaolinmicro.com> wrote:
 > > >
 > > > Hi,
 > > >
 > > > If I do the following to an inode mapping page .
 > > >
 > > > 1. Generate a "struct page" from read_cache_page()
 > > > 2. kmap() the page, do some memset() (Dirty the page)
 > > > 3. kunmap() and page_cache_release() the page.
 > > >
 > > 
 > > The VFS does not know that the page has changed.
 > > 
 > > You should do:
 > > 
 > >         lock_page(page);
 > >         memset()
 > >         set_page_dirty(page);
 > >         unlock_page(page);
 > > 
 > > the page will be written to disk on the next kupdate cycle.
 > 
 > Make that:
 > 
 > 	lock_page(page);
 > 	kaddr = kmap_atomic(page, KM_USER0);
 > 	memset(kaddr, ...);
 > 	flush_dcache_page(page)
 > 	kunmap_atomic(kaddr, KM_USER0);
 > 	set_page_dirty(page);

Shouldn't mark_page_accessed() go here?

 > 	unlock_page(page);

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
