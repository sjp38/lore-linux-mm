Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4B88B6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 04:25:14 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e52so1047613eek.2
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 01:25:12 -0700 (PDT)
Date: Sun, 4 Aug 2013 10:25:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 02/23] memcg, thp: charge huge cache pages
Message-ID: <20130804082509.GC24005@dhcp22.suse.cz>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375582645-29274-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun 04-08-13 05:17:04, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> mem_cgroup_cache_charge() has check for PageCompound(). The check
> prevents charging huge cache pages.
> 
> I don't see a reason why the check is present. Looks like it's just
> legacy (introduced in 52d4b9a memcg: allocate all page_cgroup at boot).
> 
> Let's just drop it.

If the page cache charging path only sees THP as compound pages then OK.
Can we keep at least VM_BUG_ON(PageCompound(page) && !PageTransHuge(page))

Otherwise mem_cgroup_charge_common would be confused and charge such a
page as order-0
 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

Other than that, looks good to me.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b6cd870..dc50c1a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3921,8 +3921,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
> -	if (PageCompound(page))
> -		return 0;
>  
>  	if (!PageSwapCache(page))
>  		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> -- 
> 1.8.3.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
