Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB98A831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:55:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j27so11856270wre.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:55:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si186616wmb.91.2017.05.22.06.55.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 06:55:50 -0700 (PDT)
Date: Mon, 22 May 2017 15:55:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170522135548.GA8514@dhcp22.suse.cz>
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
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon 22-05-17 16:36:00, Mike Rapoport wrote:
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

I am not sure I undestand the problem. Do I get it right that the
khugepaged will effectivelly corrupt the memory by collapsing a range
which is not yet fully populated? If yes shouldn't that be fixed in
khugepaged rather than adding yet another madvise command? Also how do
you prevent on races? (say you VM_NOHUGEPAGE, khugepaged would be in the
middle of the operation and sees a collapsable vma and you get the same
result)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
