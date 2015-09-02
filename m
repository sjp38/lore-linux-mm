Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 833056B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:47:42 -0400 (EDT)
Received: by wiclp12 with SMTP id lp12so12708962wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:47:42 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id gw8si3397406wib.22.2015.09.02.02.47.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 02:47:41 -0700 (PDT)
Received: by wicmc4 with SMTP id mc4so59851894wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:47:41 -0700 (PDT)
Date: Wed, 2 Sep 2015 12:47:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902094739.GA2627@node.dhcp.inet.fi>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901100804.GA7045@node.dhcp.inet.fi>
 <20150901224922.GR3902@dastard>
 <20150902091321.GA2323@node.dhcp.inet.fi>
 <55E6C36C.3090402@plexistor.com>
 <55E6C458.3040901@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55E6C458.3040901@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 02, 2015 at 12:41:44PM +0300, Boaz Harrosh wrote:
> On 09/02/2015 12:37 PM, Boaz Harrosh wrote:
> >>  
> >> +               /*
> >> +                * Make sure that for VM_MIXEDMAP VMA has both
> >> +                * vm_ops->page_mkwrite and vm_ops->pfn_mkwrite or has none.
> >> +                */
> >> +               if ((vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite) &&
> >> +                               vma->vm_flags & VM_MIXEDMAP) {
> >> +                       VM_BUG_ON_VMA(!vma->vm_ops->page_mkwrite, vma);
> >> +                       VM_BUG_ON_VMA(!vma->vm_ops->pfn_mkwrite, vma);
> > 
> > BTW: the page_mkwrite is used for reading of holes that put zero-pages at the radix tree.
> >      One can just map a single global zero-page in pfn-mode for that.
> > 
> > Kirill Hi. Please don't make these BUG_ONs its counter productive believe me.

This is VM_BUG_ON, not normal BUG_ON. VM_BUG_ON is under CONFIG_DEBUG_VM 
which is disabled on production kernels.

> > Please make them WARN_ON_ONCE() it is not a crashing bug to work like this.
> > (Actually it is not a bug at all in some cases, but we can relax that when a user
> >  comes up)
> > 
> > Thanks
> > Boaz
> > 
> 
> Second thought I do not like this patch. This is why we have xftests for, the fact of it
> is that test 080 catches this. For me this is enough.

I don't insist on applying the patch. And I worry about false-positives.

> An FS developer should test his code, and worst case we help him on ML, like we did
> in this case.
> 
> Thanks
> Boaz
> 
> >> +               }
> >>                 addr = vma->vm_start;
> >>                 vm_flags = vma->vm_flags;
> >>         } else if (vm_flags & VM_SHARED) {
> >>
> > 
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
