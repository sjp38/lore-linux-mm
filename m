Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80BDD280296
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 11:29:12 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so515493wma.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:29:12 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id y124si11722351wme.83.2016.11.11.08.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 08:29:11 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id g23so10573945wme.1
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:29:11 -0800 (PST)
Date: Fri, 11 Nov 2016 19:29:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: THP page cache support for ppc64
Message-ID: <20161111162909.GG19382@node.shutemov.name>
References: <20161107083441.21901-1-aneesh.kumar@linux.vnet.ibm.com>
 <20161107083441.21901-2-aneesh.kumar@linux.vnet.ibm.com>
 <20161111101439.GB19382@node.shutemov.name>
 <8737iy1ahw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737iy1ahw.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, Nov 11, 2016 at 05:42:11PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > On Mon, Nov 07, 2016 at 02:04:41PM +0530, Aneesh Kumar K.V wrote:
> >> @@ -2953,6 +2966,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
> >>  	ret = VM_FAULT_FALLBACK;
> >>  	page = compound_head(page);
> >>  
> >> +	/*
> >> +	 * Archs like ppc64 need additonal space to store information
> >> +	 * related to pte entry. Use the preallocated table for that.
> >> +	 */
> >> +	if (arch_needs_pgtable_deposit() && !fe->prealloc_pte)
> >> +		fe->prealloc_pte = pte_alloc_one(vma->vm_mm, fe->address);
> >> +
> >
> > -ENOMEM handling?
> 
> How about
> 
> 	if (arch_needs_pgtable_deposit() && !fe->prealloc_pte) {
> 		fe->prealloc_pte = pte_alloc_one(vma->vm_mm, fe->address);
> 		if (!fe->prealloc_pte)
> 			return VM_FAULT_OOM;
> 	}
> 
> 
> 
> >
> > I think we should do this way before this point. Maybe in do_fault() or
> > something.
> 
> doing this in do_set_pmd keeps this closer to where we set the pmd. Any
> reason you thing we should move it higher up the stack. We already do
> pte_alloc() at the same level for a non transhuge case in
> alloc_set_pte().

I vaguely remember Hugh mentioned deadlock of allocation under page-lock vs.
OOM-killer (or something else?).

If the deadlock is still there it would be matter of making preallocation
unconditional to fix the issue.

But what you propose about doesn't make situation any worse. I'm fine with
that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
