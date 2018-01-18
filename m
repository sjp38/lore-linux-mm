Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 511366B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 10:40:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r9so1639419wme.8
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:40:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g55sor4463725eda.3.2018.01.18.07.40.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 07:40:42 -0800 (PST)
Date: Thu, 18 Jan 2018 18:40:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
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
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

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

Something like this?
