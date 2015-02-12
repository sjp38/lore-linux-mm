Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7935D6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:56:35 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id m14so6541942wev.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:56:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id li8si4786281wic.1.2015.02.12.11.56.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 11:56:33 -0800 (PST)
Message-ID: <54DD054E.7000605@redhat.com>
Date: Thu, 12 Feb 2015 14:55:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
> With new refcounting pte entries can point to tail pages. It's
> doesn't make much sense to mark tail page locked -- we need to
> protect whole compound page.
> 
> This patch adjust helpers related to PG_locked to operate on head
> page.
> 
> Signed-off-by: Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> --- include/linux/page-flags.h |
> 3 ++- include/linux/pagemap.h    | 5 +++++ mm/filemap.c
> | 1 + mm/slub.c                  | 2 ++ 4 files changed, 10
> insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/page-flags.h
> b/include/linux/page-flags.h index 5ed7bdaf22d5..d471370f27e8
> 100644 --- a/include/linux/page-flags.h +++
> b/include/linux/page-flags.h @@ -207,7 +207,8 @@ static inline int
> __TestClearPage##uname(struct page *page) { return 0; }
> 
> struct page;	/* forward declaration */
> 
> -TESTPAGEFLAG(Locked, locked) +#define PageLocked(page)
> test_bit(PG_locked, &compound_head(page)->flags) + PAGEFLAG(Error,
> error) TESTCLEARFLAG(Error, error) PAGEFLAG(Referenced, referenced)
> TESTCLEARFLAG(Referenced, referenced) __SETPAGEFLAG(Referenced,
> referenced) diff --git a/include/linux/pagemap.h
> b/include/linux/pagemap.h index 4b3736f7065c..ad6da4e49555 100644 
> --- a/include/linux/pagemap.h +++ b/include/linux/pagemap.h @@
> -428,16 +428,19 @@ extern void unlock_page(struct page *page);
> 
> static inline void __set_page_locked(struct page *page) { +
> VM_BUG_ON_PAGE(PageTail(page), page); __set_bit(PG_locked,
> &page->flags); }
> 
> static inline void __clear_page_locked(struct page *page) { +
> VM_BUG_ON_PAGE(PageTail(page), page); __clear_bit(PG_locked,
> &page->flags); }
> 
> static inline int trylock_page(struct page *page) { +	page =
> compound_head(page); return
> (likely(!test_and_set_bit_lock(PG_locked, &page->flags))); }
> 
> @@ -490,6 +493,7 @@ extern int
> wait_on_page_bit_killable_timeout(struct page *page,
> 
> static inline int wait_on_page_locked_killable(struct page *page) 
> { +	page = compound_head(page); if (PageLocked(page)) return
> wait_on_page_bit_killable(page, PG_locked); return 0; @@ -510,6
> +514,7 @@ static inline void wake_up_page(struct page *page, int
> bit) */ static inline void wait_on_page_locked(struct page *page) 
> { +	page = compound_head(page); if (PageLocked(page)) 
> wait_on_page_bit(page, PG_locked); }

These are all atomic operations.

This may be a stupid question with the answer lurking somewhere
in the other patches, but how do you ensure you operate on the
right page lock during a THP collapse or split?



- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU3QVOAAoJEM553pKExN6DUtAH/2hjg6ab/9bArQ187YGssOoZ
yXqpeMgt0klHjqWxtVxZnzExbSfYIrrBKpg5kJJzqk2cQ/ZjMj0TbVnkgHhFEn3f
r6vh4wIljmmFjo+4RiYGEEJkQWNwFgX0XTEcJLw2VQp4xKL0wjhN1hC+SQBGiPL0
JefeCraxqAoq+viV65lvxWYJrXQ4Lm90z7dIa5fh8M5lG3P+Wy6cZXCeevV1Tvw7
iF20HuOTnGuNfClo7b5h/vCV6I6ViHEgThCCR3iBIdsh1L2bBoqMaNzDVD19tw7Y
m2I8Of/cc4eSadDJPkkfXxKD2w/qpbHxYXviN9dRq/qm7ApeySLN3GdW1K/xvAw=
=q6Zo
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
