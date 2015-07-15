Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 15D18280245
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:19:35 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so43302984wgx.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:19:34 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id df10si10104476wjc.48.2015.07.15.14.19.32
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 14:19:33 -0700 (PDT)
Date: Thu, 16 Jul 2015 00:18:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
Message-ID: <20150715211853.GA25181@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.11.1507151517290.30883@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507151517290.30883@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 15, 2015 at 03:20:01PM -0500, Christoph Lameter wrote:
> On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> 
> > Currently we take naive approach to page flags on compound -- we set the
> > flag on the page without consideration if the flag makes sense for tail
> > page or for compound page in general. This patchset try to sort this out
> > by defining per-flag policy on what need to be done if page-flag helper
> > operate on compound page.
> 
> Well we hand pointers to head pages around if handling compound pages.
> References to tail pages are dicey and should only be used in a limited
> way. At least that is true in the slab allocators and that was my
> understanding in earlier years. Therefore it does not make sense
> then check for tail pages.

This is preparation patchset for THP refcounting rework. With new
refcounting sub-pages for THP can be mapped with PTEs, therefore we will
see tail pages returned from pte_page().

I've tried ad-hoc approach to page flags wrt tail pages on earlier (pre
LFS/MM) revisions of THP refcounting patchset. And IIRC, *you* pointed
that it would be nice to have more systematic approach.

And here's my attempt.

> > For now I catched one case of illigal usage of page flags or ->mapping:
> > sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> > It leads to setting dirty bit on tail pages and access to tail_page's
> > ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> > anyway.
> 
> Does this catch any errors?

It helped to catch BUG fixed by c761471b58e6 (mm: avoid tail page
refcounting on non-THP compound pages) and helped with work on
refcounting patchset.
 
> > This patchset makes more sense if you take my THP refcounting into
> > account: we will see more compound pages mapped with PTEs and we need to
> > define behaviour of flags on compound pages to avoid bugs.
> 
> Ok that introduces the risk of pointers to tail pages becoming more of an
> issue. But that does not affect non pagecache pages.

We don't have huge pages in pagecache yet. Refcounting patchset only
affects anon-THP. And makes compound pages suitable for pagecache.

We also have PTE-mapped compound pages -- in sound subsystem and some
drivers (framebuffer, etc.)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
