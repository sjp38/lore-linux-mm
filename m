Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAEA96B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:30:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25-v6so3021268pfn.19
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:30:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m23-v6si10506648pgb.420.2018.07.30.04.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 04:30:35 -0700 (PDT)
Date: Mon, 30 Jul 2018 13:30:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
Message-ID: <20180730113029.GM24267@dhcp22.suse.cz>
References: <20180727165454.27292-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727165454.27292-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@techadventures.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri 27-07-18 18:54:54, David Hildenbrand wrote:
> Right now, struct pages are inititalized when memory is onlined, not
> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
> memory hotplug")).
> 
> remove_memory() will call arch_remove_memory(). Here, we usually access
> the struct page to get the zone of the pages.
> 
> So effectively, we access stale struct pages in case we remove memory that
> was never onlined. So let's simply inititalize them earlier, when the
> memory is added. We only have to take care of updating the zone once we
> know it. We can use a dummy zone for that purpose.

I have considered something like this when I was reworking memory
hotplug to not associate struct pages with zone before onlining and I
considered this to be rather fragile. I would really not like to get
back to that again if possible.

> So effectively, all pages will already be initialized and set to
> reserved after memory was added but before it was onlined (and even the
> memblock is added). We only inititalize pages once, to not degrade
> performance.

To be honest, I would rather see d0dc12e86b31 reverted. It is late in
the release cycle and if the patch is buggy then it should be reverted
rather than worked around. I found the optimization not really
convincing back then and this is still the case TBH.
-- 
Michal Hocko
SUSE Labs
