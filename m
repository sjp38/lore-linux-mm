Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6966B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:36:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h191so2781678wmd.15
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:36:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f192si12113200wmd.95.2017.10.12.03.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 03:36:35 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9CAYjCZ001115
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:36:34 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dj31ujsd4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:36:33 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 12 Oct 2017 11:36:29 +0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9CAaOmQ20709470
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:36:26 GMT
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9CAaP38031647
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 21:36:25 +1100
Subject: Re: [RFC PATCH 0/3] Add mmap(MAP_CONTIG) support
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 12 Oct 2017 16:06:13 +0530
MIME-Version: 1.0
In-Reply-To: <20171012014611.18725-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f1737666-b65e-38e2-94af-129e66031503@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/12/2017 07:16 AM, Mike Kravetz wrote:
> The following is a 'possible' way to add such functionality.  I just
> did what was easy and pre-allocated contiguous pages which are used
> to populate the mapping.  I did not use any of the higher order
> allocators such as alloc_contig_range.  Therefore, it is limited to

Just tried with a small prototype with an implementation similar to that
of alloc_gigantic_page() where we scan the zones (applicable zonelist)
for contiguous valid PFN range and try allocating with alloc_contig_range.
Will share it soon.

> allocations of MAX_ORDER size.  Also, the allocations should probably

Just did a quick test and it worked till 1UL << (MAX_ORDER - 1) numbers
of pages on a POWER system with the current RFC patches. As the pages
are allocated during VMA creation time, comparison to normal page fault
speed while accessing the buffer wont be fair.

> be done outside mmap_sem but that was the easiest place to do it in
> this quick and easy POC.

Why it should be done outside the mmap_sem, because it can take some
time ? But then VMA can just go away while we are allocating the big
chunks of pages (if we dont hold mmap_sem).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
