Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 238026B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 09:45:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 25so16856389qtx.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 06:45:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si19695736qtv.302.2017.06.01.06.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 06:45:25 -0700 (PDT)
Date: Thu, 1 Jun 2017 15:45:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170601134522.GE302@redhat.com>
References: <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170601065302.GA30495@rapoport-lnx>
 <20170601080909.GD32677@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601080909.GD32677@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jun 01, 2017 at 10:09:09AM +0200, Michal Hocko wrote:
> That is a bit surprising. I didn't think that the userfault syscall
> (ioctl) can be faster than a regular #PF but considering that
> __mcopy_atomic bypasses the page fault path and it can be optimized for
> the anon case suggests that we can save some cycles for each page and so
> the cumulative savings can be visible.

__mcopy_atomic works not just for anonymous memory, hugetlbfs/shmem
are covered too and there are branches to handle those.

If you were to run more than one precopy pass UFFDIO_COPY shall become
slower than the userland access starting from the second pass.

At the light of this if CRIU can only do one single pass of precopy,
CRIU is probably better off using UFFDIO_COPY than using prctl or
madvise to temporarily turn off THP.

With QEMU as opposed we set MADV_HUGEPAGE during precopy on
destination to maximize the THP utilization for all those 2M naturally
aligned guest regions that aren't re-dirtied in the source, so we're
better off without using UFFDIO_COPY in precopy even during the first
pass to avoid the enter/kernel for subpages that are written to
destination in a already instantiated THP. At least until we teach
QEMU to map 2M at once if possible (UFFDIO_COPY would then also
require an enhancement, because currently it won't map THP on the
fly).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
