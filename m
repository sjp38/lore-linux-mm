Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42D206B0507
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 04:58:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v31so1427244wrc.7
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 01:58:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si1567621wrd.130.2017.08.01.01.58.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 01:58:01 -0700 (PDT)
Date: Tue, 1 Aug 2017 10:57:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm:hugetlb: Define system call hugetlb size
 encodings in single file
Message-ID: <20170801085759.GC15774@dhcp22.suse.cz>
References: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
 <1501527386-10736-2-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501527386-10736-2-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>

On Mon 31-07-17 11:56:24, Mike Kravetz wrote:
> If hugetlb pages are requested in mmap or shmget system calls,  a huge
> page size other than default can be requested.  This is accomplished by
> encoding the log2 of the huge page size in the upper bits of the flag
> argument.  asm-generic and arch specific headers all define the same
> values for these encodings.
> 
> Put common definitions in a single header file.  The primary uapi
> header files for mmap and shm will use these definitions as a basis
> for definitions specific to those system calls.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/uapi/asm-generic/hugetlb_encode.h | 34 +++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>  create mode 100644 include/uapi/asm-generic/hugetlb_encode.h
> 
> diff --git a/include/uapi/asm-generic/hugetlb_encode.h b/include/uapi/asm-generic/hugetlb_encode.h
> new file mode 100644
> index 0000000..e4732d3
> --- /dev/null
> +++ b/include/uapi/asm-generic/hugetlb_encode.h
> @@ -0,0 +1,34 @@
> +#ifndef _ASM_GENERIC_HUGETLB_ENCODE_H_
> +#define _ASM_GENERIC_HUGETLB_ENCODE_H_
> +
> +/*
> + * Several system calls take a flag to request "hugetlb" huge pages.
> + * Without further specification, these system calls will use the
> + * system's default huge page size.  If a system supports multiple
> + * huge page sizes, the desired huge page size can be specified in
> + * bits [26:31] of the flag arguments.  The value in these 6 bits
> + * will encode the log2 of the huge page size.
> + *
> + * The following definitions are associated with this huge page size
> + * encoding in flag arguments.  System call specific header files
> + * that use this encoding should include this file.  They can then
> + * provide definitions based on these with their own specific prefix.
> + * for example:
> + * #define MAP_HUGE_SHIFT HUGETLB_FLAG_ENCODE_SHIFT
> + */
> +
> +#define HUGETLB_FLAG_ENCODE_SHIFT	26
> +#define HUGETLB_FLAG_ENCODE_MASK	0x3f
> +
> +#define HUGETLB_FLAG_ENCODE_64KB	(16 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_512KB	(19 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_1MB		(20 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_2MB		(21 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_8MB		(23 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_16MB	(24 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_256MB	(28 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_1GB		(30 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_2GB		(31 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_16GB	(34 << HUGETLB_FLAG_ENCODE_SHIFT)
> +
> +#endif /* _ASM_GENERIC_HUGETLB_ENCODE_H_ */
> -- 
> 2.7.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
