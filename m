Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3B21C6B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 03:34:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2D4223EE0B6
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 17:34:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1111145DE67
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 17:34:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DFD9C45DE4E
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 17:34:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CE8851DB8043
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 17:34:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 71C701DB8041
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 17:34:07 +0900 (JST)
Date: Thu, 2 Feb 2012 17:32:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Message-Id: <20120202173235.066b16b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328160478-28346-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20120130152212.3a6a2039.kamezawa.hiroyu@jp.fujitsu.com>
	<1328160478-28346-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Thu,  2 Feb 2012 00:27:58 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Mon, Jan 30, 2012 at 03:22:12PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 27 Jan 2012 18:02:49 -0500
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> >
> > > Currently when we check if we can handle thp as it is or we need to
> > > split it into regular sized pages, we hold page table lock prior to
> > > check whether a given pmd is mapping thp or not. Because of this,
> > > when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> > > To remove it, this patch introduces a optimized check function and
> > > replace several similar logics with it.
> > >
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: David Rientjes <rientjes@google.com>
> > >
> > > Changes since v3:
> > >   - Fix likely/unlikely pattern in pmd_trans_huge_stable()
> > >   - Change suffix from _stable to _lock
> > >   - Introduce __pmd_trans_huge_lock() to avoid micro-regression
> > >   - Return 1 when wait_split_huge_page path is taken
> > >
> > > Changes since v2:
> > >   - Fix missing "return 0" in "thp under splitting" path
> > >   - Remove unneeded comment
> > >   - Change the name of check function to describe what it does
> > >   - Add VM_BUG_ON(mmap_sem)
> >
> >
> > > +/*
> > > + * Returns 1 if a given pmd maps a stable (not under splitting) thp,
> > > + * -1 if the pmd maps thp under splitting, 0 if the pmd does not map thp.
> > > + *
> > > + * Note that if it returns 1, this routine returns without unlocking page
> > > + * table locks. So callers must unlock them.
> > > + */
> >
> >
> > Seems nice clean up but... why you need to return (-1, 0, 1) ?
> >
> > It seems the caller can't see the difference between -1 and 0.
> >
> > Why not just return 0 (not locked) or 1 (thp found and locked) ?
> 
> Sorry, I changed wrongly from v3.
> We can do fine without return value of -1 if we remove else-if (!err)
> {...} block after move_huge_pmd() call in move_page_tables(), right?
> (split_huge_page_pmd() after wait_split_huge_page() do nothing...)
> 

Hm ?

               if (pmd_trans_huge(*old_pmd)) {
                        int err = 0;
                        if (extent == HPAGE_PMD_SIZE)
                                err = move_huge_pmd(vma, new_vma, old_addr,
                                                    new_addr, old_end,
                                                    old_pmd, new_pmd);
                        if (err > 0) {
                                need_flush = true;
                                continue;
                        } else if (!err) {
                                split_huge_page_pmd(vma->vm_mm, old_pmd);
                        }
                        VM_BUG_ON(pmd_trans_huge(*old_pmd));
                }

I think you're right. BUG_ON() in wait_split_huge_page() 

 #define wait_split_huge_page(__anon_vma, __pmd)                         \
        do {                                                            \
                pmd_t *____pmd = (__pmd);                               \
                anon_vma_lock(__anon_vma);                              \
                anon_vma_unlock(__anon_vma);                            \
                BUG_ON(pmd_trans_splitting(*____pmd) ||                 \
                       pmd_trans_huge(*____pmd));                       \
        } while (0)

says pmd is always splitted.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
