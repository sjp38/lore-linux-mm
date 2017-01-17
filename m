Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB886B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:21:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t6so89267733pgt.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:21:51 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id 21si15883312pga.271.2017.01.16.19.21.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 19:21:49 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcas1p2.samsung.com (unknown [182.195.41.46])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OJW01SLNMO7E150@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 17 Jan 2017 12:21:43 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <587D8DE5.6040408@samsung.com>
Date: Tue, 17 Jan 2017 12:22:13 +0900
In-reply-to: <20170115071726.GB6474@yury-N73SV>
References: 
 <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
 <20170115071726.GB6474@yury-N73SV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2017e?? 01i?? 15i? 1/4  16:17, Yury Norov wrote:
> Hi Jaewon,
>
> with all comments above, some of my concerns.
>
> On Mon, Dec 26, 2016 at 01:18:11PM +0900, Jaewon Kim wrote:
>> There was no bitmap API which returns both next zero index and size of zeros
>> from that index.
> Yes, there is. Most probably because this function is not needed.
> Typical usecase is looking for the area of N free bits, were caller
> knows N, and doesn't care of free areas smaller than N. There is 
> bitmap_find_next_zero_area() for exactly that.
Hi Yuri
Thank you for comment.
I did not mean finding free area but wanted to know its size.
So bitmap_find_next_zero_area is not what I wanted.
I will not submit this patch though.
>
>> This is helpful to look fragmentation. This is an test code to look size of zeros.
>> Test result is '10+9+994=>1013 found of total: 1024'
>>
>> unsigned long search_idx, found_idx, nr_found_tot;
>> unsigned long bitmap_max;
>> unsigned int nr_found;
>> unsigned long *bitmap;
>>
>> search_idx = nr_found_tot = 0;
>> bitmap_max = 1024;
>> bitmap = kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
>> 		 GFP_KERNEL);
>>
>> /* test bitmap_set offset, count */
>> bitmap_set(bitmap, 10, 1);
>> bitmap_set(bitmap, 20, 10);
>>
>> for (;;) {
>> 	found_idx = bitmap_find_next_zero_area_and_size(bitmap,
>> 				bitmap_max, search_idx, &nr_found);
>> 	if (found_idx >= bitmap_max)
>> 		break;
>> 	if (nr_found_tot == 0)
>> 		printk("%u", nr_found);
>> 	else
>> 		printk("+%u", nr_found);
>> 	nr_found_tot += nr_found;
>> 	search_idx = found_idx + nr_found;
>> }
>> printk("=>%lu found of total: %lu\n", nr_found_tot, bitmap_max);
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> This usecase is problematic in real world. Consider 1-byte bitmap
> '01010101'. To store fragmentation information for further analysis,
> you have to allocate 4 pairs of address and size. On 64-bit machine
> it's 64 bytes of additional memory. Brief grepping of kernel sources
> shows that no one does it. Correct me if I missed something.
Sorry but I did not understand for "you have to allocate 4 pairs of address and size"
I used just local variables.
>
> If you still think this API is useful, you'd walk over kernel
> and find bins of code that will become better with your function,
> and send the patch that adds the use of your function there. Probable
> candidates for search are bitmap_find_next_zero_area() and find_next_bit()
> functions.
>
> If the only suitable place for new function is your example below, I
> think it's better not to introduce new API and reconsider your
> implementation instead.
>
> Yury.
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
