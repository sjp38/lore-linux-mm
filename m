Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA23402
	for <linux-mm@kvack.org>; Tue, 28 Jan 2003 11:13:38 -0800 (PST)
Date: Tue, 28 Jan 2003 11:13:53 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: dirty pages path in kernel
Message-Id: <20030128111353.3a104e3d.akpm@digeo.com>
In-Reply-To: <3E36BD6B.6080000@shaolinmicro.com>
References: <3E36BD6B.6080000@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Chow <davidchow@shaolinmicro.com> wrote:
>
> Hi,
> 
> If I do the following to an inode mapping page .
> 
> 1. Generate a "struct page" from read_cache_page()
> 2. kmap() the page, do some memset() (Dirty the page)
> 3. kunmap() and page_cache_release() the page.
> 

The VFS does not know that the page has changed.

You should do:

	lock_page(page);
	memset()
	set_page_dirty(page);
	unlock_page(page);

the page will be written to disk on the next kupdate cycle.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
