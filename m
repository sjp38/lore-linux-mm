Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFEF6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:22:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s58so68839564qtb.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:22:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k66si900087qte.2.2017.05.24.08.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 08:22:54 -0700 (PDT)
Date: Wed, 24 May 2017 17:22:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170524152251.GA17425@redhat.com>
References: <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524142735.GF3063@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hello,

On Wed, May 24, 2017 at 05:27:36PM +0300, Mike Rapoport wrote:
> khugepaged does skip over VMAs which have userfault. We could register the
> regions with userfault before populating them to avoid collapses in the
> transition period. But then we'll have to populate these regions with
> UFFDIO_COPY which adds quite an overhead.

Yes, in fact with postcopy-only mode, there's no issue because of the
above.

The case where THP has to be temporarily disabled by CRIU is before
postcopy/userfaults engages, i.e. during the precopy with a
precopy+postcopy mode.

QEMU preferred mode is to do one pass of precopy before starting
postcopy/userfaults. During QEMU precopy phase VM_HUGEPAGE is set for
maximum performance and to back with THP in the destination as many
readonly (i.e. no source-redirtied) pages as possible. The dirty
logging in the source happens at 4k granularity by forcing the KVM
shadow MMU to map all pages at 4k granularity and by tracking the
dirty bit in software for the updates happening through the primary
MMU (linux pagetables dirty bit are ignored because soft dirty would
be too slow with O(N) complexity where N is linear with the size of
the VM, not with the number of re-dirtied pages in a precopy
pass). After that we track which 4k pages aren't uptodate on
destination and we zap them at 4k granularity with MADV_DONTNEED (we
badly need madvisev in fact to reduce the totally unnecessary flood of
4k wide MADV_DONTNEED there). So before calling the MADV_DONTNEED
flood, QEMU sets VM_NOHUGEPAGE, and after calling UFFDIO_REGISTER QEMU
sets back VM_HUGEPAGE (as the UFFDIO registration will keep khugepaged
at bay until postcopy completes). QEMU then finally calls
UFFDIO_UNREGISTER and khugepaged starts compacting everything that was
migrated through 4k wide userfaults.

CRIU doesn't attempt to populate destination with THP at all to be
simpler, but the problem is similar. It still has to call
VM_NOHUGEPAGE somehow during precopy (i.e. during the whole precopy
phase, precisely to avoid having to call MADV_DONTNEED to zap
4k not-uptodate fragments).

QEMU gets away with setting VM_NOHUGEPAGE and then back to VM_HUGEPAGE
without any issue because it's cooperative. CRIU as opposed has to
restore the same vm_flags that the vma had in the source to avoid
changing the behavior of the app after precopy+postcopy
completes. This is where the need of clearing the VM_*HUGEPAGE bits
from vm_flags comes into play.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
