Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2B30D600044
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 01:05:37 -0400 (EDT)
Message-ID: <4C60DE0E.2000707@kernel.org>
Date: Tue, 10 Aug 2010 08:05:18 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] Use percpu buffers
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-5-git-send-email-ngupta@vflare.org> <AANLkTin7_fKxTzE2rngh1Ew5Ss8F_Aw0s9Gz6ySug6SX@mail.gmail.com> <4C60D9E6.3050700@vflare.org>
In-Reply-To: <4C60D9E6.3050700@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  Hi Nitin,

On 10.8.2010 7.47, Nitin Gupta wrote:
> On 08/10/2010 12:27 AM, Pekka Enberg wrote:
>> On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta<ngupta@vflare.org>  wrote:
>>> @@ -303,38 +307,41 @@ static int zram_write(struct zram *zram, struct bio *bio)
>>>                                 zram_test_flag(zram, index, ZRAM_ZERO))
>>>                         zram_free_page(zram, index);
>>>
>>> -               mutex_lock(&zram->lock);
>>> +               preempt_disable();
>>> +               zbuffer = __get_cpu_var(compress_buffer);
>>> +               zworkmem = __get_cpu_var(compress_workmem);
>>> +               if (unlikely(!zbuffer || !zworkmem)) {
>>> +                       preempt_enable();
>>> +                       goto out;
>>> +               }
>> The per-CPU buffer thing with this preempt_disable() trickery looks
>> overkill to me. Most block device drivers seem to use mempool_alloc()
>> for this sort of thing. Is there some reason you can't use that here?
>>
> Other block drivers are allocating relatively small structs using
> mempool_alloc(). However, in case of zram, these buffers are quite
> large (compress_workmem is 64K!). So, allocating them on every write
> would probably be much slower than using a pre-allocated per-cpu buffer.
The mempool API is precisely for that - using pre-allocated buffers 
instead of allocating every time. The preempt_disable() games make the 
code complex and have the downside of higher scheduling latencies so why 
not give mempools a try?

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
