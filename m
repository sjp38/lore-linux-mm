Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 442F36B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:50:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 92so31244709wra.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 02:50:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si13219907wrh.288.2017.07.26.02.50.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 02:50:42 -0700 (PDT)
Date: Wed, 26 Jul 2017 11:50:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm:hugetlb:  Define system call hugetlb size
 encodings in single file
Message-ID: <20170726095038.GD2981@dhcp22.suse.cz>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-2-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500330481-28476-2-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Mon 17-07-17 15:27:59, Mike Kravetz wrote:
> If hugetlb pages are requested in mmap or shmget system calls,  a huge
> page size other than default can be requested.  This is accomplished by
> encoding the log2 of the huge page size in the upper bits of the flag
> argument.  asm-generic and arch specific headers all define the same
> values for these encodings.
> 
> Put common definitions in a single header file.  arch specific code can
> still override if desired.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

with
s@HUGETLB_FLAG_ENCODE__16GB@HUGETLB_FLAG_ENCODE_16GB@

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/uapi/asm-generic/hugetlb_encode.h | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
>  create mode 100644 include/uapi/asm-generic/hugetlb_encode.h
> 
> diff --git a/include/uapi/asm-generic/hugetlb_encode.h b/include/uapi/asm-generic/hugetlb_encode.h
> new file mode 100644
> index 0000000..aa09fc0
> --- /dev/null
> +++ b/include/uapi/asm-generic/hugetlb_encode.h
> @@ -0,0 +1,30 @@
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
> + * for example #define MAP_HUGE_SHIFT HUGETLB_FLAG_ENCODE_SHIFT.
> + */
> +
> +#define HUGETLB_FLAG_ENCODE_SHIFT	26
> +#define HUGETLB_FLAG_ENCODE_MASK	0x3f
> +
> +#define HUGETLB_FLAG_ENCODE_512KB	(19 << MAP_HUGE_SHIFT
> +#define HUGETLB_FLAG_ENCODE_1MB		(20 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_2MB		(21 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_8MB		(23 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_16MB	(24 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_1GB		(30 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE__16GB	(34 << MAP_HUGE_SHIFT)
> +
> +#endif /* _ASM_GENERIC_HUGETLB_ENCODE_H_ */
> -- 
> 2.7.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
