Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C95EC6B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 05:29:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q87so15088116pfk.15
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 02:29:23 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id e27si1258118plj.423.2017.07.06.02.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 02:29:22 -0700 (PDT)
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20170706092920epoutp023219a49ae8c31ae2cee2fc48bd62ddea~Os79bet9x0971309713epoutp02j
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 09:29:20 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH v2] zswap: Zero-filled pages handling
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
In-Reply-To: <20170706051959.GD7195@jagdpanzerIV.localdomain>
Message-ID: <20170706092919epcms5p53dae183bd95cd2fa5b050f496f32aa73@epcms5p5>
Date: Thu, 06 Jul 2017 09:29:19 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <20170706051959.GD7195@jagdpanzerIV.localdomain>
	<20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
	<CAC8qmcBa3ZBpw12AjbZ8bWuK5DW=wiXcURzomqXZXLrQhUWDhg@mail.gmail.com>
	<CGME20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p5>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>
Cc: "ddstreet@ieee.org" <ddstreet@ieee.org>, "penberg@kernel.org" <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Jul 6, 2017 at 10:49 AM, Sergey Senozhatsky wrote:
> On (07/02/17 20:28), Seth Jennings wrote:
>> On Sun, Jul 2, 2017 at 9:19 AM, Srividya Desireddy
>> > Zswap is a cache which compresses the pages that are being swapped out
>> > and stores them into a dynamically allocated RAM-based memory pool.
>> > Experiments have shown that around 10-20% of pages stored in zswap
>> > are zero-filled pages (i.e. contents of the page are all zeros), but
>> > these pages are handled as normal pages by compressing and allocating
>> > memory in the pool.
>> 
>> I am somewhat surprised that this many anon pages are zero filled.
>> 
>> If this is true, then maybe we should consider solving this at the
>> swap level in general, as we can de-dup zero pages in all swap
>> devices, not just zswap.
>> 
>> That being said, this is a fair small change and I don't see anything
>> objectionable.  However, I do think the better solution would be to do
> this at a higher level.
> 

Thank you for your suggestion. It is a better solution to handle
zero-filled pages before swapping-out to zswap. Since, Zram is already
handles Zero pages internally, I considered to handle within Zswap.
In a long run, we can work on it to commonly handle zero-filled anon
pages.

> zero-filled pages are just 1 case. in general, it's better
> to handle pages that are memset-ed with the same value (e.g.
> memset(page, 0x01, page_size)). which includes, but not
> limited to, 0x00. zram does it.
> 
>         -ss

It is a good solution to extend zero-filled pages handling to same value
pages. I will work on to identify the percentage of same value pages
excluding zero-filled pages in Zswap and will get back.

- Srividya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
