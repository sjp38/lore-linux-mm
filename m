Date: Wed, 14 Jun 2000 19:14:40 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006141235460.6887-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006141858500.15011-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Rik van Riel wrote:

>On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
>> On Wed, 14 Jun 2000, Rik van Riel wrote:
>> 
>> >So if the ZONE_DMA is filled by mlock()ed memory, classzone
>> >will *not* try to balance it? Will classzone *only* try to
>> 
>> It will try but it won't succeed.
>> 
>> >balance the big classzone containing zone_dma, and not the
>> >dma zone itself?  (since the dma zone doesn't contain any
>> 
>> No, I definitely try to balance the DMA zone itself. But in such
>> case (all DMA zone mlocked) kswapd will just spend CPU trying to
>> balance the zone but it _can't_ succeed because mlocked just
>> means we can't even attempt to move such memory elsewhere in the
>> physical space or we'll break userspace critical latency needs.
>
>I fully agree with this, this is the obviously right thing to

Ok. [1]

>do. Would you be surprised to know that the code in the last
>2.4.0-ac kernels does exactly this?

I'm not surprised. I know what the current code does and infact I didn't
took that case as the testcase. That was _your_ testcase that you invented
changing the text of the problem in something that is handled correctly by
the current code and I'm not interested about it (as far as the kernel
continues to handle it correctly as now ;).

_My_ testcase (first mlocked and then cache) is instead handled wrong by
the latest kernels and that's the only thing I'm interested about at this
moment.

>(with the exception of the two implementation bugs which can
>cause kswapd and shrink_mmap to loop)

Indeed, I don't mind about that issue at the moment.

>> >A few mails back you wrote that the classzone patch would
>> >do just about the same if a _classzone_ fills up. (except
>> 
>> What you mean with "just about the same"? You mean spending CPU
>> in kswapd trying to release some memory? If so yes. When a
>> classzone fills up kswapd will spend cpu trying to free some
>> memory so that the next GFP_DMA/GFP_KERNEL/GFP_HIGHUSER
>> allocation (depending on the classzone that is low on memory)
>> will succeed.
>
>So classzone and the normal zoned VM behave in the same way here
>except that classzone doesn't show the bad effects when the
>allocations happen in a certain lucky order.
>
>I think the differences between classzone and the zoned vm are
>pretty small at this moment, with most of classzone's benefits
>being theoretical ones that rely on memory zones being inclusive
>rather than numa-like...

You got it. Exactly.

However don't mix numa with the internal of a node. We have the pgdat and
each one is a node in a NUMA system. All the zones internal to a pgdat
have to belong to the some node or it will become impossible to shrink
cache only from one zone and to do smart decisions in NUMA systems.

>> >that the different shrink_mmap() causes it to go to sleep
>> >before being woken up again at the next allocation)
>> 
>> In classzone shrink_mmap doesn't control in any way how kswapd
>> will react to low memory conditions. Only the level of memory of
>> the classzones are controlling kswapd. If classzone is low on
>> memory kswapd will keep to try to shrink it.
>
>Owww, so classzone kswapd will get into an infinite loop with
>the disaster scenario too?

Yes. If I understood well from the first line of your email you agree
that's the right behaviour (see [1]). Since in the disaster scenario the
ZONE_DMA classzone is low on memory kswapd will continue to spend CPU to
try to free some page there.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
