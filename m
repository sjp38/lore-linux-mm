Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id F23C16B0251
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 15:44:03 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1046718eek.17
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:44:03 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id y6si4458684eep.77.2014.03.20.12.44.02
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 12:44:02 -0700 (PDT)
Date: Thu, 20 Mar 2014 21:43:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [LSF/MM TOPIC] THP page cache
Message-ID: <20140320194355.GA4896@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ning Qu <quning@google.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

Hi,

I believe we will get to transparent huge pages at summit anyway. Below is data
points on file-backed transparent huge pages.

The code I have by the time is in my repo[1], see branches
thp/pc/v7/p1-base and thp/pc/v7/p2-mmap. Ning Qu works on rebasing
shmem/tmpfs support on top of this.

Workloads known to benefit from THP for page cache:

- MongoDB: mongoperf on ramfs shows increase number of iops by 1.9x for r/o and
  1.7x for r/w;
- Google search/indexing benchmark shows +3% (in addition to +5% from AnonTHP),
  on pair with hugetlbfs;
- IOZone shows improvement up to 2.5x on ramfs;

Should help also with:

- Reducing ITLB pressure:
  + x86-64 binaries is ready to be mapped with 2M pages: binutils creates
    binaries with required file offset and virtual address alignment, no
    changes required;
  + reported 11% performance increase of RDBMS by putting code to hugetlbfs;
  + MySQL spends 2.5% of cycles in page table walk due ITLB misses[2];
- HPC workloads on many-cores systems (like Xeon Phi): large code and data,
  small TLB, limited memory bandwidth.

[1] git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
[2] http://research.cs.wisc.edu/multifacet/papers/isca13_direct_segment.pdf

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
