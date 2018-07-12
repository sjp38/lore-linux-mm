Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8118E6B0006
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 18:45:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so18038656pld.23
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 15:45:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x1-v6si16636211pga.480.2018.07.12.15.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 15:45:55 -0700 (PDT)
Date: Thu, 12 Jul 2018 15:45:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/5] mm/sparse: abstract sparse buffer allocations
Message-Id: <20180712154552.db99d1893bcba7f9503534a0@linux-foundation.org>
In-Reply-To: <20180712203730.8703-2-pasha.tatashin@oracle.com>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
	<20180712203730.8703-2-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu, 12 Jul 2018 16:37:26 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> When struct pages are allocated for sparse-vmemmap VA layout, we first
> try to allocate one large buffer, and than if that fails allocate struct
> pages for each section as we go.
> 
> The code that allocates buffer is uses global variables and is spread
> across several call sites.
> 
> Cleanup the code by introducing three functions to handle the global
> buffer:
> 
> sparse_buffer_init()	initialize the buffer
> sparse_buffer_fini()	free the remaining part of the buffer
> sparse_buffer_alloc()	alloc from the buffer, and if buffer is empty
> return NULL
> 
> Define these functions in sparse.c instead of sparse-vmemmap.c because
> later we will use them for non-vmemmap sparse allocations as well.
> 
> ...
>
> +void * __meminit sparse_buffer_alloc(unsigned long size)
> +{
> +	void *ptr = NULL;
> +
> +	if (sparsemap_buf) {
> +		ptr = (void *)ALIGN((unsigned long)sparsemap_buf, size);
> +		if (ptr + size > sparsemap_buf_end)
> +			ptr = NULL;
> +		else
> +			sparsemap_buf = ptr + size;
> +	}
> +	return ptr;
> +}

tweak...

diff -puN mm/sparse.c~mm-sparse-abstract-sparse-buffer-allocations-fix mm/sparse.c
--- a/mm/sparse.c~mm-sparse-abstract-sparse-buffer-allocations-fix
+++ a/mm/sparse.c
@@ -491,7 +491,7 @@ void * __meminit sparse_buffer_alloc(uns
 	void *ptr = NULL;
 
 	if (sparsemap_buf) {
-		ptr = (void *)ALIGN((unsigned long)sparsemap_buf, size);
+		ptr = PTR_ALIGN(sparsemap_buf, size);
 		if (ptr + size > sparsemap_buf_end)
 			ptr = NULL;
 		else
