Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA28117
	for <linux-mm@kvack.org>; Tue, 28 Jan 2003 13:09:00 -0800 (PST)
Message-ID: <3E36F167.7FB37E6B@digeo.com>
Date: Tue, 28 Jan 2003 13:08:55 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: dirty pages path in kernel
References: <3E36BD6B.6080000@shaolinmicro.com> <20030128111353.3a104e3d.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> David Chow <davidchow@shaolinmicro.com> wrote:
> >
> > Hi,
> >
> > If I do the following to an inode mapping page .
> >
> > 1. Generate a "struct page" from read_cache_page()
> > 2. kmap() the page, do some memset() (Dirty the page)
> > 3. kunmap() and page_cache_release() the page.
> >
> 
> The VFS does not know that the page has changed.
> 
> You should do:
> 
>         lock_page(page);
>         memset()
>         set_page_dirty(page);
>         unlock_page(page);
> 
> the page will be written to disk on the next kupdate cycle.

Make that:

	lock_page(page);
	kaddr = kmap_atomic(page, KM_USER0);
	memset(kaddr, ...);
	flush_dcache_page(page)
	kunmap_atomic(kaddr, KM_USER0);
	set_page_dirty(page);
	unlock_page(page);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
