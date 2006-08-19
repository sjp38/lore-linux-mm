Message-ID: <44E69011.4080604@google.com>
Date: Fri, 18 Aug 2006 21:14:09 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: Network receive stall avoidance (was [PATCH 2/9] deadlock prevention
 core)
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins>	<20060813215853.0ed0e973.akpm@osdl.org>	<44E3E964.8010602@google.com>	<20060816225726.3622cab1.akpm@osdl.org>	<44E5015D.80606@google.com>	<20060817230556.7d16498e.akpm@osdl.org>	<44E62F7F.7010901@google.com>	<20060818153455.2a3f2bcb.akpm@osdl.org>	<44E650C1.80608@google.com> <20060818194435.25bacee0.akpm@osdl.org>
In-Reply-To: <20060818194435.25bacee0.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>handwaving
> 
> - The mmap(MAP_SHARED)-the-whole-world scenario should be fixed by
>   mm-tracking-shared-dirty-pages.patch.  Please test it and if you are
>   still able to demonstrate deadlocks, describe how, and why they
>   are occurring.

OK, but please see "atomic 0 order allocation failure" below.

> - We expect that the lots-of-dirty-anon-memory-over-swap-over-network
>   scenario might still cause deadlocks.  
> 
>   I assert that this can be solved by putting swap on local disks.  Peter
>   asserts that this isn't acceptable due to disk unreliability.  I point
>   out that local disk reliability can be increased via MD, all goes quiet.
> 
>   A good exposition which helps us to understand whether and why a
>   significant proportion of the target user base still wishes to do
>   swap-over-network would be useful.

I don't care much about swap-over-network, Peter does.  I care about
reliable remote disks in general, and reliable nbd in particular.

> - Assuming that exposition is convincing, I would ask that you determine
>   at what level of /proc/sys/vm/min_free_kbytes the swap-over-network
>   deadlock is no longer demonstrable.

Earlier, I wrote: "we need to actually fix the out of memory
deadlock/performance bug right now so that remote storage works
properly."  It is actually far more likely that memory reclaim stuffups
will cause TCP to drop block IO packets here and there than that we
will hit some endless retransmit deadlock.  But dropping packets and
thus causing TCP stalls during block writeout is a very bad thing too,
I do not think you could call a system that exhibits such behavior a
particularly reliable one.

So rather than just the word deadlock, let us add "or atomic 0 order
alloc failure during TCP receive" to the challenge.  Fair?

On the client send side, Peter already showed an easily reproducable
deadlock which we avoid by using elevator-noop.  The bug is still
there, it is just under a different rock now.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
