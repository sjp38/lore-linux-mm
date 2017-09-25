Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0B36B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:54:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f4so8356996wmh.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 04:54:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d90si1114230edd.437.2017.09.25.04.54.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 04:54:32 -0700 (PDT)
Date: Mon, 25 Sep 2017 13:54:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <20170925115430.zccesf75c4ysaznb@dhcp22.suse.cz>
References: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Mon 25-09-17 10:39:13, Kirill A. Shutemov wrote:
> On machine with 5-level paging support a process can allocate
> significant amount of memory and stay unnoticed by oom-killer and
> memory cgroup. The trick is to allocate a lot of PUD page tables.
> We don't account PUD page tables, only PMD and PTE.
> 
> We already addressed the same issue for PMD page tables, see
> dc6c9a35b66b ("mm: account pmd page tables to the process").
> Introduction 5-level paging bring the same issue for PUD page tables.
> 
> The patch expands accounting to PUD level.

OK, we definitely need this or something like that but I really do not
like how much code we actually need for each pte level for accounting.
Do we really need to distinguish each level? Do we have any arch that
would use a different number of pages to back pte/pmd/pud?

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
>  Documentation/sysctl/vm.txt   |  8 ++++----
>  arch/powerpc/mm/hugetlbpage.c |  1 +
>  arch/sparc/mm/hugetlbpage.c   |  1 +
>  fs/proc/task_mmu.c            |  5 ++++-
>  include/linux/mm.h            | 34 ++++++++++++++++++++++++++++++++--
>  include/linux/mm_types.h      |  3 +++
>  kernel/fork.c                 |  4 ++++
>  mm/debug.c                    |  6 ++++--
>  mm/memory.c                   | 15 +++++++++------
>  mm/oom_kill.c                 |  8 +++++---
>  10 files changed, 67 insertions(+), 18 deletions(-)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
