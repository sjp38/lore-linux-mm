Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 660376B00BD
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:59:42 -0400 (EDT)
Date: Fri, 19 Mar 2010 17:48:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-Id: <20100319174850.439e1992.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 16:10:23 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 19 Mar 2010 15:26:36 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we look into pagemap using page-types with option -p, the value
> > of pfn for hugepages looks wrong (see below.)
> > This is because pte was evaluated only once for one vma
> > although it should be updated for each hugepage. This patch fixes it.
> > 
> > $ page-types -p 3277 -Nl -b huge
> > voffset   offset  len     flags
> > 7f21e8a00 11e400  1       ___U___________H_G________________
> > 7f21e8a01 11e401  1ff     ________________TG________________
> > 7f21e8c00 11e400  1       ___U___________H_G________________
> > 7f21e8c01 11e401  1ff     ________________TG________________
> >              ^^^
> >              should not be the same
> > 
> > With this patch applied:
> > 
> > $ page-types -p 3386 -Nl -b huge
> > voffset   offset   len    flags
> > 7fec7a600 112c00   1      ___UD__________H_G________________
> > 7fec7a601 112c01   1ff    ________________TG________________
> > 7fec7a800 113200   1      ___UD__________H_G________________
> > 7fec7a801 113201   1ff    ________________TG________________
> >              ^^^
> >              OK
> > 
> Hmm. Is this bug ? To me, it's just shown in hugepage's pagesize, by design.
> 
> _And_, Doesn't this patch change behavior of walk_pagemap_range() implicitly ?
> No influence to other users ? (as memcontrol.c. in mmotm. Ask Nishimura-san ;)
> 
>From the view point of memcg, this change in walk_pagemap_range() has no influence,
because memcg does "if (is_vm_hugetlb_page(vma)) break" before calling walk_pagemap_range().
But we must check other callers too.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
