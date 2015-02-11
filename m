Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 89AC36B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:09:18 -0500 (EST)
Received: by pdno5 with SMTP id o5so7111077pdn.8
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:09:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w7si2663290pdi.19.2015.02.11.14.09.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 14:09:17 -0800 (PST)
Date: Wed, 11 Feb 2015 14:09:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: pagemap: limit scan to virtual region being
 asked
Message-Id: <20150211140915.760d9737099fa0f1669818a8@linux-foundation.org>
In-Reply-To: <20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
References: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
	<20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 14 Jan 2015 01:08:40 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

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
> This patch works in some case, but there still seems a problem in another case.
> 
> Consider that we have two vmas within some narrow (PAGEMAP_WALK_SIZE) region.
> One vma in lower address is VM_PFNMAP, and the other vma in higher address is not.
> Then a single call of walk_page_range() skips the first vma and scans the
> second vma, but the pagemap record of the second vma will be stored on the
> wrong offset in the buffer, because we just skip vma(VM_PFNMAP) without calling
> any callbacks (within which add_to_pagemap() increments pm.pos).
> 
> So calling pte_hole() for vma(VM_PFNMAP) looks a better fix to me.
> 

Can we get this finished off?  ASAP, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
