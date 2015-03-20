Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1B56B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:35:56 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so106522837pab.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:35:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pf2si11496699pdb.27.2015.03.20.13.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 13:35:55 -0700 (PDT)
Date: Fri, 20 Mar 2015 13:35:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/16] page-flags: introduce page flags policies wrt
 compound pages
Message-Id: <20150320133553.eb8576a5ff1e85f201690628@linux-foundation.org>
In-Reply-To: <1426784902-125149-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1426784902-125149-4-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015 19:08:09 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> This patch third argument to macros which create function definitions
> for page flags. This arguments defines how page-flags helpers behave
> on compound functions.
> 
> For now we define four policies:
> 
>  - ANY: the helper function operates on the page it gets, regardless if
>    it's non-compound, head or tail.
> 
>  - HEAD: the helper function operates on the head page of the compound
>    page if it gets tail page.
> 
>  - NO_TAIL: only head and non-compond pages are acceptable for this
>    helper function.
> 
>  - NO_COMPOUND: only non-compound pages are acceptable for this helper
>    function.
> 
> For now we use policy ANY for all helpers, which match current
> behaviour.
> 
> We do not enforce the policy for TESTPAGEFLAG, because we have flags
> checked for random pages all over the kernel. Noticeable exception to
> this is PageTransHuge() which triggers VM_BUG_ON() for tail page.
> 
> +/* Page flags policies wrt compound pages */
> +#define ANY(page, enforce)	page
> +#define HEAD(page, enforce)	compound_head(page)
> +#define NO_TAIL(page, enforce) ({					\
> +#define NO_COMPOUND(page, enforce) ({					\
> ...
>
> +#undef ANY
> +#undef HEAD
> +#undef NO_TAIL
> +#undef NO_COMPOUND
>  #endif /* !__GENERATING_BOUNDS_H */

This is risky - there are existing definitions of ANY and HEAD, and
this code may go and undefine them.  This is improbable at present, as
those definitions are in .c, after all includes.  But still, it's not
good to chew off great hunks of the namespace like this.

So I think I'll prefix all these with "PF_", OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
