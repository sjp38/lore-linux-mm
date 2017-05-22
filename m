Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AABD4831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:36:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so25566213wmb.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:36:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r137si19855408wmg.97.2017.05.22.06.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:36:14 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4MDSsAA084454
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:36:13 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2akv55y2d6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:36:12 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 22 May 2017 14:36:07 +0100
Date: Mon, 22 May 2017 16:36:00 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
Message-Id: <20170522133559.GE27382@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, May 22, 2017 at 02:42:43PM +0300, Kirill A. Shutemov wrote:
> On Mon, May 22, 2017 at 09:12:42AM +0300, Mike Rapoport wrote:
> > Currently applications can explicitly enable or disable THP for a memory
> > region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> > these advises is used, the region will always have
> > VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> > The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> > the region according to system-wide settings.
> 
> Seems reasonable. But could you describe an use-case when it's useful in
> real world.

My use-case was combination of pre- and post-copy migration of containers
with CRIU.
In this case we populate a part of a memory region with data that was saved
during the pre-copy stage. Afterwards, the region is registered with
userfaultfd and we expect to get page faults for the parts of the region
that were not yet populated. However, khugepaged collapses the pages and
the page faults we would expect do not occur.

We could have used MADV_NOHUGEPAGE before populating the region with the
pre-copy data, but then, in the end, the restored application will be resumed
with vma->vm_flags different from the ones it had when it was frozen.

Another possibility I've considered was to register the region with
userfaultfd before populating it with data, but in that case we get the
overhead of UFFD_EVENT_PAGEFAULT + UFFDIO_{COPY,ZEROPAGE} for nothing :(

> And the name is bad. But I don't have better suggestion. At least do not
> abbreviate CLEAR. Saving two letters doesn't worth it.
> 
> Maybe RESET instead?

I hesitated between CLR and RST, and CLR was chosen pretty much with coin
toss :)
I'm ok with RESET, which might be a bit more descriptive than CLEAR.
 
> -- 
>  Kirill A. Shutemov
> 

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
