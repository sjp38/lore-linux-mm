Message-ID: <45B6DA8B.7060004@yahoo.com.au>
Date: Wed, 24 Jan 2007 15:03:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>	 <45B6CBD9.80600@yahoo.com.au>	 <Pine.LNX.4.64.0701231908420.6123@schroedinger.engr.sgi.com> <6d6a94c50701231951o66487813vcd078fc25e25ffa0@mail.gmail.com>
In-Reply-To: <6d6a94c50701231951o66487813vcd078fc25e25ffa0@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

Aubrey Li wrote:
> On 1/24/07, Christoph Lameter <clameter@sgi.com> wrote:
> 
>> On Wed, 24 Jan 2007, Nick Piggin wrote:
>>
>> > > 1. Insure that anonymous pages that may contain performance
>> > >    critical data is never subject to swap.
>> > >
>> > > 2. Insure rapid turnaround of pages in the cache.
>> >
>> > So if these two aren't working properly at 100%, then I want to know 
>> the
>> > reason why. Or at least see what the workload and the numbers look 
>> like.
>>
>> The reason for the anonymous page may be because data is rarely touched
>> but for some reason the pages must stay in memory. Rapid turnaround is
>> just one of the reason that I vaguely recall but I never really
>> understood what the purpose was.
>>
>> > > 3. Reserve memory for other uses? (Aubrey?)
>> >
>> > Maybe. This is still a bad hack, and I don't like to legitimise such 
>> use
>> > though. I hope Aubrey isn't relying on this alone for his device to 
>> work
>> > because his customers might end up hitting fragmentation problems 
>> sooner
>> > or later.
>>
>> I surely wish that Aubrey would give us some more clarity on
>> how this should work. Maybe the others who want this feature could also
>> speak up? I am not that clear on its purpose.
>>
> Sorry for the delay. Somehow this thread was put into the spam folder
> of my gmail box. :(
> The patch I posted several days ago works properly on my side. I'm
> working on blackfin-uclinux platform. So I'm not sure it works 100% on
> the other arch platform. From O_DIRECT threads, I know different
> people suffer from VFS pagecache issue for different reason. So I
> really hope the patch can be improved.

So we need to work out what those issues are and fix them.

> On my side, When VFS pagecache eat up all of the available memory,
> applications who want to allocate the largeish block(order =4 ?) will
> fail. So the logic is as follows:

Yeah, it will be failing at order=4, because the allocator won't try
very hard reclaim pagecache pages at that cutoff point. This needs to
be fixed in the allocator.

>> I hope Aubrey isn't relying on this alone for his device to work
>> because his customers might end up hitting fragmentation problems sooner
>> or later.
> 
> 
> That's true. I wrote a replacement of buddy system, it's here:
> http://lkml.org/lkml/2006/12/30/36.
> 
> That can improve the fragmentation problems on our platform.

That might be a good idea, but while the buddy system may not seem as
efficient and wastes space, it is actually really good for fragmentation.

Anyway, point being that you can't eliminate fragmentation, so you need
to cope with allocation failures or implement reserve pools if you want a
robust system.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
