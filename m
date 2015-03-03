Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7890C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 10:22:57 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so23310216pdb.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 07:22:57 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id hf1si207384pac.201.2015.03.03.07.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 07:22:56 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 4 Mar 2015 01:22:51 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4D84E357804F
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 02:22:47 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t23FMbqK38076564
	for <linux-mm@kvack.org>; Wed, 4 Mar 2015 02:22:47 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t23FMBH7002442
	for <linux-mm@kvack.org>; Wed, 4 Mar 2015 02:22:11 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
In-Reply-To: <20150303133524.GA6111@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com> <54DD054E.7000605@redhat.com> <54DD08BC.2020008@redhat.com> <87egp69pyw.fsf@linux.vnet.ibm.com> <20150303133524.GA6111@node.dhcp.inet.fi>
Date: Tue, 03 Mar 2015 20:51:50 +0530
Message-ID: <87bnka9kdt.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Mar 03, 2015 at 06:51:11PM +0530, Aneesh Kumar K.V wrote:
>> Rik van Riel <riel@redhat.com> writes:
>> 
>> > -----BEGIN PGP SIGNED MESSAGE-----
>> > Hash: SHA1
>> >
>> > On 02/12/2015 02:55 PM, Rik van Riel wrote:
>> >> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
>> >
>> >>> @@ -490,6 +493,7 @@ extern int 
>> >>> wait_on_page_bit_killable_timeout(struct page *page,
>> >> 
>> >>> static inline int wait_on_page_locked_killable(struct page *page)
>> >>>  { +	page = compound_head(page); if (PageLocked(page)) return 
>> >>> wait_on_page_bit_killable(page, PG_locked); return 0; @@ -510,6 
>> >>> +514,7 @@ static inline void wake_up_page(struct page *page, int 
>> >>> bit) */ static inline void wait_on_page_locked(struct page *page)
>> >>>  { +	page = compound_head(page); if (PageLocked(page)) 
>> >>> wait_on_page_bit(page, PG_locked); }
>> >> 
>> >> These are all atomic operations.
>> >> 
>> >> This may be a stupid question with the answer lurking somewhere in
>> >> the other patches, but how do you ensure you operate on the right
>> >> page lock during a THP collapse or split?
>> >
>> > Kirill answered that question on IRC.
>> >
>> > The VM takes a refcount on a page before attempting to take a page
>> > lock, which prevents the THP code from doing anything with the
>> > page. In other words, while we have a refcount on the page, we
>> > will dereference the same page lock.
>> 
>> Can we explain this more ? Don't we allow a thp split to happen even if
>> we have page refcount ?.
>
> The patchset changes this. Have you read the cover letter?
>

Ok got that.

Thanks,
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
