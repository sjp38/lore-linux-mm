Date: Sun, 29 Jul 2001 09:05:22 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072916102900.00341@starship>
Message-ID: <Pine.LNX.4.33.0107290902060.7119-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Daniel Phillips wrote:
>
> When I looked at age_page_up, I saw an anomaly:
>
> 	void age_page_up_nolock(struct page * page)
> 	{
> 	 	if (!page->age)   /* wrong */
> 			activate_page_nolock(page);

I agree that it is wrong, but it's really strange that it should make a
difference.

The only user of age_page_up_nolock() is refill_inactive_scan(), which
already scans the active list, so the main reason the above is wrong is
that it makes no sense any more (the page is already on the active list,
and it should be a no-op).

It does set the page->age to a minimum of PAGE_AGE_START, which is
probably the _real_ bug. That's definitely wrong. Especially as we're just
about to bump it anyway.

Removed. Which makes all the "age_page_up*()" functions go away entirely.
They were mostly gone already.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
