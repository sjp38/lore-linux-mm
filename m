Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEE86B0267
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 04:41:14 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so92900523pad.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 01:41:14 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id o90si17305616pfj.222.2016.07.29.01.41.12
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 01:41:13 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <01fa01d1e94c$4be09210$e3a1b630$@alibaba-inc.com> <021901d1e96f$4b271830$e1754890$@alibaba-inc.com> <20160729081011.GA28534@black.fi.intel.com> <022c01d1e972$7ee5ada0$7cb108e0$@alibaba-inc.com> <20160729083115.GA24577@node.shutemov.name>
In-Reply-To: <20160729083115.GA24577@node.shutemov.name>
Subject: RE: [PATCH] mm: fail prefaulting if page table allocation fails
Date: Fri, 29 Jul 2016 16:40:56 +0800
Message-ID: <022d01d1e974$ece0ab00$c6a20100$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vegard Nossum' <vegard.nossum@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org

> > In filemap_map_pages()
> > 	CPU0					CPU1
> > 	trylock_page at offset_A		trylock_page at offset_A
> > 						goto offset_A+1
> > 	if (!fe->pte) {
> > 		alloc pte
> > 		map pte
> > 		lock pte
> > 	}
> > 	handle offset_A with ptl held		handle offset_A+1 without acquiring ptl
> 
> I still don't see where's the problem.
> 
> On the seond iteration (for offset_A+1), CPU1 would go into
> alloc_set_pte() and as its fe->pte is NULL pte_alloc_one_map() would map
> and lock the pte table allocated by CPU0.
> 
Ah, you are right. I missed the 2nd fe!

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
