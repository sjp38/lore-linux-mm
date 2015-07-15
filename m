Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 788782802A6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:20:05 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so36660604qkd.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 13:20:05 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 102si6741003qgk.119.2015.07.15.13.20.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 13:20:04 -0700 (PDT)
Date: Wed, 15 Jul 2015 15:20:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1507151517290.30883@east.gentwo.org>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:

> Currently we take naive approach to page flags on compound -- we set the
> flag on the page without consideration if the flag makes sense for tail
> page or for compound page in general. This patchset try to sort this out
> by defining per-flag policy on what need to be done if page-flag helper
> operate on compound page.

Well we hand pointers to head pages around if handling compound pages.
References to tail pages are dicey and should only be used in a limited
way. At least that is true in the slab allocators and that was my
understanding in earlier years. Therefore it does not make sense
then check for tail pages.

> For now I catched one case of illigal usage of page flags or ->mapping:
> sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> It leads to setting dirty bit on tail pages and access to tail_page's
> ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> anyway.

Does this catch any errors?

> This patchset makes more sense if you take my THP refcounting into
> account: we will see more compound pages mapped with PTEs and we need to
> define behaviour of flags on compound pages to avoid bugs.

Ok that introduces the risk of pointers to tail pages becoming more of an
issue. But that does not affect non pagecache pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
