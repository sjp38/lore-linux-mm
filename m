Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 850D96B520B
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:34:22 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d1-v6so8035773qth.21
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:34:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 33-v6si5016879qtc.294.2018.08.30.07.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:34:21 -0700 (PDT)
Date: Thu, 30 Aug 2018 10:34:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/7] mm/rmap: map_pte() was not handling private
 ZONE_DEVICE page properly
Message-ID: <20180830143418.GC3529@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-3-jglisse@redhat.com>
 <20180830140538.GA28695@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180830140538.GA28695@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

On Fri, Aug 31, 2018 at 12:05:38AM +1000, Balbir Singh wrote:
> On Fri, Aug 24, 2018 at 03:25:44PM -0400, jglisse@redhat.com wrote:
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
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: stable@vger.kernel.org
> > ---
> >  mm/page_vma_mapped.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> > index ae3c2a35d61b..1cf5b9bfb559 100644
> > --- a/mm/page_vma_mapped.c
> > +++ b/mm/page_vma_mapped.c
> > @@ -21,6 +21,15 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
> >  			if (!is_swap_pte(*pvmw->pte))
> >  				return false;
> >  		} else {
> > +			if (is_swap_pte(*pvmw->pte)) {
> > +				swp_entry_t entry;
> > +
> > +				/* Handle un-addressable ZONE_DEVICE memory */
> > +				entry = pte_to_swp_entry(*pvmw->pte);
> > +				if (is_device_private_entry(entry))
> > +					return true;
> > +			}
> > +
> 
> This happens just for !PVMW_SYNC && PVMW_MIGRATION? I presume this
> is triggered via the remove_migration_pte() code path? Doesn't
> returning true here imply that we've taken the ptl lock for the
> pvmw?

This happens through try_to_unmap() from migrate_vma_unmap() and thus
has !PVMW_SYNC and !PVMW_MIGRATION

But you are right about the ptl lock, so looking at code we were just
doing pte modification without holding the pte lock but the
page_vma_mapped_walk() would not try to unlock as pvmw->ptl == NULL
so this never triggered any warning.

I am gonna post a v2 shortly which address that.

Cheers,
Jerome
