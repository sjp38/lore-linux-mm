Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id CC0C76B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 09:44:51 -0500 (EST)
Received: by qgeb1 with SMTP id b1so146077661qge.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 06:44:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u127si19594435qka.6.2015.12.07.06.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 06:44:51 -0800 (PST)
Date: Mon, 7 Dec 2015 15:44:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages
 during MMU gather
Message-ID: <20151207144445.GG29105@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
 <1447938052-22165-2-git-send-email-aarcange@redhat.com>
 <20151119162255.b73e9db832501b40e1850c1a@linux-foundation.org>
 <20151123160302.GX5078@redhat.com>
 <87poyl5mlo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87poyl5mlo.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Sat, Dec 05, 2015 at 01:54:51PM +0530, Aneesh Kumar K.V wrote:
> If we can update mmu_gather to track the page size of the pages, that
> will also help some archs to better implement tlb_flush(struct
> mmu_gather *). Right now arch/powerpc/mm/tlb_nohash.c does flush the tlb
> mapping for the entire mm_struct. 
> 
> we can also make sure that we do a force flush when we are trying to
> gather pages of different size. So one instance of mmu_gather will end
> up gathering pages of specific size only ?

Tracking the TLB flush of multiple page sizes won't bring down the
complexity of the fix though, in fact the multiple page sizes are
arch-knowledge so such improvement would need to break the arch API
of the MMU gather.

THP is a common code abstraction, so the fix is self contained into
the common code and it can't take more than one bit to encode the
flush size because THP supports only one page size.

To achieve the multiple TLB flush size we could use an array of
unsigned long long physaddr where the bits below PAGE_SHIFT are the
page order. That would however require a pfn_to_page then to free the
page, so it's probably better to have the page struct and a order in
two different fields and double up the array size of the MMU
gather. Then we could as well look if we can go cross-mm so that it's
usable for the rmap-walk too, which is what I was looking into when I
found the THP SMP TLB flushing theoretical race.

In my view this is even more complicated from an implementation
standpoint because it isn't self contained in the common code. So I
doubt it's worth mixing the optimization in arch code for hugetlbfs
with the THP race fix that is all common code knowledge and it's
actually a fix (albeit purely theoretical) and not an optimization.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
