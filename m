Date: Fri, 11 May 2001 13:42:57 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] VM fixes against 2.4.4-ac6
In-Reply-To: <Pine.LNX.4.21.0105111222330.23350-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0105111340020.23350-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 11 May 2001, Marcelo Tosatti wrote:

> Hi, 
> 
> The following patch addresses two issues:
> 
> 
> - Buffer cache pages in the inactive lists are not getting their age
> increased if they get touched by getblk (which will set the referenced bit
> on the page).  page_launder() simply cleans the referenced bit on such
> pages and moves them to the active list. To resume: buffercache pages
> suffer more pressure from VM than pagecache pages. That is horrible for
> performance.
> 
> 
> - When there is no memory available on the system for normal allocations
> (GFP_KERNEL), the tasks may loop in try_to_free_pages() (which is here
> called by __alloc_pages()) without blocking:
> 
> 	- GFP_BUFFER allocations will _never_ block on IO inside
> 	try_to_free_pages(). They will keep looping inside __alloc_pages() 
> 	until they get a free page. 
> 	
> 	- __GFP_IO|__GFP_WAIT allocations may not find any way to block on
> 	IO inside try_to_free_pages() in case we already have other tasks
> 	inside there (kswapd will be there in such condition, for sure).

Ah, one subtle issue here: if they loop, they'll probably bump
memory_pressure a lot.  

That will result in a bigger inactive target, which means aggressive
aging. 

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
