Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA12195
	for <linux-mm@kvack.org>; Mon, 10 May 1999 19:42:07 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14135.28332.780955.729082@dukat.scot.redhat.com>
Date: Tue, 11 May 1999 00:41:32 +0100 (BST)
Subject: Re: [RFT] [PATCH] kanoj-mm1-2.2.5 ia32 big memory patch
In-Reply-To: <199905101734.KAA43772@google.engr.sgi.com>
References: <199905101734.KAA43772@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 10 May 1999 10:33:59 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> There are probably a lot of problems with the code as it stands
> today. Reviewers, please let me know of any possible improvements.
> Any ideas on how to improve the uaccess performance will also be
> greatly appreciated. Testers, your input will be most valuable.

On a first scan one thing in particular jumped out:

+/*
+ * validate in a user page, so that the kernel can use the kernel direct
+ * mapped vaddr for the physical page to access user data. This locking
+ * relies on the fact that the caller has kernel_lock held, which restricts
+ * kswapd (or anyone else looking for a free page) from running and stealing 
+ * pages. By the same token, grabbing mmap_sem is not needed. 
+ */

Unfortunately, mmap_sem _is_ needed here.  Both find_extend_vma and
handle_mm_fault need it.  You can't modify or block while scanning the
vma list without it, or you risk breaking things in threaded
applications (for example, taking a page fault in handle_mm_fault
without it can be nasty if you are in the middle of a munmap at the
time).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
