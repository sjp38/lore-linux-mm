Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id F2CEF6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 09:04:43 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so949378wgh.18
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:04:43 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id l2si3297023wix.39.2014.11.25.06.04.42
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 06:04:42 -0800 (PST)
Date: Tue, 25 Nov 2014 16:04:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/19] mm, thp: drop FOLL_SPLIT
Message-ID: <20141125140428.GA11841@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20141125030109.GA21716@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141125030109.GA21716@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Nov 25, 2014 at 03:01:16AM +0000, Naoya Horiguchi wrote:
> On Wed, Nov 05, 2014 at 04:49:36PM +0200, Kirill A. Shutemov wrote:
> > FOLL_SPLIT is used only in two places: migration and s390.
> > 
> > Let's replace it with explicit split and remove FOLL_SPLIT.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> ...
> > @@ -1246,6 +1246,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> >  		if (!page)
> >  			goto set_status;
> >  
> > +		if (PageTransHuge(page) && split_huge_page(page)) {
> > +			err = -EBUSY;
> > +			goto set_status;
> > +		}
> > +
> 
> This check makes split_huge_page() be called for hugetlb pages, which
> triggers BUG_ON. So could you do this after if (PageHuge) block below?
> And I think that we have "Node already in the right place" check afterward,
> so I hope that moving down this check also helps us reduce thp splitting.

It makes sense. Thanks for report.

Other problem here is that we need to goto put_and_set, not set_status :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
