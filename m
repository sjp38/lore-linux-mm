Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A74BC6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:32:07 -0400 (EDT)
Message-ID: <4C91B9E9.4020701@ens-lyon.org>
Date: Thu, 16 Sep 2010 08:32:09 +0200
From: Brice Goglin <Brice.Goglin@ens-lyon.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach
References: <20100915104855.41de3ebf@lilo> <4C90A6C7.9050607@redhat.com> <20100916001232.0c496b02@lilo>
In-Reply-To: <20100916001232.0c496b02@lilo>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Le 15/09/2010 16:42, Christopher Yeoh a ecrit :
> On Wed, 15 Sep 2010 12:58:15 +0200
> Avi Kivity <avi@redhat.com> wrote:
>
>   
>>   On 09/15/2010 03:18 AM, Christopher Yeoh wrote:
>>     
>>> The basic idea behind cross memory attach is to allow MPI programs
>>> doing intra-node communication to do a single copy of the message
>>> rather than a double copy of the message via shared memory.
>>>       
>> If the host has a dma engine (many modern ones do) you can reduce
>> this to zero copies (at least, zero processor copies).
>>     
> Yes, this interface doesn't really support that. I've tried to keep
> things really simple here, but I see potential for increasing
> level/complexity of support with diminishing returns:
>
> 1. single copy (basically what the current implementation does)
> 2. support for async dma offload (rather arch specific)
> 3. ability to map part of another process's address space directly into
>    the current one. Would have setup/tear down overhead, but this would
>    be useful specifically for reduction operations where we don't even
>    need to really copy the data once at all, but use it directly in
>    arithmetic/logical operations on the receiver.
>
> For reference, there is also knem http://runtime.bordeaux.inria.fr/knem/
> which does implement (2) for I/OAT, though it looks to me the interface
> and implementation are relatively speaking quite a bit more complex.
>   

I am the guy doing KNEM so I can comment on this. The I/OAT part of KNEM
was mostly a research topic, it's mostly useless on current machines
since the memcpy performance is much larger than I/OAT DMA Engine. We
also have an offload model with a kernel thread, but it wasn't used a
lot so far. These features can be ignored for the current discussion.

We've been working on this for a while with MPICH and OpenMPI developers
(both already use KNEM), and here's what I think is missing in
Christopher's proposal:
* Vectorial buffer support: MPI likes things like datatypes, which make
buffers non-contigous. You could add vectorial buffer support to your
interface, but the users would have to store the data-representation of
each process in all processes. Not a good idea, it's easier to keep the
knowledge of the non-contigous-ness of the remote buffer only in the
remote process.
* Collectives: You don't want to pin/unpin the same region over and
over, it's overkill when multiple processes are reading for the same
exact buffer (broadcast) or from contigous parts of the same buffer
(scatter).

So what we do in KNEM is:
* declare a memory region (sets of non-contigous segments + protection),
aka get_user_pages and return an associated cookie id
* have syscalls to read/write from region given a cookie, an offset in
the region and a length
This one-sided interface looks like an InfiniBand model, but only for
intra-node data transfers.

So OpenMPI and MPICH declare regions, pass their cookies through their
shared-memory buffer, and the remote process reads from there. Then,
they notify the first process that it may destroy the region (can be
automatic if the region creator passed a specific flag saying destroy
after first use).

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
