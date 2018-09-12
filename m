Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55C378E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:50:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w185-v6so2969003oig.19
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:50:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g11-v6sor1477486oiy.92.2018.09.12.09.50.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 09:50:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdKZVUPBk=rg5kfUuFBpuZQEKPuGw31x5O2nMyuULgi0g@mail.gmail.com>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234354.4068.65260.stgit@localhost.localdomain> <7b96298e-9590-befd-0670-ed0c9fcf53d5@microsoft.com>
 <CAKgT0UdKZVUPBk=rg5kfUuFBpuZQEKPuGw31x5O2nMyuULgi0g@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Sep 2018 09:50:34 -0700
Message-ID: <CAPcyv4gEDwp8Xh4_E8RNBC_OqstwhqxkZOpvYjWd_siB4C=BEQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Pavel.Tatashin@microsoft.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 12, 2018 at 8:48 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Sep 12, 2018 at 6:59 AM Pasha Tatashin
> <Pavel.Tatashin@microsoft.com> wrote:
>>
>> Hi Alex,
>
> Hi Pavel,
>
>> Please re-base on linux-next,  memmap_init_zone() has been updated there
>> compared to mainline. You might even find a way to unify some parts of
>> memmap_init_zone and memmap_init_zone_device as memmap_init_zone() is a
>> lot simpler now.
>
> This patch applied to the linux-next tree with only a little bit of
> fuzz. It looks like it is mostly due to some code you had added above
> the function as well. I have updated this patch so that it will apply
> to both linux and linux-next by just moving the new function to
> underneath memmap_init_zone instead of above it.
>
>> I think __init_single_page() should stay local to page_alloc.c to keep
>> the inlining optimization.
>
> I agree. In addition it will make pulling common init together into
> one space easier. I would rather not have us create an opportunity for
> things to further diverge by making it available for anybody to use.

I'll buy the inline argument for keeping the new routine in
page_alloc.c, but I otherwise do not see the divergence danger or
"making __init_single_page() available for anybody" given the the
declaration is limited in scope to a mm/ local header file.
