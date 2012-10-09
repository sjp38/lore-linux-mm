Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A7E806B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 16:02:34 -0400 (EDT)
Message-ID: <507482D7.909@tilera.com>
Date: Tue, 9 Oct 2012 16:02:31 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] sparc64: Eliminate PTE table memory wastage.
References: <20121002.182642.49574627747120711.davem@davemloft.net>	<87y5jmfbd3.fsf@linux.vnet.ibm.com> <20121004.142003.851528112593506369.davem@davemloft.net>
In-Reply-To: <20121004.142003.851528112593506369.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org

On 10/4/2012 2:23 PM, David Miller wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Date: Thu, 04 Oct 2012 22:00:48 +0530
> 
>> David Miller <davem@davemloft.net> writes:
>>
>>> We've split up the PTE tables so that they take up half a page instead
>>> of a full page.  This is in order to facilitate transparent huge page
>>> support, which works much better if our PMDs cover 4MB instead of 8MB.
>>>
>>> What we do is have a one-behind cache for PTE table allocations in the
>>> mm struct.
>>>
>>> This logic triggers only on allocations.  For example, we don't try to
>>> keep track of free'd up page table blocks in the style that the s390
>>> port does.
>>
>> I am also implementing a similar change for powerpc. We have a 64K page
>> size, and want to make sure PMD cover 16MB, which is the huge page size
>> supported by the hardware. I was looking at using the s390 logic,
>> considering we have 16 PMDs mapping to same PTE page. Should we look at
>> generalizing the case so that other architectures can start using the
>> same code ?
> 
> I think until we have multiple cases we won't know what's common or not.
> 
> Each arch has different need.  I need to split the page into two pieces
> so my code is simpler, and juse uses page counting to manage alloc/free.
> 
> Whereas s390 uses an bitmask to manage page state, and also reclaims
> pgtable pages into a per-mm list on free.  I decided not to do that
> and to just let the page allocator do the work.
> 
> So I don't think it's appropriate to think about commonization at this
> time, as even the only two cases existing are very non-common :-)

I'll add arch/tile to the list of architectures that would benefit.
We currently allocate PTEs using the page allocator, but by default
we use 64K pages and 16M huge pages, so with 8-byte PTEs that's
just 2K for the page table, so we could fit 32 of them on a page
if we wished.  Instead, for the time being, we just waste the space.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
