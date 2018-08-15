Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 031D86B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 20:16:10 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id m19-v6so11418825uap.3
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 17:16:09 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b29-v6si10217329uac.19.2018.08.14.17.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 17:16:08 -0700 (PDT)
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
 <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
 <d4cf0f85-e010-36f2-3fae-f7983e4f6505@oracle.com>
 <20180814084837.nl7dkea7aov2pzao@black.fi.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <17bfe24d-957f-2985-f134-3ebe2648aecb@oracle.com>
Date: Tue, 14 Aug 2018 17:15:57 -0700
MIME-Version: 1.0
In-Reply-To: <20180814084837.nl7dkea7aov2pzao@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 08/14/2018 01:48 AM, Kirill A. Shutemov wrote:
> On Mon, Aug 13, 2018 at 11:21:41PM +0000, Mike Kravetz wrote:
>> On 08/13/2018 03:58 AM, Kirill A. Shutemov wrote:
>>> On Sun, Aug 12, 2018 at 08:41:08PM -0700, Mike Kravetz wrote:
>>>> I am not %100 sure on the required flushing, so suggestions would be
>>>> appreciated.  This also should go to stable.  It has been around for
>>>> a long time so still looking for an appropriate 'fixes:'.
>>>
>>> I believe we need flushing. And huge_pmd_unshare() usage in
>>> __unmap_hugepage_range() looks suspicious: I don't see how we flush TLB in
>>> that case.
>>
>> Thanks Kirill,
>>
>> __unmap_hugepage_range() has two callers:
>> 1) unmap_hugepage_range, which wraps the call with tlb_gather_mmu and
>>    tlb_finish_mmu on the range.  IIUC, this should cause an appropriate
>>    TLB flush.
>> 2) __unmap_hugepage_range_final via unmap_single_vma.  unmap_single_vma
>>   has three callers:
>>   - unmap_vmas which assumes the caller will flush the whole range after
>>     return.
>>   - zap_page_range wraps the call with tlb_gather_mmu/tlb_finish_mmu
>>   - zap_page_range_single wraps the call with tlb_gather_mmu/tlb_finish_mmu
>>
>> So, it appears we are covered.  But, I could be missing something.
> 
> My problem here is that the mapping that moved by huge_pmd_unshare() in
> not accounted into mmu_gather and can be missed on tlb_finish_mmu().

Ah, I think I now see the issue you are concerned with.

When huge_pmd_unshare succeeds we effectively unmap a PUD_SIZE area.
The routine __unmap_hugepage_range may only have been passed a range
that is a subset of PUD_SIZE.  In the case I was trying to address,
try_to_unmap_one() the 'range' will certainly be less than PUD_SIZE.
Upon further thought, I think that even in the case of try_to_unmap_one
we should flush PUD_SIZE range.

My first thought would be to embed this flushing within huge_pmd_unshare
itself.  Perhaps, whenever huge_pmd_unshare succeeds we should do an
explicit:
flush_cache_range(PUD_SIZE)
flush_tlb_range(PUD_SIZE)
mmu_notifier_invalidate_range(PUD_SIZE)
That would take some of the burden off the callers of huge_pmd_unshare.
However, I am not sure if the flushing calls above play nice in all the
calling environments.  I'll look into it some more, but would appreciate
additional comments.

-- 
Mike Kravetz
