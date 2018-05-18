Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBC016B05E6
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:00:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x134-v6so5382355oif.19
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:00:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b48-v6sor4426712otj.310.2018.05.18.09.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 09:00:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180518094616.GA25838@lst.de>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180518094616.GA25838@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 09:00:29 -0700
Message-ID: <CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri, May 18, 2018 at 2:46 AM, Christoph Hellwig <hch@lst.de> wrote:
> This looks reasonable to me.  A few more comments below.
>
>> This patch replaces and consolidates patch 2 [1] and 4 [2] from the v9
>> series [3] for "dax: fix dma vs truncate/hole-punch".
>
> Can you repost the whole series?  Otherwise things might get a little
> too confusing.

Sure thing.

>>               WARN_ON(IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API));
>> +             return 0;
>>       } else if (pfn_t_devmap(pfn)) {
>> +             struct dev_pagemap *pgmap;
>
> This should probably become something like:
>
>         bool supported = false;
>
>         ...
>
>
>         if (IS_ENABLED(CONFIG_FS_DAX_LIMITED) && pfn_t_special(pfn)) {
>                 ...
>                 supported = true;
>         } else if (pfn_t_devmap(pfn)) {
>                 pgmap = get_dev_pagemap(pfn_t_to_pfn(pfn), NULL);
>                 if (pgmap && pgmap->type == MEMORY_DEVICE_FS_DAX)
>                         supported = true;
>                 put_dev_pagemap(pgmap);
>         }
>
>         if (!supported) {
>                 pr_debug("VFS (%s): error: dax support not enabled\n",
>                         sb->s_id);
>                 return -EOPNOTSUPP;
>         }
>         return 0;

Looks good, will do.

>> +     select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
>
> Btw, what was the reason again we couldn't get rid of FS_DAX_LIMITED?

The last I heard from Gerald they were still mildly interested in
keeping the dccssblk dax support going with this limited mode, and
threatened to add full page support at a later date:

---
From: Gerald

dcssblk seems to work fine, I did not see any SIGBUS while "executing
in place" from dcssblk with the current upstream kernel, maybe because
we only use dcssblk with fs dax in read-only mode.

Anyway, the dcssblk change is fine with me. I will look into adding
struct pages for dcssblk memory later, to make it work again with
this change, but for now I do not know of anyone needing this in the
upstream kernel.

https://www.spinics.net/lists/linux-xfs/msg14628.html
---

>> +void generic_dax_pagefree(struct page *page, void *data)
>> +{
>> +     wake_up_var(&page->_refcount);
>> +}
>> +EXPORT_SYMBOL_GPL(generic_dax_pagefree);
>
> Why is this here and exported instead of static in drivers/nvdimm/pmem.c?

I was thinking it did not belong to the pmem driver, but you're right
unless / until we grow another fsdax capable driver this detail can
stay internal to the pmem driver.
