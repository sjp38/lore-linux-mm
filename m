Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CB26B6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:34:11 -0500 (EST)
Received: by pacej9 with SMTP id ej9so76045556pac.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:34:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rs4si52114383pbb.50.2015.11.16.10.34.10
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 10:34:10 -0800 (PST)
Date: Mon, 16 Nov 2015 11:34:04 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mm, dax: fix DAX deadlocks (COW fault)
Message-ID: <20151116183404.GA22996@linux.intel.com>
References: <1447675755-5692-1-git-send-email-yigal@plexistor.com>
 <CAPcyv4gaeq=dJziT3xdWfaprVg6KsRO2-yR9QC3_XV8zb6b=Mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gaeq=dJziT3xdWfaprVg6KsRO2-yR9QC3_XV8zb6b=Mg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Yigal Korman <yigal@plexistor.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, david <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Stable Tree <stable@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <dchinner@redhat.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Mon, Nov 16, 2015 at 10:15:56AM -0800, Dan Williams wrote:
> On Mon, Nov 16, 2015 at 4:09 AM, Yigal Korman <yigal@plexistor.com> wrote:
> > DAX handling of COW faults has wrong locking sequence:
> >         dax_fault does i_mmap_lock_read
> >         do_cow_fault does i_mmap_unlock_write
> >
> > Ross's commit[1] missed a fix[2] that Kirill added to Matthew's
> > commit[3].
> >
> > Original COW locking logic was introduced by Matthew here[4].
> >
> > This should be applied to v4.3 as well.
> >
> > [1] 0f90cc6609c7 mm, dax: fix DAX deadlocks
> > [2] 52a2b53ffde6 mm, dax: use i_mmap_unlock_write() in do_cow_fault()
> > [3] 843172978bb9 dax: fix race between simultaneous faults
> > [4] 2e4cdab0584f mm: allow page fault handlers to perform the COW
> >
> > Signed-off-by: Yigal Korman <yigal@plexistor.com>
> >
> > Cc: Stable Tree <stable@vger.kernel.org>
> > Cc: Boaz Harrosh <boaz@plexistor.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Dave Chinner <dchinner@redhat.com>
> > Cc: Jan Kara <jack@suse.com>
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> > ---
> >  mm/memory.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/memory.c b/mm/memory.c
> > index c716913..e5071af 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3015,9 +3015,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >                 } else {
> >                         /*
> >                          * The fault handler has no page to lock, so it holds
> > -                        * i_mmap_lock for write to protect against truncate.
> > +                        * i_mmap_lock for read to protect against truncate.
> >                          */
> > -                       i_mmap_unlock_write(vma->vm_file->f_mapping);
> > +                       i_mmap_unlock_read(vma->vm_file->f_mapping);
> >                 }
> >                 goto uncharge_out;
> >         }
> > @@ -3031,9 +3031,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >         } else {
> >                 /*
> >                  * The fault handler has no page to lock, so it holds
> > -                * i_mmap_lock for write to protect against truncate.
> > +                * i_mmap_lock for read to protect against truncate.
> >                  */
> > -               i_mmap_unlock_write(vma->vm_file->f_mapping);
> > +               i_mmap_unlock_read(vma->vm_file->f_mapping);
> >         }
> >         return ret;
> >  uncharge_out:
> 
> Looks good to me.  I'll include this with some other DAX fixes I have pending.

Looks good to me as well.  Thanks for catching this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
