Message-ID: <3B6DE4AE.9A06D23F@zip.com.au>
Date: Sun, 05 Aug 2001 17:28:30 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Accelerate dbench
References: <Pine.LNX.4.33L.0108042101341.2526-100000@imladris.rielhome.conectiva>,
		<Pine.LNX.4.33L.0108042101341.2526-100000@imladris.rielhome.conectiva> <01080504334100.00294@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> How wrong could it be when it's turning in results like this:
> 
>   dbench 12, 2.4.8-pre4 vanilla
>   12.76user 76.49system 6:20.56elapsed 23%CPU (0avgtext+0avgdata 0maxresident)k
>   0inputs+0outputs (426major+405minor)pagefaults 0swaps

Oi!  Didn't Andrew say not to optimise for dbench?

We've had some interesting times with ext3 and dbench lately.
It all boils down to the fact that dbench deletes its own
working files inside the kupdate writeback interval.

This means that:

a) If dbench is running fast enough to delete its file within
   the writeback interval, it'll run even faster because it
   does less IO!  Non-linear behaviour there.

b) If a butterfly flaps its wing, and something triggers
   bdflush then your dbench throughput is demolished, because
   data which ordinarily is deleted before ever getting written
   out ends up hitting disk.

   It was discovered that with one particular workload ext2
   was not triggering bdflush but ext3 was.   Twiddling the
   bdflush nfract and nfract_sync parameters prevented this
   and our throughput went from something unmentionable up
   to 85% of ext2.  (actually, it was a teeny bit faster with
   80 clients - dunno why).

All this was with ext3 in data writeback mode, of course - the
other journalling modes write data out within 5 seconds anyway,
which is another reason why ext3 dbench numbers are unrepresentatively
lower than ext2 - we do about four times as much I/O!

So...  This artifact makes *gross* throughput differences, and
if your VM changes are somehow causing changed flush behaviour
then perhaps you won't see what you're looking for.

And note the positive feedback cycle: a slower dbench run will
result in more IO, which will result in a slower dbench run, 
which will....

For VM/fs tuning efforts I'd recommend that you consider hacking
dbench to not delete its files - just rename them or something.

(Not blaming dbench here - it is merely emulating netbench dopiness).

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
