Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f49.google.com (mail-qe0-f49.google.com [209.85.128.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7176B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 22:50:48 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id w7so1286779qeb.8
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:50:48 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id ko6si9766506qeb.85.2013.11.20.19.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 19:50:47 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id j5so2774507qaq.5
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:50:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <528D570D.3020006@oracle.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
	<528D570D.3020006@oracle.com>
Date: Thu, 21 Nov 2013 11:50:47 +0800
Message-ID: <CAL1ERfNr+J5gT-s1Qe+RVmNz+CenNFOzAWi86MNCt2ZGLB4ZCA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hello Dan,

On Thu, Nov 21, 2013 at 8:42 AM, Bob Liu <bob.liu@oracle.com> wrote:
> Hi Dan,
>
> On 11/21/2013 03:49 AM, Dan Streetman wrote:
>> Currently, zswap is writeback cache; stored pages are not sent
>> to swap disk, and when zswap wants to evict old pages it must
>> first write them back to swap cache/disk manually.  This avoids
>> swap out disk I/O up front, but only moves that disk I/O to
>> the writeback case (for pages that are evicted), and adds the
>> overhead of having to uncompress the evicted pages, and adds the
>> need for an additional free page (to store the uncompressed page)
>> at a time of likely high memory pressure.  Additionally, being
>> writeback adds complexity to zswap by having to perform the
>> writeback on page eviction.
>>
>
> Good work!
>
>> This changes zswap to writethrough cache by enabling
>> frontswap_writethrough() before registering, so that any
>> successful page store will also be written to swap disk.  All the
>> writeback code is removed since it is no longer needed, and the
>> only operation during a page eviction is now to remove the entry
>> from the tree and free it.
>>

Thanks for your work. I reviewed this patch, and it is good to me.

However, I am skeptical about it because:
1. it will add more IO than original zswap, how does it result in a
performance improvement ?
2. most embedded device use NAND, more IO will reduce its working life

Regards

> Could you do some testing using eg. SPECjbb? And compare the result with
> original zswap.
>
> Thanks,
> -Bob
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
