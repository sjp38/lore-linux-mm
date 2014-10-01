Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 01BF96B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 07:39:41 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id tr6so143440ieb.2
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 04:39:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q9si3120275icz.41.2014.10.01.04.39.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 04:39:41 -0700 (PDT)
Message-ID: <542BE7F5.2000808@oracle.com>
Date: Wed, 01 Oct 2014 07:39:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/01/2014 07:31 AM, Kirill A. Shutemov wrote:
> +#define _VM_DUMP(arg, cond) do {					\
> +	if (__builtin_types_compatible_p(typeof(*arg), struct page))	\
> +		dump_page((struct page *) arg,				\
> +				"VM_BUG_ON(" __stringify(cond)")");	\
> +	else if (__builtin_types_compatible_p(typeof(*arg),		\
> +				struct vm_area_struct))			\
> +		dump_vma((struct vm_area_struct *) arg);		\
> +	else if (__builtin_types_compatible_p(typeof(*arg),		\
> +				struct mm_struct))			\
> +		dump_mm((struct mm_struct *) arg);			\
> +	else								\
> +		BUILD_BUG();						\
> +} while(0)

__same_type() instead of __builtin_types_compatible_p() would look nicer,
but I don't think that all compilers support that:

	include/linux/compiler-intel.h:/* Intel ECC compiler doesn't support __builtin_types_compatible_p() */

So it would effectively disable VM_BUG_ONs on Intel's compiler.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
