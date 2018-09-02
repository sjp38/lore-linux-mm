Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A85636B60EE
	for <linux-mm@kvack.org>; Sun,  2 Sep 2018 02:59:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so9396251pfn.3
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 23:59:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b69-v6sor4694961plb.139.2018.09.01.23.59.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Sep 2018 23:59:04 -0700 (PDT)
Date: Sun, 2 Sep 2018 16:58:59 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 3/7] mm/rmap: map_pte() was not handling private
 ZONE_DEVICE page properly v2
Message-ID: <20180902065859.GE28695@350D>
References: <20180824192549.30844-3-jglisse@redhat.com>
 <20180830144156.7226-1-jglisse@redhat.com>
 <20180831092724.GD28695@350D>
 <20180831161935.GB4111@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180831161935.GB4111@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

On Fri, Aug 31, 2018 at 12:19:35PM -0400, Jerome Glisse wrote:
> On Fri, Aug 31, 2018 at 07:27:24PM +1000, Balbir Singh wrote:
> > On Thu, Aug 30, 2018 at 10:41:56AM -0400, jglisse@redhat.com wrote:
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > Private ZONE_DEVICE pages use a special pte entry and thus are not
> > > present. Properly handle this case in map_pte(), it is already handled
> > > in check_pte(), the map_pte() part was lost in some rebase most probably.
> > > 
> > > Without this patch the slow migration path can not migrate back private
> > > ZONE_DEVICE memory to regular memory. This was found after stress
> > > testing migration back to system memory. This ultimatly can lead the
> > > CPU to an infinite page fault loop on the special swap entry.
> > > 
> > > Changes since v1:
> > >     - properly lock pte directory in map_pte()
> > > 
> > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > Cc: stable@vger.kernel.org
> > > ---
> > >  mm/page_vma_mapped.c | 9 ++++++++-
> > >  1 file changed, 8 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> > > index ae3c2a35d61b..bd67e23dce33 100644
> > > --- a/mm/page_vma_mapped.c
> > > +++ b/mm/page_vma_mapped.c
> > > @@ -21,7 +21,14 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
> > >  			if (!is_swap_pte(*pvmw->pte))
> > >  				return false;
> > >  		} else {
> > > -			if (!pte_present(*pvmw->pte))
> > > +			if (is_swap_pte(*pvmw->pte)) {
> > > +				swp_entry_t entry;
> > > +
> > > +				/* Handle un-addressable ZONE_DEVICE memory */
> > > +				entry = pte_to_swp_entry(*pvmw->pte);
> > > +				if (!is_device_private_entry(entry))
> > > +					return false;
> > 
> > OK, so we skip this pte from unmap since it's already unmapped? This prevents
> > try_to_unmap from unmapping it and it gets restored with MIGRATE_PFN_MIGRATE
> > flag cleared?
> > 
> > Sounds like the right thing, if I understand it correctly
> 
> Well not exactly we do not skip it, we replace it with a migration

I think I missed the !is_device_private_entry and missed the ! part,
so that seems reasonable

Reviewed-by: Balbir Singh <bsingharora@gmail.com>
