Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3C636B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:27:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v190so7008409pgv.11
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:27:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o27si5192849pgc.320.2017.12.08.00.27.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 00:27:40 -0800 (PST)
Date: Fri, 8 Dec 2017 09:27:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm, thp: introduce generic transparent huge page
 allocation interfaces
Message-ID: <20171208082737.GA15790@dhcp22.suse.cz>
References: <1512708175-14089-1-git-send-email-changbin.du@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512708175-14089-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 08-12-17 12:42:55, changbin.du@intel.com wrote:
> From: Changbin Du <changbin.du@intel.com>
> 
> This patch introduced 4 new interfaces to allocate a prepared transparent
> huge page. These interfaces merge distributed two-step allocation as simple
> single step. And they can avoid issue like forget to call prep_transhuge_page()
> or call it on wrong page. A real fix:
> 40a899e ("mm: migrate: fix an incorrect call of prep_transhuge_page()")
> 
> Anyway, I just want to prove that expose direct allocation interfaces is
> better than a interface only do the second part of it.
> 
> These are similar to alloc_hugepage_xxx which are for hugetlbfs pages. New
> interfaces are:
>   - alloc_transhuge_page_vma
>   - alloc_transhuge_page_nodemask
>   - alloc_transhuge_page_node
>   - alloc_transhuge_page
> 
> These interfaces implicitly add __GFP_COMP gfp mask which is the minimum
> flags used for huge page allocation. More flags leave to the callers.
> 
> This patch does below changes:
>   - define alloc_transhuge_page_xxx interfaces
>   - apply them to all existing code
>   - declare prep_transhuge_page as static since no others use it
>   - remove alloc_hugepage_vma definition since it no longer has users

I am not really convinced this is a huge win, to be honest. Just look at
the diffstat. Very few callsites get marginally simpler while we add a
lot of stubs and the code churn.

> Signed-off-by: Changbin Du <changbin.du@intel.com>
> 
> ---
> v4:
>   - Revise the nop function definition. (Andrew)
> 
> v3:
>   - Rebase to latest mainline.
> 
> v2:
> Anshuman Khandu:
>   - Remove redundant 'VM_BUG_ON(!(gfp_mask & __GFP_COMP))'.
> Andrew Morton:
>   - Fix build error if thp is disabled.
> ---
>  include/linux/gfp.h     |  4 ----
>  include/linux/huge_mm.h | 35 +++++++++++++++++++++++++++++++++--
>  include/linux/migrate.h | 14 +++++---------
>  mm/huge_memory.c        | 48 +++++++++++++++++++++++++++++++++++++++++-------
>  mm/khugepaged.c         | 11 ++---------
>  mm/mempolicy.c          | 14 +++-----------
>  mm/migrate.c            | 14 ++++----------
>  mm/shmem.c              |  6 ++----
>  8 files changed, 90 insertions(+), 56 deletions(-)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
