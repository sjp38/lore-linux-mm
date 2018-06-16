Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C03B26B0277
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 01:40:57 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x16-v6so9286051qto.20
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 22:40:57 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t67-v6si6830050qkb.321.2018.06.15.22.40.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 22:40:56 -0700 (PDT)
Subject: Re: OpenAFS module libafs.ko uses GPL-only symbol
 '__put_devmap_managed_page'
References: <CAFhSwD9RNcsaTNdT-4DiE_BKK6zrsdBbNbGBEkBoJuwQn1JdQA@mail.gmail.com>
 <CAPcyv4hpjNaUz6qpJ0_Wh1SAz9tS9a5HLsYSgeCh_pNZKfY74A@mail.gmail.com>
 <1970355c-ebca-7f7d-38f7-ceac1ae553fb@nvidia.com>
 <CAPcyv4j=LFY31zn7yFXUrsrvzQEz=a92VLOa=Tp46JbGHhC7Xw@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a6a16c1c-3e80-2cf8-6d8d-1d0fc91008af@nvidia.com>
Date: Fri, 15 Jun 2018 22:40:01 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4j=LFY31zn7yFXUrsrvzQEz=a92VLOa=Tp46JbGHhC7Xw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Joe Gorse <jhgorse@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>

On 06/15/2018 10:22 PM, Dan Williams wrote:
> On Fri, Jun 15, 2018 at 9:43 PM, John Hubbard <jhubbard@nvidia.com> wrote:
>> On 06/13/2018 12:51 PM, Dan Williams wrote:
>>> [ adding Andrew, Christoph, and linux-mm ]
>>>
>>> On Wed, Jun 13, 2018 at 12:33 PM, Joe Gorse <jhgorse@gmail.com> wrote:
[snip]
>>>>
>>>> P.S. The build failure, for the morbidly curious:
>>>>> FATAL: modpost: GPL-incompatible module libafs.ko uses GPL-only symbol
>>>>> '__put_devmap_managed_page'
>>>>> scripts/Makefile.modpost:92: recipe for target '__modpost' failed
>>>>> make[6]: *** [__modpost] Error 1
>>>
>>> I think the right answer here is to make __put_devmap_managed_page()
>>> EXPORT_SYMBOL(), since features like devm_memremap_pages() want to
>>> change the behavior of all users of put_page(). It again holds that
>>> devm_memremap_pages() needs to become EXPORT_SYMBOL_GPL() because it,
>>> not put_page(), is the interface that is leaking control of core
>>> kernel state/infrastructure to its users.
>>>
>>
>> Hi Dan and all,
>>
>> It looks like put_page() also picks up one more GPL symbol:
>> devmap_managed_key.
>>
>> put_page
>>     put_devmap_managed_page
>>         devmap_managed_key
>>
>>     __put_devmap_managed_page
>>
>>
>> So if the goal is to restore put_page() to be effectively EXPORT_SYMBOL
>> again, then I think there would also need to be either a non-inlined
>> wrapper for devmap_managed_key (awkward for a static key), or else make
>> it EXPORT_SYMBOL, or maybe something else that's less obvious to me at the
>> moment.
> 
> Right, certainly flipping the key is a kernel internal detail since it
> is giving the dev_pagemap owner purview over all kernel page events,
> but put_page() users are silent consumers. And you're right there's
> currently no good way I see to export the 'producer' and 'consumer'
> side of the key with different export types.
> 

It's hard to imagine how anyone could end up using devmap_managed_key
in an out-of-tree driver, given that other related symbols are already
locked down with EXPORT_SYMBOL_GPL. So one easy fix might be to just
make it EXPORT_SYMBOL, with a comment that explains the intent, and just
call it a day:

/* This is intended to be EXPORT_SYMBOL_GPL, but actually doing so would
 * cause a problem for put_page().
 */
EXPORT_SYMBOL(devmap_managed_key);

...I'm sort of winging it here... :)
