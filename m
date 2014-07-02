Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA4B6B003C
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:51:39 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so9974414wib.7
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 09:51:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si23797284wiy.1.2014.07.02.09.51.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 09:51:36 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/10] RFC: userfault
Date: Wed,  2 Jul 2014 18:50:06 +0200
Message-Id: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

Hello everyone,

There's a large CC list for this RFC because this adds two new
syscalls (userfaultfd and remap_anon_pages) and
MADV_USERFAULT/MADV_NOUSERFAULT, so suggestions on changes to the API
or on a completely different API if somebody has better ideas are
welcome now.

The combination of these features are what I would propose to
implement postcopy live migration in qemu, and in general demand
paging of remote memory, hosted in different cloud nodes.

The MADV_USERFAULT feature should be generic enough that it can
provide the userfaults to the Android volatile range feature too, on
access of reclaimed volatile pages.

If the access could ever happen in kernel context through syscalls
(not not just from userland context), then userfaultfd has to be used
to make the userfault unnoticeable to the syscall (no error will be
returned). This latter feature is more advanced than what volatile
ranges alone could do with SIGBUS so far (but it's optional, if the
process doesn't call userfaultfd, the regular SIGBUS will fire, if the
fd is closed SIGBUS will also fire for any blocked userfault that was
waiting a userfaultfd_write ack).

userfaultfd is also a generic enough feature, that it allows KVM to
implement postcopy live migration without having to modify a single
line of KVM kernel code. Guest async page faults, FOLL_NOWAIT and all
other GUP features works just fine in combination with userfaults
(userfaults trigger async page faults in the guest scheduler so those
guest processes that aren't waiting for userfaults can keep running in
the guest vcpus).

remap_anon_pages is the syscall to use to resolve the userfaults (it's
not mandatory, vmsplice will likely still be used in the case of local
postcopy live migration just to upgrade the qemu binary, but
remap_anon_pages is faster and ideal for transferring memory across
the network, it's zerocopy and doesn't touch the vma: it only holds
the mmap_sem for reading).

The current behavior of remap_anon_pages is very strict to avoid any
chance of memory corruption going unnoticed. mremap is not strict like
that: if there's a synchronization bug it would drop the destination
range silently resulting in subtle memory corruption for
example. remap_anon_pages would return -EEXIST in that case. If there
are holes in the source range remap_anon_pages will return -ENOENT.

If remap_anon_pages is used always with 2M naturally aligned
addresses, transparent hugepages will not be splitted. In there could
be 4k (or any size) holes in the 2M (or any size) source range,
remap_anon_pages should be used with the RAP_ALLOW_SRC_HOLES flag to
relax some of its strict checks (-ENOENT won't be returned if
RAP_ALLOW_SRC_HOLES is set, remap_anon_pages then will just behave as
a noop on any hole in the source range). This flag is generally useful
when implementing userfaults with THP granularity, but it shouldn't be
set if doing the userfaults with PAGE_SIZE granularity if the
developer wants to benefit from the strict -ENOENT behavior.

The remap_anon_pages syscall API is not vectored, as I expect it to be
used mainly for demand paging (where there can be just one faulting
range per userfault) or for large ranges (with the THP model as an
alternative to zapping re-dirtied pages with MADV_DONTNEED with 4k
granularity before starting the guest in the destination node) where
vectoring isn't going to provide much performance advantages (thanks
to the THP coarser granularity).

On the rmap side remap_anon_pages doesn't add much complexity: there's
no need of nonlinear anon vmas to support it because I added the
constraint that it will fail if the mapcount is more than 1. So in
general the source range of remap_anon_pages should be marked
MADV_DONTFORK to prevent any risk of failure if the process ever
forks (like qemu can in some case).

One part that hasn't been tested is the poll() syscall on the
userfaultfd because the postcopy migration thread currently is more
efficient waiting on blocking read()s (I'll write some code to test
poll() too). I also appended below a patch to trinity to exercise
remap_anon_pages and userfaultfd and it completes trinity
successfully.

The code can be found here:

git clone --reference linux git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git -b userfault 

The branch is rebased so you can get updates for example with:

git fetch && git checkout -f origin/userfault

Comments welcome, thanks!
Andrea
