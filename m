Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6E36B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 18:40:19 -0400 (EDT)
Date: Fri, 19 Mar 2010 17:40:23 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-ID: <20100319084023.GC13107@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com> <20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 04:27:32PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 19 Mar 2010 16:10:23 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 19 Mar 2010 15:26:36 +0900
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > When we look into pagemap using page-types with option -p, the value
> > > of pfn for hugepages looks wrong (see below.)
> > > This is because pte was evaluated only once for one vma
> > > although it should be updated for each hugepage. This patch fixes it.
> > > 
> > > $ page-types -p 3277 -Nl -b huge
> > > voffset   offset  len     flags
> > > 7f21e8a00 11e400  1       ___U___________H_G________________
> > > 7f21e8a01 11e401  1ff     ________________TG________________
> > > 7f21e8c00 11e400  1       ___U___________H_G________________
> > > 7f21e8c01 11e401  1ff     ________________TG________________
> > >              ^^^
> > >              should not be the same
> > > 
> > > With this patch applied:
> > > 
> > > $ page-types -p 3386 -Nl -b huge
> > > voffset   offset   len    flags
> > > 7fec7a600 112c00   1      ___UD__________H_G________________
> > > 7fec7a601 112c01   1ff    ________________TG________________
> > > 7fec7a800 113200   1      ___UD__________H_G________________
> > > 7fec7a801 113201   1ff    ________________TG________________
> > >              ^^^
> > >              OK
> > > 
> > Hmm. Is this bug ? To me, it's just shown in hugepage's pagesize, by design.
> > 
> I'm sorry it seems this is bugfix.
> 
> But, this means hugeltb_entry() is not called per hugetlb entry...isn't it ?
> 

Correct. Hugetlb_entry() is called per vma.

> Why hugetlb_entry() cannot be called per hugeltb entry ? Don't we need a code
> for a case as pmd_size != hugetlb_size in walk_page_range() for generic fix ?
> 

Because in some architecture there is no generic means to know whether
a pgd/pmd/pud/pte is hugetlb entry or not.
For second question, vma-based walking is generic solution and
works for "pmd_size != hugetlb_size" case.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
