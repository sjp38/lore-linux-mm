Date: Sat, 28 Jul 2001 13:26:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072822131300.00315@starship>
Message-ID: <Pine.LNX.4.33.0107281309450.23117-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2001, Daniel Phillips wrote:
>
> Here is what I think is happening on a typical burst of small, non-page
> aligned reads:
>
>   - Page is read the 1st time: age = 2, inactive
>   - Page is read the second time: age = 5, active
>   - Two more reads immediately on the same page: age = 11

No.

We only mark the page referenced when we read it, we don't actually
increment the age.

The _aging_ is only done by the actual scanning routines.

At least that's how it should work. A quick grep for who does
"age_page_up()" shows that it is only done by refill_inactive_scan().
(page_launder() doesn't need to do it, because it already knows the age is
zero on the inactive list, so it just sets the age).

Maybe the problem is that use-once works on accesses, not on ages?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
