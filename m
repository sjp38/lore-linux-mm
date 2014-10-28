Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 15ACD900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:18:43 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ex7so1557693wid.4
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:18:43 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id we10si1949244wjb.121.2014.10.28.06.18.41
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 06:18:42 -0700 (PDT)
Date: Tue, 28 Oct 2014 15:18:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same as
 normal zero page.
Message-ID: <20141028131810.GB9768@node.dhcp.inet.fi>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
 <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
 <20141028150944.GA13840@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141028150944.GA13840@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengwei Yin <yfw.kernel@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org

On Tue, Oct 28, 2014 at 11:18:38PM +0800, Fengwei Yin wrote:
> On Mon, Oct 27, 2014 at 03:17:48PM -0700, Andrew Morton wrote:
> > On Mon, 27 Oct 2014 23:02:13 +0800 Fengwei Yin <yfw.kernel@gmail.com> wrote:
> > 
> > > We could see following memory info in /proc/xxxx/smaps with THP enabled.
> > >   7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
> > >   Size:           4294967296 kB
> > >   Rss:            10612736 kB
> > >   Pss:            10612736 kB
> > >   Shared_Clean:          0 kB
> > >   Shared_Dirty:          0 kB
> > >   Private_Clean:  10612736 kB
> > >   Private_Dirty:         0 kB
> > >   Referenced:     10612736 kB
> > >   Anonymous:             0 kB
> > >   AnonHugePages:  10612736 kB
> > >   Swap:                  0 kB
> > >   KernelPageSize:        4 kB
> > >   MMUPageSize:           4 kB
> > >   Locked:                0 kB
> > >   VmFlags: rd mr mw me
> > > which is wrong becuase just huge_zero_page/normal_zero_page is used for
> > > /dev/zero. Most of the value should be 0.
> > > 
> > > This patch detects huge_zero_page (original implementation just detect
> > > normal_zero_page) and avoids to update the wrong value for huge_zero_page.
> > > 
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
> I suppose the huge zero page should have same behavior as normal zero
> page. vm_normal_page will return NULL if the pte is for normal zero
> page. This change make it return NULL for huge zero page.
> 
> > What effect does it have upon vm_normal_page()'s many existing callers?
> This is good question. I suppose it will not impact existing caller.

vm_normal_page() is designed to handle pte. We only get there due hack
with pmd to pte cast in smaps_pte_range(). Let's try to get rid of it
instead.

Could you test the patch below? I think it's a better fix.
