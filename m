Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33A896B0253
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 03:16:45 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so63775825pfi.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 00:16:45 -0800 (PST)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id h75si35598641pfk.290.2016.11.08.00.16.44
        for <linux-mm@kvack.org>;
        Tue, 08 Nov 2016 00:16:44 -0800 (PST)
Date: Tue, 8 Nov 2016 17:16:43 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd migration
Message-ID: <20161108081642.GA29855@www9186uo.sakura.ne.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <58218942.8010608@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <58218942.8010608@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Nov 08, 2016 at 01:43:54PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> > This patch prepares thp migration's core code. These code will be open when
> > unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
> > to allocate destination thps.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> > ChangeLog v1 -> v2:
> > - support pte-mapped thp, doubly-mapped thp
> > ---
> >  arch/x86/include/asm/pgtable_64.h |   2 +
> >  include/linux/swapops.h           |  61 +++++++++++++++
> >  mm/huge_memory.c                  | 154 ++++++++++++++++++++++++++++++++++++++
> >  mm/migrate.c                      |  44 ++++++++++-
> >  mm/pgtable-generic.c              |   3 +-
> >  5 files changed, 262 insertions(+), 2 deletions(-)
> > 
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> > index 1cc82ec..3a1b48e 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> > @@ -167,7 +167,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
> >  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
> >  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
> >  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> > +#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })
> 
> The above macro takes *pte* but evaluates on *pmd*, guess its should
> be fixed either way.

Right, I fix it.
Thank you very much.

- Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
