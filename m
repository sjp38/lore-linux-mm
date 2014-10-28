Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6C15C900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 16:35:40 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so1488965pdi.3
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:35:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm1si2362443pbd.6.2014.10.28.13.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 13:35:39 -0700 (PDT)
Date: Tue, 28 Oct 2014 13:35:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same
 as normal zero page.
Message-Id: <20141028133539.c82f5e856fd66b39c2630dd4@linux-foundation.org>
In-Reply-To: <20141028154416.GB13840@gmail.com>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
	<20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
	<20141028154416.GB13840@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengwei Yin <yfw.kernel@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, 28 Oct 2014 23:44:50 +0800 Fengwei Yin <yfw.kernel@gmail.com> wrote:

> > > ...
> > >
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -41,6 +41,7 @@
> > >  #include <linux/kernel_stat.h>
> > >  #include <linux/mm.h>
> > >  #include <linux/hugetlb.h>
> > > +#include <linux/huge_mm.h>
> > >  #include <linux/mman.h>
> > >  #include <linux/swap.h>
> > >  #include <linux/highmem.h>
> > > @@ -787,6 +788,9 @@ check_pfn:
> > >  		return NULL;
> > >  	}
> > >  
> > > +	if (is_huge_zero_pfn(pfn))
> > > +		return NULL;
> > > +
> > 
> > Why this change?
> > 
> > What effect does it have upon vm_normal_page()'s many existing callers?
> 
> Subject: [PATCH v3] smaps should deal with huge zero page exactly same as
>  normal zero page.
> 
> We could see following memory info in /proc/xxxx/smaps with THP enabled.
>   7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
>   Size:           4294967296 kB
>   Rss:            10612736 kB
>   Pss:            10612736 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:  10612736 kB
>   Private_Dirty:         0 kB
>   Referenced:     10612736 kB
>   Anonymous:             0 kB
>   AnonHugePages:  10612736 kB
>   Swap:                  0 kB
>   KernelPageSize:        4 kB
>   MMUPageSize:           4 kB
>   Locked:                0 kB
>   VmFlags: rd mr mw me
> which is wrong becuase just huge_zero_page/normal_zero_page is used for
> /dev/zero. Most of the value should be 0.
> 
> This patch detects huge_zero_page (original implementation just detect
> normal_zero_page) and avoids to update the wrong value for huge_zero_page.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Fengwei Yin <yfw.kernel@gmail.com>
> ---
> 
> Hi Andrew,
> Please try this patch.
> It passed build with/without CONFIG_TRANSPARENT_HUGEPAGE. Thanks.

You didn't answer my question.

What is the reason for that change to vm_normal_page() and how does it
affect that function's callers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
