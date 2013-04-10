Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2DCCB6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:51:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id u11so483473pdi.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:51:49 -0700 (PDT)
Date: Wed, 10 Apr 2013 14:51:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND][PATCH v5 3/3] hugetlbfs: add swap entry check in
 follow_hugetlb_page()
In-Reply-To: <1365610669-16625-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1304101450110.1526@chino.kir.corp.google.com>
References: <1365610669-16625-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365610669-16625-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 10 Apr 2013, Naoya Horiguchi wrote:

> # I suspended Reviewed and Acked given for the previous version, because
> # it has a non-minor change. If you want to restore it, please let me know.
> -----
> With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
> initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
> error happens on a hugepage and the affected processes try to access
> the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
> in get_page().
> 
> The reason for this bug is that coredump-related code doesn't recognise
> "hugepage hwpoison entry" with which a pmd entry is replaced when a memory
> error occurs on a hugepage.
> In other words, physical address information is stored in different bit layout
> between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
> which is called in get_dump_page() returns a wrong page from a given address.
> 
> The expected behavior is like this:
> 
>   absent   is_swap_pte   FOLL_DUMP   Expected behavior
>   -------------------------------------------------------------------
>    true     false         false       hugetlb_fault
>    false    true          false       hugetlb_fault
>    false    false         false       return page
>    true     false         true        skip page (to avoid allocation)
>    false    true          true        hugetlb_fault
>    false    false         true        return page
> 
> With this patch, we can call hugetlb_fault() and take proper actions
> (we wait for migration entries, fail with VM_FAULT_HWPOISON_LARGE for
> hwpoisoned entries,) and as the result we can dump all hugepages except
> for hwpoisoned ones.
> 
> ChangeLog v5:
>  - improve comment and description.
> 
> ChangeLog v4:
>  - move is_swap_page() to right place.
> 
> ChangeLog v3:
>  - add comment about using is_swap_pte()
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

Stable for 2.6.34+?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
