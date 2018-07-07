Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5CF16B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 17:11:30 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p21-v6so12252320itc.7
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 14:11:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w143-v6sor4523863iow.74.2018.07.07.14.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 14:11:29 -0700 (PDT)
MIME-Version: 1.0
References: <20180622035151.6676-1-ying.huang@intel.com> <20180622035151.6676-2-ying.huang@intel.com>
In-Reply-To: <20180622035151.6676-2-ying.huang@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 7 Jul 2018 14:11:18 -0700
Message-ID: <CAA9_cmcwczyEb=+3F7HtDDqZA-3rdqgw=gkYipDtx5r+4Kd5Tw@mail.gmail.com>
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations
 for CONFIG_THP_SWAP
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, n-horiguchi@ah.jp.nec.com, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>
> From: Huang Ying <ying.huang@intel.com>
>
> Previously, the PMD swap operations are only enabled for
> CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
> THP migration support.  We will support PMD swap mapping to the huge
> swap cluster and swapin the THP as a whole.  That will be enabled via
> CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
> PMD swap operations for CONFIG_THP_SWAP too.
>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  arch/x86/include/asm/pgtable.h |  2 +-
>  include/asm-generic/pgtable.h  |  2 +-
>  include/linux/swapops.h        | 44 ++++++++++++++++++++++--------------------
>  3 files changed, 25 insertions(+), 23 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 99ecde23c3ec..13bf58838daf 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1224,7 +1224,7 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
>         return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
>  }
>
> -#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)

How about introducing a new config symbol representing the common
infrastructure between the two and have them select that symbol.

Would that also allow us to clean up the usage of
CONFIG_ARCH_ENABLE_THP_MIGRATION in fs/proc/task_mmu.c? In other
words, what's the point of having nice ifdef'd alternatives in header
files when ifdefs are still showing up in C files, all of it should be
optionally determined by header files.
