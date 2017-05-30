Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63E5B6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 06:19:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so89331607pfd.11
        for <linux-mm@kvack.org>; Tue, 30 May 2017 03:19:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m2si13140429pga.313.2017.05.30.03.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 03:19:35 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UAIXRH074313
	for <linux-mm@kvack.org>; Tue, 30 May 2017 06:19:35 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2as4dbe9yt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 May 2017 06:19:34 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 30 May 2017 11:19:31 +0100
Date: Tue, 30 May 2017 13:19:22 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530074408.GA7969@dhcp22.suse.cz>
Message-Id: <20170530101921.GA25738@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, May 30, 2017 at 09:44:08AM +0200, Michal Hocko wrote:
> On Wed 24-05-17 17:27:36, Mike Rapoport wrote:
> > On Wed, May 24, 2017 at 01:18:00PM +0200, Michal Hocko wrote:
> [...]
> > > Why cannot khugepaged simply skip over all VMAs which have userfault
> > > regions registered? This would sound like a less error prone approach to
> > > me.
> > 
> > khugepaged does skip over VMAs which have userfault. We could register the
> > regions with userfault before populating them to avoid collapses in the
> > transition period.
> 
> Why cannot you register only post-copy regions and "manually" copy the
> pre-copy parts?

We can register only post-copy regions, but this will cause VMA
fragmentation. Now we register the entire VMA with userfaultfd, no matter
how many pages were dirtied there since the pre-dump. If we register only
post-copy regions, we will split out the VMAs for those regions.
 
> > But then we'll have to populate these regions with
> > UFFDIO_COPY which adds quite an overhead.
> 
> How big is the performance impact?

I don't have the numbers handy, but for each post-copy range it means that
instead of memcpy() we will use ioctl(UFFDIO_COPY).

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
