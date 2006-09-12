Message-ID: <4506F2B9.5020600@google.com>
Date: Tue, 12 Sep 2006 10:47:37 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com> <20060912133457.GC10689@sgi.com> <Pine.LNX.4.64.0609121032310.11278@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609121032310.11278@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Resending. Your outbound email address is invalid
(Christoph Lameter <christoph@engr.sgi.com>), as is
the address for linux-mm


Christoph Lameter wrote:
> On Tue, 12 Sep 2006, Jack Steiner wrote:
> 
> 
>>I'm missing something here. On Altix, currently ALL of the memory is reported
>>as being in the DMA zone:
>>
>>	% cat /proc/budd*
>>	Node 0, zone      DMA   3015    116      4      1    ...
>>	Node 1, zone      DMA   4243    355     15      3    ...
>>	Node 2, zone      DMA   4384    113      6      4    ...
>>
>>	% cat /proc/zoneinfo
>>	Node 0, zone      DMA
>>	  pages free     5868
>>	  ...
>>
>>The DMA slabs are empty, though.
> 
> 
> This is wrong. All memory should be in ZONE_NORMAL since we have no DMA 
> restrictions on Altix.

PPC64 works the same way, I believe. All memory is DMA'able, therefore
it all fits in ZONE_DMA.

The real problem is that there's no consistent definition of what the
zones actually mean.

1. Is it DMA'able (this is stupid, as it doesn't say 'for what device'
2. Is it permanently mapped into kernel address space.

Given an inconsistent set of questions, it is unsuprising that we come
up with an inconsistent set of answers. We're trying to answer a 2D
question with a 1D answer.

What is really needed is to pass a physical address limit from the
caller, together with a flag that says whether the memory needs to be
mapped into the permanent kernel address space or not. The allocator
then finds the set of zones that will fulfill this criteria.
But I suspect this level of change will cause too many people to squeak
loudly.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
