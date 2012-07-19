Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 0B35F6B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 05:08:51 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Srmj0-0004sn-9e
	for linux-mm@kvack.org; Thu, 19 Jul 2012 11:08:46 +0200
Received: from 112.132.185.57 ([112.132.185.57])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 11:08:46 +0200
Received: from xiyou.wangcong by 112.132.185.57 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 11:08:46 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables
Date: Thu, 19 Jul 2012 09:08:34 +0000 (UTC)
Message-ID: <ju8iqh$vvl$1@dough.gmane.org>
References: <20120718104220.GR9222@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Wed, 18 Jul 2012 at 10:43 GMT, Mel Gorman <mgorman@suse.de> wrote:
> +		if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> +			mutex_unlock(&mapping->i_mmap_mutex);
> +			goto retry;
> +		}
> +
> +		smmap_sem = &svma->vm_mm->mmap_sem;
> +		spage_table_lock = &svma->vm_mm->page_table_lock;
> +		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
>  
>  		saddr = page_table_shareable(svma, vma, addr, idx);
>  		if (saddr) {
> @@ -85,6 +108,10 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  				break;
>  			}
>  		}
> +		up_read(smmap_sem);
> +		spin_unlock(spage_table_lock);

Looks like we should do spin_unlock() before up_read(),
in the reverse order of how they get accquired.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
