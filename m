Date: Thu, 10 Jan 2008 08:50:27 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
Message-ID: <20080110145027.GA4431@sgi.com>
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <20080110131612.GA1933@sgi.com> <47861D3C.6070709@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47861D3C.6070709@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 10, 2008 at 03:27:24PM +0200, Avi Kivity wrote:
> Robin Holt wrote:
>>
>>> The patch does enable some nifty things; one example you may be familiar 
>>> with is using page migration to move a guest from one numa node to 
>>> another.
>>>     
>>
>> xpmem allows one MPI rank to "export" his address space, a different
>> MPI rank to "import" that address space, and they share the same pages.
>> This allows sharing of things like stack and heap space.  XPMEM also
>> provides a mechanism to share that PFN information across partition
>> boundaries so the pages become available on a different host.  This,
>> of course, is dependent upon hardware that supports direct access to
>> the memory by the processor.
>>
>>   
>
> So this is yet another instance of hardware that has a tlb that needs to be 
> kept in sync with the page tables, yes?

Yep, the external TLBs happen to be cpus in a different OS instance,
but you get the idea.

> Excellent, the more users the patch has, the easier it will be to justify 
> it.

I think we have another hardware device driver that will use it first.
It is sort of a hardware coprocessor that is available from user space
to do operations against a processes address space.  That driver will
probably be first out the door.

Looking at the mmu_notifiers patch, there are locks held which will
preclude the use of invalidate_page for xpmem.  In that circumstance,
the clearing operation will need to be messaged to the other OS instance
and that will certainly involving putting the current task to sleep.

We will work on that detail later.  First, we will focus on getting the
other driver submitted to the community.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
