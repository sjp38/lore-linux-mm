Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5321C6B026D
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 20:49:03 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id z32so5254648ota.5
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:49:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor9818073otb.235.2017.12.22.17.49.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 17:49:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-5-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-5-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Dec 2017 17:49:01 -0800
Message-ID: <CAPcyv4jyjNM1nRskA5Q9Q6w69OeL1=mssyTYDqFXqW2X40Oc0g@mail.gmail.com>
Subject: Re: [PATCH 04/17] mm: pass the vmem_altmap to arch_add_memory and __add_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> We can just pass this on instead of having to do a radix tree lookup
> without proper locking 2 levels into the callchain.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
[..]
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 403ab9cdb949..16456117a1b1 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -427,7 +427,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>                 goto err_pfn_remap;
>
>         mem_hotplug_begin();
> -       error = arch_add_memory(nid, align_start, align_size, false);
> +       error = arch_add_memory(nid, align_start, align_size, altmap, false);
>         if (!error)
>                 move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
>                                         align_start >> PAGE_SHIFT,

Subtle bug here. This altmap is the one that was passed in that we
copy into its permanent location in the pgmap, so it looks like this
patch needs to fold the following fix:

diff --git a/kernel/memremap.c b/kernel/memremap.c
index f277bf5b8c57..157a3756e1d5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -382,6 +382,7 @@ void *devm_memremap_pages(struct device *dev,
struct resource *res,
        if (altmap) {
                memcpy(&page_map->altmap, altmap, sizeof(*altmap));
                pgmap->altmap = &page_map->altmap;
+               altmap = pgmap->altmap;
        }
        pgmap->ref = ref;
        pgmap->res = &page_map->res;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
