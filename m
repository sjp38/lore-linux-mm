Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA60F6B0003
	for <linux-mm@kvack.org>; Sat,  3 Nov 2018 08:02:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r16-v6so3810986pgv.17
        for <linux-mm@kvack.org>; Sat, 03 Nov 2018 05:02:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 66-v6si22271211pfv.38.2018.11.03.05.02.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 03 Nov 2018 05:02:42 -0700 (PDT)
Date: Sat, 3 Nov 2018 05:02:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
Message-ID: <20181103120235.GA10491@bombadil.infradead.org>
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, pasha.tatashin@oracle.com, vbabka@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:
> Page fault handlers are supposed to return VM_FAULT codes,
> but some drivers/file systems mistakenly return error
> numbers. Now that all drivers/file systems have been converted
> to use the vm_fault_t return type, change the type definition
> to no longer be compatible with 'int'. By making it an unsigned
> int, the function prototype becomes incompatible with a function
> which returns int. Sparse will detect any attempts to return a
> value which is not a VM_FAULT code.


> -/* Encode hstate index for a hwpoisoned large page */
> -#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> -#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
...
> +/* Encode hstate index for a hwpoisoned large page */
> +#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
> +#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)

I think it's important to mention in the changelog that these values
have been changed to avoid conflicts with other VM_FAULT codes.

> +/**
> + * typedef vm_fault_t -  __bitwise unsigned int
> + *
> + * vm_fault_t is the new unsigned int type to return VM_FAULT
> + * code by page fault handlers of drivers/file systems. Now if
> + * any page fault handlers returns non VM_FAULT code instead
> + * of VM_FAULT code, it will be a mismatch with function
> + * prototype and sparse will detect it.
> + */

The first line should be what the typedef *means*, not repeat the
compiler's definition.  The rest of the description should be information
for someone coming to the type for the first time; what you've written
here is changelog material.

/**
 * typedef vm_fault_t - Return type for page fault handlers.
 *
 * Page fault handlers return a bitmask of %VM_FAULT values.
 */

> +typedef __bitwise unsigned int vm_fault_t;
> +
> +/**
> + * enum - VM_FAULT code

Can you document an anonymous enum?  I've never tried.  Did you run this
through 'make htmldocs'?

> + * This enum is used to track the VM_FAULT code return by page
> + * fault handlers.

 * Page fault handlers return a bitmask of these values to tell the
 * core VM what happened when handling the fault.
