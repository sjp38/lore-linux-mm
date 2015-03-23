Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EDFBC6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:28:56 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so169804235pdn.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:28:56 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id cb5si7883975pbb.125.2015.03.22.17.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 17:28:56 -0700 (PDT)
Received: by padcy3 with SMTP id cy3so173422994pad.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:28:56 -0700 (PDT)
Date: Sun, 22 Mar 2015 17:28:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1503221713370.3913@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:

> Currently we take naive approach to page flags on compound -- we set the
> flag on the page without consideration if the flag makes sense for tail
> page or for compound page in general. This patchset try to sort this out
> by defining per-flag policy on what need to be done if page-flag helper
> operate on compound page.
> 
> The last patch in patchset also sanitize usege of page->mapping for tail
> pages. We don't define meaning of page->mapping for tail pages. Currently
> it's always NULL, which can be inconsistent with head page and potentially
> lead to problems.
> 
> For now I catched one case of illigal usage of page flags or ->mapping:
> sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> It leads to setting dirty bit on tail pages and access to tail_page's
> ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> anyway.

But there's nothing to fix there.  We're more used to having page->mapping
set by filesystems, but it is normal for drivers to have pages with NULL
page->mapping mapped into userspace (and it's not accidental that they
appear !PageAnon); and subpages of compound pages mapped into userspace,
and set_page_dirty applied to them.

> 
> This patchset makes more sense if you take my THP refcounting into
> account: we will see more compound pages mapped with PTEs and we need to
> define behaviour of flags on compound pages to avoid bugs.

Yes, I quite understand that you want to clarify the usage of different
page flags to yourself, to help towards a policy of what to do with each
of them when subpages of a huge compound page are mapped into userspace;
but I don't see that we need this patchset in the kernel now, given that
it adds unnecessary overhead into several low-level inline functions.

I'm surprised that Andrew has fast-tracked it into his mmotm tree:
I don't think it's harmful beyond the overhead, but it seems premature:
let's wait until we get some benefit too?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
