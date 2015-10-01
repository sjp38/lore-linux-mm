Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0DA6B0290
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 12:45:56 -0400 (EDT)
Received: by qkbi190 with SMTP id i190so11322496qkb.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 09:45:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y45si6337695qgd.42.2015.10.01.09.45.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 09:45:55 -0700 (PDT)
Subject: Re: [PATCH 00/12] userfaultfd non-x86 and selftest updates for 4.2.0+
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
 <560C5A83.9080103@oracle.com> <20151001000625.GF19466@redhat.com>
 <560C8161.5020602@oracle.com> <20151001160430.GJ19466@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <560D6328.909@oracle.com>
Date: Thu, 1 Oct 2015 09:45:28 -0700
MIME-Version: 1.0
In-Reply-To: <20151001160430.GJ19466@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Thanks for the detailed explanation Andrea

On 10/01/2015 09:04 AM, Andrea Arcangeli wrote:
> Hello Mike,
> 
> On Wed, Sep 30, 2015 at 05:42:09PM -0700, Mike Kravetz wrote:
>> The use case I have is pretty simple.  Recently, fallocate hole punch
>> support was added to hugetlbfs.  The reason for this is that the database
>> people want to 'free up' huge pages they know will no longer be used.
>> However, these huge pages are part of SGA areas sometimes mapped by tens
>> of thousands of tasks.  They would like to 'catch' any tasks that
>> (incorrectly) fault in a page after hole punch.  The thought is that
>> this can be done with userfaultfd by registering these mappings with
>> UFFDIO_REGISTER_MODE_MISSING.  No need for UFFDIO_COPY or UFFDIO_ZEROPAGE.
>> We would just send a signal to the task (such as SIGBUS) and then do
>> a UFFDIO_WAKE.  The only downside to this approach is having thousands
>> of threads monitoring userfault fds to catch a database error condition.
>> I believe the MADV_USERFAULT/NOUSERFAULT code you proposed some time back
>> would be the ideal solution for this use case.  Unfortunately, I did not
>> know of this use case or your proposal back then. :(
> 
> I see how the MADV_USERFAULT would have been lighter weight in
> avoiding to allocate anon file structures and the associated anon
> inode, but it's no big deal. A few thousand files are lost in the
> noise in terms of memory footprint and there will be no performance
> difference.
> 
> Note also that adding back MADV_USEFAULT always remains possible but
> you can avoid all those threads even with the userfaultfd API. CRIU
> and postcopy live migration of containers are also going to use a
> similar logic (and for them MADV_USERFAULT API would not be enough).
> 
> Even at the light of this, I don't think MADV_USERFAULT was worth
> saving, it was too flakey when you deal with copy-user or GUP failing
> in the context of read/write or other syscalls that just return
> -EFAULT and are not restartable by signals if page faults fails. Not
> to tell it requires going back to userland and back into kernel in
> order to run the sigbus handler, userfaultfd optimizes that away. Last
> but not the least a communication channel between the sigbus handler
> and the userfault handler thread would need to be allocated by
> manually by userland anyway. With userfaultfd it's the kernel that
> talks directly to the userfault handler thread so there's no need of
> maintaining another communication channel because the userfaultfd
> provides for it in a more efficient way.
> 
> If you have a parent alive of all those processes waiting for sigchld
> to reap the zombies, you can send the userfaultfd of the child to a
> thread in the parent using unix domain sockets, then you can release
> the fd in the child. Then the uffd will be pollable in the parent and
> it'll still work on the child "mm" as if it was a thread per-child
> handling it. A single parent thread (or even the main process thread
> itself if it's using a epoll driven loop) can poll all child. If doing
> it with a separate thread cloned by the parent, no need of epoll for
> your case, as you only get waken in case of memory corruption and
> failure to cleanup and report.

Yes, it was my intention to try and consolidate userfault fd polling to
several threads using this method.

> Once an uffd gets waken you can send any signal to the child to kill
> it (note that only SIGKILL is reliable to kill a task stuck in
> handle_userfaultd because if the userfault happened inside a syscall
> all other signals can't run until the child is waken by
> UFFDIO_WAKE). SIGKILL always works reliably at killing a task stuck in
> userfault no matter if it was originated by userland or not. To
> decrease the latency of signals and to allow gdb/strace to work
> seamlessly in most cases, we allowed signals to interrupt a blocked
> userfault if it originated in userland and in turn it will be retried
> immediately after the signal sigreturns. It'll be like if no page
> fault has happened yet by the time the signal returns. You don't want
> to depend on this as you won't know if the handle_userfault() was
> originated by a userland or kernel page fault.

Thanks.  I was not aware of this issue.

> When a SIGCHLD is received by the parent and you call one of the
> wait() variants to reap the zombie, you also close the associated uffd
> to release the memory of the child.
> 
> Alternatively if you are satisfied with just an hang instead of ending
> up with memory-corrupting, you can just register it in the child and
> leave the uffd open without ever polling it. If you've a watchdog in
> the parent process detecting task in S state not responding you can
> still detect the corruption case by looking in /proc/pid/stack, you'll
> see it hung in handle_userfault(). This won't provide for an accurate
> error message though but it'd be the simplest to deploy. It'll still
> provide for a fully safe avoidance of memory corruption and it may be
> enough considering what would happen if the userfault wasn't armed.

I need to talk with the database folks about this.  Pretty sure they want
to be signaled in this case.  However, it does make me wonder what type
of 'recovery' is possible in the thread accessing data that should no
longer be valid.  I am pretty sure this would be a rare occurrence.  They
only want the ability to catch potential bugs in their code.  Ideally,
this never happens.  This is why there is some concern about the resources
necessary (per-process userfault fd and polling thread) for something that
hopefully never happens.

-- 
Mike Kravetz

> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
