Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9358B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 08:31:40 -0500 (EST)
Received: by padfa1 with SMTP id fa1so24020684pad.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 05:31:40 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id i2si963804pdc.145.2015.03.03.05.31.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 05:31:39 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 3 Mar 2015 19:01:36 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 35BB7E0044
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 19:03:27 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t23DR6CL40239208
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 19:01:34 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t23DLjdj009710
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 18:51:45 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
In-Reply-To: <54DD08BC.2020008@redhat.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com> <54DD054E.7000605@redhat.com> <54DD08BC.2020008@redhat.com>
Date: Tue, 03 Mar 2015 18:51:11 +0530
Message-ID: <87egp69pyw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Rik van Riel <riel@redhat.com> writes:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> On 02/12/2015 02:55 PM, Rik van Riel wrote:
>> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
>
>>> @@ -490,6 +493,7 @@ extern int 
>>> wait_on_page_bit_killable_timeout(struct page *page,
>> 
>>> static inline int wait_on_page_locked_killable(struct page *page)
>>>  { +	page = compound_head(page); if (PageLocked(page)) return 
>>> wait_on_page_bit_killable(page, PG_locked); return 0; @@ -510,6 
>>> +514,7 @@ static inline void wake_up_page(struct page *page, int 
>>> bit) */ static inline void wait_on_page_locked(struct page *page)
>>>  { +	page = compound_head(page); if (PageLocked(page)) 
>>> wait_on_page_bit(page, PG_locked); }
>> 
>> These are all atomic operations.
>> 
>> This may be a stupid question with the answer lurking somewhere in
>> the other patches, but how do you ensure you operate on the right
>> page lock during a THP collapse or split?
>
> Kirill answered that question on IRC.
>
> The VM takes a refcount on a page before attempting to take a page
> lock, which prevents the THP code from doing anything with the
> page. In other words, while we have a refcount on the page, we
> will dereference the same page lock.

Can we explain this more ? Don't we allow a thp split to happen even if
we have page refcount ?.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
