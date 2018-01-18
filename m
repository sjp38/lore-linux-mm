Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4A86B025F
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:59:04 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u194so12318439oie.20
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:59:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si2905769oib.121.2018.01.18.06.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 06:59:03 -0800 (PST)
Date: Thu, 18 Jan 2018 15:58:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118145830.GA6406@redhat.com>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Thu, Jan 18, 2018 at 06:45:00AM -0800, Dave Hansen wrote:
> On 01/18/2018 04:25 AM, Kirill A. Shutemov wrote:
> > [   10.084024] diff: -858690919
> > [   10.084258] hpage_nr_pages: 1
> > [   10.084386] check1: 0
> > [   10.084478] check2: 0
> ...
> > diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> > index d22b84310f6d..57b4397f1ea5 100644
> > --- a/mm/page_vma_mapped.c
> > +++ b/mm/page_vma_mapped.c
> > @@ -70,6 +70,14 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
> >  		}
> >  		if (pte_page(*pvmw->pte) < pvmw->page)
> >  			return false;
> > +
> > +		if (pte_page(*pvmw->pte) - pvmw->page) {
> > +			printk("diff: %d\n", pte_page(*pvmw->pte) - pvmw->page);
> > +			printk("hpage_nr_pages: %d\n", hpage_nr_pages(pvmw->page));
> > +			printk("check1: %d\n", pte_page(*pvmw->pte) - pvmw->page < 0);
> > +			printk("check2: %d\n", pte_page(*pvmw->pte) - pvmw->page >= hpage_nr_pages(pvmw->page));
> > +			BUG();
> > +		}
> 
> This says that pte_page(*pvmw->pte) and pvmw->page are roughly 4GB away
> from each other (858690919*4=0xccba559c0).  That's not the compiler
> being wonky, it just means that the virtual addresses of the memory
> sections are that far apart.
> 
> This won't happen when you have vmemmap or flatmem because the mem_map[]
> is virtually contiguous and pointer arithmetic just works against all
> 'struct page' pointers.  But with classic sparsemem, it doesn't.
> 
> You need to make sure that the PFNs are in the same section before you
> can do the math that you want to do here.

Isn't it simply that pvmw->page isn't a page or pte_page(*pvmw->pte)
isn't a page?

The distance cannot matter, MMU isn't involved, this is pure 64bit
aritmetics, 1giga 1 terabyte, 48bits 5level pagetables are meaningless
in this comparison.

#include <stdio.h>

int main()
{
	volatile long i;
	struct x { char a[4000000000]; };
	for (i = 0; i < 4000000000*3; i += 4000000000) {
		printf("%ld\n", ((struct x *)0)-((((struct x *)i))));
	}
	printf("xxxx\n");
	for (i = 0; i < 4000000000; i += 1) {
		if (i==4)
			i = 4000000000;
		printf("%ld\n", ((struct x *)0)-((((struct x *)i))));
	}
	return 0;
}

You need to add two debug checks on "pte_page(*pvmw->pte) % 64" and
same for pvmw->page to find out the one of the two that isn't a page.

If both are real pages there's a bug that allocates page structs not
naturally aligned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
