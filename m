Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAF898E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 18:27:25 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id s69-v6so6662261ota.13
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 15:27:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k185-v6sor19123368oif.68.2018.09.19.15.27.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 15:27:24 -0700 (PDT)
MIME-Version: 1.0
References: <20180919210250.28858-1-keith.busch@intel.com> <40b392d0-0642-2d9b-5325-664a328ff677@intel.com>
In-Reply-To: <40b392d0-0642-2d9b-5325-664a328ff677@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Sep 2018 15:27:13 -0700
Message-ID: <CAPcyv4iVpKD=yLS=YM18+_LGQp3_y+h4Cx4s3Bc9gHmdRrimAg@mail.gmail.com>
Subject: Re: [PATCH 0/7] mm: faster get user pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 19, 2018 at 2:15 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 09/19/2018 02:02 PM, Keith Busch wrote:
> > Pinning user pages out of nvdimm dax memory is significantly slower
> > compared to system ram. Analysis points to software overhead incurred
> > from a radix tree lookup. This patch series fixes that by removing the
> > relatively costly dev_pagemap lookup that was repeated for each page,
> > significantly increasing gup time.
>
> Could you also remind us why DAX pages are such special snowflakes and
> *require* radix tree lookups in the first place?

They are special because they need to check backing device live-ness
when taking new references. We manage a percpu-ref for each device
that registers physical memory with devm_memremap_pages(). When that
device is disabled we kill the percpu-ref to block new references
being taken, and then wait for existing references to drain. This
allows for disabling persistent-memory namepace-devices at will
relative to new get_user_pages() requests.
