Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id A2F616B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:05 -0500 (EST)
Received: by labgm9 with SMTP id gm9so13267263lab.7
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g13si15236022wiv.96.2015.03.05.09.19.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:03 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/21] userfaultfd: linux/Documentation/vm/userfaultfd.txt
Date: Thu,  5 Mar 2015 18:17:45 +0100
Message-Id: <1425575884-2574-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Add documentation.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/userfaultfd.txt | 97 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)
 create mode 100644 Documentation/vm/userfaultfd.txt

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
new file mode 100644
index 0000000..2ec296c
--- /dev/null
+++ b/Documentation/vm/userfaultfd.txt
@@ -0,0 +1,97 @@
+= Userfaultfd =
+
+== Objective ==
+
+Userfaults allow to implement on demand paging from userland and more
+generally they allow userland to take control various memory page
+faults, something otherwise only the kernel code could do.
+
+For example userfaults allows a proper and more optimal implementation
+of the PROT_NONE+SIGSEGV trick.
+
+== Design ==
+
+Userfaults are delivered and resolved through the userfaultfd syscall.
+
+The userfaultfd (aside from registering and unregistering virtual
+memory ranges) provides for two primary functionalities:
+
+1) read/POLLIN protocol to notify an userland thread of the faults
+   happening
+
+2) various UFFDIO_* ioctls that can mangle over the virtual memory
+   regions registered in the userfaultfd that allows userland to
+   efficiently resolve the userfaults it receives via 1) or to mangle
+   the virtual memory in the background
+
+The real advantage of userfaults if compared to regular virtual memory
+management of mremap/mprotect is that the userfaults in all their
+operations never involve heavyweight structures like vmas (in fact the
+userfaultfd runtime load never takes the mmap_sem for writing).
+
+Vmas are not suitable for page(or hugepage)-granular fault tracking
+when dealing with virtual address spaces that could span
+Terabytes. Too many vmas would be needed for that.
+
+The userfaultfd once opened by invoking the syscall, can also be
+passed using unix domain sockets to a manager process, so the same
+manager process could handle the userfaults of a multitude of
+different process without them being aware about what is going on
+(well of course unless they later try to use the userfaultfd themself
+on the same region the manager is already tracking, which is a corner
+case that would currently return -EBUSY).
+
+== API ==
+
+When first opened the userfaultfd must be enabled invoking the
+UFFDIO_API ioctl specifying an uffdio_api.api value set to UFFD_API
+which will specify the read/POLLIN protocol userland intends to speak
+on the UFFD. The UFFDIO_API ioctl if successful (i.e. if the requested
+uffdio_api.api is spoken also by the running kernel), will return into
+uffdio_api.bits and uffdio_api.ioctls two 64bit bitmasks of
+respectively the activated feature bits below PAGE_SHIFT in the
+userfault addresses returned by read(2) and the generic ioctl
+available.
+
+Once the userfaultfd has been enabled the UFFDIO_REGISTER ioctl should
+be invoked (if present in the returned uffdio_api.ioctls bitmask) to
+register a memory range in the userfaultfd by setting the
+uffdio_register structure accordingly. The uffdio_register.mode
+bitmask will specify to the kernel which kind of faults to track for
+the range (UFFDIO_REGISTER_MODE_MISSING would track missing
+pages). The UFFDIO_REGISTER ioctl will return the
+uffdio_register.ioctls bitmask of ioctls that are suitable to resolve
+userfaults on the range reigstered. Not all ioctls will necessarily be
+supported for all memory types depending on the underlying virtual
+memory backend (anonymous memory vs tmpfs vs real filebacked
+mappings).
+
+Userland can use the uffdio_register.ioctls to mangle the virtual
+address space in the background (to add or potentially also remove
+memory from the userfaultfd registered range). This means an userfault
+could be triggering just before userland maps in the background the
+user-faulted page. To avoid POLLIN resulting in an unexpected blocking
+read (if the UFFD is not opened in nonblocking mode in the first
+place), we don't allow the background thread to wake userfaults that
+haven't been read by userland yet. If we would do that likely the
+UFFDIO_WAKE ioctl could be dropped. This may change in the future
+(with a UFFD_API protocol bumb combined with the removal of the
+UFFDIO_WAKE ioctl) if it'll be demonstrated that it's a valid
+optimization and worthy to force userland to use the UFFD always in
+nonblocking mode if combined with POLLIN.
+
+userfaultfd is also a generic enough feature, that it allows KVM to
+implement postcopy live migration (one form of memory externalization
+consisting of a virtual machine running with part or all of its memory
+residing on a different node in the cloud) without having to modify a
+single line of KVM kernel code. Guest async page faults, FOLL_NOWAIT
+and all other GUP features works just fine in combination with
+userfaults (userfaults trigger async page faults in the guest
+scheduler so those guest processes that aren't waiting for userfaults
+can keep running in the guest vcpus).
+
+The primary ioctl to resolve userfaults is UFFDIO_COPY. That
+atomically copies a page into the userfault registered range and wakes
+up the blocked userfaults (unless uffdio_copy.mode &
+UFFDIO_COPY_MODE_DONTWAKE is set). Other ioctl works similarly to
+UFFDIO_COPY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
