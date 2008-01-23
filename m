Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080123160454.SGAO22392.tomts13-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 23 Jan 2008 11:04:54 -0500
Date: Wed, 23 Jan 2008 11:04:54 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [RFC] Userspace tracing memory mappings
Message-ID: <20080123160454.GA15405@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, mbligh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Since memory management is not my speciality, I would like to know if
there are some implementation details I should be aware of for my
LTTng userspace tracing buffers. Here is what I want to do :

Upon a new alloc_tracebuf syscall :

- map the ZERO_PAGE in the current process. Reserve enough pages to hold
  16 per cpu trace buffers at the same time. (supports up to 16 active
  traces at the same time). Could be mapped write-only by the traced
  process.
- Also reserve a few ZERO_PAGES for the buffer control
  (current read/write offset...) : mapped RW by the process
- Also need some space for the kernel to export control information.
  This could be pages mapped read-only by the process (seqlock,
  tracing active....)
- When the process tries to write to these pages, allocate physical pages.
- The read-only (as seen by the process) pages should be allocated when
  the kernel has its first trace active. Can be the ZERO_PAGE before
  that.

When the process issues its first buffer switch (that's a second added
syscall) or exits before its first buffer switch, for every active trace
on the system, we create a debugfs file in the trace directory. A
userspace daemon gets inotified of the file creation and maps the
buffers specific to a single trace. (mmap on a file) The daemon already
uses ioctl on the file to get the buffer offset to read. This is the
"disk writer" daemon.

I don't think the kernel really has to map the buffers in its address
space. For kernel crash buffer extraction, I guess we can simply deal
with pages instead of virtual addresses. By doing so, we could extract
the userspace tracing buffers upon kernel crash.

We have to be aware that a new trace can be allocated/activated on the
system while the process is running. Therefore, the kernel and the
process would share a few pages (RW for the kernel, RO for the traced
process) where the trace control information would be held. I would
re-create the trace control information update mechanism I currently
have in LTTng for kernel-only tracing (I use RCU), but, since RCU is not
available in user-space, I would use a write seqlock in the kernel and a
read seqlock in userspace. These pages would therefore have to be mapped
at 3 different locations :

- Buffers
  - traced process (write)
  - disk writing daemon (read-only)
- Buffer control information (buffer read/write offsets)
  - traced process (RW)
  - kernel mapping (RW) (disk writing daemon issues an ioctl for offset
    updates and hence doesn't need to map this information)
- Tracing control information
  - kernel memory (RW)
  - traced process (read-only)

So if we want the tightest control possible, we would have to create 3
different mappings, initially populated with the zero page, populated by
page faults, and shared between two locations each.

Comments/ideas/concerns are welcome.

Mathieu


-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
