Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id CC75F6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 13:48:57 -0500 (EST)
Received: by qgdz107 with SMTP id z107so1203362qgd.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 10:48:57 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id f82si4030148qhe.123.2015.03.04.10.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 10:48:56 -0800 (PST)
Date: Wed, 4 Mar 2015 12:48:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv4 03/24] mm: avoid PG_locked on tail pages
In-Reply-To: <1425486792-93161-4-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1503041246470.23719@gentwo.org>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 4 Mar 2015, Kirill A. Shutemov wrote:

> index c851ff92d5b3..58b98bced299 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -207,7 +207,8 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
>
>  struct page;	/* forward declaration */
>
> -TESTPAGEFLAG(Locked, locked)
> +#define PageLocked(page) test_bit(PG_locked, &compound_head(page)->flags)
> +
>  PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)

Hmmm... Now one of the pageflag functions operates on the head page unlike
the other pageflag functions that only operate on the flag indicated.

Given that pageflags provide a way to implement checks for head / tail
pages this seems to be a bad idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
