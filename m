Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 483576B0257
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 11:12:55 -0500 (EST)
Received: by lffu14 with SMTP id u14so27215909lff.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:12:54 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id l80si13003482lfg.31.2015.11.24.08.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 08:12:53 -0800 (PST)
Received: by lfs39 with SMTP id 39so2398404lfs.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:12:53 -0800 (PST)
Date: Tue, 24 Nov 2015 17:12:49 +0100
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH v3] mm/mmap.c: remove incorrect MAP_FIXED flag comparison
 from mmap_region
Message-ID: <20151124161248.GA1414@home.local>
References: <20151123081946.GA21050@dhcp22.suse.cz>
 <1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20151123141401.0ad7e291be4d62ec83de7101@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123141401.0ad7e291be4d62ec83de7101@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 23, 2015 at 02:14:01PM -0800, Andrew Morton wrote:
> On Mon, 23 Nov 2015 18:36:42 +0100 Piotr Kwapulinski <kwapulinski.piotr@gmail.com> wrote:
> 
> > The following flag comparison in mmap_region makes no sense:
> > 
> > if (!(vm_flags & MAP_FIXED))
> >     return -ENOMEM;
> > 
> > The condition is always false and thus the above "return -ENOMEM" is never
> > executed. The vm_flags must not be compared with MAP_FIXED flag.
> > The vm_flags may only be compared with VM_* flags.
> > MAP_FIXED has the same value as VM_MAYREAD.
> > Hitting the rlimit is a slow path and find_vma_intersection should realize
> > that there is no overlapping VMA for !MAP_FIXED case pretty quickly.
> > 
> > Remove the code that makes no sense.
> > 
> > ...
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1551,9 +1551,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
> >  		 * MAP_FIXED may remove pages of mappings that intersects with
> >  		 * requested mapping. Account for the pages it would unmap.
> >  		 */
> > -		if (!(vm_flags & MAP_FIXED))
> > -			return -ENOMEM;
> > -
> >  		nr_pages = count_vma_pages_range(mm, addr, addr + len);
> >  
> >  		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
> 
> Did you intend to retain the stale comment?

It was my intention. This comment is still valid, even after removing the
condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
