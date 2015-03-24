Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 79CAC6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:06:02 -0400 (EDT)
Received: by wetk59 with SMTP id k59so3036110wet.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 13:06:01 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id c9si8721092wiy.123.2015.03.24.13.06.00
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 13:06:00 -0700 (PDT)
Date: Tue, 24 Mar 2015 22:04:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
Message-ID: <20150324200442.GA6269@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CALYGNiOSczCjcJPWocXFnBm=mF7zjeA+xd9j=wBS_ZjZL5z0Pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiOSczCjcJPWocXFnBm=mF7zjeA+xd9j=wBS_ZjZL5z0Pw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 24, 2015 at 08:39:49PM +0300, Konstantin Khlebnikov wrote:
> On Thu, Mar 19, 2015 at 8:08 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
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
> Do you mean call of set_page_dirty() from zap_pte_range() ?

No. I trigger it earlier: set_page_dirty() from do_shared_fault().

> I think this should be replaced with vma operation:
> vma->vm_ops->set_page_dirty()

Does anybody know why would we want to dirtying pages with ->mapping ==
NULL?

I don't see a place where we can make any use of this. We probably could
avoid dirting such pages. Hm?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
