Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2709B8E0011
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:59:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t3-v6so309316oif.20
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:59:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k126-v6sor25222818oih.179.2018.09.11.17.59.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 17:59:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdmkAXLdR6cfgmu-LcJUOO8a4qAS8zO3Bn+LwjJ9rT3pg@mail.gmail.com>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234354.4068.65260.stgit@localhost.localdomain> <CAPcyv4ja7=eUbwwJZhreexa9_7JyJotQwObrQm=nCEcgcfbWyw@mail.gmail.com>
 <CAKgT0UdmkAXLdR6cfgmu-LcJUOO8a4qAS8zO3Bn+LwjJ9rT3pg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Sep 2018 17:59:25 -0700
Message-ID: <CAPcyv4iiR3JgHg+Xyw-zON4+66stf917kUqNBxMFFLwT=H14qg@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 11, 2018 at 5:51 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Sep 11, 2018 at 3:35 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> On Mon, Sep 10, 2018 at 4:43 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>> >
>> > From: Alexander Duyck <alexander.h.duyck@intel.com>
>> >
>> > The ZONE_DEVICE pages were being initialized in two locations. One was with
>> > the memory_hotplug lock held and another was outside of that lock. The
>> > problem with this is that it was nearly doubling the memory initialization
>> > time. Instead of doing this twice, once while holding a global lock and
>> > once without, I am opting to defer the initialization to the one outside of
>> > the lock. This allows us to avoid serializing the overhead for memory init
>> > and we can instead focus on per-node init times.
>> >
>> > One issue I encountered is that devm_memremap_pages and
>> > hmm_devmmem_pages_create were initializing only the pgmap field the same
>> > way. One wasn't initializing hmm_data, and the other was initializing it to
>> > a poison value. Since this is something that is exposed to the driver in
>> > the case of hmm I am opting for a third option and just initializing
>> > hmm_data to 0 since this is going to be exposed to unknown third party
>> > drivers.
>> >
>> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> > ---
>> >  include/linux/mm.h |    2 +
>> >  kernel/memremap.c  |   24 +++++---------
>> >  mm/hmm.c           |   12 ++++---
>> >  mm/page_alloc.c    |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>>
>> Hmm, why mm/page_alloc.c and not kernel/memremap.c for this new
>> helper? I think that would address the kbuild reports and keeps all
>> the devm_memremap_pages / ZONE_DEVICE special casing centralized. I
>> also think it makes sense to move memremap.c to mm/ rather than
>> kernel/ especially since commit 5981690ddb8f "memremap: split
>> devm_memremap_pages() and memremap() infrastructure". Arguably, that
>> commit should have went ahead with the directory move.
>
> The issue ends up being the fact that I would then have to start
> exporting infrastructure such as __init_single_page from page_alloc. I
> have some follow-up patches I am working on that will generate some
> other shared functions that can be used by both memmap_init_zone and
> memmap_init_zone_device, as well as pulling in some of the code from
> the deferred memory init.

You wouldn't need to export it, just make it public to mm/ in
mm/internal.h, or a similar local header. With kernel/memremap.c moved
to mm/memremap.c this becomes even easier and better scoped for the
shared symbols.
