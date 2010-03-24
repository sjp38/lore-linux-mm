Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B0586B01CE
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 12:54:37 -0400 (EDT)
Subject: Re: [PATCH -mmotm] [BUGFIX] pagemap: fix pfn calculation for
 hugepage
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20100324054227.GB9336@spritzerA.linux.bs1.fc.nec.co.jp>
References: <20100324054227.GB9336@spritzerA.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 24 Mar 2010 11:54:31 -0500
Message-ID: <1269449671.3552.173.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-03-24 at 14:42 +0900, Naoya Horiguchi wrote:
> When we look into pagemap using page-types with option -p, the value
> of pfn for hugepages looks wrong (see below.)
> This is because pte was evaluated only once for one vma
> although it should be updated for each hugepage. This patch fixes it.
> 
>   $ page-types -p 3277 -Nl -b huge
>   voffset   offset  len     flags
>   7f21e8a00 11e400  1       ___U___________H_G________________
>   7f21e8a01 11e401  1ff     ________________TG________________
>                ^^^
>   7f21e8c00 11e400  1       ___U___________H_G________________
>   7f21e8c01 11e401  1ff     ________________TG________________
>                ^^^
> 
> One hugepage contains 1 head page and 511 tail pages in x86_64 and
> each two lines represent each hugepage. Voffset and offset mean
> virtual address and physical address in the page unit, respectively.
> The different hugepages should not have the same offset value.
> 
> With this patch applied:
> 
>   $ page-types -p 3386 -Nl -b huge
>   voffset   offset   len    flags
>   7fec7a600 112c00   1      ___UD__________H_G________________
>   7fec7a601 112c01   1ff    ________________TG________________
>                ^^^
>   7fec7a800 113200   1      ___UD__________H_G________________
>   7fec7a801 113201   1ff    ________________TG________________
>                ^^^
>                OK
> 
> Changelog:
>  - add hugetlb entry walker in mm/pagewalk.c
>    (the idea based on Kamezawa-san's patch)
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
