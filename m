Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB966B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:17:09 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id yy13so108928063pab.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:17:09 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id sk8si6562155pac.44.2016.01.26.20.17.08
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 20:17:08 -0800 (PST)
Date: Tue, 26 Jan 2016 23:17:06 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 3/3] dax: Handle write faults more efficiently
Message-ID: <20160127041706.GP2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWuPa2SoUcMCtDiv1UDodNqKcQzsZV5PxQx5Xhb524f7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWuPa2SoUcMCtDiv1UDodNqKcQzsZV5PxQx5Xhb524f7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 09:38:19AM -0800, Andy Lutomirski wrote:
> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
> <matthew.r.wilcox@intel.com> wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> >
> > When we handle a write-fault on a DAX mapping, we currently insert a
> > read-only mapping and then take the page fault again to convert it to
> > a writable mapping.  This is necessary for the case where we cover a
> > hole with a read-only zero page, but when we have a data block already
> > allocated, it is inefficient.
> >
> > Use the recently added vmf_insert_pfn_prot() to insert a writable mapping,
> > even though the default VM flags say to use a read-only mapping.
> 
> Conceptually, I like this.  Do you need to make sure to do all the
> do_wp_page work, though?  (E.g. we currently update mtime in there.
> Some day I'll fix that, but it'll be replaced with a set_bit to force
> a deferred mtime update.)

We update mtime in the ->fault handler of filesystems which support DAX
like this:

        if (vmf->flags & FAULT_FLAG_WRITE) {
                sb_start_pagefault(inode->i_sb);
                file_update_time(vma->vm_file);
        }

so I think we're covered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
