Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB95B6B02F4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:40:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p29so110082698pgn.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:40:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x6si5293400pgo.242.2017.05.24.03.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 03:39:59 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OASwoj082850
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:39:59 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2an1m11p37-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:39:59 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 24 May 2017 11:39:56 +0100
Date: Wed, 24 May 2017 13:39:48 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
Message-Id: <20170524103947.GC3063@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, May 24, 2017 at 09:58:06AM +0200, Vlastimil Babka wrote:
> On 05/24/2017 09:50 AM, Mike Rapoport wrote:
> > On Mon, May 22, 2017 at 05:52:47PM +0200, Vlastimil Babka wrote:
> >> On 05/22/2017 04:29 PM, Mike Rapoport wrote:
> >>>
> >>> Probably I didn't explained it too well.
> >>>
> >>> The range is intentionally not populated. When we combine pre- and
> >>> post-copy for process migration, we create memory pre-dump without stopping
> >>> the process, then we freeze the process without dumping the pages it has
> >>> dirtied between pre-dump and freeze, and then, during restore, we populate
> >>> the dirtied pages using userfaultfd.
> >>>
> >>> When CRIU restores a process in such scenario, it does something like:
> >>>
> >>> * mmap() memory region
> >>> * fill in the pages that were collected during the pre-dump
> >>> * do some other stuff
> >>> * register memory region with userfaultfd
> >>> * populate the missing memory on demand
> >>>
> >>> khugepaged collapses the pages in the partially populated regions before we
> >>> have a chance to register these regions with userfaultfd, which would
> >>> prevent the collapse.
> >>>
> >>> We could have used MADV_NOHUGEPAGE right after the mmap() call, and then
> >>> there would be no race because there would be nothing for khugepaged to
> >>> collapse at that point. But the problem is that we have no way to reset
> >>> *HUGEPAGE flags after the memory restore is complete.
> >>
> >> Hmm, I wouldn't be that sure if this is indeed race-free. Check that
> >> this scenario is indeed impossible?
> >>
> >> - you do the mmap
> >> - khugepaged will choose the process' mm to scan
> >> - khugepaged will get to the vma in question, it doesn't have
> >> MADV_NOHUGEPAGE yet
> >> - you set MADV_NOHUGEPAGE on the vma
> >> - you start populating the vma
> >> - khugepaged sees the vma is non-empty, collapses
> >>
> >> unless I'm wrong, the racers will have mmap_sem for reading only when
> >> setting/checking the MADV_NOHUGEPAGE? Might be actually considered a bug.
> >>
> >> However, can't you use prctl(PR_SET_THP_DISABLE) instead? "If arg2 has a
> >> nonzero value, the flag is set, otherwise it is cleared." says the
> >> manpage. Do it before the mmap and you avoid the race as well?
> > 
> > Unfortunately, prctl(PR_SET_THP_DISABLE) didn't help :(
> > When I've tried to use it, I've ended up with VM_NOHUGEPAGE set on all VMAs
> > created after prctl(). This returns me to the state when checkpoint-restore
> > alters the application vma->vm_flags although it shouldn't and I do not see
> > a way to fix it using existing interfaces.
> 
> [CC linux-api, should have been done in the initial posting already]

Sorry, missed that.
 
> Hm so the prctl does:
> 
>                 if (arg2)
>                         me->mm->def_flags |= VM_NOHUGEPAGE;
>                 else
>                         me->mm->def_flags &= ~VM_NOHUGEPAGE;
> 
> That's rather lazy implementation IMHO. Could we change it so the flag
> is stored elsewhere in the mm, and the code that decides to (not) use
> THP will check both the per-vma flag and the per-mm flag?

I afraid I don't understand how that can help.
What we need is an ability to temporarily disable collapse of the pages in
VMAs that do not have VM_*HUGEPAGE flags set and that after we re-enable
THP, the vma->vm_flags for those VMAs will remain intact.

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
