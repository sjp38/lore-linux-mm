Date: Tue, 9 Nov 2004 18:53:29 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109185329.35eca4a1.akpm@osdl.org>
In-Reply-To: <20041109231654.GE8414@logos.cnet>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
	<20041109142257.1d1411e1.akpm@osdl.org>
	<20041109203143.GC8414@logos.cnet>
	<20041109162801.7f7ca242.akpm@osdl.org>
	<20041109231654.GE8414@logos.cnet>
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
> 
> > And in that case, they may be
> > holding locks whcih prevent kswapd from being able to do any work either.
> 
> OK... Just out of curiosity:
> Isnt the "lock contention" at this level (filesystem) a relatively rare situation? 
> 

It should be relatively rare - most of the blocking opportunities on the
writepage path should be avoided by now - we bale out, try another page,
throttle on some I/O completion if it's all not working out.

There are probably filesystem allocation semaphores.  journal_start/stop
acts as a semaphore, as does get_request_wait().

It all depends on whether you're looking for common case or worst case.  In
page reclaim we should tune for the common case, and avoid deadlocking in
the worst case.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
