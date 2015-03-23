Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 310946B0078
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:04:50 -0400 (EDT)
Received: by wetk59 with SMTP id k59so133366547wet.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 03:04:49 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id zb3si404047wjc.137.2015.03.23.03.04.47
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 03:04:48 -0700 (PDT)
Date: Mon, 23 Mar 2015 12:04:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
Message-ID: <20150323100433.GA30088@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1503221713370.3913@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503221713370.3913@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 22, 2015 at 05:28:47PM -0700, Hugh Dickins wrote:
> On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> 
> > Currently we take naive approach to page flags on compound -- we set the
> > flag on the page without consideration if the flag makes sense for tail
> > page or for compound page in general. This patchset try to sort this out
> > by defining per-flag policy on what need to be done if page-flag helper
> > operate on compound page.
> > 
> > The last patch in patchset also sanitize usege of page->mapping for tail
> > pages. We don't define meaning of page->mapping for tail pages. Currently
> > it's always NULL, which can be inconsistent with head page and potentially
> > lead to problems.
> > 
> > For now I catched one case of illigal usage of page flags or ->mapping:
> > sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> > It leads to setting dirty bit on tail pages and access to tail_page's
> > ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> > anyway.
> 
> But there's nothing to fix there.  We're more used to having page->mapping
> set by filesystems, but it is normal for drivers to have pages with NULL
> page->mapping mapped into userspace (and it's not accidental that they
> appear !PageAnon); and subpages of compound pages mapped into userspace,
> and set_page_dirty applied to them.

Yes, it works until some sound driver decide it wants to use
page->mappging.

It's just pure luck that it happened to work in this particular case.

> > This patchset makes more sense if you take my THP refcounting into
> > account: we will see more compound pages mapped with PTEs and we need to
> > define behaviour of flags on compound pages to avoid bugs.
> 
> Yes, I quite understand that you want to clarify the usage of different
> page flags to yourself, to help towards a policy of what to do with each
> of them when subpages of a huge compound page are mapped into userspace;
> but I don't see that we need this patchset in the kernel now, given that
> it adds unnecessary overhead into several low-level inline functions.

We already have subpages of compound page mapped to userspace -- the sound
case.

And what overhead are you talking about?

Check for compound or head bit is practically free in most cases since you
are going to check other bits in the same cache line anyway. Probably a
bit more expensive if the flag is encoded in ->mapping or somewhere else.
(on 32-bit x86 ->mapping case is also free, since it's in the same cache
line as ->flags).

You only need to pay the expense if you hit tail page which is very rare
in current kernel. I think we can pay this cost for correctness.

We will shave some cost of compound_head() if/when my refcounting patchset
get merged: no need of barrier anymore.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
