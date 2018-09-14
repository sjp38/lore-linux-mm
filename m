Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 332F48E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:25:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q11-v6so10304239oih.15
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:25:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5-v6sor3033109otm.148.2018.09.14.10.25.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Sep 2018 10:25:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180914131618.GD27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680533706.453305.3428304103990941022.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180914131618.GD27141@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Sep 2018 10:25:09 -0700
Message-ID: <CAPcyv4jTOYjeG4eJd+XR9dzQGb2f_rdn1Knb7V=AMgokzC0M7Q@mail.gmail.com>
Subject: Re: [PATCH v5 3/7] mm, devm_memremap_pages: Fix shutdown handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 14, 2018 at 6:16 AM, Christoph Hellwig <hch@lst.de> wrote:
>> An argument could be made to require that the ->kill() operation be set
>> in the @pgmap arg rather than passed in separately. However, it helps
>> code readability, tracking the lifetime of a given instance, to be able
>> to grep the kill routine directly at the devm_memremap_pages() call
>> site.
>
> I generally do not like passing redundant argument, and I don't really
> see why this case is different.  Or in other ways I'd like to make
> your above argument..

Logan had similar feedback, and now the chorus is getting louder. I
personally like how I can do this with grep:

drivers/dax/pmem.c:114: addr = devm_memremap_pages(dev,
&dax_pmem->pgmap, dax_pmem_percpu_kill);
--
drivers/nvdimm/pmem.c:411:              addr =
devm_memremap_pages(dev, &pmem->pgmap,
drivers/nvdimm/pmem.c-412-                              pmem_freeze_queue);
--
drivers/nvdimm/pmem.c:425:              addr =
devm_memremap_pages(dev, &pmem->pgmap,
drivers/nvdimm/pmem.c-426-                              pmem_freeze_queue);
--
mm/hmm.c:1059:  result = devm_memremap_pages(devmem->device, &devmem->pagemap,
mm/hmm.c-1060-                  hmm_devmem_ref_kill);
--
mm/hmm.c:1113:  result = devm_memremap_pages(devmem->device, &devmem->pagemap,
mm/hmm.c-1114-                  hmm_devmem_ref_kill);

...and see all of the kill() variants, but the redundancy will likely
continue to bother folks.

> Except for that the patch looks good to me.

Thanks, I'll fix it up to drop the redundant arg.
