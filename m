Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD226B026B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 21:12:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p5-v6so4343514pfh.11
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 18:12:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j1-v6si6819524plt.126.2018.08.09.18.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 18:12:26 -0700 (PDT)
Date: Thu, 9 Aug 2018 18:12:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding
 memory
Message-Id: <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
In-Reply-To: <20180809025409.31552-1-rashmica.g@gmail.com>
References: <20180809025409.31552-1-rashmica.g@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, malat@debian.org, bhelgaas@google.com, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rppt@linux.vnet.ibm.com

On Thu,  9 Aug 2018 12:54:09 +1000 Rashmica Gupta <rashmica.g@gmail.com> wrote:

> When hot-removing memory release_mem_region_adjustable() splits
> iomem resources if they are not the exact size of the memory being
> hot-deleted. Adding this memory back to the kernel adds a new
> resource.
> 
> Eg a node has memory 0x0 - 0xfffffffff. Offlining and hot-removing
> 1GB from 0xf40000000 results in the single resource 0x0-0xfffffffff being
> split into two resources: 0x0-0xf3fffffff and 0xf80000000-0xfffffffff.
> 
> When we hot-add the memory back we now have three resources:
> 0x0-0xf3fffffff, 0xf40000000-0xf7fffffff, and 0xf80000000-0xfffffffff.
> 
> Now if we try to remove some memory that overlaps these resources,
> like 2GB from 0xf40000000, release_mem_region_adjustable() fails as it
> expects the chunk of memory to be within the boundaries of a single
> resource.
> 
> This patch adds a function request_resource_and_merge(). This is called
> instead of request_resource_conflict() when registering a resource in
> add_memory(). It calls request_resource_conflict() and if hot-removing is
> enabled (if it isn't we won't get resource fragmentation) we attempt to
> merge contiguous resources on the node.

What is the end-user impact of this patch?

Do you believe the fix should be merged into 4.18?  Backporting into
-stable kernels?  If so, why?

Thanks.
