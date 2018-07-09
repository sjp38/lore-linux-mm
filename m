Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22AB76B0269
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 02:08:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so13796148oib.4
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 23:08:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor9459513oia.184.2018.07.08.23.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Jul 2018 23:08:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87muv1kluq.fsf@yhuang-dev.intel.com>
References: <20180622035151.6676-1-ying.huang@intel.com> <20180622035151.6676-2-ying.huang@intel.com>
 <CAA9_cmcwczyEb=+3F7HtDDqZA-3rdqgw=gkYipDtx5r+4Kd5Tw@mail.gmail.com> <87muv1kluq.fsf@yhuang-dev.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 8 Jul 2018 23:08:24 -0700
Message-ID: <CAPcyv4hxBwRx_XPt9MrDq6xgvFnCmQhJee_G3-k=c62vxYDv1A@mail.gmail.com>
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations
 for CONFIG_THP_SWAP
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

On Sun, Jul 8, 2018 at 10:40 PM, Huang, Ying <ying.huang@intel.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>>>
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> Previously, the PMD swap operations are only enabled for
>>> CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
>>> THP migration support.  We will support PMD swap mapping to the huge
>>> swap cluster and swapin the THP as a whole.  That will be enabled via
>>> CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
>>> PMD swap operations for CONFIG_THP_SWAP too.
>>>
>>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Shaohua Li <shli@kernel.org>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Minchan Kim <minchan@kernel.org>
>>> Cc: Rik van Riel <riel@redhat.com>
>>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>>> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>>> ---
>>>  arch/x86/include/asm/pgtable.h |  2 +-
>>>  include/asm-generic/pgtable.h  |  2 +-
>>>  include/linux/swapops.h        | 44 ++++++++++++++++++++++--------------------
>>>  3 files changed, 25 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
>>> index 99ecde23c3ec..13bf58838daf 100644
>>> --- a/arch/x86/include/asm/pgtable.h
>>> +++ b/arch/x86/include/asm/pgtable.h
>>> @@ -1224,7 +1224,7 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
>>>         return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
>>>  }
>>>
>>> -#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>>> +#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
>>
>> How about introducing a new config symbol representing the common
>> infrastructure between the two and have them select that symbol.
>
> The common infrastructure shared by two mechanisms is PMD swap entry.
> But I didn't find there are many places where the common infrastructure
> is used.  So I think it may be over-engineering to introduce a new
> config symbol but use it for so few times.
>
>> Would that also allow us to clean up the usage of
>> CONFIG_ARCH_ENABLE_THP_MIGRATION in fs/proc/task_mmu.c? In other
>> words, what's the point of having nice ifdef'd alternatives in header
>> files when ifdefs are still showing up in C files, all of it should be
>> optionally determined by header files.
>
> Unfortunately, I think it is not a easy task to wrap all C code via
> #ifdef in header files.  And it may be over-engineering to wrap them
> all.  I guess this is why there are still some #ifdef in C files.

That's the entire point. Yes, over-engineer the header files so the
actual C code is more readable.
