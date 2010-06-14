Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E94AA6B01EC
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:35:46 -0400 (EDT)
Message-ID: <4C164C22.1050503@redhat.com>
Date: Mon, 14 Jun 2010 18:34:58 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>	 <1276214852.6437.1427.camel@nimitz>	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>	 <20100614084810.GT5191@balbir.in.ibm.com> <1276528376.6437.7176.camel@nimitz>
In-Reply-To: <1276528376.6437.7176.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/14/2010 06:12 PM, Dave Hansen wrote:
> On Mon, 2010-06-14 at 14:18 +0530, Balbir Singh wrote:
>    
>> 1. A slab page will not be freed until the entire page is free (all
>> slabs have been kfree'd so to speak). Normal reclaim will definitely
>> free this page, but a lot of it depends on how frequently we are
>> scanning the LRU list and when this page got added.
>>      
> You don't have to be freeing entire slab pages for the reclaim to have
> been useful.  You could just be making space so that _future_
> allocations fill in the slab holes you just created.  You may not be
> freeing pages, but you're reducing future system pressure.
>    

Depends.  If you've evicted something that will be referenced soon, 
you're increasing system pressure.

> If unmapped page cache is the easiest thing to evict, then it should be
> the first thing that goes when a balloon request comes in, which is the
> case this patch is trying to handle.  If it isn't the easiest thing to
> evict, then we _shouldn't_ evict it.
>    

Easy to evict is just one measure.  There's benefit (size of data 
evicted), cost to refill (seeks, cpu), and likelihood that the cost to 
refill will be incurred (recency).

It's all very complicated.  We need better information to make these 
decisions.  For one thing, I'd like to see age information tied to 
objects.  We may have two pages that were referenced in wildly different 
times be next to each other in LRU order.  We have many LRUs, but no 
idea of the relative recency of the tails of those LRUs.

If each page or object had an age, we could scale those ages by the 
benefit from reclaim and cost to refill and make a better decision as to 
what to evict first.  But of course page->age means increasing sizeof 
struct page, and we can only approximate its value by scanning the 
accessed bit, not determine it accurately (unlike the other objects 
managed by the cache).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
