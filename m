Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id DA21A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 08:35:42 -0500 (EST)
Received: by wivr20 with SMTP id r20so22721933wiv.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 05:35:42 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id di6si23917710wid.52.2015.03.03.05.35.40
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 05:35:41 -0800 (PST)
Date: Tue, 3 Mar 2015 15:35:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
Message-ID: <20150303133524.GA6111@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com>
 <54DD054E.7000605@redhat.com>
 <54DD08BC.2020008@redhat.com>
 <87egp69pyw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87egp69pyw.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 03, 2015 at 06:51:11PM +0530, Aneesh Kumar K.V wrote:
> Rik van Riel <riel@redhat.com> writes:
> 
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > On 02/12/2015 02:55 PM, Rik van Riel wrote:
> >> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
> >
> >>> @@ -490,6 +493,7 @@ extern int 
> >>> wait_on_page_bit_killable_timeout(struct page *page,
> >> 
> >>> static inline int wait_on_page_locked_killable(struct page *page)
> >>>  { +	page = compound_head(page); if (PageLocked(page)) return 
> >>> wait_on_page_bit_killable(page, PG_locked); return 0; @@ -510,6 
> >>> +514,7 @@ static inline void wake_up_page(struct page *page, int 
> >>> bit) */ static inline void wait_on_page_locked(struct page *page)
> >>>  { +	page = compound_head(page); if (PageLocked(page)) 
> >>> wait_on_page_bit(page, PG_locked); }
> >> 
> >> These are all atomic operations.
> >> 
> >> This may be a stupid question with the answer lurking somewhere in
> >> the other patches, but how do you ensure you operate on the right
> >> page lock during a THP collapse or split?
> >
> > Kirill answered that question on IRC.
> >
> > The VM takes a refcount on a page before attempting to take a page
> > lock, which prevents the THP code from doing anything with the
> > page. In other words, while we have a refcount on the page, we
> > will dereference the same page lock.
> 
> Can we explain this more ? Don't we allow a thp split to happen even if
> we have page refcount ?.

The patchset changes this. Have you read the cover letter?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
