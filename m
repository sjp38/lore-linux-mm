Date: Mon, 22 Jan 2007 11:22:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <6d6a94c50701192026q4aad8954s2d2aaa6b66ab1fd0@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701221117250.25121@schroedinger.engr.sgi.com>
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
 <45B0DB45.4070004@linux.vnet.ibm.com>  <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
  <45B112B6.9060806@linux.vnet.ibm.com>  <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>
  <45B17D6D.2030004@yahoo.com.au>  <6d6a94c50701191908i63fe7eebi9a97a4afb94f5df4@mail.gmail.com>
  <45B19483.6010300@yahoo.com.au> <6d6a94c50701192026q4aad8954s2d2aaa6b66ab1fd0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jan 2007, Aubrey Li wrote:

> assume:
> min = 123pages
> pagecache_reserved = 200 pages
> 
> if( alloc_flags & ALLOC_PAGECACHE)
>        watermark = min + pagecache_reserved ( 323 pages)
> else
>        watermark = min ( 123 pages)
> 
> So if request pagecache, when free pages < 323 pages, reclaim is triggered.
> But at this time if request memory not pagecache, reclaim will be
> triggered when free pages < 123 as the present reclaimer does.
> 
> I verified it on my side, why do you think it doesn't work properly?

The code does not check the page cache size but the number of free pages. 
The page cache size is available via zone_page_state(zone, NR_FILE_PAGES).

In its current form your patch is making the system reclaim earlier for 
page cache allocations. And its reclaiming regardless of the number of 
pages in the page cache. If there are no pagecache pages but only 
anonymous pages in the zone then the code will still reclaim although the 
page cache size is zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
