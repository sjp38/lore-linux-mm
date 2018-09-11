Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 271F18E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:35:06 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r131-v6so33770677oie.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:35:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5-v6sor24724192oiy.33.2018.09.11.15.35.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 15:35:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180910234354.4068.65260.stgit@localhost.localdomain>
References: <20180910232615.4068.29155.stgit@localhost.localdomain> <20180910234354.4068.65260.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Sep 2018 15:35:04 -0700
Message-ID: <CAPcyv4ja7=eUbwwJZhreexa9_7JyJotQwObrQm=nCEcgcfbWyw@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 10, 2018 at 4:43 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> The ZONE_DEVICE pages were being initialized in two locations. One was with
> the memory_hotplug lock held and another was outside of that lock. The
> problem with this is that it was nearly doubling the memory initialization
> time. Instead of doing this twice, once while holding a global lock and
> once without, I am opting to defer the initialization to the one outside of
> the lock. This allows us to avoid serializing the overhead for memory init
> and we can instead focus on per-node init times.
>
> One issue I encountered is that devm_memremap_pages and
> hmm_devmmem_pages_create were initializing only the pgmap field the same
> way. One wasn't initializing hmm_data, and the other was initializing it to
> a poison value. Since this is something that is exposed to the driver in
> the case of hmm I am opting for a third option and just initializing
> hmm_data to 0 since this is going to be exposed to unknown third party
> drivers.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/linux/mm.h |    2 +
>  kernel/memremap.c  |   24 +++++---------
>  mm/hmm.c           |   12 ++++---
>  mm/page_alloc.c    |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++-

Hmm, why mm/page_alloc.c and not kernel/memremap.c for this new
helper? I think that would address the kbuild reports and keeps all
the devm_memremap_pages / ZONE_DEVICE special casing centralized. I
also think it makes sense to move memremap.c to mm/ rather than
kernel/ especially since commit 5981690ddb8f "memremap: split
devm_memremap_pages() and memremap() infrastructure". Arguably, that
commit should have went ahead with the directory move.
