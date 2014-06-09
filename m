Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 42BA96B00AC
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 17:35:14 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so526337wgh.4
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:35:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bu8si33582591wjc.35.2014.06.09.14.35.12
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 14:35:12 -0700 (PDT)
Message-ID: <53962890.c8aec20a.7e8a.ffffeeb8SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/7] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
Date: Mon,  9 Jun 2014 17:35:04 -0400
In-Reply-To: <53961338.4050309@intel.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-7-git-send-email-n-horiguchi@ah.jp.nec.com> <53961338.4050309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Mon, Jun 09, 2014 at 01:04:08PM -0700, Dave Hansen wrote:
> On 06/06/2014 03:58 PM, Naoya Horiguchi wrote:
> > @@ -6723,14 +6723,9 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
> >  					struct mm_walk *walk)
> >  {
> >  	struct vm_area_struct *vma = walk->vma;
> > -	spinlock_t *ptl;
> >  
> > -	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> > -		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
> > -			mc.precharge += HPAGE_PMD_NR;
> > -		spin_unlock(ptl);
> > -	} else
> > -		skip->control = PTWALK_DOWN;
> > +	if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
> > +		mc.precharge += HPAGE_PMD_NR;
> >  	return 0;
> >  }
> 
> I guess my series did two things:
> 1. move page table walking to the walk_page_range() code
> 2. make new walk handler that can take arbitrarily-sizes ptes
> 
> This does (1) quite nicely and has some nice code savings.  I still
> think (2) has some value, and like my approach, but this is definitely a
> step in the right direction.

Thank you. And yes, I'm planning to add (2) to this series in later version.

Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
