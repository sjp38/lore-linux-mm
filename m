Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sat, 28 Jul 2001 03:11:16 +0200
References: <200107272112.f6RLC3d28206@maila.telia.com> <0107280034050V.00285@starship> <200107272347.f6RNlTs15460@maild.telia.com>
In-Reply-To: <200107272347.f6RNlTs15460@maild.telia.com>
MIME-Version: 1.0
Message-Id: <0107280311160X.00285@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@skelleftea.mail.telia.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 28 July 2001 01:43, Roger Larsson wrote:
> Hi again,
>
> It might be variations in dbench - but I am not sure since I run
> the same script each time.
>
> (When I made a testrun in a terminal window - with X running, but not
> doing anything activly, I got
> [some '.' deleted]
> .............++++++++++++++++++++++++++++++++************************
>******** Throughput 15.8859 MB/sec (NB=19.8573 MB/sec  158.859
> MBit/sec) 14.74user 22.92system 4:26.91elapsed 14%CPU
> (0avgtext+0avgdata 0maxresident)k 0inputs+0outputs
> (912major+1430minor)pagefaults 0swaps
>
> I have never seen anyting like this - all '+' together!
>
> I logged off and tried again - got more normal values 32 MB/s
> and '+' were spread out.
>
> More testing needed...

Truly wild, truly crazy.  OK, this is getting interesting.  I'll go 
read the dbench source now, I really want to understand how the IO and 
thread sheduling are interrelated.  I'm not even going to try to 
advance a theory just yet ;-)

I'd mentioned that dbench seems to run fastest when threads run and 
complete all at different times instead of all together.  It's easy to 
see why this might be so: if the sum of all working sets is bigger than 
memory then the system will thrash and do its work much more slowly.  
If the threads *can* all run independently (which I think is true of 
dbench because it simulates SMB accesses from a number of unrelated 
sources) then the optimal strategy is to suspend enough processes so 
that all the working sets do fit in memory.  Linux has no mechanism for 
detecting or responding to such situations (whereas FreeBSD - our 
arch-rival in the mm sweepstakes - does) so we sometimes see what are 
essentially random variations in scheduling causing very measurable 
differences in throughput.  (The "butterfly effect" where the beating 
wings of a butterfly in Alberta set in motion a chain of events that 
culminates with a hurricane in Florida.)

I am not saying this is the effect we're seeing here (the working set 
effect, not the butterfly:-) but it is something to keep in mind when 
investigating this.  There is such a thing as being too fair, and maybe 
that's what we're running into here.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
