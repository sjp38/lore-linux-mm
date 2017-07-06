Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90F056B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 06:03:41 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f28so3394110lfi.12
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 03:03:41 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id h26si645976ljb.141.2017.07.06.03.03.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 03:03:39 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id t72so9587003lff.1
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 03:03:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706092919epcms5p53dae183bd95cd2fa5b050f496f32aa73@epcms5p5>
References: <20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
 <CAC8qmcBa3ZBpw12AjbZ8bWuK5DW=wiXcURzomqXZXLrQhUWDhg@mail.gmail.com>
 <CGME20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p5>
 <20170706051959.GD7195@jagdpanzerIV.localdomain> <20170706092919epcms5p53dae183bd95cd2fa5b050f496f32aa73@epcms5p5>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 6 Jul 2017 06:02:58 -0400
Message-ID: <CALZtONDqz0GZUxhBt0QXmup2=5zw+xsSvNrNGOFN4KAZRb9urg@mail.gmail.com>
Subject: Re: [PATCH v2] zswap: Zero-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Thu, Jul 6, 2017 at 5:29 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
> On Wed, Jul 6, 2017 at 10:49 AM, Sergey Senozhatsky wrote:
>> On (07/02/17 20:28), Seth Jennings wrote:
>>> On Sun, Jul 2, 2017 at 9:19 AM, Srividya Desireddy
>>> > Zswap is a cache which compresses the pages that are being swapped out
>>> > and stores them into a dynamically allocated RAM-based memory pool.
>>> > Experiments have shown that around 10-20% of pages stored in zswap
>>> > are zero-filled pages (i.e. contents of the page are all zeros), but
>>> > these pages are handled as normal pages by compressing and allocating
>>> > memory in the pool.
>>>
>>> I am somewhat surprised that this many anon pages are zero filled.
>>>
>>> If this is true, then maybe we should consider solving this at the
>>> swap level in general, as we can de-dup zero pages in all swap
>>> devices, not just zswap.
>>>
>>> That being said, this is a fair small change and I don't see anything
>>> objectionable.  However, I do think the better solution would be to do
>> this at a higher level.
>>
>
> Thank you for your suggestion. It is a better solution to handle
> zero-filled pages before swapping-out to zswap. Since, Zram is already
> handles Zero pages internally, I considered to handle within Zswap.
> In a long run, we can work on it to commonly handle zero-filled anon
> pages.
>
>> zero-filled pages are just 1 case. in general, it's better
>> to handle pages that are memset-ed with the same value (e.g.
>> memset(page, 0x01, page_size)). which includes, but not
>> limited to, 0x00. zram does it.
>>
>>         -ss
>
> It is a good solution to extend zero-filled pages handling to same value
> pages. I will work on to identify the percentage of same value pages
> excluding zero-filled pages in Zswap and will get back.

Yes, this sounds like a good modification to the patch.  Also, unless
anyone else disagrees, it may be good to control this with a module
param - in case anyone has a use case that they know won't be helped
by this, and the extra overhead of checking each page is wasteful.
Probably should default to enabled.

>
> - Srividya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
