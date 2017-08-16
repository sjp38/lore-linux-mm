Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 615B66B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 13:20:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so18991235pfg.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:20:15 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id a15si784034pfl.347.2017.08.16.10.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 10:20:13 -0700 (PDT)
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20170816172011epoutp037ea267e1cdd5bba2e4dd6ae72a977ff5~bYzw-QPf42221422214epoutp03M
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:20:11 +0000 (GMT)
Mime-Version: 1.0
Subject: [PATCH v2] zswap: Zero-filled pages handling
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
Message-ID: <20170816172008epcms5p24e951e01951f055559210af10edf2250@epcms5p2>
Date: Wed, 16 Aug 2017 17:20:08 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CGME20170816172008epcms5p24e951e01951f055559210af10edf2250@epcms5p2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ddstreet@ieee.org" <ddstreet@ieee.org>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>, Sarbojit Ganguly <ganguly.s@samsung.com>


On Thu, Jul 6, 2017 at 3:32 PM, Dan Streetman wrote:
> On Thu, Jul 6, 2017 at 5:29 AM, Srividya Desireddy
> wrote:
>> On Wed, Jul 6, 2017 at 10:49 AM, Sergey Senozhatsky wrote:
>>> On (07/02/17 20:28), Seth Jennings wrote:
>>>> On Sun, Jul 2, 2017 at 9:19 AM, Srividya Desireddy
>>>> > Zswap is a cache which compresses the pages that are being swapped out
>>>> > and stores them into a dynamically allocated RAM-based memory pool.
>>>> > Experiments have shown that around 10-20% of pages stored in zswap
>>>> > are zero-filled pages (i.e. contents of the page are all zeros), but
>>>> > these pages are handled as normal pages by compressing and allocating
>>>> > memory in the pool.
>>>>
>>>> I am somewhat surprised that this many anon pages are zero filled.
>>>>
>>>> If this is true, then maybe we should consider solving this at the
>>>> swap level in general, as we can de-dup zero pages in all swap
>>>> devices, not just zswap.
>>>>
>>>> That being said, this is a fair small change and I don't see anything
>>>> objectionable.  However, I do think the better solution would be to do
>>> this at a higher level.
>>>
>>
>> Thank you for your suggestion. It is a better solution to handle
>> zero-filled pages before swapping-out to zswap. Since, Zram is already
>> handles Zero pages internally, I considered to handle within Zswap.
>> In a long run, we can work on it to commonly handle zero-filled anon
>> pages.
>>
>>> zero-filled pages are just 1 case. in general, it's better
>>> to handle pages that are memset-ed with the same value (e.g.
>>> memset(page, 0x01, page_size)). which includes, but not
>>> limited to, 0x00. zram does it.
>>>
>>>         -ss
>>
>> It is a good solution to extend zero-filled pages handling to same value
>> pages. I will work on to identify the percentage of same value pages
>> excluding zero-filled pages in Zswap and will get back.
>
> Yes, this sounds like a good modification to the patch.  Also, unless
> anyone else disagrees, it may be good to control this with a module
> param - in case anyone has a use case that they know won't be helped
> by this, and the extra overhead of checking each page is wasteful.
> Probably should default to enabled.
>
>>
>> - Srividya

I have made changes to patch to handle pages with same-value filled.

I tested on a ARM Quad Core 32-bit device with 1.5GB RAM by launching
and relaunching different applications. After the test, out of ~64000
pages stored in zswap, ~ 11000 pages were same-value filled pages
(including zero-filled pages) and ~9000 pages were zero-filled pages.

An average of 17% of pages(including zero-filled pages) in zswap are 
same-value filled pages and 14% pages are zero-filled pages.
An average of 3% of pages are same-filled non-zero pages.

The below table shows the execution time profiling with the patch.

                          Baseline    With patch  % Improvement
-----------------------------------------------------------------
*Zswap Store Time           26.5ms	      18ms          32%
 (of same value pages)
*Zswap Load Time
 (of same value pages)      25.5ms      13ms          49%
-----------------------------------------------------------------

On Ubuntu PC with 2GB RAM, while executing kernel build and other test
scripts and running multimedia applications, out of 360000 pages 
stored in zswap 78000(~22%) of pages were found to be same-value filled
pages (including zero-filled pages) and 64000(~17%) are zero-filled 
pages. So an average of %5 of pages are same-filled non-zero pages.

The below table shows the execution time profiling with the patch.

                          Baseline    With patch  % Improvement
-----------------------------------------------------------------
*Zswap Store Time           91ms        74ms           19%
 (of same value pages)
*Zswap Load Time            50ms        7.5ms          85%
 (of same value pages)
-----------------------------------------------------------------

*The execution times may vary with test device used.

I will send this patch of handling same-value filled pages along with
module param to control it(default being enabled).

 - Srividya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
