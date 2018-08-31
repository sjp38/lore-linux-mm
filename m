Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8CE76B57D8
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 12:19:38 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 123-v6so234307qkl.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 09:19:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e7-v6si4651947qvb.153.2018.08.31.09.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 09:19:38 -0700 (PDT)
Date: Fri, 31 Aug 2018 12:19:35 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 3/7] mm/rmap: map_pte() was not handling private
 ZONE_DEVICE page properly v2
Message-ID: <20180831161935.GB4111@redhat.com>
References: <20180824192549.30844-3-jglisse@redhat.com>
 <20180830144156.7226-1-jglisse@redhat.com>
 <20180831092724.GD28695@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180831092724.GD28695@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

On Fri, Aug 31, 2018 at 07:27:24PM +1000, Balbir Singh wrote:
> On Thu, Aug 30, 2018 at 10:41:56AM -0400, jglisse@redhat.com wrote:
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > Private ZONE_DEVICE pages use a special pte entry and thus are not
> > present. Properly handle this case in map_pte(), it is already handled
> > in check_pte(), the map_pte() part was lost in some rebase most probably.
> > 
> > Without this patch the slow migration path can not migrate back private
> > ZONE_DEVICE memory to regular memory. This was found after stress
> > testing migration back to system memory. This ultimatly can lead the
> > CPU to an infinite page fault loop on the special swap entry.
> > 
> > Changes since v1:
> >     - properly lock pte directory in map_pte()
> > 
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Balbir Singh <bsingharora@gmail.com>
> > Cc: stable@vger.kernel.org
> > ---
> >  mm/page_vma_mapped.c | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> > index ae3c2a35d61b..bd67e23dce33 100644
> > --- a/mm/page_vma_mapped.c
> > +++ b/mm/page_vma_mapped.c
> > @@ -21,7 +21,14 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
> >  			if (!is_swap_pte(*pvmw->pte))
> >  				return false;
> >  		} else {
> > -			if (!pte_present(*pvmw->pte))
> > +			if (is_swap_pte(*pvmw->pte)) {
> > +				swp_entry_t entry;
> > +
> > +				/* Handle un-addressable ZONE_DEVICE memory */
> > +				entry = pte_to_swp_entry(*pvmw->pte);
> > +				if (!is_device_private_entry(entry))
> > +					return false;
> 
> OK, so we skip this pte from unmap since it's already unmapped? This prevents
> try_to_unmap from unmapping it and it gets restored with MIGRATE_PFN_MIGRATE
> flag cleared?
> 
> Sounds like the right thing, if I understand it correctly

Well not exactly we do not skip it, we replace it with a migration
pte see try_to_unmap_one() which get call with TTU_MIGRATION flag
set (which do not translate in PVMW_MIGRATION being set on contrary).

>From migration point of view even if this is a swap pte, it is still
a valid mapping of the page and is counted as such for all intent and
purposes. The only thing we don't need is flushing CPU tlb or cache.

So this all happens when we are migrating something back to regular
memory either because of CPU fault or because the device driver want
to make room in its memory and decided to evict that page back to
regular memory.

Cheers,
Jerome
