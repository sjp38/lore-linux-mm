Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 910796B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 12:13:22 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id y20so3332874ier.1
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 09:13:22 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id q3si6252033ign.27.2015.01.18.09.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jan 2015 09:13:21 -0800 (PST)
Date: Sun, 18 Jan 2015 22:43:16 +0530
From: Shiraz Hashim <shashim@codeaurora.org>
Subject: Re: [PATCH 1/1] mm: pagemap: limit scan to virtual region being asked
Message-ID: <20150118171315.GA25218@shashim-linux.in.qualcomm.com>
References: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
 <20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jan 14, 2015 at 01:08:40AM +0000, Naoya Horiguchi wrote:
> On Tue, Jan 13, 2015 at 05:57:04PM +0530, Shiraz Hashim wrote:
> > pagemap_read scans through the virtual address space of a
> > task till it prepares 'count' pagemaps or it reaches end
> > of task.
> > 
> > This presents a problem when the page walk doesn't happen
> > for vma with VM_PFNMAP set. In which case walk is silently
> > skipped and no pagemap is prepare, in turn making
> > pagemap_read to scan through task end, even crossing beyond
> > 'count', landing into a different vma region. This leads to
> > wrong presentation of mappings for that vma.
> > 
> > Fix this by limiting end_vaddr to the end of the virtual
> > address region being scanned.
> > 
> > Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
> 
> This patch works in some case, but there still seems a problem in
> another case.
> 
> Consider that we have two vmas within some narrow
> (PAGEMAP_WALK_SIZE) region.  One vma in lower address is VM_PFNMAP,
> and the other vma in higher address is not.  Then a single call of
> walk_page_range() skips the first vma and scans the second vma, but
> the pagemap record of the second vma will be stored on the wrong
> offset in the buffer, because we just skip vma(VM_PFNMAP) without
> calling any callbacks (within which add_to_pagemap() increments
> pm.pos).
> 
> So calling pte_hole() for vma(VM_PFNMAP) looks a better fix to me.
> 

Thanks. That makes sense, If you are okay, I can send following patch formally.

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index ad83195..b16ea60 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -200,6 +200,11 @@ int walk_page_range(unsigned long addr, unsigned long end,
                        if ((vma->vm_start <= addr) &&
                            (vma->vm_flags & VM_PFNMAP)) {
                                next = vma->vm_end;
+                               if (walk->pte_hole)
+                                       err = walk->pte_hole(addr, next, walk);
+                               if (err)
+                                       break;
+
                                pgd = pgd_offset(walk->mm, next);
                                continue;
                        }

regards
Shiraz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
