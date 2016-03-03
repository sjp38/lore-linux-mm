Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 104396B0255
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:15:57 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id rt7so24263557obb.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:15:57 -0800 (PST)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id m130si15234228oig.80.2016.03.03.08.15.55
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:15:55 -0800 (PST)
Date: Fri, 4 Mar 2016 01:15:54 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: Re: [PATCH v1 05/11] mm: thp: check pmd migration entry in common
 path
Message-ID: <20160303161554.GB14896@www9186uo.sakura.ne.jp>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1456990918-30906-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160303105058.GC30948@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20160303105058.GC30948@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

On Thu, Mar 03, 2016 at 01:50:58PM +0300, Kirill A. Shutemov wrote:
> On Thu, Mar 03, 2016 at 04:41:52PM +0900, Naoya Horiguchi wrote:
> > If one of callers of page migration starts to handle thp, memory management code
> > start to see pmd migration entry, so we need to prepare for it before enabling.
> > This patch changes various code point which checks the status of given pmds in
> > order to prevent race between thp migration and the pmd-related works.
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  arch/x86/mm/gup.c  |  3 +++
> >  fs/proc/task_mmu.c | 25 +++++++++++++--------
> >  mm/gup.c           |  8 +++++++
> >  mm/huge_memory.c   | 66 ++++++++++++++++++++++++++++++++++++++++++++++++------
> >  mm/memcontrol.c    |  2 ++
> >  mm/memory.c        |  5 +++++
> >  6 files changed, 93 insertions(+), 16 deletions(-)
> >
> > diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/mm/gup.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/mm/gup.c
> > index f8d0b5e..34c3d43 100644
> > --- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/mm/gup.c
> > +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/mm/gup.c
> > @@ -10,6 +10,7 @@
> >  #include <linux/highmem.h>
> >  #include <linux/swap.h>
> >  #include <linux/memremap.h>
> > +#include <linux/swapops.h>
> >
> >  #include <asm/pgtable.h>
> >
> > @@ -210,6 +211,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
> >  		if (pmd_none(pmd))
> >  			return 0;
> >  		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> > +			if (unlikely(is_pmd_migration_entry(pmd)))
> > +				return 0;
>
> Hm. I've expected to see bunch of pmd_none() to pmd_present() conversions.
> That's seems a right way guard the code. Otherwise we wound need even more
> checks once PMD-level swap is implemented.

Yes, I agree. I'll try some for this pmd_none/pmd_present issue.

Thanks,
Naoya

>
> I think we need to check for migration entires only if we have something
> to do with migration. In all other cases pmd_present() should be enough to
> bail out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
