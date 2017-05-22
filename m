Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91B5A831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:44:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g15so9095509wmc.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:44:59 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 88si12001542wre.266.2017.05.22.06.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:44:58 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id b84so299283638wmh.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:44:58 -0700 (PDT)
Date: Mon, 22 May 2017 16:44:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170522134456.ig2tgf2spbuq55ig@node.shutemov.name>
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522133559.GE27382@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, May 22, 2017 at 04:36:00PM +0300, Mike Rapoport wrote:
> On Mon, May 22, 2017 at 02:42:43PM +0300, Kirill A. Shutemov wrote:
> > On Mon, May 22, 2017 at 09:12:42AM +0300, Mike Rapoport wrote:
> > > Currently applications can explicitly enable or disable THP for a memory
> > > region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> > > these advises is used, the region will always have
> > > VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> > > The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> > > the region according to system-wide settings.
> > 
> > Seems reasonable. But could you describe an use-case when it's useful in
> > real world.
> 
> My use-case was combination of pre- and post-copy migration of containers
> with CRIU.
> In this case we populate a part of a memory region with data that was saved
> during the pre-copy stage. Afterwards, the region is registered with
> userfaultfd and we expect to get page faults for the parts of the region
> that were not yet populated. However, khugepaged collapses the pages and
> the page faults we would expect do not occur.
> 
> We could have used MADV_NOHUGEPAGE before populating the region with the
> pre-copy data, but then, in the end, the restored application will be resumed
> with vma->vm_flags different from the ones it had when it was frozen.
> 
> Another possibility I've considered was to register the region with
> userfaultfd before populating it with data, but in that case we get the
> overhead of UFFD_EVENT_PAGEFAULT + UFFDIO_{COPY,ZEROPAGE} for nothing :(

Okay. Makes sense. Feel free to use my Acked-by (with change to RESET).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
