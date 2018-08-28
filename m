Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5409D6B4342
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 20:35:21 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s1-v6so782089qte.19
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 17:35:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n43-v6si728989qtc.232.2018.08.27.17.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 17:35:20 -0700 (PDT)
Date: Mon, 27 Aug 2018 20:35:17 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828003517.GA4042@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Aug 24, 2018 at 08:05:46PM -0400, Zi Yan wrote:
> Hi Jerome,
> 
> On 24 Aug 2018, at 15:25, jglisse@redhat.com wrote:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> >
> > Before this patch migration pmd entry (!pmd_present()) would have
> > been treated as a bad entry (pmd_bad() returns true on migration
> > pmd entry). The outcome was that device driver would believe that
> > the range covered by the pmd was bad and would either SIGBUS or
> > simply kill all the device's threads (each device driver decide
> > how to react when the device tries to access poisonnous or invalid
> > range of memory).
> >
> > This patch explicitly handle the case of migration pmd entry which
> > are non present pmd entry and either wait for the migration to
> > finish or report empty range (when device is just trying to pre-
> > fill a range of virtual address and thus do not want to wait or
> > trigger page fault).
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  mm/hmm.c | 45 +++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 39 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index a16678d08127..659efc9aada6 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -577,22 +577,47 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  {
> >  	struct hmm_vma_walk *hmm_vma_walk = walk->private;
> >  	struct hmm_range *range = hmm_vma_walk->range;
> > +	struct vm_area_struct *vma = walk->vma;
> >  	uint64_t *pfns = range->pfns;
> >  	unsigned long addr = start, i;
> >  	pte_t *ptep;
> > +	pmd_t pmd;
> >
> > -	i = (addr - range->start) >> PAGE_SHIFT;
> >
> >  again:
> > -	if (pmd_none(*pmdp))
> > +	pmd = READ_ONCE(*pmdp);
> > +	if (pmd_none(pmd))
> >  		return hmm_vma_walk_hole(start, end, walk);
> >
> > -	if (pmd_huge(*pmdp) && (range->vma->vm_flags & VM_HUGETLB))
> > +	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
> >  		return hmm_pfns_bad(start, end, walk);
> >
> > -	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
> > -		pmd_t pmd;
> > +	if (!pmd_present(pmd)) {
> > +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> > +
> > +		if (is_migration_entry(entry)) {
> 
> I think you should check thp_migration_supported() here, since PMD migration is only enabled in x86_64 systems.
> Other architectures should treat PMD migration entries as bad.

You are right, Andrew do you want to repost or can you edit above if
to:

if (thp_migration_supported() && is_migration_entry(entry)) {

Cheers,
Jerome
