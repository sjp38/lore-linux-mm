Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4B2D16B005C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 14:23:28 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 5/6] introduce thp_ptep_get()
Date: Mon, 30 Jan 2012 14:24:56 -0500
Message-Id: <1327951496-29186-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120130152646.3f202259.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Jan 30, 2012 at 03:26:46PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 27 Jan 2012 18:02:52 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Casting pmd into pte_t to handle thp is strongly architecture dependent.
> > This patch introduces a new function to separate this dependency from
> > independent part.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  arch/x86/include/asm/pgtable.h |    5 +++++
> >  fs/proc/task_mmu.c             |    4 ++--
> >  include/asm-generic/pgtable.h  |    4 ++++
> >  3 files changed, 11 insertions(+), 2 deletions(-)
> > 
> > diff --git 3.3-rc1.orig/arch/x86/include/asm/pgtable.h 3.3-rc1/arch/x86/include/asm/pgtable.h
> > index 49afb3f..4cfcc7e 100644
> > --- 3.3-rc1.orig/arch/x86/include/asm/pgtable.h
> > +++ 3.3-rc1/arch/x86/include/asm/pgtable.h
> > @@ -165,6 +165,11 @@ static inline int has_transparent_hugepage(void)
> >  {
> >  	return cpu_has_pse;
> >  }
> > +
> > +static inline pte_t thp_ptep_get(pmd_t *pmd)
> > +{
> > +	return *(pte_t *)pmd;
> > +}
> 
> I'm sorry but I don't think the name is good. 
> (But I know my sense of naming is bad ;)

I named it from huge_ptep_get() defined for hugetlbfs.
But by my rethinking, it's bad naming.

> 
> How about pmd_to_pte_t ?

OK, it looks straightforward.
I'll take it if someone does not have better ideas.

> And, I wonder you can add error check as VM_BUG_ON(!pmd_trans_huge(*pmd));

Good, I'll add it.

Thank you, KAMEZAWA-san.
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
