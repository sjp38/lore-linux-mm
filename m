Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 905AC8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:16:33 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so12334155qkf.1
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 21:16:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i8si7207739qvp.40.2018.12.10.21.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 21:16:32 -0800 (PST)
Date: Tue, 11 Dec 2018 13:16:25 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH] userfaultfd: clear flag if remap event not enabled
Message-ID: <20181211051625.GB3260@xz-x1>
References: <20181210065121.14984-1-peterx@redhat.com>
 <20181210175115.GB6380@rapoport-lnx>
 <20181210200925.GA14751@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181210200925.GA14751@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Pravin Shedge <pravin.shedge4linux@gmail.com>, linux-mm@kvack.org

On Mon, Dec 10, 2018 at 03:09:25PM -0500, Andrea Arcangeli wrote:
> Hello,
> 
> On Mon, Dec 10, 2018 at 07:51:16PM +0200, Mike Rapoport wrote:
> > On Mon, Dec 10, 2018 at 02:51:21PM +0800, Peter Xu wrote:
> > > When the process being tracked do mremap() without
> > > UFFD_FEATURE_EVENT_REMAP on the corresponding tracking uffd file
> > > handle, we should not generate the remap event, and at the same
> > > time we should clear all the uffd flags on the new VMA.  Without
> > > this patch, we can still have the VM_UFFD_MISSING|VM_UFFD_WP
> > > flags on the new VMA even the fault handling process does not
> > > even know the existance of the VMA.
> > > 
> > > CC: Andrea Arcangeli <aarcange@redhat.com>
> > > CC: Andrew Morton <akpm@linux-foundation.org>
> > > CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > CC: Kirill A. Shutemov <kirill@shutemov.name>
> > > CC: Hugh Dickins <hughd@google.com>
> > > CC: Pavel Emelyanov <xemul@virtuozzo.com>
> > > CC: Pravin Shedge <pravin.shedge4linux@gmail.com>
> > > CC: linux-mm@kvack.org
> > > CC: linux-kernel@vger.kernel.org
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > ---
> > >  fs/userfaultfd.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > index cd58939dc977..798ae8a438ff 100644
> > > --- a/fs/userfaultfd.c
> > > +++ b/fs/userfaultfd.c
> > > @@ -740,6 +740,9 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
> > >  		vm_ctx->ctx = ctx;
> > >  		userfaultfd_ctx_get(ctx);
> > >  		WRITE_ONCE(ctx->mmap_changing, true);
> > > +	} else if (ctx) {
> > > +		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> > > +		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
> 
> Great catch Peter!
> 
> > 
> > My preference would be 
> > 
> > 	if (!ctx)
> > 		return;
> > 	
> > 	if (ctx->features & UFFD_FEATURE_EVENT_REMAP) {
> > 		...
> > 	} else {
> > 		...
> > 	}
> > 
> > but I don't feel strongly about it.
> 
> Yes, it'd look nicer to run a single "ctx not null" check.

I agree.

> 
> > 
> > I'd appreciate a comment in the code and with it 
> > 
> > Acked-by: Mike Rapoport <rppt@linux.ibm.com>
> > 
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks to both!  I'll repost soon.

Regards,

-- 
Peter Xu
