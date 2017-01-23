Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA806B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:03:36 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so187634109pfw.5
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:03:36 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id l8si14340644pln.291.2017.01.22.20.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 20:03:35 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 19so9109466pfo.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:03:35 -0800 (PST)
Date: Mon, 23 Jan 2017 13:03:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123040347.GA2327@jagdpanzerIV.localdomain>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123025826.GA24581@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: zhouxianrong <zhouxianrong@huawei.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On (01/23/17 11:58), Joonsoo Kim wrote:
> Hello,
> 
> On Sun, Jan 22, 2017 at 10:58:38AM +0800, zhouxianrong wrote:
> > 1. memset is just set a int value but i want to set a long value.
> 
> Sorry for late review.
> 
> Do we really need to set a long value? I cannot believe that
> long value is repeated in the page. Value repeatition is
> usually done by value 0 or 1 and it's enough to use int. And, I heard
> that value 0 or 1 is repeated in Android. Could you check the distribution
> of the value in the same page?

Hello Joonsoo,

thanks for taking a look and for bringing this question up.
so I kinda wanted to propose union of `ulong handle' with `uint element'
and switching to memset(), but I couldn't figure out if that change would
break detection of some patterns.

 /* Allocated for each disk page */
 struct zram_table_entry {
-       unsigned long handle;
+       union {
+               unsigned long handle;
+               unsigned int element;
+       };
        unsigned long value;
 };

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
