Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7DDE60080E
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 03:36:40 -0400 (EDT)
Message-ID: <4C610184.7070909@kernel.org>
Date: Tue, 10 Aug 2010 10:36:36 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] Use percpu buffers
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-5-git-send-email-ngupta@vflare.org> <AANLkTin7_fKxTzE2rngh1Ew5Ss8F_Aw0s9Gz6ySug6SX@mail.gmail.com> <4C60D9E6.3050700@vflare.org> <4C60DE0E.2000707@kernel.org> <4C60E48A.5090608@vflare.org>
In-Reply-To: <4C60E48A.5090608@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org, jaxboe@fusionio.com
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On 8/10/10 8:32 AM, Nitin Gupta wrote:
> Other block drivers are allocating relatively small structs using
>>> mempool_alloc(). However, in case of zram, these buffers are quite
>>> large (compress_workmem is 64K!). So, allocating them on every write
>>> would probably be much slower than using a pre-allocated per-cpu buffer.
>>>        
>> The mempool API is precisely for that - using pre-allocated buffers instead of allocating every time. The preempt_disable() games make the code complex and have the downside of higher scheduling latencies so why not give mempools a try?
>>      
> mempool_alloc() first calls alloc_fn with ~(__GFP_WAIT | __GFP_IO)
> and *then* falls down to pre-allocated buffers. So, it will always
> be slower than directly using pre-allocated buffers as is done
> currently.
>
> One trick we can use is to have alloc_fn such that it always returns
> failure with ~__GFP_WAIT and do actual allocation otherwise. But still
> it seems like unnecessary cost.
>    
We can always extend the mempool API with mempool_prealloc() function if 
that turns out to be a problem. The per-CPU buffer with 
preempt_disable() trickery isn't really the proper thing to do here. It 
doesn't make much sense to disable preemption for compression that's 
purely CPU bound.

                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
