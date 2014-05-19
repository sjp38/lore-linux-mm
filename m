Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 56B766B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 20:25:50 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so3048965eek.17
        for <linux-mm@kvack.org>; Sun, 18 May 2014 17:25:49 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id w2si13322992eel.56.2014.05.18.17.25.48
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 17:25:48 -0700 (PDT)
Date: Mon, 19 May 2014 03:25:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH] mm: unified interface to handle page table entries
 on different levels?
Message-ID: <20140519002543.GA3899@node.dhcp.inet.fi>
References: <1400286785-26639-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140518234559.GG6121@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140518234559.GG6121@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave@sr71.net, riel@redhat.com, mgorman@suse.de, aarcange@redhat.com

On Sun, May 18, 2014 at 07:45:59PM -0400, Matthew Wilcox wrote:
> On Sat, May 17, 2014 at 03:33:05AM +0300, Kirill A. Shutemov wrote:
> > Below is my attempt to play with the problem. I've took one function --
> > page_referenced_one() -- which looks ugly because of different APIs for
> > PTE/PMD and convert it to use vpte_t. vpte_t is union for pte_t, pmd_t
> > and pud_t.
> > 
> > Basically, the idea is instead of having different helpers to handle
> > PTE/PMD/PUD, we have one, which take pair of vpte_t + pglevel.
> 
> I can't find my original attempt at this now (I am lost in a maze of
> twisted git trees, all subtly different), but I called it a vpe (Virtual
> Page Entry).
> 
> Rather than using a pair of vpte_t and pglevel, the vpe_t contained
> enough information to discern what level it was; that's only two bits
> and I think all the architectures have enough space to squeeze in two
> more bits to the PTE (the PMD and PUD obviously have plenty of space).

I'm not sure if it's possible to find a single free bit on all
architectures. Two is near impossible.

And what about 5-level page tables in future? Will we need 3 bits there?
No way.

> > +static inline unsigned long vpte_size(vpte_t vptep, enum ptlevel ptlvl)
> > +{
> > +	switch (ptlvl) {
> > +	case PTE:
> > +		return PAGE_SIZE;
> > +#ifdef PMD_SIZE
> > +	case PMD:
> > +		return PMD_SIZE;
> > +#endif
> > +#ifdef PUD_SIZE
> > +	case PUD:
> > +		return PUD_SIZE;
> > +#endif
> > +	default:
> > +		return 0; /* XXX */
> 
> As you say, XXX.  This needs to be an error ... perhaps VM_BUG_ON(1)
> in this case?

Yeah. But include <linux/bug.h> is problematic here...

Anyway the only purpose of the code is to start discussion.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
