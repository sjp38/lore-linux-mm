Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA12643
	for <linux-mm@kvack.org>; Mon, 10 May 1999 20:16:18 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14135.30408.623997.961605@dukat.scot.redhat.com>
Date: Tue, 11 May 1999 01:16:08 +0100 (BST)
Subject: Re: [RFT] [PATCH] kanoj-mm1-2.2.5 ia32 big memory patch
In-Reply-To: <199905110010.RAA45630@google.engr.sgi.com>
References: <14135.28332.780955.729082@dukat.scot.redhat.com>
	<199905110010.RAA45630@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 10 May 1999 17:10:14 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Btw, is mmap_sem really needed for find_extend_vma, since we are already
> holding lock_kernel (which mmap/munmap also gets)?

Yes: find_extend_vma modifies the vma, so you have to make sure that you
aren't doing this while somebody else already has the mm semaphore.  You
don't want to modify the vma while another process is doing the page
fault, so you still need to serialise.

The mmap code allocates new vmas, which calls kmalloc, and that can
block if you run out of memory.  It really isn't safe to extend the vma
while another thread is blocked like that.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
