Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 029166B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:55:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p9so16370524pgc.6
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:55:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si1540366pfm.21.2017.10.24.23.55.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 23:55:32 -0700 (PDT)
Date: Wed, 25 Oct 2017 08:55:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Hugetlb pages rss accounting is incorrect in
 /proc/<pid>/smaps
Message-ID: <20171025065527.wmii7ce5y5i4exx5@dhcp22.suse.cz>
References: <1508889368-14489-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508889368-14489-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, rientjes@google.com, dancol@google.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

[CCing Naoya]

On Tue 24-10-17 16:56:08, Prakash Sangappa wrote:
> Resident set size(Rss) accounting of hugetlb pages is not done
> currently in /proc/<pid>/smaps. The pmap command reads rss from
> this file and so it shows Rss to be 0 in pmap -x output for
> hugetlb mapped vmas. This patch fixes it.

We do not account in rss because we do have a dedicated counters
depending on whether the hugetlb page is mapped privately or it is
shared. The reason this is not in RSS IIRC is that a large unexpected
RSS from hugetlb pages might confuse system monitors. This is one of
those backward compatibility issues when you start accounting something
too late.

> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>  fs/proc/task_mmu.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 5589b4b..c7e1048 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -724,6 +724,7 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
>  		else
>  			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
> +		mss->resident += huge_page_size(hstate_vma(vma));
>  	}
>  	return 0;
>  }
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
