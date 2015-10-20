Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id BF1C36B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 09:44:34 -0400 (EDT)
Received: by ykaz22 with SMTP id z22so16660608yka.2
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 06:44:34 -0700 (PDT)
Received: from mail-yk0-f193.google.com (mail-yk0-f193.google.com. [209.85.160.193])
        by mx.google.com with ESMTPS id x131si1337783ywa.226.2015.10.20.06.44.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 06:44:33 -0700 (PDT)
Received: by ykdr3 with SMTP id r3so1350679ykd.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 06:44:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151019214216.GU19147@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
	<CACh33FoFK4tbKFgcvN3mBuW7V=pMjM=X7eO68Pp9+56pH4B-EQ@mail.gmail.com>
	<20151019214216.GU19147@redhat.com>
Date: Tue, 20 Oct 2015 09:44:33 -0400
Message-ID: <CACh33FrecLbWiysXyN8gCEFy4J-2epVhgUw0qrr_b-9Hg0oksQ@mail.gmail.com>
Subject: Re: [PATCH 0/7] userfault21 update
From: Patrick Donnelly <batrick@batbytes.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Mon, Oct 19, 2015 at 5:42 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Patrick,
>
> On Mon, Oct 12, 2015 at 11:04:11AM -0400, Patrick Donnelly wrote:
>> Hello Andrea,
>>
>> On Mon, Jun 15, 2015 at 1:22 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>> > This is an incremental update to the userfaultfd code in -mm.
>>
>> Sorry I'm late to this party. I'm curious how a ptrace monitor might
>> use a userfaultfd to handle faults in all of its tracees. Is this
>> possible without having each (newly forked) tracee "cooperate" by
>> creating a userfaultfd and passing that to the tracer?
>
> To make the non cooperative usage work, userfaulfd also needs more
> features to track fork() and mremap() syscalls and such, as the
> monitor needs to be aware about modifications to the address space of
> each "mm" is managing and of new forked "mm" as well. So fork() won't
> need to call userfaultfd once we add those features, but it still
> doesn't need to know about the "pid". The uffd_msg already has padding
> to add the features you need for that.
>
> Pavel invented and developed those features for the non cooperative
> usage to implement postcopy live migration of containers. He posted
> some patchset on the lists too, but it probably needs to be rebased on
> upstream.
>
> The ptrace monitor thread can also fault into the userfault area if it
> wants to (but only if it's not the userfault manager thread as well).
> I didn't expect the ptrace monitor to want to be a userfault manager
> too though.
> [...]

Okay, it's definitely tricky to make this work for a tree of
non-cooperative processes. Brainstorming some ideas:

o If we are using ptrace, then we can add a ptrace event for receiving
the userfaultfd associated with the tracee, via waitpid (!). The
ptrace monitor can deduplicate userfaultfds by looking at the inode.
It can also associate a userfaultfd with a group of threads sharing a
mm. [For my possible use-case with Parrot[1], we already track the
shared address spaces of tracees in order to implement an mmap hook.]

o The userfaultfd can have a flag for tracking a tree of processes
(which can be sent via unix sockets to the userfault handler) and use
an opaque tag (the mm pointer?) to disambiguate the faults, instead of
a pid. There would need to be some kind of message to notify about
newly cloned threads and the mm associated with them? Yes, you
wouldn't be able to know which pid (or kernel/ptrace thread) generated
a fault but at least you would know which pids the mm belongs to.

I didn't see the patchset Pavel posted in a quick search of the
archives. Only this [2].

[1] http://ccl.cse.nd.edu/software/parrot/
[2] https://lkml.org/lkml/2015/1/15/103

-- 
Patrick Donnelly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
