Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE006B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 09:18:42 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so277595pac.0
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 06:18:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kf2si747008pad.211.2014.10.01.06.18.41
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 06:18:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <542BE7F5.2000808@oracle.com>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
 <542BE7F5.2000808@oracle.com>
Subject: Re: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
Content-Transfer-Encoding: 7bit
Message-Id: <20141001131812.1893BE00A3@blue.fi.intel.com>
Date: Wed,  1 Oct 2014 16:18:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sasha Levin wrote:
> On 10/01/2014 07:31 AM, Kirill A. Shutemov wrote:
> > +#define _VM_DUMP(arg, cond) do {					\
> > +	if (__builtin_types_compatible_p(typeof(*arg), struct page))	\
> > +		dump_page((struct page *) arg,				\
> > +				"VM_BUG_ON(" __stringify(cond)")");	\
> > +	else if (__builtin_types_compatible_p(typeof(*arg),		\
> > +				struct vm_area_struct))			\
> > +		dump_vma((struct vm_area_struct *) arg);		\
> > +	else if (__builtin_types_compatible_p(typeof(*arg),		\
> > +				struct mm_struct))			\
> > +		dump_mm((struct mm_struct *) arg);			\
> > +	else								\
> > +		BUILD_BUG();						\
> > +} while(0)
> 
> __same_type() instead of __builtin_types_compatible_p() would look nicer,
> but I don't think that all compilers support that:
> 
> 	include/linux/compiler-intel.h:/* Intel ECC compiler doesn't support __builtin_types_compatible_p() */
> 
> So it would effectively disable VM_BUG_ONs on Intel's compiler

We can make _VM_DUMP nop, but I don't think ICC can build kernel anyway:
we already use __builtin_types_compatible_p() in i915 driver and other
places. Nobody cares.

Any other comments?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
