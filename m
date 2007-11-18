Date: Sun, 18 Nov 2007 13:09:33 -0500
From: Robin Humble <rjh@cita.utoronto.ca>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Message-ID: <20071118180933.GA17103@lemming.cita.utoronto.ca>
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au> <1193830033.27652.159.camel@twins> <47287220.8050804@garzik.org> <1193835413.27652.205.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1193835413.27652.205.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jeff Garzik <jeff@garzik.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

<apologies for being insanely late into this thread>

On Wed, Oct 31, 2007 at 01:56:53PM +0100, Peter Zijlstra wrote:
>On Wed, 2007-10-31 at 08:16 -0400, Jeff Garzik wrote:
>> Thoughts:
>> 1) I absolutely agree that NFS is far more prominent and useful than any 
>> network block device, at the present time.
>> 
>> 2) Nonetheless, swap over NFS is a pretty rare case.  I view this work 
>> as interesting, but I really don't see a huge need, for swapping over 
>> NBD or swapping over NFS.  I tend to think swapping to a remote resource 
>> starts to approach "migration" rather than merely swapping.  Yes, we can 
>> do it...  but given the lack of burning need one must examine the price.
>
>There is a large corporate demand for this, which is why I'm doing this.
>
>The typical usage scenarios are:
> - cluster/blades, where having local disks is a cost issue (maintenance
>   of failures, heat, etc)

HPC clusters are increasingly diskless, especially at the high end.
for all the reasons you mention, but also because networks are faster
than disks.

>But please, people who want this (I'm sure some of you are reading) do
>speak up. I'm just the motivated corporate drone implementing the
>feature :-)

swap to iSCSI has worked well in the past with your anti-deadlock
patches, and I'd definitely like to see that continue and to be merged
into mainline!! swap-to-network is a highly desirable feature for
modern clusters.

performance and scalability of NFS is poor, so it's not a good option.

actually swap to a file on Lustre(*) would be best, but iSER and iSCSI
would be my next choices. iSER is better than iSCSI as it's ~5x faster
in practice, and InfiniBand seems to be here to stay.

hmmm - any idea what the issues are with RDMA in low memory situations?
presumably if DMA regions are mapped early then there's not actually
much of a problem? I might try it with tgtd's iSER...

cheers,
robin

(*) obviously not your responsibility. although Lustre (Sun/CFS) could
presumably use your infrastructure once you have it in mainline.


>> 3) You note
>> > Swap over network has the problem that the network subsystem does not use fixed
>> > sized allocations, but heavily relies on kmalloc(). This makes mempools
>> > unusable.
>> 
>> True, but IMO there are mitigating factors that should be researched and 
>> taken into account:
>> 
>> a) To give you some net driver background/history, most mainstream net 
>> drivers were coded to allocate RX skbs of size 1538, under the theory 
>> that they would all be allocating out of the same underlying slab cache. 
>>   It would not be difficult to update a great many of the [non-jumbo] 
>> cases to create a fixed size allocation pattern.
>
>One issue that comes to mind is how to ensure we'd still overflow the
>IP-reassembly buffers. Currently those are managed on the number of
>bytes present, not the number of fragments.
>
>One of the goals of my approach was to not rewrite the network subsystem
>to accomodate this feature (and I hope I succeeded).
>
>> b) Spare-time experiments and anecdotal evidence points to RX and TX skb 
>> recycling as a potentially valuable area of research.  If you are able 
>> to do something like that, then memory suddenly becomes a lot more 
>> bounded and predictable.
>> 
>> 
>> So my gut feeling is that taking a hard look at how net drivers function 
>> in the field should give you a lot of good ideas that approach the 
>> shared goal of making network memory allocations more predictable and 
>> bounded.
>
>Note that being bounded only comes from dropping most packets before
>trying them to a socket. That is the crucial part of the RX path, to
>receive all packets from the NIC (regardless their size) but to not pass
>them on to the network stack - unless they belong to a 'special' socket
>that promises undelayed processing.
>
>Thanks for these ideas, I'll look into them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
