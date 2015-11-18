Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFE3D6B0256
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:29:45 -0500 (EST)
Received: by lfdo63 with SMTP id o63so30071475lfd.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:29:45 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id k185si2466820lfe.96.2015.11.18.08.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:29:44 -0800 (PST)
Received: by lfdo63 with SMTP id o63so2926857lfd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:29:44 -0800 (PST)
Date: Wed, 18 Nov 2015 17:29:41 +0100
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH] mm/mmap.c: remove incorrect MAP_FIXED flag comparison
 from mmap_region
Message-ID: <20151118162939.GA1842@home.local>
References: <20151117161928.GA9611@redhat.com>
 <1447781198-5496-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20151117165251.ccfe80f7007dfc3d0f346cd7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151117165251.ccfe80f7007dfc3d0f346cd7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 17, 2015 at 04:52:51PM -0800, Andrew Morton wrote:
> On Tue, 17 Nov 2015 18:26:38 +0100 Piotr Kwapulinski <kwapulinski.piotr@gmail.com> wrote:
> 
> > The following flag comparison in mmap_region is not fully correct:
> > 
> > if (!(vm_flags & MAP_FIXED))
> > 
> > The vm_flags should not be compared with MAP_FIXED (0x10). It is a bit
> > confusing. This condition is almost always true since VM_MAYREAD (0x10)
> > flag is almost always set by default. This patch removes this condition.
> > 
> > ...
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1547,13 +1547,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
> >  	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
> >  		unsigned long nr_pages;
> >  
> > -		/*
> > -		 * MAP_FIXED may remove pages of mappings that intersects with
> > -		 * requested mapping. Account for the pages it would unmap.
> > -		 */
> > -		if (!(vm_flags & MAP_FIXED))
> > -			return -ENOMEM;
> > -
> >  		nr_pages = count_vma_pages_range(mm, addr, addr + len);
> >  
> >  		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
> 
> That looks simpler.
> 
> However the changelog doesn't describe the end-user visible effects of
> the bug, as changelogs should always do.  Presumably this is causing
> incorrect ENOMEM reporting due to RLIMIT_AS being exceeded, but this
> isn't very specific.
> 
> So can you please fill in the details here?  Such info is needed when
> deciding which kernel version(s) need the fix.
> 
> Thanks.

The first patch has got a user visible effect and it fixes the
real issue (corner case one). The second patch has no user visible effect.
It just removes the code that makes no sense. The second patch has
been created in case the first patch was not going to be accepted.
I will send both patches again to let you choose which one you preffer.
This time the patches will contain the more clear changelog containing
the user visible effect. 

Thanks.
---
Piotr Kwapulinski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
