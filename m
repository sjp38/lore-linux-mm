Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 033EB6B0082
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 18:30:16 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so2020165iga.14
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:30:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cj5si916429igc.29.2014.11.19.15.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 15:30:14 -0800 (PST)
Date: Wed, 19 Nov 2014 15:30:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 120/306] fs/proc/task_mmu.c:474 smaps_account()
 warn: should 'size << 12' be a 64 bit type?
Message-Id: <20141119153012.b49f2c2effb61d57e593fded@linux-foundation.org>
In-Reply-To: <20141117130328.GA20563@node.dhcp.inet.fi>
References: <20141114114415.GD5351@mwanda>
	<20141117130328.GA20563@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Mon, 17 Nov 2014 15:03:28 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Nov 14, 2014 at 02:44:15PM +0300, kbuild test robot wrote:
> > [ You would have to enable transparent huge page tables on a 32 bit
> >   system to trigger this bug and I don't think that's possible.
> 
> It is. We have THP on 32-bit x86.
> 
> >   I don't think Smatch will complain about this if you have the cross
> >   function database turned on because it knows the value of size in that
> >   case.  But most people don't build the database so it might be worth
> >   silencing this bug?  Should I even bother sending these email for
> >   non-bugs?  Let me know.  -dan ]
> > 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   e668fb4c5c5e6de5b9432bd36d83b3a0b4ce78e8
> > commit: be7c8db9daa43935912bc8c898ecea99b32d805b [120/306] mm: fix huge zero page accounting in smaps report
> > 
> > fs/proc/task_mmu.c:474 smaps_account() warn: should 'size << 12' be a 64 bit type?
> 
> This should fix the issue.
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 8fd00743bd4d..de80a887d98e 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -464,17 +464,16 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>                         mss->shared_dirty += size;
>                 else
>                         mss->shared_clean += size;
> -               mss->pss += (size << PSS_SHIFT) / mapcount;
> +               mss->pss += ((u64)size << PSS_SHIFT) / mapcount;
>         } else {
>                 if (dirty || PageDirty(page))
>                         mss->private_dirty += size;
>                 else
>                         mss->private_clean += size;
> -               mss->pss += (size << PSS_SHIFT);
> +               mss->pss += (u64)size << PSS_SHIFT;
>         }
>  }
>  
> -
>  static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>                 struct mm_walk *walk)
>  {

Please check...


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-fix-huge-zero-page-accounting-in-smaps-report-fix-2-fix

use do_div to fix 32-bit build

fs/built-in.o: In function `smaps_account':
task_mmu.c:(.text+0x943a3): undefined reference to `__udivdi3'

Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/task_mmu.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff -puN fs/proc/task_mmu.c~mm-fix-huge-zero-page-accounting-in-smaps-report-fix-2-fix fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~mm-fix-huge-zero-page-accounting-in-smaps-report-fix-2-fix
+++ a/fs/proc/task_mmu.c
@@ -461,11 +461,15 @@ static void smaps_account(struct mem_siz
 		mss->referenced += size;
 	mapcount = page_mapcount(page);
 	if (mapcount >= 2) {
+		u64 pss_delta;
+
 		if (dirty || PageDirty(page))
 			mss->shared_dirty += size;
 		else
 			mss->shared_clean += size;
-		mss->pss += ((u64)size << PSS_SHIFT) / mapcount;
+		pss_delta = (u64)size << PSS_SHIFT;
+		do_div(pss_delta, mapcount);
+		mss->pss += pss_delta;
 	} else {
 		if (dirty || PageDirty(page))
 			mss->private_dirty += size;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
