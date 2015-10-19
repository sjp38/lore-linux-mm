Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id E97DD82F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 17:42:21 -0400 (EDT)
Received: by qgeo38 with SMTP id o38so126967610qge.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:42:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g67si32089551qgf.96.2015.10.19.14.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 14:42:21 -0700 (PDT)
Date: Mon, 19 Oct 2015 23:42:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/7] userfault21 update
Message-ID: <20151019214216.GU19147@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
 <CACh33FoFK4tbKFgcvN3mBuW7V=pMjM=X7eO68Pp9+56pH4B-EQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACh33FoFK4tbKFgcvN3mBuW7V=pMjM=X7eO68Pp9+56pH4B-EQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick Donnelly <batrick@batbytes.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello Patrick,

On Mon, Oct 12, 2015 at 11:04:11AM -0400, Patrick Donnelly wrote:
> Hello Andrea,
> 
> On Mon, Jun 15, 2015 at 1:22 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > This is an incremental update to the userfaultfd code in -mm.
> 
> Sorry I'm late to this party. I'm curious how a ptrace monitor might
> use a userfaultfd to handle faults in all of its tracees. Is this
> possible without having each (newly forked) tracee "cooperate" by
> creating a userfaultfd and passing that to the tracer?

To make the non cooperative usage work, userfaulfd also needs more
features to track fork() and mremap() syscalls and such, as the
monitor needs to be aware about modifications to the address space of
each "mm" is managing and of new forked "mm" as well. So fork() won't
need to call userfaultfd once we add those features, but it still
doesn't need to know about the "pid". The uffd_msg already has padding
to add the features you need for that.

Pavel invented and developed those features for the non cooperative
usage to implement postcopy live migration of containers. He posted
some patchset on the lists too, but it probably needs to be rebased on
upstream.

The ptrace monitor thread can also fault into the userfault area if it
wants to (but only if it's not the userfault manager thread as well).
I didn't expect the ptrace monitor to want to be a userfault manager
too though.

On a side note, the signals the ptrace monitor sends to the tracee
(SIGCONT|STOP included) will only be executed by the tracee without
waiting for userfault resolution from the userfault manager, if the
tracees userfault wasn't triggered in kernel context (and in a non
cooperative usage that's not an assumption you can make). If the
tracee hits an userfault while running in kernel context, the
userfault manager must resolve the userfault before any signal (except
SIGKILL of course) can be executed by the tracee. Only SIGKILL is
instantly executed by all tracees no matter if it was an userfault in
kernel or user context. That may be another reason for not wanting the
ptrace monitor and the userfault manager in the same thread (they can
still be running in two different threads of the same external
process).

> Have you considered using one userfaultfd for an entire tree of
> processes (signaled through a flag)? Would not a process id included
> in the include/uapi/linux/userfaultfd.h:struct uffd_msg be sufficient
> to disambiguate faults?

I got a private email asking a corollary question about having the
faulting IP address in the uffd_msg recently, which I answered and I
take opportunity to quote it as well below, as it's somewhat connected
with your "pid" question and this adds more context.

===

At times it's the kernel accessing the page (copy-user get user pages)
like if the buffer is a parameter to the write or read syscalls, just
to make an example.

The IP address triggering the fault isn't necessarily a userland
address. Furthermore not even the pid is known, so you don't know
which process accessed it.

userfaultfd only notifies userland that a certain page is requested
and must be mapped ASAP. You don't know why or who touched it.

===

Now about adding the "pid": the association between "pid" and "mm"
isn't so strict in the kernel. You can tell which "pid" shares the
same "mm" but if you look from userland, you can't always tell which
"mm"(/process) the pid belongs to. At times async io threads or
vhost-net threads can impersonate the "mm" and in effect become part
of the process and you'd get those random "pid" of kernel threads.

It could also be a ptrace that triggers an userfault, with a "pid" that
isn't part of the application and the manager must still work
seamlessly no matter who or which "pid" triggered the userfault.

So overall dealing the "pid"s sounds like not very clean as the same
kernel thread "pid" can impersonate multiple "mm" and you wouldn't get
the information of which "mm" the "address" belongs to.

When userfaultfd() is called, it literally binds to the "mm" the
process is running on and it's pid agnostic. Then when a kernel thread
impersonating the "mm" faults into the "mm" with get_user_pages or
copy_user or when a ptrace faults into the "mm", the userafult manager
won't even see the difference.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
