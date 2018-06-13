Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACD4B6B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 15:51:38 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id d26-v6so2212677otl.9
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 12:51:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u28-v6sor1485623ote.11.2018.06.13.12.51.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 12:51:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFhSwD9RNcsaTNdT-4DiE_BKK6zrsdBbNbGBEkBoJuwQn1JdQA@mail.gmail.com>
References: <CAFhSwD9RNcsaTNdT-4DiE_BKK6zrsdBbNbGBEkBoJuwQn1JdQA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Jun 2018 12:51:34 -0700
Message-ID: <CAPcyv4hpjNaUz6qpJ0_Wh1SAz9tS9a5HLsYSgeCh_pNZKfY74A@mail.gmail.com>
Subject: Re: OpenAFS module libafs.ko uses GPL-only symbol '__put_devmap_managed_page'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Gorse <jhgorse@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>

[ adding Andrew, Christoph, and linux-mm ]

On Wed, Jun 13, 2018 at 12:33 PM, Joe Gorse <jhgorse@gmail.com> wrote:
> Greetings,
>
> Please CC answers & comments to this email. Thanks! =)
>
> Our build is breaking as of
> commit e7638488434415aa478e78435cac8f0365737638
> Author: Dan Williams <dan.j.williams@intel.com>
> Date: Wed May 16 11:46:08 2018 -0700
>
> mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
> ... snip ...
> https://patchwork.kernel.org/patch/10412459/
>
> We do not directly use the GPL-only symbol '__put_devmap_managed_page'. It
> appears to be picked up from static-inlining in put_page(), which we need.
>
> How shall we proceed? Would it be reasonable to request the change of the
> GPL-only exports for this commit?
>
> Cheers,
> Joe Gorse
>
> P.S. The build failure, for the morbidly curious:
>> FATAL: modpost: GPL-incompatible module libafs.ko uses GPL-only symbol
>> '__put_devmap_managed_page'
>> scripts/Makefile.modpost:92: recipe for target '__modpost' failed
>> make[6]: *** [__modpost] Error 1

I think the right answer here is to make __put_devmap_managed_page()
EXPORT_SYMBOL(), since features like devm_memremap_pages() want to
change the behavior of all users of put_page(). It again holds that
devm_memremap_pages() needs to become EXPORT_SYMBOL_GPL() because it,
not put_page(), is the interface that is leaking control of core
kernel state/infrastructure to its users.
