Message-ID: <3B1E203C.5DC20103@uow.edu.au>
Date: Wed, 06 Jun 2001 22:21:16 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
References: <l03130308b7439bb9f187@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton wrote:
> 
> Interesting observation.  Something else though, which kswapd is guilty of
> as well: consider a page shared among many processes, eg. part of a
> library.  As kswapd scans, the page is aged down for each process that uses
> it.  So glibc gets aged down many times more quickly than a non-shared
> page, precisely the opposite of what we really want to happen.

Perhaps the page should be aged down by (1 / page->count)?

Just scale all the age stuff by 256 or 1000 or whatever and
instead of saying

	page->age -= CONSTANT;

you can use

	page->age -= (CONSTANT * 256) / atomic_read(page->count);


So the more users, the more slowly it ages.  You get the idea.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
