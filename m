Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3A76B0069
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:41:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e64so16258268pfk.0
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:41:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si3997414plm.625.2017.10.23.05.41.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 05:41:25 -0700 (PDT)
Date: Mon, 23 Oct 2017 14:41:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-10-17 14:22:30, C.Wehrmeyer wrote:
> On 2017-10-23 13:42, Michal Hocko wrote:
> > I do not remember any such a request either. I can see some merit in the
> > described use case. It is not specific on why hugetlb pages are used for
> > the allocator memory because that comes with it own issues.
> 
> That is yet for the user to specify. As of now hugepages still require a
> special setup that not all people might have as of now - to my knowledge a
> kernel being compiled with CONFIG_TRANSPARENT_HUGEPAGE=y and a number of
> such pages being allocated either through the kernel boot line or through

CONFIG_TRANSPARENT_HUGEPAGE has nothing to do with hugetlb pages. These
are THP which do not need any special configuration and mremap works on
them.

> /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages. I'm deliberately
> ignoring 1-GiB pages here because those are only allocatable during boot,
> when no processes have been spawned and memory is still not fragmented.

This is no longer true. GB pages can be allocated during runtime as
well.
 
> My point is that I can see people not being too eager to support 1 GiB pages
> as of now unless for very specific use case.

1G or 2M pages make absolutely no difference from the mremap semantic.
It is just pte to be updated. The problem at hands is that hugetlb
implementation is far from straightforward and the lack of mremap is
mainly caused by implementation details (like reservetions I presume).

> 2-MiB pages, on the other hand,
> shouldn't have those limitations anymore. User-space programs should be
> capable of allocating such pages without the need for the user to fiddle
> with nr_hugepages beforehand.

And that is what we have THP for...

[...]

> With the knowledge that allocations in the Mebibyte range aren't uncommon at
> all nowadays and that one 2-MiB page eliminates the need for 512 4-KiB
> pages, we really should make advances towards treating 2-MiB pages just as
> casual as older pages. Allocators can still query if the kernel supports the
> specified page size, and specifying MAP_HUGETLB | MAP_HUGE_2MB would still
> be required in order to not break older programs, but from my perspective
> there is a lot to gain here.

I can see your sentiment here but hugetlb has never been really a full
featured type of memory. General purpose allocator playing with hugetlb
pages is rather tricky and I would be really cautious there. I would
rather play with THP to reduce the TLB footprint.

So by all means, mremap _should_ work with hugetlb pages but the
additional implementation and potentially the complexity should have a
strong usecase. If we can do mremap with old_size == new_size trivially
implemented then I am not really against but full featured mremap is not
worth it IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
