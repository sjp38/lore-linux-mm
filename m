Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 596D76B0008
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 14:21:53 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id p29so7272846ote.3
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 11:21:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b20sor8974953otb.35.2018.11.12.11.21.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 11:21:52 -0800 (PST)
MIME-Version: 1.0
References: <20181015153034.32203-1-osalvador@techadventures.net> <20181015153034.32203-3-osalvador@techadventures.net>
In-Reply-To: <20181015153034.32203-3-osalvador@techadventures.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Nov 2018 11:21:39 -0800
Message-ID: <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, rppt@linux.vnet.ibm.com, malat@debian.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jonathan.Cameron@huawei.com, "Rafael J. Wysocki" <rafael@kernel.org>, David Hildenbrand <david@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Linux MM <linux-mm@kvack.org>, alexander.h.duyck@linux.intel.com, osalvador@suse.de

On Mon, Oct 15, 2018 at 8:31 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> HMM/devm have a particular handling of memory-hotplug.
> They do not go through the common path, and so, they do not
> call either offline_pages() or online_pages().
>
> The operations they perform are the following ones:
>
> 1) Create the linear mapping in case the memory is not private
> 2) Initialize the pages and add the sections
> 3) Move the pages to ZONE_DEVICE
>
> Due to this particular handling of hot-add/remove memory from HMM/devm,
> I think it would be nice to provide a helper function in order to
> make this cleaner, and not populate other regions with code
> that should belong to memory-hotplug.
>
> The helpers are named:
>
> del_device_memory
> add_device_memory
>
> The idea is that add_device_memory will be in charge of:
>
> a) call either arch_add_memory() or add_pages(), depending on whether
>    we want a linear mapping
> b) online the memory sections that correspond to the pfn range
> c) call move_pfn_range_to_zone() being zone ZONE_DEVICE to
>    expand zone/pgdat spanned pages and initialize its pages
>
> del_device_memory, on the other hand, will be in charge of:
>
> a) offline the memory sections that correspond to the pfn range
> b) call shrink_zone_pgdat_pages(), which shrinks node/zone spanned pages.
> c) call either arch_remove_memory() or __remove_pages(), depending on
>    whether we need to tear down the linear mapping or not
>
> The reason behind step b) from add_device_memory() and step a)
> from del_device_memory is that now find_smallest/biggest_section_pfn
> will have to check for online sections, and not for valid sections as
> they used to do, because we call offline_mem_sections() in
> offline_pages().
>
> In order to split up better the patches and ease the review,
> this patch will only make a) case work for add_device_memory(),
> and case c) for del_device_memory.
>
> The other cases will be added in the next patch.
>
> These two functions have to be called from devm/HMM code:
>
> dd_device_memory:
>         - devm_memremap_pages()
>         - hmm_devmem_pages_create()
>
> del_device_memory:
>         - hmm_devmem_release
>         - devm_memremap_pages_release
>
> One thing I do not know is whether we can move kasan calls out of the
> hotplug lock or not.
> If we can, we could move the hotplug lock within add/del_device_memory().
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/memory_hotplug.h | 11 +++++++++++
>  kernel/memremap.c              | 11 ++++-------
>  mm/hmm.c                       | 33 +++++++++++++++++----------------
>  mm/memory_hotplug.c            | 41 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 73 insertions(+), 23 deletions(-)

This collides with the refactoring of hmm, to be done in terms of
devm_memremap_pages(). I'd rather not introduce another common
function *beneath* hmm and devm_memremap_pages() and rather make
devm_memremap_pages() the common function.

I plan to resubmit that cleanup after Plumbers. So, unless I'm
misunderstanding some other benefit a nak from me on this patch as it
stands currently.
