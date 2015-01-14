Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 950496B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 18:01:35 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id k15so8917080qaq.9
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 15:01:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si33093650qga.61.2015.01.14.15.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 15:01:34 -0800 (PST)
Date: Thu, 15 Jan 2015 00:01:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [LSF/MM TOPIC] userfaultfd
Message-ID: <20150114230130.GR6103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

Hello,

I would like to attend this year (2015) LSF/MM summit. I'm
particularly interested about the MM track, in order to get help in
finalizing the userfaultfd feature I've been working on lately.

An overview on the userfaultfd feature can be read here:

   http://lwn.net/Articles/615086/

In essence the userfault feature could be imagined as an optimal
implementation for userland driven on demand paging similar to
PROT_NONE+SIGSEGV.

userfaultfd is fundamentally allowing to manage memory at the
pagetable level by delivering the page fault notification to userland
to handle it with proper userfaultfd commands that mangle the address
space, without involving heavyweight structures like vmas (in fact the
userfaultfd runtime load never takes the mmap_sem for writing, just
like its kernel counterpart wouldn't). The number of vmas is limited
too so they're not suitable if there are too many scattered faults and
the address space is not limited. userfaultfd allows all userfaults to
happen in parallel from different threads and it relies on userland to
use atomic copy or move commands to resolve the userfaults.

By adding more featured commands to the userfaultfd protocol (spoken
on the fd, like the basic atomic copy command that is needed to
resolve the userfault) in the future we can also mark regions readonly
and trap only wrprotect faults (or both wrprotect and non present
faults simultaneously).

Different userfaultfd can already be used independently by multiple
librarians and the main application within the same process.

The userfaultfd once opened, can also be passed using unix domain
sockets to a manager process (use case 5) below wants to do this), so the
same manager process could handle the userfaults of a multitude of
different process without them being aware about what is going on
(well of course unless they later try to use the userfaultfd themself
on the same region the manager is already tracking, which is a corner
case the relevancy of which should be discussed).

There was interest from multiple users, hope I'm not forgetting some:

1) KVM postcopy live migration (one form of cloud memory
   externalization). KVM postcopy live migration is the primary driver
   of this work:
   http://blog.zhaw.ch/icclab/setting-up-post-copy-live-migration-in-openstack/
   )

2) KVM postcopy live snapshotting (allowing to limit/throttle the
   memory usage, unlike fork would).

3) KVM userfaults on shared memory (currently only anonymous memory
   is handled by the userfaultfd but there's nothing that prevents to
   extend it and allow to register a tmpfs region in the userfaultfd
   and fire an userfault if the tmpfs page is not present)

4) alternate mechanism to notify web browsers or apps on embedded
   devices that volatile pages have been reclaimed. This basically
   avoids the need to run a syscall before the app can access with the
   CPU the virtual regions marked volatile. This also requires point 3)
   to be fulfilled, as volatile pages happily apply to tmpfs.

5) postcopy live migration of binaries inside linux containers
   (provided there is a userfaultfd command [not an external syscall
   like the original implementation] that allows to copy memory
   atomically in the userfaultfd "mm" and not in the manager "mm",
   hence the main reason the external syscalls are going away, and in
   turn MADV_USERFAULT fd-less is going away as well).

6) qemu linux-user binary emulation was also briefly interested about
   the wrprotection fault notification for non-x86 archs. In this
   context the userfaultfd ""might"" (not sure) be useful to JIT
   emulation to efficiently protect the translated regions by only
   wrprotecting the page table without having to split or merge vmas
   (the risk of running out of vmas isn't there for this use case as
   the translated cache is probably limited in size and not heavily
   scattered).

7) distributed shared memory that could allow simultaneous mapping of
   regions marked readonly and collapse them on the first exclusive
   write. I'm mentioning it as a corollary, because I'm not aware of
   anybody who is planning to use it that way (still I'd like that
   this will be possible too just in case it finds its way later on).

The currently planned API (as hinted above) is already different to
the first version of the code posted a couple of months ago, thanks to
the valuable feedback received by the community so far.

As usual suggestions will be welcome, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
