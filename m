Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA05276
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 21:19:22 -0500
Date: Tue, 26 Jan 1999 02:57:41 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901251625.QAA04452@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990126025518.3579A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Stephen C. Tweedie wrote:

> --- mm/filemap.c.~1~	Thu Jan 21 10:26:41 1999
> +++ mm/filemap.c	Mon Jan 25 12:59:38 1999
> @@ -125,7 +125,7 @@
>  	struct page * page;
>  	int count;
>  
> -	count = (limit << 1) >> priority;
> +	count = limit >> priority;
>  
>  	page = mem_map + clock;
>  	do {
> @@ -147,7 +147,6 @@
>  			clock = page - mem_map;
>  		}
>  		
> -		count--;

OK to remove the << 1 and to move count-- after checking referenced.

>  		referenced = test_and_clear_bit(PG_referenced, &page->flags);
>  
>  		if (PageLocked(page))
> @@ -159,6 +158,8 @@
>  		/* We can't free pages unless there's just one user */
>  		if (atomic_read(&page->count) != 1)
>  			continue;
> +
> +		count--;

but this is plain bogus. When your machine will reach 0 freeable pages
(and that happens a bit before to kill the process because OOM) you'll get
an infinite loop in shrink_mmap().

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
