Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA12525
	for <linux-mm@kvack.org>; Mon, 10 May 1999 20:10:43 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905110010.RAA45630@google.engr.sgi.com>
Subject: Re: [RFT] [PATCH] kanoj-mm1-2.2.5 ia32 big memory patch
Date: Mon, 10 May 1999 17:10:14 -0700 (PDT)
In-Reply-To: <14135.28332.780955.729082@dukat.scot.redhat.com> from "Stephen C. Tweedie" at May 11, 99 00:41:32 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 10 May 1999 10:33:59 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > There are probably a lot of problems with the code as it stands
> > today. Reviewers, please let me know of any possible improvements.
> > Any ideas on how to improve the uaccess performance will also be
> > greatly appreciated. Testers, your input will be most valuable.
> 
> On a first scan one thing in particular jumped out:
> 
> +/*
> + * validate in a user page, so that the kernel can use the kernel direct
> + * mapped vaddr for the physical page to access user data. This locking
> + * relies on the fact that the caller has kernel_lock held, which restricts
> + * kswapd (or anyone else looking for a free page) from running and stealing 
> + * pages. By the same token, grabbing mmap_sem is not needed. 
> + */
> 
> Unfortunately, mmap_sem _is_ needed here.  Both find_extend_vma and
> handle_mm_fault need it.  You can't modify or block while scanning the
> vma list without it, or you risk breaking things in threaded
> applications (for example, taking a page fault in handle_mm_fault
> without it can be nasty if you are in the middle of a munmap at the
> time).
> 
> --Stephen
> 
Yes, how could I have missed that. mmap_sem is indeed needed in the 
slowpath: cases (hopefully the performance impact will be insignificant,
as this is the infrequent path). I will wait for people to show me more 
problems, before I put in all the changes and publish v2 of the patch.

Btw, is mmap_sem really needed for find_extend_vma, since we are already
holding lock_kernel (which mmap/munmap also gets)?

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
