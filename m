Date: Tue, 9 Nov 2004 16:28:01 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109162801.7f7ca242.akpm@osdl.org>
In-Reply-To: <20041109203143.GC8414@logos.cnet>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
	<20041109142257.1d1411e1.akpm@osdl.org>
	<20041109203143.GC8414@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> Back to arguing in favour of my patch - it seemed to me that kswapd could 
>  go to sleep leaving allocators which can't reclaim pages themselves in a 
>  bad situation. 

Yes, but those processes would be sleeping in blk_congestion_wait() during,
say, a GFP_NOIO/GFP_NOFS allocation attempt.  And in that case, they may be
holding locks whcih prevent kswapd from being able to do any work either.

>  It would have to be waken up by another instance of alloc_pages to then 
>  execute and start doing its job, while if it was executing already (madly 
>  scanning as you say), the chance it would find freeable pages quite
>  earlier.
> 
>  Note that not only disk IO can cause pages to become freeable. A user
>  can give up its reference on pagecache page for example (leaving
>  the page on LRU to be found and freed by kswapd).

yup.  Or munlock(), or direct-io completion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
