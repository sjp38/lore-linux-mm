Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CA1FA6B00B2
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 03:31:15 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J7VAYo032437
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 16:31:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F70C45DE4F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:31:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 207E845DE4E
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:31:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE71E08002
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:31:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8A3D1DB8037
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:31:09 +0900 (JST)
Date: Fri, 19 Mar 2010 16:27:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-Id: <20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 16:10:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
I'm sorry it seems this is bugfix.

But, this means hugeltb_entry() is not called per hugetlb entry...isn't it ?

Why hugetlb_entry() cannot be called per hugeltb entry ? Don't we need a code
for a case as pmd_size != hugetlb_size in walk_page_range() for generic fix ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
