Date: Sun, 13 Jan 2008 06:09:39 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
Message-ID: <20080113120939.GA3221@sgi.com>
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com> <47891A5C.8060907@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47891A5C.8060907@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 12, 2008 at 09:51:56PM +0200, Avi Kivity wrote:
> Christoph Lameter wrote:
>> On Thu, 10 Jan 2008, Avi Kivity wrote:
>>
>>   
>>> Actually sharing memory is possible even without this patch; one simply
>>> mmap()s a file into the address space of both guests.  Or are you 
>>> referring to
>>> something else?
>>>     
>>
>> A file from where? If a file is read by two guests then they will have 
>> distinct page structs.
>>
>>   
>
> Two kvm instances mmap() the file (from anywhere) into the guest address 
> space.  That memory is shared, and will be backed by the same page structs 
> at the same offset.

That sounds nice, but...

For larger machine configurations, we have different memory access
capabilities.  When a partition that is located close to the home node
of the memory accesses memory, it is normal access.  When it is further
away, they get special access to the line.  Before the shared line is
sent to the reading node, it is converted by the memory controller into
an exclusive request and the reading node is handed the only copy of
the line.  If we gave a remote kernel access to the page, we would also
open the entire owning nodes page tables up to speculative references
which effectively would be viewed by hardware as cache-line contention.

Additionally, we have needs beyond memory backed by files.  Including
special devices which do not have struct pages at all (see mspec.c).

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
