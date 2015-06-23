Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 592C16B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 17:41:48 -0400 (EDT)
Received: by qgal13 with SMTP id l13so8127701qga.3
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 14:41:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c5si23559956qgf.109.2015.06.23.14.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jun 2015 14:41:47 -0700 (PDT)
Date: Tue, 23 Jun 2015 23:41:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/23] userfaultfd: add new syscall to provide memory
 externalization
Message-ID: <20150623214141.GB4312@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-11-git-send-email-aarcange@redhat.com>
 <5589ACC3.3060401@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5589ACC3.3060401@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hi Dave,

On Tue, Jun 23, 2015 at 12:00:19PM -0700, Dave Hansen wrote:
> Down in userfaultfd_wake_function(), it looks like you intended for a
> len=0 to mean "wake all".  But the validate_range() that we do from
> userspace has a !len check in it, which keeps us from passing a len=0 in
> from userspace.
> Was that "wake all" for some internal use, or is the check too strict?

It's for internal use or userfaultfd_release that has to wake them all
(after setting ctx->released) if the uffd is closed. It avoids to
enlarge the structure by depending on the invariant that userland
cannot pass len=0.

If we'd accept len=0 from userland as valid, I'd be safer if it does
nothing like in madvise, I doubt we want to expose this non standard
kernel internal behavior to userland.

> I was trying to use the wake ioctl after an madvise() (as opposed to
> filling things in using a userfd copy).

madvise will return 0 if len=0, mremap would return -EINVAL if new_len
is zero, mmap also returns -EINVAL if len is 0, not all MM syscalls
are as permissive as madvise. Can't you pass the same len you pass to
madvise to UFFDIO_WAKE (or just skip the call if the madvise len is
zero)?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
