Message-ID: <3D6D3AA4.31A4AD3A@zip.com.au>
Date: Wed, 28 Aug 2002 14:03:32 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: MM patches against 2.5.31
References: <3D644C70.6D100EA5@zip.com.au> <E17jjWN-0002fo-00@starship> <20020828131445.25959.qmail@thales.mathematik.uni-ulm.de> <E17k9dO-0002tR-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> Going right back to basics, what do you suppose is wrong with the 2.4
> strategy of always doing the lru removal in free_pages_ok?

That's equivalent to what we have at present, which is:

	if (put_page_testzero(page)) {
		/* window here */
		lru_cache_del(page);
		__free_pages_ok(page, 0);
	}

versus:

	spin_lock(lru lock);
	page = list_entry(lru, ...);
	if (page_count(page) == 0)
		continue;
	/* window here */
	page_cache_get(page);
	page_cache_release(page);	/* double-free */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
