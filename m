Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFA0F6B000A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 01:40:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g20-v6so11058346pfi.2
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 22:40:50 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id z3-v6si13486914pgl.579.2018.07.08.22.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 22:40:49 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations for CONFIG_THP_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-2-ying.huang@intel.com>
	<CAA9_cmcwczyEb=+3F7HtDDqZA-3rdqgw=gkYipDtx5r+4Kd5Tw@mail.gmail.com>
Date: Mon, 09 Jul 2018 13:40:45 +0800
In-Reply-To: <CAA9_cmcwczyEb=+3F7HtDDqZA-3rdqgw=gkYipDtx5r+4Kd5Tw@mail.gmail.com>
	(Dan Williams's message of "Sat, 7 Jul 2018 14:11:18 -0700")
Message-ID: <87muv1kluq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, n-horiguchi@ah.jp.nec.com, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

Dan Williams <dan.j.williams@intel.com> writes:

> On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> Previously, the PMD swap operations are only enabled for
>> CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
>> THP migration support.  We will support PMD swap mapping to the huge
>> swap cluster and swapin the THP as a whole.  That will be enabled via
>> CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
>> PMD swap operations for CONFIG_THP_SWAP too.
>>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>> ---
>>  arch/x86/include/asm/pgtable.h |  2 +-
>>  include/asm-generic/pgtable.h  |  2 +-
>>  include/linux/swapops.h        | 44 ++++++++++++++++++++++--------------------
>>  3 files changed, 25 insertions(+), 23 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
>> index 99ecde23c3ec..13bf58838daf 100644
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -1224,7 +1224,7 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
>>         return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
>>  }
>>
>> -#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
>
> How about introducing a new config symbol representing the common
> infrastructure between the two and have them select that symbol.

The common infrastructure shared by two mechanisms is PMD swap entry.
But I didn't find there are many places where the common infrastructure
is used.  So I think it may be over-engineering to introduce a new
config symbol but use it for so few times.

> Would that also allow us to clean up the usage of
> CONFIG_ARCH_ENABLE_THP_MIGRATION in fs/proc/task_mmu.c? In other
> words, what's the point of having nice ifdef'd alternatives in header
> files when ifdefs are still showing up in C files, all of it should be
> optionally determined by header files.

Unfortunately, I think it is not a easy task to wrap all C code via
#ifdef in header files.  And it may be over-engineering to wrap them
all.  I guess this is why there are still some #ifdef in C files.

Best Regards,
Huang, Ying
