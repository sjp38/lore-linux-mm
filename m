Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Date: Sun, 28 Oct 2001 18:22:00 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.33.0110280945150.7360-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 28, 2001 09:59:14 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15xuZM-0008W5-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> In contrast, the -ac logic says roughly "Who the hell cares if the driver
> can merge requests or not, we can just give it thousands of small requests
> instead, and cap the total number of _sectors_ instead of capping the
> total number of requests earlier"

If you think about it the major resource constraint is sectors - or another
way to think of it "number of pinned pages the VM cannot rescue until the
I/O is done". We also have many devices where the latency is horribly
important - IDE is one because it lacks sensible overlapping I/O. I'm less
sure what the latency trade offs are. Less commands means less turnarounds
so there is counterbalance.

In the case of IDE the -ac tree will do basically the same merging - the
limitations on IDE DMA are pretty reasonable. DMA IDE has scatter gather
tables and is actually smarter than many older scsi controllers. The IDE
layer supports up to 128 chunks of up to just under 64Kb (should be 64K
but some chipsets get 64K = 0 wrong and its not pretty)

> In my opinion, the -ac logic is really bad, but one thing it does allow is
> for stupid drivers that look like high-performance drivers. Which may be
> why it got implemented.

Well I'm all for making dumb hardware go as fast as smart stuff but that
wasn't the original goal - the original goal was to fix the bad behaviour
with the base kernel and large I/O queues to slow devices like M/O disks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
