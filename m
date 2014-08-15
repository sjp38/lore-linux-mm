Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 07E9A6B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 16:38:54 -0400 (EDT)
Received: by mail-yk0-f177.google.com with SMTP id 79so2501445ykr.36
        for <linux-mm@kvack.org>; Fri, 15 Aug 2014 13:38:54 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id v61si14082521yhn.157.2014.08.15.13.38.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 Aug 2014 13:38:53 -0700 (PDT)
Message-ID: <1408134524.26567.38.camel@misato.fc.hp.com>
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 15 Aug 2014 14:28:44 -0600
In-Reply-To: <53EB5960.50200@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Wed, 2014-08-13 at 15:26 +0300, Boaz Harrosh wrote:
> From: Yigal Korman <yigal@plexistor.com>
> 
> One of the current short comings of the NVDIMM/PMEM
> support is that this memory does not have a page-struct(s)
> associated with its memory and therefor cannot be passed
> to a block-device or network or DMAed in any way through
> another device in the system.
> 
> This simple patch fixes all this. After this patch an FS
> can do:
> 	bdev_direct_access(,&pfn,);
> 	page = pfn_to_page(pfn);
> And use that page for a lock_page(), set_page_dirty(), and/or
> anything else one might do with a page *.
> (Note that with brd one can already do this)
> 
> [pmem-pages-ref-count]
> pmem will serve it's pages with ref==0. Once an FS does
> an blkdev_get_XXX(,FMODE_EXCL,), that memory is own by the FS.
> The FS needs to manage its allocation, just as it already does
> for its disk blocks. The fs should set page->count = 2, before
> submission to any Kernel subsystem so when it returns it will
> never be released to the Kernel's page-allocators. (page_freeze)
> 
> All is actually needed for this is to allocate page-sections
> and map them into kernel virtual memory. Note that these sections
> are not associated with any zone, because that would add them to
> the page_allocators.

Can we just use memory hotplug and call add_memory(), instead of
directly calling sparse_add_one_section()?  Memory hotplug adds memory
as off-line state, and sets all pages reserved.  So, I do not think the
page allocators will mess with them (unless you put them online).  It
can also maps the pages with large page size.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
