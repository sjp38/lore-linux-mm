Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 79BD56B0035
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 13:26:17 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id j5so641076qga.31
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:26:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q4si6579459qca.36.2014.09.26.10.26.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 10:26:16 -0700 (PDT)
Date: Fri, 26 Sep 2014 19:25:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: RFC: get_user_pages_locked|unlocked to leverage VM_FAULT_RETRY
Message-ID: <20140926172535.GC4590@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Thu, Sep 25, 2014 at 02:50:29PM -0700, Andres Lagar-Cavilla wrote:
> It's nearly impossible to name it right because 1) it indicates we can
> relinquish 2) it returns whether we still hold the mmap semaphore.
> 
> I'd prefer it'd be called mmap_sem_hold, which conveys immediately
> what this is about ("nonblocking" or "locked" could be about a whole
> lot of things)

To me FOLL_NOWAIT/FAULT_FLAG_RETRY_NOWAIT is nonblocking,
"locked"/FAULT_FLAG_ALLOW_RETRY is still very much blocking, just
without the mmap_sem, so I called it "locked"... but I'm fine to
change the name to mmap_sem_hold. Just get_user_pages_mmap_sem_hold
seems less friendly than get_user_pages_locked(..., &locked). locked
as you used comes intuitive when you do later "if (locked) up_read".

Then I added an _unlocked kind which is a drop in replacement for many
places just to clean it up.

get_user_pages_unlocked and get_user_pages_fast are equivalent in
semantics, so any call of get_user_pages_unlocked(current,
current->mm, ...) has no reason to exist and should be replaced to
get_user_pages_fast unless "force = 1" (gup_fast has no force param
just to make the argument list a bit more confusing across the various
versions of gup).

get_user_pages over time should be phased out and dropped.

> I can see that. My background for coming into this is very similar: in
> a previous life we had a file system shim that would kick up into
> userspace for servicing VM memory. KVM just wouldn't let the file
> system give up the mmap semaphore. We had /proc readers hanging up all
> over the place while userspace was servicing. Not happy.
> 
> With KVM (now) and the standard x86 fault giving you ALLOW_RETRY, what
> stands in your way? Methinks that gup_fast has no slowpath fallback
> that turns on ALLOW_RETRY. What would oppose that being the global
> behavior?

It should become the global behavior. Just it doesn't need to become a
global behavior immediately for all kind of gups (i.e. video4linux
drivers will never need to poke into the KVM guest user memory so it
doesn't matter if they don't use gup_locked immediately). Even then we
can still support get_user_pages_locked(...., locked=NULL) for
ptrace/coredump and other things that may not want to trigger the
userfaultfd protocol and just get an immediate VM_FAULT_SIGBUS.

Userfaults will just VM_FAULT_SIGBUS (translated to -EFAULT by all gup
invocations) and not invoke the userfaultfd protocol, if
FAULT_FLAG_ALLOW_RETRY is not set. So any gup_locked with locked ==
NULL or or gup() (without locked parameter) will not invoke the
userfaultfd protocol.

But I need gup_fast to use FAULT_FLAG_ALLOW_RETRY because core places
like O_DIRECT uses it.

I tried to do a RFC patch below that goes into this direction and
should be enough for a start to solve all my issues with the mmap_sem
holding inside handle_userfault(), comments welcome.

=======
