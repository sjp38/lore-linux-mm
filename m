Message-Id: <l0313030db743d4a05018@[192.168.239.105]>
In-Reply-To: <3B1E203C.5DC20103@uow.edu.au>
References: <l03130308b7439bb9f187@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 6 Jun 2001 13:50:53 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Interesting observation.  Something else though, which kswapd is guilty of
>> as well: consider a page shared among many processes, eg. part of a
>> library.  As kswapd scans, the page is aged down for each process that uses
>> it.  So glibc gets aged down many times more quickly than a non-shared
>> page, precisely the opposite of what we really want to happen.
>
>Perhaps the page should be aged down by (1 / page->count)?
>
>Just scale all the age stuff by 256 or 1000 or whatever and
>instead of saying
>
>	page->age -= CONSTANT;
>
>you can use
>
>	page->age -= (CONSTANT * 256) / atomic_read(page->count);
>
>
>So the more users, the more slowly it ages.  You get the idea.

However big you make that scaling constant, you'll always find some pages
which have more users than that.  Consider a shell server, and pages
belonging to glibc.  Once the number of users gets that large, the age will
go down by exactly zero, even if it just happens that the page is truly not
in use.

BUT, as it turns out, refill_inactive_scan() already does ageing down on a
page-by-page basis, rather than process-by-process.  So I can indeed take
out my little decrement in try_to_swap_out() and just leave the
bail-out-if-age-wasn't-zero code.  The age-up code stays - it's good to
catch accesses as frequently as possible.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
