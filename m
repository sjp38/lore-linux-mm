Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2916B0271
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 00:44:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p12-v6so9231292qtg.5
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 21:44:30 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k11-v6si1749352qvo.167.2018.06.15.21.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 21:44:29 -0700 (PDT)
Subject: Re: OpenAFS module libafs.ko uses GPL-only symbol
 '__put_devmap_managed_page'
References: <CAFhSwD9RNcsaTNdT-4DiE_BKK6zrsdBbNbGBEkBoJuwQn1JdQA@mail.gmail.com>
 <CAPcyv4hpjNaUz6qpJ0_Wh1SAz9tS9a5HLsYSgeCh_pNZKfY74A@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1970355c-ebca-7f7d-38f7-ceac1ae553fb@nvidia.com>
Date: Fri, 15 Jun 2018 21:43:33 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hpjNaUz6qpJ0_Wh1SAz9tS9a5HLsYSgeCh_pNZKfY74A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Joe Gorse <jhgorse@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>

On 06/13/2018 12:51 PM, Dan Williams wrote:
> [ adding Andrew, Christoph, and linux-mm ]
> 
> On Wed, Jun 13, 2018 at 12:33 PM, Joe Gorse <jhgorse@gmail.com> wrote:
>> Greetings,
>>
>> Please CC answers & comments to this email. Thanks! =)
>>
>> Our build is breaking as of
>> commit e7638488434415aa478e78435cac8f0365737638
>> Author: Dan Williams <dan.j.williams@intel.com>
>> Date: Wed May 16 11:46:08 2018 -0700
>>
>> mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
>> ... snip ...
>> https://patchwork.kernel.org/patch/10412459/
>>
>> We do not directly use the GPL-only symbol '__put_devmap_managed_page'. It
>> appears to be picked up from static-inlining in put_page(), which we need.
>>
>> How shall we proceed? Would it be reasonable to request the change of the
>> GPL-only exports for this commit?
>>
>> Cheers,
>> Joe Gorse
>>
>> P.S. The build failure, for the morbidly curious:
>>> FATAL: modpost: GPL-incompatible module libafs.ko uses GPL-only symbol
>>> '__put_devmap_managed_page'
>>> scripts/Makefile.modpost:92: recipe for target '__modpost' failed
>>> make[6]: *** [__modpost] Error 1
> 
> I think the right answer here is to make __put_devmap_managed_page()
> EXPORT_SYMBOL(), since features like devm_memremap_pages() want to
> change the behavior of all users of put_page(). It again holds that
> devm_memremap_pages() needs to become EXPORT_SYMBOL_GPL() because it,
> not put_page(), is the interface that is leaking control of core
> kernel state/infrastructure to its users.
> 

Hi Dan and all,

It looks like put_page() also picks up one more GPL symbol: 
devmap_managed_key.

put_page
    put_devmap_managed_page
        devmap_managed_key

    __put_devmap_managed_page


So if the goal is to restore put_page() to be effectively EXPORT_SYMBOL
again, then I think there would also need to be either a non-inlined 
wrapper for devmap_managed_key (awkward for a static key), or else make
it EXPORT_SYMBOL, or maybe something else that's less obvious to me at the
moment.


thanks,
-- 
John Hubbard
NVIDIA
