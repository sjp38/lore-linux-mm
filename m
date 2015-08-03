Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id ED14E6B0257
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 06:43:31 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so115247940wib.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:43:31 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id i2si24690345wjz.123.2015.08.03.03.43.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 03:43:30 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so108359069wib.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:43:29 -0700 (PDT)
Date: Mon, 3 Aug 2015 13:43:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9 26/36] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Message-ID: <20150803104328.GB25034@node.dhcp.inet.fi>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437402069-105900-27-git-send-email-kirill.shutemov@linux.intel.com>
 <55BB8E72.3070101@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55BB8E72.3070101@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 31, 2015 at 05:04:18PM +0200, Jerome Marchand wrote:
> On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> > We're going to allow mapping of individual 4k pages of THP compound.
> > It means we need to track mapcount on per small page basis.
> > 
> > Straight-forward approach is to use ->_mapcount in all subpages to track
> > how many time this subpage is mapped with PMDs or PTEs combined. But
> > this is rather expensive: mapping or unmapping of a THP page with PMD
> > would require HPAGE_PMD_NR atomic operations instead of single we have
> > now.
> > 
> > The idea is to store separately how many times the page was mapped as
> > whole -- compound_mapcount. This frees up ->_mapcount in subpages to
> > track PTE mapcount.
> > 
> > We use the same approach as with compound page destructor and compound
> > order to store compound_mapcount: use space in first tail page,
> > ->mapping this time.
> > 
> > Any time we map/unmap whole compound page (THP or hugetlb) -- we
> > increment/decrement compound_mapcount. When we map part of compound page
> > with PTE we operate on ->_mapcount of the subpage.
> > 
> > page_mapcount() counts both: PTE and PMD mappings of the page.
> > 
> > Basically, we have mapcount for a subpage spread over two counters.
> > It makes tricky to detect when last mapcount for a page goes away.
> > 
> > We introduced PageDoubleMap() for this. When we split THP PMD for the
> > first time and there's other PMD mapping left we offset up ->_mapcount
> > in all subpages by one and set PG_double_map on the compound page.
> > These additional references go away with last compound_mapcount.
> 
> So this stays even if all PTE mappings goes and the page is again mapped
> only with PMD. I'm not sure how often that happen and if it's an issue
> worth caring about.

We don't have a cheap way to detect this situation and it shouldn't
happen often enough to care.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
