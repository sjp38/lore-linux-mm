Received: by wa-out-1112.google.com with SMTP id m33so1184992wag.8
        for <linux-mm@kvack.org>; Sat, 08 Mar 2008 10:54:01 -0800 (PST)
Message-ID: <6934efce0803081053t7c9c1351sd977803157540ce3@mail.gmail.com>
Date: Sat, 8 Mar 2008 10:53:59 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
In-Reply-To: <alpine.LFD.1.00.0803072331090.2911@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6934efce0803072033m5efd4d1o1ca8526f94649bb5@mail.gmail.com>
	 <alpine.LFD.1.00.0803072331090.2911@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

>  Is there any way we could just re-use the same calling conventions as we
>  already use for "vma->fault()"?
>
>
>  > +     int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
>  > +                     unsigned long *);
>
>  This really looks very close to
>
>         int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
>
>  and "struct vm_fault" returns either a kernel virtual address or a "struct
>  page *"
>
>  So would it be possible to just use the same calling convention, except
>  passing a "struct address_space" instead of a "struct vm_area_struct"?
>
>  I realize that "struct vm_fault" doesn't have a pfn in it (if they don't
>  do a "struct page", they are expected to fill in the PTE directly instead
>  and return VM_FAULT_NOPAGE), but I wonder if it should.

I think that makes a lot of sense.  The get_xip_mem() also takes in
vmf->pgoff as an input, yeah that would be nice.  I'll do that Monday.

>  The whole git_xip_page() issue really looks very similar to "fault in a
>  page from an address space". It feels kind of wrong to have filesystems
>  implement two functions for what seems to be the exact same issue.

get_xip_mem() does look similar to fault() but if you at it's place in
call stack it's more like

        int (*readpage)(struct file *, struct page *);

In AXFS depending on whether a page is XIP or not

	axfs_fault() > filemap_fault() > axfs_readpage()

Or for an XIP page it's

	axfs_fault() > xip_file_fault() > get_xip_mem()

So I it doesn't feel like overlap to me.  I think the overlap is
actually upstream in filemap_fault() vs xip_file_fault().  But I'm not
smart enough to figure it out yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
