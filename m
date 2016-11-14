Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7D136B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:22:09 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id kr7so100731089pab.5
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:22:09 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 63si24007366pfm.160.2016.11.14.15.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:22:09 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x23so10064092pgx.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:22:09 -0800 (PST)
Subject: Re: [PATCH v2 09/12] mm: hwpoison: soft offline supports thp
 migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <6e9aa943-31ea-5b08-8459-2e6a85940546@gmail.com>
 <20161110235853.GB22792@hori1.linux.bs1.fc.nec.co.jp>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <d9401974-08f7-5244-ebe2-9ac60d7aaa19@gmail.com>
Date: Tue, 15 Nov 2016 10:22:02 +1100
MIME-Version: 1.0
In-Reply-To: <20161110235853.GB22792@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 11/11/16 10:58, Naoya Horiguchi wrote:
> On Thu, Nov 10, 2016 at 09:31:10PM +1100, Balbir Singh wrote:
>>
>>
>> On 08/11/16 10:31, Naoya Horiguchi wrote:
>>> This patch enables thp migration for soft offline.
>>>
>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> ---
>>>  mm/memory-failure.c | 31 ++++++++++++-------------------
>>>  1 file changed, 12 insertions(+), 19 deletions(-)
>>>
>>> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
>>> index 19e796d..6cc8157 100644
>>> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c
>>> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
>>> @@ -1485,7 +1485,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>>>  	if (PageHuge(p))
>>>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>>>  						   nid);
>>> -	else
>>> +	else if (thp_migration_supported() && PageTransHuge(p)) {
>>> +		struct page *thp;
>>> +
>>> +		thp = alloc_pages_node(nid,
>>> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
>>> +			HPAGE_PMD_ORDER);
>>> +		if (!thp)
>>> +			return NULL;
>>
>> Just wondering if new_page() fails, migration of that entry fails. Do we then
>> split and migrate? I guess this applies to THP migration in general.
> 
> Yes, that's not implemented yet, but can be helpful.
> 
> I think that there are 2 types of callers of page migration,
> one is a caller that specifies the target pages individually (like move_pages
> and soft offline), and another is a caller that specifies the target pages
> by (physical/virtual) address range basis.
> Maybe the former ones want to fall back immediately to split and retry if
> thp migration fails, and the latter ones want to retry thp migration more.
> If this makes sense, we can make some more changes on retry logic to fit
> the situation.
> 

I think we definitely need the retry with split option, but may be we can
build it on top of this series.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
