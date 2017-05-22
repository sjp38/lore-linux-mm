Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4CC831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:29:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h76so88106604pfh.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 07:29:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f14si17364410plm.267.2017.05.22.07.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 07:29:36 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4MEPi6W014654
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:29:36 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aky1as7w5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:29:35 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 22 May 2017 15:29:33 +0100
Date: Mon, 22 May 2017 17:29:28 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522135548.GA8514@dhcp22.suse.cz>
Message-Id: <20170522142927.GG27382@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, May 22, 2017 at 03:55:48PM +0200, Michal Hocko wrote:
> On Mon 22-05-17 16:36:00, Mike Rapoport wrote:
> > On Mon, May 22, 2017 at 02:42:43PM +0300, Kirill A. Shutemov wrote:
> > > On Mon, May 22, 2017 at 09:12:42AM +0300, Mike Rapoport wrote:
> > > > Currently applications can explicitly enable or disable THP for a memory
> > > > region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> > > > these advises is used, the region will always have
> > > > VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> > > > The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> > > > the region according to system-wide settings.
> > > 
> > > Seems reasonable. But could you describe an use-case when it's useful in
> > > real world.
> > 
> > My use-case was combination of pre- and post-copy migration of containers
> > with CRIU.
> > In this case we populate a part of a memory region with data that was saved
> > during the pre-copy stage. Afterwards, the region is registered with
> > userfaultfd and we expect to get page faults for the parts of the region
> > that were not yet populated. However, khugepaged collapses the pages and
> > the page faults we would expect do not occur.
> 
> I am not sure I undestand the problem. Do I get it right that the
> khugepaged will effectivelly corrupt the memory by collapsing a range
> which is not yet fully populated? If yes shouldn't that be fixed in
> khugepaged rather than adding yet another madvise command? Also how do
> you prevent on races? (say you VM_NOHUGEPAGE, khugepaged would be in the
> middle of the operation and sees a collapsable vma and you get the same
> result)

Probably I didn't explained it too well.

The range is intentionally not populated. When we combine pre- and
post-copy for process migration, we create memory pre-dump without stopping
the process, then we freeze the process without dumping the pages it has
dirtied between pre-dump and freeze, and then, during restore, we populate
the dirtied pages using userfaultfd.

When CRIU restores a process in such scenario, it does something like:

* mmap() memory region
* fill in the pages that were collected during the pre-dump
* do some other stuff
* register memory region with userfaultfd
* populate the missing memory on demand

khugepaged collapses the pages in the partially populated regions before we
have a chance to register these regions with userfaultfd, which would
prevent the collapse.

We could have used MADV_NOHUGEPAGE right after the mmap() call, and then
there would be no race because there would be nothing for khugepaged to
collapse at that point. But the problem is that we have no way to reset
*HUGEPAGE flags after the memory restore is complete.

> -- 
> Michal Hocko
> SUSE Labs

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
