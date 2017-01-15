Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2FD6B0033
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 02:18:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so207747107pfb.6
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 23:18:07 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0062.outbound.protection.outlook.com. [104.47.38.62])
        by mx.google.com with ESMTPS id f35si17780278plh.212.2017.01.14.23.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 23:18:05 -0800 (PST)
Date: Sun, 15 Jan 2017 12:47:26 +0530
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH] lib: bitmap: introduce
 bitmap_find_next_zero_area_and_size
Message-ID: <20170115071726.GB6474@yury-N73SV>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hi Jaewon,

with all comments above, some of my concerns.

On Mon, Dec 26, 2016 at 01:18:11PM +0900, Jaewon Kim wrote:
> There was no bitmap API which returns both next zero index and size of zeros
> from that index.

Yes, there is. Most probably because this function is not needed.
Typical usecase is looking for the area of N free bits, were caller
knows N, and doesn't care of free areas smaller than N. There is 
bitmap_find_next_zero_area() for exactly that.

> This is helpful to look fragmentation. This is an test code to look size of zeros.
> Test result is '10+9+994=>1013 found of total: 1024'
> 
> unsigned long search_idx, found_idx, nr_found_tot;
> unsigned long bitmap_max;
> unsigned int nr_found;
> unsigned long *bitmap;
> 
> search_idx = nr_found_tot = 0;
> bitmap_max = 1024;
> bitmap = kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
> 		 GFP_KERNEL);
> 
> /* test bitmap_set offset, count */
> bitmap_set(bitmap, 10, 1);
> bitmap_set(bitmap, 20, 10);
> 
> for (;;) {
> 	found_idx = bitmap_find_next_zero_area_and_size(bitmap,
> 				bitmap_max, search_idx, &nr_found);
> 	if (found_idx >= bitmap_max)
> 		break;
> 	if (nr_found_tot == 0)
> 		printk("%u", nr_found);
> 	else
> 		printk("+%u", nr_found);
> 	nr_found_tot += nr_found;
> 	search_idx = found_idx + nr_found;
> }
> printk("=>%lu found of total: %lu\n", nr_found_tot, bitmap_max);
> 
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>

This usecase is problematic in real world. Consider 1-byte bitmap
'01010101'. To store fragmentation information for further analysis,
you have to allocate 4 pairs of address and size. On 64-bit machine
it's 64 bytes of additional memory. Brief grepping of kernel sources
shows that no one does it. Correct me if I missed something.

If you still think this API is useful, you'd walk over kernel
and find bins of code that will become better with your function,
and send the patch that adds the use of your function there. Probable
candidates for search are bitmap_find_next_zero_area() and find_next_bit()
functions.

If the only suitable place for new function is your example below, I
think it's better not to introduce new API and reconsider your
implementation instead.

Yury.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
