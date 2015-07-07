Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4166B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 17:16:16 -0400 (EDT)
Received: by igau2 with SMTP id u2so47448765iga.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 14:16:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pq8si575649icb.20.2015.07.07.14.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 14:16:15 -0700 (PDT)
Date: Tue, 7 Jul 2015 14:16:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 0/5] Allow user to request memory to be locked on
 page fault
Message-Id: <20150707141613.f945c98279dcb71c9743d5f2@linux-foundation.org>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Tue,  7 Jul 2015 13:03:38 -0400 Eric B Munson <emunson@akamai.com> wrote:

> mlock() allows a user to control page out of program memory, but this
> comes at the cost of faulting in the entire mapping when it is
> allocated.  For large mappings where the entire area is not necessary
> this is not ideal.  Instead of forcing all locked pages to be present
> when they are allocated, this set creates a middle ground.  Pages are
> marked to be placed on the unevictable LRU (locked) when they are first
> used, but they are not faulted in by the mlock call.
> 
> This series introduces a new mlock() system call that takes a flags
> argument along with the start address and size.  This flags argument
> gives the caller the ability to request memory be locked in the
> traditional way, or to be locked after the page is faulted in.  New
> calls are added for munlock() and munlockall() which give the called a
> way to specify which flags are supposed to be cleared.  A new MCL flag
> is added to mirror the lock on fault behavior from mlock() in
> mlockall().  Finally, a flag for mmap() is added that allows a user to
> specify that the covered are should not be paged out, but only after the
> memory has been used the first time.

Thanks for sticking with this.  Adding new syscalls is a bit of a
hassle but I do think we end up with a better interface - the existing
mlock/munlock/mlockall interfaces just aren't appropriate for these
things.

I don't know whether these syscalls should be documented via new
manpages, or if we should instead add them to the existing
mlock/munlock/mlockall manpages.  Michael, could you please advise?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
