Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33AA16B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:46:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id w64-v6so4717523pfk.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 12:46:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f6-v6si5445231pgg.182.2018.10.24.12.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 12:46:53 -0700 (PDT)
Date: Wed, 24 Oct 2018 12:46:49 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v3 1/1] kvm: vmx: use vmalloc() to allocate vcpus
Message-ID: <20181024194649.GG25444@bombadil.infradead.org>
References: <20181024193912.37318-1-marcorr@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024193912.37318-1-marcorr@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com

On Wed, Oct 24, 2018 at 12:39:12PM -0700, Marc Orr wrote:
> Previously, vcpus were allocated through the kmem_cache_zalloc() API,
> which requires the underlying physical memory to be contiguous.
> Because the x86 vcpu struct, struct vcpu_vmx, is relatively large
> (e.g., currently 47680 bytes on my setup), it can become hard to find
> contiguous memory.
> 
> At the same time, the comments in the code indicate that the primary
> reason for using the kmem_cache_zalloc() API is to align the memory
> rather than to provide physical contiguity.
> 
> Thus, this patch updates the vcpu allocation logic for vmx to use the
> vmalloc() API.
> 
> Note, this patch uses the __vmalloc_node_range() API, which is in the
> include/linux/vmalloc.h file. To use __vmalloc_node_range(), this patch
> exports the API.

Oops ;-)

> +void *vzalloc_account(unsigned long size)
> +{
> +	return __vmalloc_node_flags(size, NUMA_NO_NODE,
> +				GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT);
> +}
> +EXPORT_SYMBOL(vzalloc_account);

For the mm parts:

Reviewed-by: Matthew Wilcox <willy@infradead.org>
