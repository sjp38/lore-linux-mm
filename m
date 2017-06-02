Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18BB56B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 05:11:43 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n13so62919498ita.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 02:11:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si366227pfj.110.2017.06.02.02.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 02:11:42 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5298te6080807
	for <linux-mm@kvack.org>; Fri, 2 Jun 2017 05:11:41 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ats3sq6x3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Jun 2017 05:11:41 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 2 Jun 2017 10:11:38 +0100
Date: Fri, 2 Jun 2017 12:11:30 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170601065302.GA30495@rapoport-lnx>
 <20170601080909.GD32677@dhcp22.suse.cz>
 <20170601134522.GE302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601134522.GE302@redhat.com>
Message-Id: <20170602091129.GH30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jun 01, 2017 at 03:45:22PM +0200, Andrea Arcangeli wrote:
> On Thu, Jun 01, 2017 at 10:09:09AM +0200, Michal Hocko wrote:
> > That is a bit surprising. I didn't think that the userfault syscall
> > (ioctl) can be faster than a regular #PF but considering that
> > __mcopy_atomic bypasses the page fault path and it can be optimized for
> > the anon case suggests that we can save some cycles for each page and so
> > the cumulative savings can be visible.
> 
> __mcopy_atomic works not just for anonymous memory, hugetlbfs/shmem
> are covered too and there are branches to handle those.
> 
> If you were to run more than one precopy pass UFFDIO_COPY shall become
> slower than the userland access starting from the second pass.
> 
> At the light of this if CRIU can only do one single pass of precopy,
> CRIU is probably better off using UFFDIO_COPY than using prctl or
> madvise to temporarily turn off THP.

CRIU does memory tracking differently from QEMU. Every round of pre-copy in
CRIU means we dump the dirty pages into an image file. The restore then
chooses what image file to use. Anyway, we fill the memory only once at
restore time, hence UFFDIO_COPY would be better than disabling THP.
 
> With QEMU as opposed we set MADV_HUGEPAGE during precopy on
> destination to maximize the THP utilization for all those 2M naturally
> aligned guest regions that aren't re-dirtied in the source, so we're
> better off without using UFFDIO_COPY in precopy even during the first
> pass to avoid the enter/kernel for subpages that are written to
> destination in a already instantiated THP. At least until we teach
> QEMU to map 2M at once if possible (UFFDIO_COPY would then also
> require an enhancement, because currently it won't map THP on the
> fly).
> 
> Thanks,
> Andrea
> 

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
