Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3F0D66B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 00:26:22 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Date: Thu,  2 Feb 2012 00:27:58 -0500
Message-Id: <1328160478-28346-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120130152212.3a6a2039.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Jan 30, 2012 at 03:22:12PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 27 Jan 2012 18:02:49 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
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
> >   - Fix likely/unlikely pattern in pmd_trans_huge_stable()
> >   - Change suffix from _stable to _lock
> >   - Introduce __pmd_trans_huge_lock() to avoid micro-regression
> >   - Return 1 when wait_split_huge_page path is taken
> >
> > Changes since v2:
> >   - Fix missing "return 0" in "thp under splitting" path
> >   - Remove unneeded comment
> >   - Change the name of check function to describe what it does
> >   - Add VM_BUG_ON(mmap_sem)
>
>
> > +/*
> > + * Returns 1 if a given pmd maps a stable (not under splitting) thp,
> > + * -1 if the pmd maps thp under splitting, 0 if the pmd does not map thp.
> > + *
> > + * Note that if it returns 1, this routine returns without unlocking page
> > + * table locks. So callers must unlock them.
> > + */
>
>
> Seems nice clean up but... why you need to return (-1, 0, 1) ?
>
> It seems the caller can't see the difference between -1 and 0.
>
> Why not just return 0 (not locked) or 1 (thp found and locked) ?

Sorry, I changed wrongly from v3.
We can do fine without return value of -1 if we remove else-if (!err)
{...} block after move_huge_pmd() call in move_page_tables(), right?
(split_huge_page_pmd() after wait_split_huge_page() do nothing...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
