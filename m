Date: Wed, 31 Jul 2002 13:59:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: throttling dirtiers
Message-ID: <20020731205943.GK29537@holomorphy.com>
References: <3D479F21.F08C406C@zip.com.au> <20020731200612.GJ29537@holomorphy.com> <20020731162357.Q10270@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020731162357.Q10270@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2002 at 01:06:12PM -0700, William Lee Irwin III wrote:
>> I'm not a fan of this kind of global decision. For example, I/O devices
>> may be fast enough and memory small enough to dump all memory in < 1s,
>> in which case dirtying most or all of memory is okay from a latency
>> standpoint, or it may take hours to finish dumping out 40% of memory,
>> in which case it should be far more eager about writeback.

On Wed, Jul 31, 2002 at 04:23:57PM -0400, Benjamin LaHaise wrote:
> Why?  Filling the entire ram with dirty pages is okay, and in fact you 
> want to support that behaviour for apps that "just fit" (think big 
> scientific apps).  The only interesting point is that when you hit the 
> limit of available memory, the system needs to block on *any* io 
> completing and resulting in clean memory (which is reasonably low 
> latency), not a specific io which may have very high latency.

I had more in mind the case of streaming I/O, not things that "just fit".
IIRC scientific apps mmap and have to have their I/O handled by
background scanning (or trapping writes), and should end up in the
situation you describe because no one has any idea when to throttle them
anyway. If I/O requests are allowed to proceed without blocking and/or
failing at a greater rate than devices can process them, eventually
one's forced to shove data down the device's throat at a greater rate
than it can handle, and you just end up with a backlog of dirty memory
that can't be written out because the rest of memory is dirtied just as
quickly as it's cleaned that could be used elsewhere. That is, if you
can't keep up with dirtiers, you're never going to make forward progress
cleaning, and everything will block/fail anyway when it gets to the end
of the memory supply.  And background VM writeback should also be aware
of the rate at which it should submit I/O as the most visible symptom is
kswapd itself generating excessive arrival rates to the I/O queues.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
