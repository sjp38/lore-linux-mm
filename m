Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EABB6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:09:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a77so1335075wma.12
        for <linux-mm@kvack.org>; Wed, 31 May 2017 02:09:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l24si16439044edj.227.2017.05.31.02.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 02:09:35 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4V99TmX103566
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:09:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aspg436ea-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:09:32 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 31 May 2017 10:08:52 +0100
Date: Wed, 31 May 2017 12:08:45 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530103930.GB7969@dhcp22.suse.cz>
Message-Id: <20170531090844.GA25375@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, May 30, 2017 at 12:39:30PM +0200, Michal Hocko wrote:
> On Tue 30-05-17 13:19:22, Mike Rapoport wrote:
> > > > But then we'll have to populate these regions with
> > > > UFFDIO_COPY which adds quite an overhead.
> > > 
> > > How big is the performance impact?
> > 
> > I don't have the numbers handy, but for each post-copy range it means that
> > instead of memcpy() we will use ioctl(UFFDIO_COPY).
> 
> It would be good to measure that though.

I will, but I won't expect huge difference here. Anyway, memcpy() will
touch still unpopulated pages, so we'll anyway enter/exit kernel.

> You are proposing a new user 
> API and the THP api is quite convoluted already so there better be a
> very good reason to add a new API. So far I can only see that it would
> be more convinient to add another madvise command and that is rather
> insufficient justification IMHO.

Well, the most convenient for my use case would be simply disable THP
before restore and re-enable it afterwards. And the need to use
ioctl(UFFDIO_COPY) is not that less convenient that the proposed madvise
command.

I've proposed the new madvise command because I firmly believe it is
missing. All madvise() commands that set some flag in vma->vm_flags have
the counter-command that resets that flag. Except for THP. The THP-related
flags can define three states for a VMA, pretty much like VM_SEQ_READ and
VM_RAND_READ. And it requires three madvise commands to allow setting any
of the desired states, just like with MADV_RANDOM, MADV_SEQUENTIAL and
MADV_NORMAL.

> Also do you expect somebody else would use new madvise? What would be the
> usecase?

I can think of an application that wants to keep 4K pages to save physical
memory for certain phase, e.g. until these pages are populated with very
few data. After the memory usage increases, the application may wish to
stop preventing khugepged from merging these pages, but it does not have
strong inclination to force use of huge pages.

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
