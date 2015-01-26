Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 33DFE6B006C
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:13:16 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id k48so8665814wev.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:13:15 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id w5si19603060wjr.60.2015.01.26.04.13.12
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 04:13:13 -0800 (PST)
Date: Mon, 26 Jan 2015 14:13:09 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
Message-ID: <20150126121309.GD25833@node.dhcp.inet.fi>
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org>
 <54C62803.8010105@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C62803.8010105@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 12:41:55PM +0100, Vlastimil Babka wrote:
> On 01/21/2015 01:48 AM, Andrew Morton wrote:
> > On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> >> + * Should be called with the mm_sem of the vma hold.
> > 
> > That's a pretty cruddy sentence, isn't it?  Copied from
> > alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.
> > 
> > And it should tell us whether mmap_sem required a down_read or a
> > down_write.  What purpose is it serving?
> 
> This is already said for mmap_sem further above this comment line, which
> should be just deleted (and from alloc_hugepage_vma comment too).
> 
> >> + *
> >> + */
> >> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
> >> +				unsigned long addr, int order)
> > 
> > This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?
> > 
> > 
> > 
> > --- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
> > +++ a/mm/mempolicy.c
> 
> How about this cleanup on top? I'm not fully decided on the GFP_TRANSHUGE test.
> This is potentially false positive, although I doubt anything else uses the same
> gfp mask bits.

This info on gfp mask should be in commit message.

And what about WARN_ON_ONCE() if we the matching bits with
!TRANSPARENT_HUGEPAGE?

> 
> Should "hugepage" be extra bool parameter instead? Should I #ifdef the parameter
> only for CONFIG_TRANSPARENT_HUGEPAGE, or is it not worth the ugliness?

Do we have spare gfp bit? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
