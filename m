Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1A866B025E
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:21:05 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n3so17421629qkn.9
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 23:21:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c19si2885645qta.479.2017.11.26.23.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 23:21:04 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAR7KSSd072361
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:21:03 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ege7tr243-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:21:02 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 07:20:59 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] process_vmsplice.2: New page describing process_vmsplice(2) system call.
Date: Mon, 27 Nov 2017 09:20:50 +0200
In-Reply-To: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1511767250-23064-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/process_vmsplice.2 | 188 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 188 insertions(+)
 create mode 100644 man2/process_vmsplice.2

diff --git a/man2/process_vmsplice.2 b/man2/process_vmsplice.2
new file mode 100644
index 0000000..b99c06b
--- /dev/null
+++ b/man2/process_vmsplice.2
@@ -0,0 +1,188 @@
+.\" Copyright (c) 2017, IBM Corporation.
+.\" Written by Mike Rapoport <rppt@linux.vnet.ibm.com>
+.\" Based on vmsplice(2) by Jens Axboe and
+.\" process_vm_read(2) by Christopher Yeoh, Mike Frysinger and Michael Kerrisk
+.\"
+.\" %%%LICENSE_START(VERBATIM)
+.\" Permission is granted to make and distribute verbatim copies of this
+.\" manual provided the copyright notice and this permission notice are
+.\" preserved on all copies.
+.\"
+.\" Permission is granted to copy and distribute modified versions of this
+.\" manual under the conditions for verbatim copying, provided that the
+.\" entire resulting derived work is distributed under the terms of a
+.\" permission notice identical to this one.
+.\"
+.\" Since the Linux kernel and libraries are constantly changing, this
+.\" manual page may be incorrect or out-of-date.  The author(s) assume no
+.\" responsibility for errors or omissions, or for damages resulting from
+.\" the use of the information contained herein.  The author(s) may not
+.\" have taken the same level of care in the production of this manual,
+.\" which is licensed free of charge, as they might when working
+.\" professionally.
+.\"
+.\" Formatted or processed versions of this manual, if unaccompanied by
+.\" the source, must acknowledge the copyright and authors of this work.
+.\" %%%LICENSE_END
+.\"
+.TH PROCESS_VMSPLICE 2 2017-11-23 "Linux" "Linux Programmer's Manual"
+.SH NAME
+process_vmsplice \- splice user pages from a specific process
+address space into a pipe
+.SH SYNOPSIS
+.nf
+.BR "#define _GNU_SOURCE" "         /* See feature_test_macros(7) */"
+.B #include <unistd.h>
+.B #include <sys/uio.h>
+.PP
+.BI "ssize_t process_vmsplice(pid_t " pid ", int " fd ,
+.BI "                         const struct iovec *" iov ,
+.BI "                         unsigned long " nr_segs ,
+.BI "                         unsigned int " flags );
+.fi
+.PP
+.IR Note :
+There is no glibc wrapper for this system call; see NOTES.
+.SH DESCRIPTION
+The
+.BR process_vmsplice ()
+system call maps
+.I nr_segs
+ranges of user memory described by
+.I iov
+from address space of the process identified by
+.I pid
+into a pipe.
+The file descriptor
+.I fd
+must refer to a pipe.
+.PP
+The pointer
+.I iov
+points to an array of
+.I iovec
+structures as defined in
+.IR <sys/uio.h> :
+.PP
+.in +4n
+.EX
+struct iovec {
+    void  *iov_base;        /* Starting address */
+    size_t iov_len;         /* Number of bytes */
+};
+.EE
+.in
+.PP
+The
+.I flags
+argument is a bit mask that is composed by ORing together
+zero or more of the following values:
+.RS
+.TP 1.9i
+.B SPLICE_F_MOVE
+Unused for
+.BR process_vmsplice ();
+see
+.BR splice (2).
+.TP
+.B SPLICE_F_NONBLOCK
+Do not block on I/O; see
+.BR splice (2)
+for further details.
+.TP
+.B SPLICE_F_MORE
+Currently has no effect for
+.BR process_vmsplice ()
+.TP
+.B SPLICE_F_GIFT
+The user pages are a gift to the kernel.
+see
+.BR vmsplice (2)
+for further details.
+.RE
+.PP
+Buffers pointed by the
+.I iov
+parameter are processed in array order.
+This means that
+.BR process_vmsplice ()
+completely fills
+.I iov[0]
+before proceeding to
+.IR iov[1] ,
+and so on.
+.PP
+The
+.BR process_vmsplice ()
+does not check the memory regions in the process
+until just before remapping those regions into the pipe.
+Consequently, a partial read may result if one of the
+.I iov
+elements points to an invalid memory region in the process.
+No further reads will be attempted beyond that point.
+.PP
+Permission to read from or write to another process
+is governed by a ptrace access mode
+.B PTRACE_MODE_ATTACH_REALCREDS
+check; see
+.BR ptrace (2).
+.SH RETURN VALUE
+Upon successful completion,
+.BR process_vmsplice ()
+returns the number of bytes transferred to the pipe.
+On error,
+.BR process_vmsplice ()
+returns \-1 and
+.I errno
+is set to indicate the error.
+.SH ERRORS
+.TP
+.B EAGAIN
+.B SPLICE_F_NONBLOCK
+was specified in
+.IR flags ,
+and the operation would block.
+.TP
+.B EBADF
+.I fd
+either not valid, or doesn't refer to a pipe.
+.TP
+.B EINVAL
+.I nr_segs
+is greater than
+.BR IOV_MAX ;
+or memory not aligned if
+.B SPLICE_F_GIFT
+set.
+.TP
+.B ENOMEM
+Out of memory.
+.TP
+.B ESRCH
+No process with ID
+.I pid
+exists.
+.SH VERSIONS
+The
+.BR process_vmsplice ()
+system call first appeared in Linux 4.15.
+.SH CONFORMING TO
+This system call is Linux-specific.
+.SH NOTES
+Glibc does not provide a wrapper for this system call; call it using
+.BR syscall (2).
+.BR process_vmsplice ()
+follows the other vectorized read/write type functions when it comes to
+limitations on the number of segments being passed in.
+This limit is
+.B IOV_MAX
+as defined in
+.IR <limits.h> .
+Currently,
+.\" UIO_MAXIOV in kernel source
+this limit is 1024.
+.SH SEE ALSO
+.BR process_vm_read (2)
+.BR ptrace (2),
+.BR splice (2),
+.BR pipe (7)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
