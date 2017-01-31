Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAD56B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 13:04:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so524318644pfw.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:04:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z86si16602989pfj.81.2017.01.31.10.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 10:04:12 -0800 (PST)
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
 <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
 <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
 <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <217e817e-2f91-91a5-1bef-16fb0cbacb63@intel.com>
Date: Tue, 31 Jan 2017 10:04:11 -0800
MIME-Version: 1.0
In-Reply-To: <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 11:25 PM, John Hubbard wrote:
> I also don't like having these policies hard-coded, and your 100x
> example above helps clarify what can go wrong about it. It would be
> nicer if, instead, we could better express the "distance" between nodes
> (bandwidth, latency, relative to sysmem, perhaps), and let the NUMA
> system figure out the Right Thing To Do.
> 
> I realize that this is not quite possible with NUMA just yet, but I
> wonder if that's a reasonable direction to go with this?

In the end, I don't think the kernel can make the "right" decision very
widely here.

Intel's Xeon Phis have some high-bandwidth memory (MCDRAM) that
evidently has a higher latency than DRAM.  Given a plain malloc(), how
is the kernel to know that the memory will be used for AVX-512
instructions that need lots of bandwidth vs. some random data structure
that's latency-sensitive?

In the end, I think all we can do is keep the kernel's existing default
of "low latency to the CPU that allocated it", and let apps override
when that policy doesn't fit them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
