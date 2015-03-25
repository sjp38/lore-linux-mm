Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id F40F36B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:55:50 -0400 (EDT)
Received: by wgs2 with SMTP id 2so22667613wgs.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:55:50 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id gx6si4441967wib.50.2015.03.25.03.55.48
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 03:55:49 -0700 (PDT)
Date: Wed, 25 Mar 2015 12:55:35 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
Message-ID: <20150325105535.GA10932@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1503221713370.3913@eggly.anvils>
 <20150323100433.GA30088@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1503241621050.2532@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503241621050.2532@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 24, 2015 at 04:42:48PM -0700, Hugh Dickins wrote:
> On Mon, 23 Mar 2015, Kirill A. Shutemov wrote:
> > Yes, it works until some sound driver decide it wants to use
> > page->mappging.
> 
> (a) Why would it want to use page->mapping?

No idea.

> (b) What's the problem if it wants to use page->mapping?

It would need to be initalized for all subpages to get core mm see correct
value. And this doesn't match with current ->mapping users of __GFP_COMP
page (THP and hugetlb) which initialize ->mapping only for head pages.

> (c) Or perhaps some __GFP_COMP driver does already use page->mapping?

I haven't found any.

> > It's just pure luck that it happened to work in this particular case.
> 
> We were lucky that it fitted together without needing extra code, yes.
> But this didn't happen by accident, it was known and considered.

I don't agree it was considered well enough.

> > You only need to pay the expense if you hit tail page which is very rare
> > in current kernel. I think we can pay this cost for correctness.
> 
> But it's correct as is.

See above.

> > 
> > We will shave some cost of compound_head() if/when my refcounting patchset
> > get merged: no need of barrier anymore.
> 
> And if these changes are necessary for that, sure, go ahead:
> but as part of that work.

I believe the patchset has value by its own. And having it merged makes my
life easier. But up to Andrew.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
