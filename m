Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 441FB6B0313
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 08:10:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so18631158pfe.11
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 05:10:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c16si103170plk.615.2017.07.06.05.10.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 05:10:00 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v66C9VHA096100
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 08:09:59 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bhm2naj4k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:09:59 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Jul 2017 13:09:56 +0100
Date: Thu, 6 Jul 2017 15:09:50 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2] userfaultfd: Add feature to request for a signal
 delivery
References: <ff16daf5-7ba0-3dc2-7f73-eb7db8336df7@oracle.com>
 <20170704182806.GB4070@rapoport-lnx>
 <c1fa4d29-cbc9-6606-3e1f-9953078900a3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c1fa4d29-cbc9-6606-3e1f-9953078900a3@oracle.com>
Message-Id: <20170706120949.GE9625@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Jul 05, 2017 at 05:41:14PM -0700, prakash.sangappa wrote:
> 
> 
> On 07/04/2017 11:28 AM, Mike Rapoport wrote:
> >On Tue, Jun 27, 2017 at 09:08:40AM -0700, Prakash Sangappa wrote:
> >>Applications like the database use hugetlbfs for performance reason.
> >>Files on hugetlbfs filesystem are created and huge pages allocated
> >>using fallocate() API. Pages are deallocated/freed using fallocate() hole
> >>punching support. These files are mmap'ed and accessed by many
> >>single threaded processes as shared memory.  The database keeps
> >>track of which offsets in the hugetlbfs file have pages allocated.
> >>

[ ... ]

> >>+     *
> >>+     * UFFD_FEATURE_SIGBUS feature means no page-fault
> >>+     * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
> >>+     * a SIGBUS signal will be sent to the faulting process.
> >>+     * The application process can enable this behavior by adding
> >>+     * it to uffdio_api.features.
> >I think that it maybe worth making UFFD_FEATURE_SIGBUS mutually exclusive
> >with the non-cooperative events. There is no point of having monitor if the
> >page fault handler will anyway just kill the faulting process.
> 
> 
> Will this not be too restrictive?. The non-cooperative events could
> still be useful if an application wants to track changes
> to VA ranges that are registered even though it expects
> a signal on page fault.


I wouldn't say that we must make UFFD_FEATURE_SIGBUS mutually exclusive
with other events, but, IMHO, it's something we should at least think
about.

In my view, if you anyway have uffd monitor, you may process page faults
there as well and then there is no actual need in UFFD_FEATURE_SIGBUS.

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
