Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2005F6B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 02:53:18 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e135so29763962ita.8
        for <linux-mm@kvack.org>; Wed, 31 May 2017 23:53:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h41si18146056ioi.92.2017.05.31.23.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 23:53:17 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v516mYlO146234
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 02:53:16 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2atdc01vv7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:53:16 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 1 Jun 2017 07:53:09 +0100
Date: Thu, 1 Jun 2017 09:53:02 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530143941.GK7969@dhcp22.suse.cz>
Message-Id: <20170601065302.GA30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, May 30, 2017 at 04:39:41PM +0200, Michal Hocko wrote:
> On Tue 30-05-17 16:04:56, Andrea Arcangeli wrote:
> > 
> > UFFDIO_COPY while not being a major slowdown for sure, it's likely
> > measurable at the microbenchmark level because it would add a
> > enter/exit kernel to every 4k memcpy. It's not hard to imagine that as
> > measurable. How that impacts the total precopy time I don't know, it
> > would need to be benchmarked to be sure.
> 
> Yes, please!

I've run a simple test (below) that fills 1G of memory either with memcpy
of ioctl(UFFDIO_COPY) in 4K chunks.
The machine I used has two "Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz" and
128G of RAM.
I've averaged elapsed time reported by /usr/bin/time over 100 runs and here
what I've got:

memcpy with THP on: 0.3278 sec
memcpy with THP off: 0.5295 sec
UFFDIO_COPY: 0.44 sec

That said, for the CRIU usecase UFFDIO_COPY seems faster that disabling THP
and then doing memcpy.

--
Sincerely yours,
Mike.

----------------------------------------------------------
{
	...

	src = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (src == MAP_FAILED)
		fprintf(stderr, "map src failed\n"), exit(1);
	*((unsigned long *)src) = 1;

 	if (disable_huge && prctl(PR_SET_THP_DISABLE, 1, 0, 0, 0))
		fprintf(stderr, "ptctl failed\n"), exit(1);

	dst = mmap(NULL, page_size * nr_pages, PROT_READ | PROT_WRITE,
		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (dst == MAP_FAILED)
		fprintf(stderr, "map dst failed\n"), exit(1);

	if (use_uffd && userfaultfd_register(dst))
		fprintf(stderr, "userfault_register failed\n"), exit(1);

	for (i = 0; i < nr_pages; i++) {
		char *address = dst + i * page_size;

		if (use_uffd) {
			struct uffdio_copy uffdio_copy;

			uffdio_copy.dst = (unsigned long)address;
			uffdio_copy.src = (unsigned long)src;
			uffdio_copy.len = page_size;
			uffdio_copy.mode = 0;
			uffdio_copy.copy = 0;

			ret = ioctl(uffd, UFFDIO_COPY, &uffdio_copy);
			if (ret)
				fprintf(stderr, "copy: %d, %d\n", ret, errno),
					exit(1);
		} else {
			memcpy(address, src, page_size);
		}

	}

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
