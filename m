From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
Date: Mon, 09 Jul 2007 20:18:37 +1000
Message-ID: <46920B7D.5090100@yahoo.com.au>
References: <1183952874.3388.349.camel@localhost.localdomain>	 <1183962981.5961.3.camel@localhost.localdomain>	 <1183963544.5961.6.camel@localhost.localdomain>	 <4691E64F.5070506@yahoo.com.au>	 <1183972349.5961.25.camel@localhost.localdomain>	 <4691FFDC.5020808@yahoo.com.au> <1183974458.5961.42.camel@localhost.localdomain> <46920A0C.3040400@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755288AbXGIKSx@vger.kernel.org>
In-Reply-To: <46920A0C.3040400@yahoo.com.au>
Sender: linux-kernel-owner@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Nick Piggin wrote:
> Benjamin Herrenschmidt wrote:
> 
>> On Mon, 2007-07-09 at 19:29 +1000, Nick Piggin wrote:
>>
>>> They could just #define one to the other though, there are only a
>>> small
>>> number of them. Is there a downside to not making them distinct? i386
>>> for example probably would just keep doing a tlb flush for fork and
>>> not
>>> want to worry about touching the tlb gather stuff.
>>
>>
>>
>> But the tlb gather stuff just does ... a flush_tlb_mm() on x86 :-)
> 
> 
> But it still does the get_cpu of the mmu gather data structure and

To elaborate on this one... I realise for this one that in the kernel
where this is currently used everything is non-preemptible anyway
because of the ptl. And I also realise that -rt kernel issues don't
really have a bearing on mainline kernel.. but the generic
implementation of this API is fundamentally used to operate on a
per-cpu data structure that is only required when tearing down page
tables. That makes this necessarily non-preemptible.

Which shows that it adds more restrictions that may not otherwise be
required.


> has to look in there and touch the cacheline. You're also having to
> do more work when unlocking/relocking the ptl etc.
> 
> 
>> I really think it's the right API

OK, the *form* of the API is fine, I have no arguments. I just don't
know why you have to reuse the same thing. If you provided a new set of
names then you can trivially do a generic implementation which compiles
to exactly the same code for all architectures right now. That seems to
me like the right way to go...

-- 
SUSE Labs, Novell Inc.
