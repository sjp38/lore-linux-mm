Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8E86B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 02:41:00 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so191542223pfy.2
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:41:00 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h7si14813943pgn.325.2017.01.22.23.40.59
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 23:40:59 -0800 (PST)
Date: Mon, 23 Jan 2017 16:40:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123074054.GA12782@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170123071339.GD2327@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhouxianrong <zhouxianrong@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Mon, Jan 23, 2017 at 04:13:39PM +0900, Sergey Senozhatsky wrote:
> On (01/23/17 15:27), Joonsoo Kim wrote:
> > Hello,
> > 
> > Think about following case in 64 bits kernel.
> > 
> > If value pattern in the page is like as following, we cannot detect
> > the same page with 'unsigned int' element.
> > 
> > AAAAAAAABBBBBBBBAAAAAAAABBBBBBBB...
> > 
> > 4 bytes is 0xAAAAAAAA and next 4 bytes is 0xBBBBBBBB and so on.
> 
> yep, that's exactly the case that I though would be broken
> with a 4-bytes pattern matching. so my conlusion was that
> for 4 byte pattern we would have working detection anyway,
> for 8 bytes patterns we might have some extra matching.
> not sure if it matters that much though.

It would be better for deduplication as pattern coverage is bigger
and we cannot guess all of patterns now so it would be never ending
story(i.e., someone claims 16bytes pattern matching would be better).
So, I want to make that path fast rather than increasing dedup ratio
if memset is really fast rather than open-looping. So in future,
if we can prove bigger pattern can increase dedup ratio a lot, then,
we could consider to extend it at the cost of make that path slow.

In summary, zhouxianrong, please test pattern as Joonsoo asked.
So if there are not much benefit with 'long', let's go to the
'int' with memset. And Please resend patch if anyone dosn't oppose
strongly by the time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
