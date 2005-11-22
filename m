From: "Yi Feng" <yifeng@cs.umass.edu>
Subject: [patch] vmsig: notify user applications of virtual memory events via real-time signals
Date: Tue, 22 Nov 2005 15:54:51 -0500
Message-ID: <000001c5efa6$ff513990$9728010a@redmond.corp.microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Emery Berger' <emery@cs.umass.edu>, 'Matthew Hertz' <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

Linux-mm community:

I apologize for this long email. I'm presenting a kernel patch that the
community might be interested in.

We are a computer science research group at University of Massachusetts
Amherst, focusing on cooperative memory management across the OS kernel and
the user applications (particular the Java ones). We have developed a patch,
"vmsig", for the Linux kernel that enables kernel-to-user communication on
the virtual memory events. Currently our communication method is through an
unused real-time signal.

By using this patch, a user application can register with the kernel (via a
new system call vmsig_register) to receive RT signals on VM events on its
memory pages. There are 5 types of VM events as listed below:

VM_EVICTING_CLEAN: the page will soon be swapped out as a clean page
VM_EVICTING_DIRTY: the page will soon be swapped out as a dirty page
VM_SWAPPED_OUT: the page has been swapped out
VM_FAULTED_IN: the page has been faulted in by the application
VM_PREFETCHED: the page has been brought into the swap cache by the VM
prefetcher

The user application can therefore maintain the residence information of all
its pages and cooperate with the kernel under memory pressure. For example,
upon receiving the VM_EVICTING_* signals, the user application can
intelligently process the page, and optionally call madvise(MADV_DONTNEED)
to discard the page if it's no longer useful, or call madvise with our new
flag, MADV_RELIQUISH, to schedule the page to be swapped out (thus its
content will be saved on disk).

We have already developed a new garbage collector for Java based on this
kernel patch and published our work "Garbage Collection without Paging" on
PLDI 2005 (http://www.cs.umass.edu/~emery/pubs/f034-hertz.pdf). We would
expect more research work on this kind of cooperative memory management if
this patch can be merged into the main kernel.

Regarding the implementation details of the patch, we have included a brief
description in Documentation/vm/vmsig in the patch itself. The core part of
the patch is to maintain the ownership information of swapped-out pages as
well as resident pages. We naturally extended the existing rmap to swap
pages. This patch also complements mincore to work on anonymous pages.

The vmsig patch for Linux 2.6.14 is available at
http://www.cs.umass.edu/~yifeng/kernel/linux-2.6.14-vmsig.patch. It's fairly
large so it's probably not appropriate to include it in the body of this
email. Also because of the size of the patch, there are many details that I
didn't cover in this email. If this is the case, please send me email. I
will try to answer all your questions and clear the confusions.

Thanks and your comments and suggestions are welcome!


Yi Feng


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
