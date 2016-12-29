Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 187F86B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:12:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so574170529pfb.6
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 18:12:31 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id u85si23799763pgb.137.2016.12.28.18.12.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 18:12:30 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from epcas1p4.samsung.com (unknown [182.195.41.48])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OIX01XF9CSSPM30@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 29 Dec 2016 11:12:28 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <58647136.8050403@samsung.com>
Date: Thu, 29 Dec 2016 11:13:10 +0900
In-reply-to: <xa1tk2ak6t01.fsf@mina86.com>
References: 
 <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
 <20161227100535.GB7662@dhcp22.suse.cz> <58634274.5060205@samsung.com>
 <xa1tk2ak6t01.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello Mical Hocko and Michal Nazarewicz

Thank you for your comment.
I agree with you on that the new bitmap API may not be used widely yet.
Let me give up the bitmap API and resend another patch regarding CMA allocation failure.

Thank you.

On 2016e?? 12i?? 28i? 1/4  23:14, Michal Nazarewicz wrote:
> On Wed, Dec 28 2016, Jaewon Kim wrote:
>> I did not add caller in this patch.
>> I am using the patch in cma_alloc function like below to show
>> available page status.
>>
>> +               printk("number of available pages: ");
>> +               start = 0;
>> +               for (;;) {
>> +                       bitmap_no = bitmap_find_next_zero_area_and_size(cma->bitmap,
>> +                                               cma->count, start, &nr);
>> +                       if (bitmap_no >= cma->count)
>> +                               break;
>> +                       if (nr_total == 0)
>> +                               printk("%u", nr);
>> +                       else
>> +                               printk("+%u", nr);
>> +                       nr_total += nr;
>> +                       start = bitmap_no + nr;
>> +               }
>> +               printk("=>%u pages, total: %lu pages\n", nr_total, cma->count);
> I would be happier should you find other existing places where this
> function can be used.  With just one caller, Ia??m not convinced it is
> worth it.
>
>>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> The code itself is good, so
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>
> and Ia??ll leave deciding whether it improves the kernel overall to
> maintainers. ;)
>
>>>> ---
>>>>  include/linux/bitmap.h |  6 ++++++
>>>>  lib/bitmap.c           | 25 +++++++++++++++++++++++++
>>>>  2 files changed, 31 insertions(+)
>>>>
>>>> diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
>>>> index 3b77588..b724a6c 100644
>>>> --- a/include/linux/bitmap.h
>>>> +++ b/include/linux/bitmap.h
>>>> @@ -46,6 +46,7 @@
>>>>   * bitmap_clear(dst, pos, nbits)		Clear specified bit area
>>>>   * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
>>>>   * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
>>>> + * bitmap_find_next_zero_area_and_size(buf, len, pos, n, mask)	Find bit free area and its size
>>>>   * bitmap_shift_right(dst, src, n, nbits)	*dst = *src >> n
>>>>   * bitmap_shift_left(dst, src, n, nbits)	*dst = *src << n
>>>>   * bitmap_remap(dst, src, old, new, nbits)	*dst = map(old, new)(src)
>>>> @@ -123,6 +124,11 @@ extern unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
>>>>  						    unsigned long align_mask,
>>>>  						    unsigned long align_offset);
>>>>  
>>>> +extern unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
>>>> +							 unsigned long size,
>>>> +							 unsigned long start,
>>>> +							 unsigned int *nr);
>>>> +
>>>>  /**
>>>>   * bitmap_find_next_zero_area - find a contiguous aligned zero area
>>>>   * @map: The address to base the search on
>>>> diff --git a/lib/bitmap.c b/lib/bitmap.c
>>>> index 0b66f0e..d02817c 100644
>>>> --- a/lib/bitmap.c
>>>> +++ b/lib/bitmap.c
>>>> @@ -332,6 +332,31 @@ unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
>>>>  }
>>>>  EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
>>>>  
>>>> +/**
>>>> + * bitmap_find_next_zero_area_and_size - find a contiguous aligned zero area
>>>> + * @map: The address to base the search on
>>>> + * @size: The bitmap size in bits
>>>> + * @start: The bitnumber to start searching at
>>>> + * @nr: The number of zeroed bits we've found
>>>> + */
>>>> +unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
>>>> +					     unsigned long size,
>>>> +					     unsigned long start,
>>>> +					     unsigned int *nr)
>>>> +{
>>>> +	unsigned long index, i;
>>>> +
>>>> +	*nr = 0;
>>>> +	index = find_next_zero_bit(map, size, start);
>>>> +
>>>> +	if (index >= size)
>>>> +		return index;
> I would remove this check.  find_next_bit handles situation when index
> == size and without this early return, *nr is always set.
>
>>>> +	i = find_next_bit(map, size, index);
>>>> +	*nr = i - index;
>>>> +	return index;
>>>> +}
>>>> +EXPORT_SYMBOL(bitmap_find_next_zero_area_and_size);
>>>> +
>>>>  /*
>>>>   * Bitmap printing & parsing functions: first version by Nadia Yvette Chambers,
>>>>   * second version by Paul Jackson, third by Joe Korty.
>>>> -- 
>>>> 1.9.1
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
