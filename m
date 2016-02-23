Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id C44556B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:28:39 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id o6so72429557qkc.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:28:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b53si24349976qge.77.2016.02.23.11.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 11:28:39 -0800 (PST)
Date: Tue, 23 Feb 2016 20:28:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: THP race?
Message-ID: <20160223192835.GJ9157@redhat.com>
References: <20160223154950.GA22449@node.shutemov.name>
 <20160223180609.GC23289@redhat.com>
 <20160223183832.GB21820@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223183832.GB21820@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org

On Tue, Feb 23, 2016 at 09:38:32PM +0300, Kirill A. Shutemov wrote:
> pmd_trans_unstable(pmd), otherwise looks good:

Yes sorry.

> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks for the quick ack, I just noticed or I would have added it to
the resubmit, but it can be still added to -mm.

> BTW, I guess DAX would need to introduce the same infrastructure for
> pmd_devmap(). Dan?

There is a i_mmap_lock_write in the truncate path that saves the day
for the pmd zapping in the truncate() case without mmap_sem (the only
case anon THP doesn't need to care about as truncate isn't possible in
the anon case), but not in the MADV_DONTNEED madvise case that runs
only with the mmap_sem for reading.

The only objective of this "infrastructure" is to add no pmd_lock()ing
overhead to the page fault, if the mapping is already established but
not huge, and we've just to walk through the pmd to reach the
pte. All because MADV_DONTNEED is running with the mmap_sem for
reading unlike munmap and other slower syscalls that are forced to
mangle the vmas and have to take the mmap_sem for writing regardless.

The question for DAX is if it should do a pmd_devmap check inside
pmd_none_or_trans_huge_or_clear_bad() after pmd_trans_huge() and get
away with a one liner, or add its own infrastructure with
pmd_devmap_unstable(). In the pmd_devmap case the problem isn't just
in __handle_mm_fault. If it could share the same infrastructure it'd
be ideal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
