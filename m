Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id DB93F6B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 08:01:07 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so8806865wiv.0
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 05:01:07 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id jy4si2413912wid.62.2014.11.19.05.01.05
        for <linux-mm@kvack.org>;
        Wed, 19 Nov 2014 05:01:05 -0800 (PST)
Date: Wed, 19 Nov 2014 15:00:50 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
Message-ID: <20141119130050.GA29884@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
 <546C761D.6050407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <546C761D.6050407@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 19, 2014 at 11:51:09AM +0100, Jerome Marchand wrote:
> On 11/05/2014 03:49 PM, Kirill A. Shutemov wrote:
> > We're going to allow mapping of individual 4k pages of THP compound and
> > we need a cheap way to find out how many time the compound page is
> > mapped with PMD -- compound_mapcount() does this.
> > 
> > page_mapcount() counts both: PTE and PMD mappings of the page.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/mm.h   | 17 +++++++++++++++--
> >  include/linux/rmap.h |  4 ++--
> >  mm/huge_memory.c     | 23 ++++++++++++++---------
> >  mm/hugetlb.c         |  4 ++--
> >  mm/memory.c          |  2 +-
> >  mm/migrate.c         |  2 +-
> >  mm/page_alloc.c      | 13 ++++++++++---
> >  mm/rmap.c            | 50 +++++++++++++++++++++++++++++++++++++++++++-------
> >  8 files changed, 88 insertions(+), 27 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 1825c468f158..aef03acff228 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -435,6 +435,19 @@ static inline struct page *compound_head(struct page *page)
> >  	return page;
> >  }
> >  
> > +static inline atomic_t *compound_mapcount_ptr(struct page *page)
> > +{
> > +	return (atomic_t *)&page[1].mapping;
> > +}
> 
> IIUC your patch overloads the unused mapping field of the first tail
> page to store the PMD mapcount. That's a non obvious trick. Why not make
> it more explicit by adding a new field (say compound_mapcount - and the
> appropriate comment of course) to the union to which mapping already belong?

I don't think we want to bloat struct page description: nobody outside of
helpers should use it direcly. And it's exactly what we did to store
compound page destructor and compound page order.

> The patch description would benefit from more explanation too.

Agreed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
