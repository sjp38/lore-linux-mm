Message-ID: <410858FE.3090007@yahoo.com.au>
Date: Thu, 29 Jul 2004 11:55:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] perzone slab LRUs
References: <410789EB.1060209@yahoo.com.au> <41078A3D.6040103@yahoo.com.au> <34870000.1091025443@[10.10.2.4]>
In-Reply-To: <34870000.1091025443@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>>Oops, forgot to CC linux-mm.
>>
>>Nick Piggin wrote:
>>
>>>This patch is only intended for comments.
>>>
>>>This implements (crappy?) infrastructure for per-zone slab LRUs for
>>>reclaimable slabs, and moves dcache.c over to use that.
>>>
>>>The global unused list is retained to reduce intrusiveness, and another
>>>per-zone LRU list is added (which are still protected with the global 
>>>dcache
>>>lock). This is an attempt to make slab scanning more robust on highmem and
>>>NUMA systems.
>>>
>
>Do we have slab that goes in highmem anywhere? I thought not .... 64 bit
>NUMA makes a lot of sense though.
>
>

I don't think so, but it still (I think) allows a general slab pressure 
forumula
for highmem and muliple ZONE_NORMAL NUMA that doesn't blow up like our 
current
one can.

The per-zone lists I'd say would have to help somewhat on the 
performance side of
things as far as not taking remote cache misses during scanning. It 
should also
mean that a low memory node will not globally shrink masses of slab from 
nodes that
have plenty of memory.

As far as the dependant inodes problem goes - it could be a significant 
problem,
and I think would need to be solved before perzone slab LRUs are a 
viable option.
The most simplistic way I can see to solve it is: if we scan an inode 
that is pinned
by dentries, scan its pinning dentries instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
