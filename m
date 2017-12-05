Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5506B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:19:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so952096pff.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:19:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r15si486117pgt.604.2017.12.05.11.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:19:31 -0800 (PST)
Date: Tue, 5 Dec 2017 12:19:28 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax: fix potential overflow on 32bit machine
Message-ID: <20171205191928.GB21010@linux.intel.com>
References: <20171205033210.38338-1-yi.zhang@huawei.com>
 <20171205052407.GA20757@bombadil.infradead.org>
 <20171205170709.GA21010@linux.intel.com>
 <20171205173713.GA26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205173713.GA26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, viro@zeniv.linux.org.uk, miaoxie@huawei.com

On Tue, Dec 05, 2017 at 09:37:13AM -0800, Matthew Wilcox wrote:
> On Tue, Dec 05, 2017 at 10:07:09AM -0700, Ross Zwisler wrote:
> > >  /* The 'colour' (ie low bits) within a PMD of a page offset.  */
> > >  #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> > > +#define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)
> > 
> > I wonder if it's confusing that PG_PMD_COLOUR is a mask, but PG_PMD_NR is a
> > count?  Would "PAGES_PER_PMD" be clearer, in the spirit of
> > PTRS_PER_{PGD,PMD,PTE}? 
> 
> Maybe.  I don't think that 'NR' can ever be confused with a mask.
> I went with PG_PMD_NR because I didn't want to use HPAGE_PMD_NR, but
> in retrospect I just needed to go to sleep and leave thinking about
> hard problems like naming things for the morning.  I decided to call it
> 'colour' rather than 'mask' originally because I got really confused with
> PMD_MASK masking off the low bits.  If you ask 'What colour is this page
> within the PMD', you know you're talking about the low bits.
> 
> I actually had cause to define PMD_ORDER in a separate unrelated patch
> I was working on this morning.  How does this set of definitions grab you?
> 
> #define PMD_ORDER	(PMD_SHIFT - PAGE_SHIFT)
> #define PMD_PAGES	(1UL << PMD_ORDER)
> #define PMD_PAGE_COLOUR	(PMD_PAGES - 1)
> 
> and maybe put them in linux/mm.h so everybody can see them?

Yep, I personally like these better, and putting them in a global header seems
like the right way to go.

> > Also, can we use the same define both in fs/dax.c and in mm/truncate.c,
> > instead of the latter using HPAGE_PMD_NR?
> 
> I'm OK with the latter using HPAGE_PMD_NR because it's explicitly "is
> this a huge page?"  But I'd kind of like to get rid of a lot of the HPAGE_*
> definitions, so 

I would also like to get rid of them if possible, but quick grep makes me
think that unfortunately they may not be entirely equivalent to other defines
we have?

i.e:

arch/metag/include/asm/page.h:# define HPAGE_SHIFT      13
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      14
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      15
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      16
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      17
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      18
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      19
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      20
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      21
arch/metag/include/asm/page.h:# define HPAGE_SHIFT      22

this arch has no PMD_SHIFT definition...

I'm not really familiar with the HPAGE defines, though, so maybe it's not as
complex as it seems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
