Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C883600044
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 00:47:10 -0400 (EDT)
Received: by gwj16 with SMTP id 16so4747811gwj.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 21:47:09 -0700 (PDT)
Message-ID: <4C60D9E6.3050700@vflare.org>
Date: Tue, 10 Aug 2010 10:17:34 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] Use percpu buffers
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-5-git-send-email-ngupta@vflare.org> <AANLkTin7_fKxTzE2rngh1Ew5Ss8F_Aw0s9Gz6ySug6SX@mail.gmail.com>
In-Reply-To: <AANLkTin7_fKxTzE2rngh1Ew5Ss8F_Aw0s9Gz6ySug6SX@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/10/2010 12:27 AM, Pekka Enberg wrote:
> On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>> @@ -303,38 +307,41 @@ static int zram_write(struct zram *zram, struct bio *bio)
>>                                zram_test_flag(zram, index, ZRAM_ZERO))
>>                        zram_free_page(zram, index);
>>
>> -               mutex_lock(&zram->lock);
>> +               preempt_disable();
>> +               zbuffer = __get_cpu_var(compress_buffer);
>> +               zworkmem = __get_cpu_var(compress_workmem);
>> +               if (unlikely(!zbuffer || !zworkmem)) {
>> +                       preempt_enable();
>> +                       goto out;
>> +               }
> 
> The per-CPU buffer thing with this preempt_disable() trickery looks
> overkill to me. Most block device drivers seem to use mempool_alloc()
> for this sort of thing. Is there some reason you can't use that here?
> 

Other block drivers are allocating relatively small structs using
mempool_alloc(). However, in case of zram, these buffers are quite
large (compress_workmem is 64K!). So, allocating them on every write
would probably be much slower than using a pre-allocated per-cpu buffer.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
