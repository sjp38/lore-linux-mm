Message-ID: <4191675B.3090903@cyberone.com.au>
Date: Wed, 10 Nov 2004 11:56:59 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
References: <20041109164642.GE7632@logos.cnet>	<20041109121945.7f35d104.akpm@osdl.org>	<20041109174125.GF7632@logos.cnet>	<20041109133343.0b34896d.akpm@osdl.org>	<20041109182622.GA8300@logos.cnet> <20041109142257.1d1411e1.akpm@osdl.org>
In-Reply-To: <20041109142257.1d1411e1.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
>
>>Does it makes sense to you?
>>
>
>Maybe.  We really shouldn't be sending kswapd into a busy loop if all zones
>are unreclaimable.  Because it could just be that there's some disk I/O in
>flight and we'll find rotated reclaimable pages available once that I/O has
>completed.  (example: all of memory becomes dirty due to a large msync of
>MAP_SHARED memory).  So rather than madly scanning, we should throttle
>kswapd to make it wait for I/O completions.  Via blk_congestion_wait(). 
>That's what the total_scanned logic is supposed to do.
>
>
>

I think the patch is possibly not a good idea. Unless it fixes up
those #*%! allocation failures (*).

For OOM conditions, kswapd can be a bit lax precisely because it
doesn't oom kill things. If there is a shortage, and kswapd can't
make progress though, I think it really should sleep rather than busy
wait (albiet nicely with cond_resched()).

(*) I'm beginning to think they're due to me accidentally bumping the
    page watermarks when 'fixing' them. I'll check that out presently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
