Date: Mon, 30 Jun 2003 19:14:56 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.73-mm2
Message-Id: <20030630191456.1aef22e0.akpm@digeo.com>
In-Reply-To: <20030701003958.GB20413@holomorphy.com>
References: <20030627202130.066c183b.akpm@digeo.com>
	<20030701003958.GB20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  @@ -217,9 +217,9 @@ void out_of_memory(void)
>   	unsigned long now, since;
>   
>   	/*
>  -	 * Enough swap space left?  Not OOM.
>  +	 * Enough swap space and ZONE_NORMAL left?  Not OOM.
>   	 */
>  -	if (nr_swap_pages > 0)
>  +	if (nr_swap_pages > 0 && nr_free_buffer_pages() + nr_used_low_pages() > 0)
>   		return;

a) if someone is trying to allocate some ZONE_DMA pages and there are
   still swappable or free ZONE_NORMAL pages, nobody gets killed.

b) If there are free ZONE_NORMAL pages then why on earth did we call
   out_of_memory()?  Does nr_free_buffer_pages() ever return non-zero in
   here?  It will do so for a ZONE_DMA allocation, but you're not doing
   them...

Generally, I'm thinking that this test should just be removed.  It is
the responsibility of try_to_free_pages() to work out whether the
allocation can succeed.

If try_to_free_pages() calls out_of_memory() when there are still
swappable, reclaimable or free pages in the relevant zones then
try_to_free_pages() goofed, and needs mending.  out_of_memory()
shouldn't be cleaning up after try_to_free_pages()'s mistakes.

I have a bad feeling that it _will_ goof.  A long time ago I looked
at the amount of scanning we're doing in there and decided that it
was way overkill and reduced it by a lot.  I may have gone overboard.  

So how's about I and thy take that test out, see how things get along?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
