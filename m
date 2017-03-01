Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8C1B6B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 18:13:37 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id s186so74855263qkb.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 15:13:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p68si5484000qkb.282.2017.03.01.15.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 15:13:37 -0800 (PST)
Date: Thu, 2 Mar 2017 00:13:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: fs: use-after-free in userfaultfd_exit
Message-ID: <20170301231334.GO5816@redhat.com>
References: <CACT4Y+Z188Wehaes7iTo5m3PLiPgusj86f39kuN-O2HeDvQEWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z188Wehaes7iTo5m3PLiPgusj86f39kuN-O2HeDvQEWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>

On Wed, Mar 01, 2017 at 07:48:00PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've got the following use-after-free report while running syzkaller
> fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760:

Yes, I posted the fix for this one last Friday, I found it during
stress testing, it triggered the first time post-upstream merging
despite I was running the same stress testing with SLUB poisoning
enabled before.

This affects all apps, also the ones that don't use userfaultfd, it's
a locking issue. Furthermore the cost of userfaultfd_exit was not
acceptable, if something it had to be activated by a flag in mm->flags
(such an optimization would have been absolutely trivial though).

Thankfully I realized another feature (UFFDIO_COPY -ENOSPC retval) can
provide the same information at zero cost so I could drop
userfaultfd_exit as a whole.

https://marc.info/?l=linux-mm&m=148796041217814&w=2

The fix is already included in -mm along with the other fix for
VM_FAULT_NOPAGE.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
