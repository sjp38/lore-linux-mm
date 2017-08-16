Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32ABC6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:15:45 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y67so4862851wrb.2
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:15:45 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id p46si1084702edc.220.2017.08.16.04.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 04:15:43 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id g32so2450975wrd.5
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:15:43 -0700 (PDT)
Date: Wed, 16 Aug 2017 14:15:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
Message-ID: <20170816111541.6c4ulnipt5cxgfsb@node.shutemov.name>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150286946261.8837.1454297295346610351.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150286946261.8837.1454297295346610351.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Aug 16, 2017 at 12:44:22AM -0700, Dan Williams wrote:
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index c8367041fafd..0e1de42c836f 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -7,6 +7,40 @@
>  #include <linux/atomic.h>
>  #include <uapi/linux/mman.h>
>  
> +#ifndef MAP_32BIT
> +#define MAP_32BIT 0
> +#endif
> +#ifndef MAP_HUGE_2MB
> +#define MAP_HUGE_2MB 0
> +#endif
> +#ifndef MAP_HUGE_1GB
> +#define MAP_HUGE_1GB 0
> +#endif
> +
> +/*
> + * The historical set of flags that all mmap implementations implicitly
> + * support when file_operations.mmap_supported_mask is zero.
> + */
> +#define LEGACY_MAP_SUPPORTED_MASK (MAP_SHARED \
> +		| MAP_PRIVATE \
> +		| MAP_FIXED \
> +		| MAP_ANONYMOUS \
> +		| MAP_UNINITIALIZED \
> +		| MAP_GROWSDOWN \
> +		| MAP_DENYWRITE \
> +		| MAP_EXECUTABLE \
> +		| MAP_LOCKED \
> +		| MAP_NORESERVE \
> +		| MAP_POPULATE \
> +		| MAP_NONBLOCK \
> +		| MAP_STACK \
> +		| MAP_HUGETLB \
> +		| MAP_32BIT \
> +		| MAP_HUGE_2MB \
> +		| MAP_HUGE_1GB)
> +
> +#define	MAP_SUPPORTED_MASK (LEGACY_MAP_SUPPORTED_MASK)
> +
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern unsigned long sysctl_overcommit_kbytes;

Since we looking into mmap(2) ABI, maybe we should consider re-defining
MAP_DENYWRITE and MAP_EXECUTABLE as 0 in hope that we would be able to
re-use these bits in the future? These flags are ignored now anyway.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
