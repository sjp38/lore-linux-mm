Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 64A166B0096
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:50:43 -0400 (EDT)
Date: Mon, 9 Jul 2012 11:50:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm/hugetlb: split out
 is_hugetlb_entry_migration_or_hwpoison
Message-ID: <20120709105040.GT13141@csn.ul.ie>
References: <1341828761-11195-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1341828761-11195-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Jul 09, 2012 at 06:12:41PM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Code was duplicated in two functions, clean it up.
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

is_hugetlb_entry_migration() now returns true for hwpoisoned pages. In
this block

                if (unlikely(is_hugetlb_entry_migration(entry))) {
                        migration_entry_wait(mm, (pmd_t *)ptep, address);
                        return 0;

we now will call migration_entry_wait and return 0 to the fault handler
instead of VM_FAULT_HWPOISON_LARGE | VM_FAULT_SET_HINDEX(h - hstates).
By co-incidence this might work because migration of hugetlb happens for
poisoned pages but it would be just a co-incidence. Some other change in
the future such as better support for memory hotplug of regions backed
by hugetlbfs may break it again.

Superficially, this patch looks broken and the changelog contains
no motivation as to why this patch should be merged such as being a
pre-requisite for another fix or feature.  It just looks like churn for
the sake of churn. It might be just me but it feels like I'm seeing a lot
more of this style of patch recently on linux-mm and review bandwidth is
not infinite :(

Nak.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
