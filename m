Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECEAE6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:58:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id l89-v6so7379330otc.6
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 15:58:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23-v6sor14830994oix.10.2018.10.11.15.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 15:58:43 -0700 (PDT)
MIME-Version: 1.0
References: <20181011221237.1925.85591.stgit@localhost.localdomain> <20181011221351.1925.67694.stgit@localhost.localdomain>
In-Reply-To: <20181011221351.1925.67694.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 11 Oct 2018 15:58:31 -0700
Message-ID: <CAPcyv4gw4YRJXZrXHunKwqbhXPekiNU6jsYkrpoBtznv0Py-sg@mail.gmail.com>
Subject: Re: [mm PATCH v2 4/6] mm: Do not set reserved flag for hotplug memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Zhang Yi <yi.z.zhang@linux.intel.com>, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>, sparclinux@vger.kernel.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Oct 11, 2018 at 3:18 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> The general suspicion at this point is that the setting of the reserved bit
> is not really needed for hotplug memory. In addition the setting of this
> bit results in issues for DAX in that it is not possible to assign the
> region to KVM if the reserved bit is set in each page.
>
> For now we can try just not setting the bit since we suspect it isn't
> adding value in setting it. If at a later time we find that it is needed we
> can come back through and re-add it for the hotplug paths.
>
> Suggested-by: Michael Hocko <mhocko@suse.com>
> Reported-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  mm/page_alloc.c |   11 -----------
>  1 file changed, 11 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3603d5444865..e435223e2ddb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5571,8 +5571,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>
>                 page = pfn_to_page(pfn);
>                 __init_single_page(page, pfn, zone, nid);
> -               if (context == MEMMAP_HOTPLUG)
> -                       __SetPageReserved(page);

At a minimum I think we need to do this before removing PageReserved,
to make sure zone_device pages are not tracked in the hibernation
image.

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 3d37c279c090..c0613137d726 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1285,6 +1285,9 @@ static struct page *saveable_page(struct zone
*zone, unsigned long pfn)
        if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
                return NULL;

+       if (is_zone_device_page(page))
+               return NULL;
+
        if (PageReserved(page)
            && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
                return NULL;
