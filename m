Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id CFB0D6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:29:38 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so74453544wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:29:38 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id gc7si4596121wib.89.2015.08.13.08.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 08:29:35 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so264256573wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:29:35 -0700 (PDT)
Message-ID: <55CCB7DD.7080005@plexistor.com>
Date: Thu, 13 Aug 2015 18:29:33 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
 KVA
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com> <55CC3222.5090503@plexistor.com> <20150813143744.GA17375@lst.de> <55CCAE57.20009@plexistor.com>
In-Reply-To: <55CCAE57.20009@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org

On 08/13/2015 05:48 PM, Boaz Harrosh wrote:
<>
> There is already an object that holds a relationship of physical
> to Kernel-virtual. It is called a memory-section. Why not just
> widen its definition?
> 

BTW: Regarding the "widen its definition"

I was thinking of two possible new models here:
[1-A page-less memory section]
- Keep the 64bit phisical-to-kernel_virtual hard coded relationship
- Allocate a section-object, but this section object does not have any
  pages, its only the header. (You need it for the pmd/pmt thing)

  Lots of things just work now if you make sure you do not go through
  a page struct. This needs no extra work I have done this in the past
  all you need is to do your ioremap through the map_kernel_range_noflush(__va(), ....)

[2- Small pages-struct]

- Like above, but each entry in the new section object is small one-ulong size
  holding just flags.

 Then if !(p->flags & PAGE_SPECIAL) page = container_of(p, struct page, flags)

 This model is good because you actually have your pfn_to_page and page_to_pfn
 and need not touch sg-list or bio. But only 8 bytes per frame instead of 64 bytes


But I still think that the best long-term model is the variable size pages
where a page* can be 2M or 1G. Again an extra flag and a widen section definition.
Is about time we move to bigger pages, throughout but still keep the 4k
page-cache-dirty granularity.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
