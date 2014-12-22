Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA846B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 17:12:13 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id v63so11657088oia.6
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:12:13 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id dm7si11360457oeb.48.2014.12.22.14.12.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 14:12:12 -0800 (PST)
Message-ID: <1419286325.8812.3.camel@stgolabs.net>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 22 Dec 2014 14:12:05 -0800
In-Reply-To: <20141222191452.GA20295@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
	 <20141222180102.GA8072@node.dhcp.inet.fi> <54985D59.5010506@oracle.com>
	 <20141222191452.GA20295@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 2014-12-22 at 21:14 +0200, Kirill A. Shutemov wrote:
> Other thing:
> 
>  unmap_mapping_range()
>    i_mmap_lock_read(mapping);
>    unmap_mapping_range_tree()
>      unmap_mapping_range_vma()
>        zap_page_range_single()
>          unmap_single_vma()
> 	   untrack_pfn()
> 	     vma->vm_flags &= ~VM_PAT;
> 
> It seems we modify ->vm_flags without mmap_sem taken, means we can corrupt
> them.

yep. Although one thing that wouldn't match this would be the mlock'd
bad page when freeing in both of Sasha's previous reports, as we would
need to have VM_PFNMAP when calling untrack_pfn().

> Sasha could you check if you hit untrack_pfn()?
> 
> The problem probably was hidden by exclusive i_mmap_lock on
> unmap_mapping_range(), but it's not exclusive anymore afrer Dave's
> patchset.
> 
> Konstantin, you've modified untrack_pfn() back in 2012 to change
> ->vm_flags. Any coments?
> 
> For now, I would propose to revert the commit and probably re-introduce it
> after v3.19:
> 
> From 14392c69fcfeeda34eb9f75d983dad32698cdd5c Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 22 Dec 2014 21:01:54 +0200
> Subject: [PATCH] Revert "mm/memory.c: share the i_mmap_rwsem"
> 
> This reverts commit c8475d144abb1e62958cc5ec281d2a9e161c1946.
> 
> There are several[1][2] of bug reports which points to this commit as potential
> cause[3].
> 
> Let's revert it until we figure out what's going on.
> 
> [1] https://lkml.org/lkml/2014/11/14/342
> [2] https://lkml.org/lkml/2014/12/22/213
> [3] https://lkml.org/lkml/2014/12/9/741
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>

I certainly have no problem with this. Furthermore we snuck this one in
kinda last minute, so:

Acked-by: Davidlohr Bueso <dave@stgolabs.net>

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
