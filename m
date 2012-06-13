Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 970F66B0070
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:03:41 -0400 (EDT)
Date: Wed, 13 Jun 2012 17:03:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 04/15] hugetlb: use mmu_gather instead of a temporary
 linked list for accumulating pages
Message-ID: <20120613150338.GB14777@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120613145923.GA14777@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120613145923.GA14777@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 16:59:23, Michal Hocko wrote:
> On Wed 13-06-12 15:57:23, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Use a mmu_gather instead of a temporary linked list for accumulating
> > pages when we unmap a hugepage range
> 
> Sorry for coming up with the comment that late but you owe us an
> explanation _why_ you are doing this.
> 
> I assume that this fixes a real problem when we take i_mmap_mutex
> already up in 
> unmap_mapping_range
>   mutex_lock(&mapping->i_mmap_mutex);
>   unmap_mapping_range_tree | unmap_mapping_range_list 
>     unmap_mapping_range_vma
>       zap_page_range_single
>         unmap_single_vma
> 	  unmap_hugepage_range
> 	    mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
> 
> And that this should have been marked for stable as well (I haven't
> checked when this has been introduced).
> 
> But then I do not see how this help when you still do this:
> [...]
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 1b7dc66..545e18a 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1326,8 +1326,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
> >  			 * Since no pte has actually been setup, it is
> >  			 * safe to do nothing in this case.
> >  			 */
> > -			if (vma->vm_file)
> > -				unmap_hugepage_range(vma, start, end, NULL);
> > +			if (vma->vm_file) {
> > +				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
> > +				__unmap_hugepage_range(tlb, vma, start, end, NULL);
> > +				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> > +			}
> >  		} else
> >  			unmap_page_range(tlb, vma, start, end, details);
> >  	}

Ahhh, you are removing the lock in the next patch. Really confusing and
not nice for the stable backport.
Could you merge those two patches and add Cc: stable? 
Then you can add my
Reviewed-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
