Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC7B36B0275
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 01:22:58 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id v37-v6so6920220ote.10
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 22:22:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o186-v6sor3960608oig.0.2018.06.15.22.22.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 22:22:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1970355c-ebca-7f7d-38f7-ceac1ae553fb@nvidia.com>
References: <CAFhSwD9RNcsaTNdT-4DiE_BKK6zrsdBbNbGBEkBoJuwQn1JdQA@mail.gmail.com>
 <CAPcyv4hpjNaUz6qpJ0_Wh1SAz9tS9a5HLsYSgeCh_pNZKfY74A@mail.gmail.com> <1970355c-ebca-7f7d-38f7-ceac1ae553fb@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Jun 2018 22:22:56 -0700
Message-ID: <CAPcyv4j=LFY31zn7yFXUrsrvzQEz=a92VLOa=Tp46JbGHhC7Xw@mail.gmail.com>
Subject: Re: OpenAFS module libafs.ko uses GPL-only symbol '__put_devmap_managed_page'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Joe Gorse <jhgorse@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>

On Fri, Jun 15, 2018 at 9:43 PM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 06/13/2018 12:51 PM, Dan Williams wrote:
>> [ adding Andrew, Christoph, and linux-mm ]
>>
>> On Wed, Jun 13, 2018 at 12:33 PM, Joe Gorse <jhgorse@gmail.com> wrote:
>>> Greetings,
>>>
>>> Please CC answers & comments to this email. Thanks! =)
>>>
>>> Our build is breaking as of
>>> commit e7638488434415aa478e78435cac8f0365737638
>>> Author: Dan Williams <dan.j.williams@intel.com>
>>> Date: Wed May 16 11:46:08 2018 -0700
>>>
>>> mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
>>> ... snip ...
>>> https://patchwork.kernel.org/patch/10412459/
>>>
>>> We do not directly use the GPL-only symbol '__put_devmap_managed_page'. It
>>> appears to be picked up from static-inlining in put_page(), which we need.
>>>
>>> How shall we proceed? Would it be reasonable to request the change of the
>>> GPL-only exports for this commit?
>>>
>>> Cheers,
>>> Joe Gorse
>>>
>>> P.S. The build failure, for the morbidly curious:
>>>> FATAL: modpost: GPL-incompatible module libafs.ko uses GPL-only symbol
>>>> '__put_devmap_managed_page'
>>>> scripts/Makefile.modpost:92: recipe for target '__modpost' failed
>>>> make[6]: *** [__modpost] Error 1
>>
>> I think the right answer here is to make __put_devmap_managed_page()
>> EXPORT_SYMBOL(), since features like devm_memremap_pages() want to
>> change the behavior of all users of put_page(). It again holds that
>> devm_memremap_pages() needs to become EXPORT_SYMBOL_GPL() because it,
>> not put_page(), is the interface that is leaking control of core
>> kernel state/infrastructure to its users.
>>
>
> Hi Dan and all,
>
> It looks like put_page() also picks up one more GPL symbol:
> devmap_managed_key.
>
> put_page
>     put_devmap_managed_page
>         devmap_managed_key
>
>     __put_devmap_managed_page
>
>
> So if the goal is to restore put_page() to be effectively EXPORT_SYMBOL
> again, then I think there would also need to be either a non-inlined
> wrapper for devmap_managed_key (awkward for a static key), or else make
> it EXPORT_SYMBOL, or maybe something else that's less obvious to me at the
> moment.

Right, certainly flipping the key is a kernel internal detail since it
is giving the dev_pagemap owner purview over all kernel page events,
but put_page() users are silent consumers. And you're right there's
currently no good way I see to export the 'producer' and 'consumer'
side of the key with different export types.
