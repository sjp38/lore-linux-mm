Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A86D6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 01:20:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so187488659pgg.4
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:20:57 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z30si14687609plh.61.2017.01.22.22.20.55
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 22:20:56 -0800 (PST)
Date: Mon, 23 Jan 2017 15:27:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123062716.GF24581@js1304-P5Q-DELUXE>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123040347.GA2327@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: zhouxianrong <zhouxianrong@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Mon, Jan 23, 2017 at 01:03:47PM +0900, Sergey Senozhatsky wrote:
> On (01/23/17 11:58), Joonsoo Kim wrote:
> > Hello,
> > 
> > On Sun, Jan 22, 2017 at 10:58:38AM +0800, zhouxianrong wrote:
> > > 1. memset is just set a int value but i want to set a long value.
> > 
> > Sorry for late review.
> > 
> > Do we really need to set a long value? I cannot believe that
> > long value is repeated in the page. Value repeatition is
> > usually done by value 0 or 1 and it's enough to use int. And, I heard
> > that value 0 or 1 is repeated in Android. Could you check the distribution
> > of the value in the same page?
> 
> Hello Joonsoo,
> 
> thanks for taking a look and for bringing this question up.
> so I kinda wanted to propose union of `ulong handle' with `uint element'
> and switching to memset(), but I couldn't figure out if that change would
> break detection of some patterns.
> 
>  /* Allocated for each disk page */
>  struct zram_table_entry {
> -       unsigned long handle;
> +       union {
> +               unsigned long handle;
> +               unsigned int element;
> +       };
>         unsigned long value;
>  };

Hello,

Think about following case in 64 bits kernel.

If value pattern in the page is like as following, we cannot detect
the same page with 'unsigned int' element.

AAAAAAAABBBBBBBBAAAAAAAABBBBBBBB...

4 bytes is 0xAAAAAAAA and next 4 bytes is 0xBBBBBBBB and so on.

However, as I said before, I think that it is uncommon case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
