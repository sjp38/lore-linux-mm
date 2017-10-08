Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFA056B0260
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 08:56:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q203so21129527wmb.0
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 05:56:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor3323480edv.46.2017.10.08.05.56.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 05:56:53 -0700 (PDT)
Date: Sun, 8 Oct 2017 15:56:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: shm: round up tmpfs size to huge page size when
 huge=always
Message-ID: <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
References: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Oct 07, 2017 at 04:22:10AM +0800, Yang Shi wrote:
> When passing "huge=always" option for mounting tmpfs, THP is supposed to
> be allocated all the time when it can fit, but when the available space is
> smaller than the size of THP (2MB on x86), shmem fault handler still tries
> to allocate huge page every time, then fallback to regular 4K page
> allocation, i.e.:
> 
> 	# mount -t tmpfs -o huge,size=3000k tmpfs /tmp
> 	# dd if=/dev/zero of=/tmp/test bs=1k count=2048
> 	# dd if=/dev/zero of=/tmp/test1 bs=1k count=2048
> 
> The last dd command will handle 952 times page fault handler, then exit
> with -ENOSPC.
> 
> Rounding up tmpfs size to THP size in order to use THP with "always"
> more efficiently. And, it will not wast too much memory (just allocate
> 511 extra pages in worst case).

Hm. I don't think it's good idea to silently increase size of fs.

Maybe better just refuse to mount with huge=always for too small fs?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
