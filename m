Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 41BCF6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 09:43:49 -0400 (EDT)
Date: Fri, 20 Jul 2012 14:43:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables
Message-ID: <20120720134344.GF9222@suse.de>
References: <20120718104220.GR9222@suse.de>
 <ju8iqh$vvl$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <ju8iqh$vvl$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 19, 2012 at 09:08:34AM +0000, Cong Wang wrote:
> On Wed, 18 Jul 2012 at 10:43 GMT, Mel Gorman <mgorman@suse.de> wrote:
> > +		if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> > +			mutex_unlock(&mapping->i_mmap_mutex);
> > +			goto retry;
> > +		}
> > +
> > +		smmap_sem = &svma->vm_mm->mmap_sem;
> > +		spage_table_lock = &svma->vm_mm->page_table_lock;
> > +		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
> >  
> >  		saddr = page_table_shareable(svma, vma, addr, idx);
> >  		if (saddr) {
> > @@ -85,6 +108,10 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  				break;
> >  			}
> >  		}
> > +		up_read(smmap_sem);
> > +		spin_unlock(spage_table_lock);
> 
> Looks like we should do spin_unlock() before up_read(),
> in the reverse order of how they get accquired.
> 

Will fix, thanks for pointing this out.

As an aside, I would prefer if you did not drop people from the CC list. I
would have missed this mail for a long time if it hadn't been pointed out
to me privately.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
