Received: by wa-out-1112.google.com with SMTP id m33so135722wag.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2007 16:12:52 -0800 (PST)
Message-ID: <6934efce0712201612x57f77ab0le1d4d08d39e92c93@mail.gmail.com>
Date: Thu, 20 Dec 2007 16:12:52 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
In-Reply-To: <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com>
	 <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Dec 20, 2007 9:24 AM, Jared Hulbert <jaredeh@gmail.com> wrote:
> > A poor man's solution could be, to store a pfn range of the flash chip
> > and/or shared memory segment inside vm_area_struct, and in case of
> > VM_MIXEDMAP we check if the pfn matches that range. If so: no
> > refcounting. If not: regular refcounting. Is that an option?
>
> I'm not picturing what is responsible for configuring this stored pfn
> range.  Does the fs do it on mount?  Does the MTD or your funky
> direct_access block driver do it?
>
> What if you use VM_PFNMAP instead of VM_MIXEDMAP?

Though that might _work_ for ext2 it doesn't fix VM_MIXEDMAP.

vm_normal_page() needs to know if a VM_MIXEDMAP pfn has a struct page
or not.  Somebody had suggested we'd need a pfn_normal() or something.
 Maybe it should be called pfn_has_page() instead.  For ARM
pfn_has_page() == pfn_valid() near as I can tell.  What about on s390?
 If pfn_valid() doesn't work, then can you check if the pfn is
hotplugged in?  What would pfn_to_page() return if the associated
struct page entry was not initialized?  Can we use what is returned to
check if the pfn has no page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
