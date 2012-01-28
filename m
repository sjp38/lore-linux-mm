Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5919E6B004D
	for <linux-mm@kvack.org>; Sat, 28 Jan 2012 17:32:42 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Date: Sat, 28 Jan 2012 17:33:46 -0500
Message-Id: <1327790026-29060-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBCGeqqAMvNAF3wPKAVQCFO-hNk1c+7UwKod6tMWqQ1Gkw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

Hi Hillf,

On Sat, Jan 28, 2012 at 07:23:47PM +0800, Hillf Danton wrote:
> Hi Naoya
> 
> On Sat, Jan 28, 2012 at 7:02 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Currently when we check if we can handle thp as it is or we need to
> > split it into regular sized pages, we hold page table lock prior to
> > check whether a given pmd is mapping thp or not. Because of this,
> > when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> > To remove it, this patch introduces a optimized check function and
> > replace several similar logics with it.
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: David Rientjes <rientjes@google.com>
> >
> > Changes since v3:
> > - Fix likely/unlikely pattern in pmd_trans_huge_stable()
> > - Change suffix from _stable to _lock
> > - Introduce __pmd_trans_huge_lock() to avoid micro-regression
> > - Return 1 when wait_split_huge_page path is taken
> >
> > Changes since v2:
> > - Fix missing "return 0" in "thp under splitting" path
> > - Remove unneeded comment
> > - Change the name of check function to describe what it does
> > - Add VM_BUG_ON(mmap_sem)
> > ---
> > fs/proc/task_mmu.c   |  70 +++++++++------------------
> > include/linux/huge_mm.h |  17 +++++++
> > mm/huge_memory.c    | 120 ++++++++++++++++++++++-------------------------
> > 3 files changed, 96 insertions(+), 111 deletions(-)
> >
> [...]
> 
> > @@ -1064,21 +1056,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> > {
> >    int ret = 0;
> >
> > -    spin_lock(&vma->vm_mm->page_table_lock);
> > -    if (likely(pmd_trans_huge(*pmd))) {
> > -        ret = !pmd_trans_splitting(*pmd);
> 
> Here the value of ret is either false or true,

You're right.

> > -        spin_unlock(&vma->vm_mm->page_table_lock);
> > -        if (unlikely(!ret))
> > -            wait_split_huge_page(vma->anon_vma, pmd);
> > -        else {
> > -            /*
> > -            * All logical pages in the range are present
> > -            * if backed by a huge page.
> > -            */
> > -            memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> > -        }
> > -    } else
> > +    if (__pmd_trans_huge_lock(pmd, vma) == 1) {
> > +        /*
> > +        * All logical pages in the range are present
> > +        * if backed by a huge page.
> > +        */
> >        spin_unlock(&vma->vm_mm->page_table_lock);
> > +        memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> > +    }
> >
> >    return ret;
> 
> what is the returned value of this function? /Hillf

In this patch, mincore_huge_pmd() always returns 0 and it's obviously wrong.
We need to set ret to 1 in if-block.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
