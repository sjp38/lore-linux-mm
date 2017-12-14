Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7588C6B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:05:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so3192641wre.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:05:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15si3258776wrh.303.2017.12.14.05.05.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 05:05:16 -0800 (PST)
Date: Thu, 14 Dec 2017 14:04:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] mm/mprotect: Add a cond_resched() inside
 change_pmd_range()
Message-ID: <20171214130435.GL16951@dhcp22.suse.cz>
References: <20171214111426.25912-1-khandual@linux.vnet.ibm.com>
 <20171214112928.GH16951@dhcp22.suse.cz>
 <28e54a80-73d9-76aa-31d5-f71375f14b96@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28e54a80-73d9-76aa-31d5-f71375f14b96@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Thu 14-12-17 18:25:54, Anshuman Khandual wrote:
> On 12/14/2017 04:59 PM, Michal Hocko wrote:
> > On Thu 14-12-17 16:44:26, Anshuman Khandual wrote:
> >> diff --git a/mm/mprotect.c b/mm/mprotect.c
> >> index ec39f73..43c29fa 100644
> >> --- a/mm/mprotect.c
> >> +++ b/mm/mprotect.c
> >> @@ -196,6 +196,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
> >>  		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
> >>  				 dirty_accountable, prot_numa);
> >>  		pages += this_pages;
> >> +		cond_resched();
> >>  	} while (pmd++, addr = next, addr != end);
> >>  
> >>  	if (mni_start)
> > 
> > this is not exactly what I meant. See how change_huge_pmd does continue.
> > That's why I mentioned zap_pmd_range which does goto next...
> 
> I might be still missing something but is this what you meant ?

yes, except

> Here we will give cond_resched() cover to the THP backed pages
> as well.

but there is still 
		if (!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
				&& pmd_none_or_clear_bad(pmd))
			continue;

so we won't have scheduling point on pmd holes. Maybe this doesn't
matter, I haven't checked but why should we handle those differently?

> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ec39f73..3d445ee 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -188,7 +188,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>                                         }
>  
>                                         /* huge pmd was handled */
> -                                       continue;
> +                                       goto next;
>                                 }
>                         }
>                         /* fall through, the trans huge pmd just split */
> @@ -196,6 +196,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>                 this_pages = change_pte_range(vma, pmd, addr, next, newprot,
>                                  dirty_accountable, prot_numa);
>                 pages += this_pages;
> +next:
> +               cond_resched();
>         } while (pmd++, addr = next, addr != end);
>  
>         if (mni_start)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
