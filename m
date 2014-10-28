Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 57971900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:22:13 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so114809pdi.3
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:22:13 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id gw4si526684pbb.172.2014.10.28.00.22.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 00:22:12 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id lf10so119184pab.4
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:22:11 -0700 (PDT)
Date: Tue, 28 Oct 2014 23:18:38 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same as
 normal zero page.
Message-ID: <20141028150944.GA13840@gmail.com>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
 <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon, Oct 27, 2014 at 03:17:48PM -0700, Andrew Morton wrote:
> On Mon, 27 Oct 2014 23:02:13 +0800 Fengwei Yin <yfw.kernel@gmail.com> wrote:
> 
> > We could see following memory info in /proc/xxxx/smaps with THP enabled.
> >   7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
> >   Size:           4294967296 kB
> >   Rss:            10612736 kB
> >   Pss:            10612736 kB
> >   Shared_Clean:          0 kB
> >   Shared_Dirty:          0 kB
> >   Private_Clean:  10612736 kB
> >   Private_Dirty:         0 kB
> >   Referenced:     10612736 kB
> >   Anonymous:             0 kB
> >   AnonHugePages:  10612736 kB
> >   Swap:                  0 kB
> >   KernelPageSize:        4 kB
> >   MMUPageSize:           4 kB
> >   Locked:                0 kB
> >   VmFlags: rd mr mw me
> > which is wrong becuase just huge_zero_page/normal_zero_page is used for
> > /dev/zero. Most of the value should be 0.
> > 
> > This patch detects huge_zero_page (original implementation just detect
> > normal_zero_page) and avoids to update the wrong value for huge_zero_page.
> > 
> > ...
> >
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -41,6 +41,7 @@
> >  #include <linux/kernel_stat.h>
> >  #include <linux/mm.h>
> >  #include <linux/hugetlb.h>
> > +#include <linux/huge_mm.h>
> >  #include <linux/mman.h>
> >  #include <linux/swap.h>
> >  #include <linux/highmem.h>
> > @@ -787,6 +788,9 @@ check_pfn:
> >  		return NULL;
> >  	}
> >  
> > +	if (is_huge_zero_pfn(pfn))
> > +		return NULL;
> > +
> 
> Why this change?
> 
I suppose the huge zero page should have same behavior as normal zero
page. vm_normal_page will return NULL if the pte is for normal zero
page. This change make it return NULL for huge zero page.

> What effect does it have upon vm_normal_page()'s many existing callers?
This is good question. I suppose it will not impact existing caller.
As I undestand, all other callers just pass real pte to vm_normal_page.
They will not go to this "is_huge_zero_pfn" path.

The only impact code is in smaps_pte_entry() (fs/proc/task_mmu.c) which
is what I want to fix.

BTW, the patch doesn't pass build without CONFIG_TRANSPARENT_HUGEPAGE. I
will send a new patch. Sorry for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
