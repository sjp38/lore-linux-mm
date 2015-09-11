Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 83D176B0258
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 10:33:30 -0400 (EDT)
Received: by qkap81 with SMTP id p81so32536797qka.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:33:30 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id 79si536399qky.115.2015.09.11.07.33.29
        for <linux-mm@kvack.org>;
        Fri, 11 Sep 2015 07:33:29 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH v3] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
Date: Fri, 11 Sep 2015 10:31:10 -0400
Message-Id: <1441981870-24042-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Update the mlock.2 man page with information on mlock2() and the new
mlockall() flag MCL_ONFAULT.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-man@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Changes from V2:
 Update available from kernel version

 man2/mlock.2  | 109 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 man2/mlock2.2 |   1 +
 2 files changed, 97 insertions(+), 13 deletions(-)
 create mode 100644 man2/mlock2.2

diff --git a/man2/mlock.2 b/man2/mlock.2
index 79c544d..118b527 100644
--- a/man2/mlock.2
+++ b/man2/mlock.2
@@ -23,21 +23,23 @@
 .\" <http://www.gnu.org/licenses/>.
 .\" %%%LICENSE_END
 .\"
-.TH MLOCK 2 2015-07-23 "Linux" "Linux Programmer's Manual"
+.TH MLOCK 2 2015-08-28 "Linux" "Linux Programmer's Manual"
 .SH NAME
-mlock, munlock, mlockall, munlockall \- lock and unlock memory
+mlock, mlock2, munlock, mlockall, munlockall \- lock and unlock memory
 .SH SYNOPSIS
 .nf
 .B #include <sys/mman.h>
 .sp
 .BI "int mlock(const void *" addr ", size_t " len );
+.BI "int mlock2(const void *" addr ", size_t " len ", int " flags );
 .BI "int munlock(const void *" addr ", size_t " len );
 .sp
 .BI "int mlockall(int " flags );
 .B int munlockall(void);
 .fi
 .SH DESCRIPTION
-.BR mlock ()
+.BR mlock (),
+.BR mlock2 (),
 and
 .BR mlockall ()
 respectively lock part or all of the calling process's virtual address
@@ -51,7 +53,7 @@ respectively unlocking part or all of the calling process's virtual
 address space, so that pages in the specified virtual address range may
 once more to be swapped out if required by the kernel memory manager.
 Memory locking and unlocking are performed in units of whole pages.
-.SS mlock() and munlock()
+.SS mlock(), mlock2(), and munlock()
 .BR mlock ()
 locks pages in the address range starting at
 .I addr
@@ -62,6 +64,34 @@ All pages that contain a part of the specified address range are
 guaranteed to be resident in RAM when the call returns successfully;
 the pages are guaranteed to stay in RAM until later unlocked.
 
+.BR mlock2 ()
+also locks pages in the specified range starting at
+.I addr
+and continuing for
+.I len
+bytes.
+However, the state of the pages contained in that range after the call
+returns successfully will depend on the value in the
+.I flags
+argument.
+
+The
+.I flags
+argument can be either 0 or the following constant:
+.TP 1.2i
+.B MLOCK_ONFAULT
+Lock pages that are currently resident and mark the entire range to have
+pages locked when they are populated by the page fault.
+.PP
+
+If
+.I flags
+is 0,
+.BR mlock2 ()
+will function exactly as
+.BR mlock ()
+would.
+
 .BR munlock ()
 unlocks pages in the address range starting at
 .I addr
@@ -93,9 +123,33 @@ the process.
 .B MCL_FUTURE
 Lock all pages which will become mapped into the address space of the
 process in the future.
-These could be for instance new pages required
+These could be, for instance, new pages required
 by a growing heap and stack as well as new memory-mapped files or
 shared memory regions.
+.TP
+.BR MCL_ONFAULT " (since Linux 4.4)"
+Used together with
+.BR MCL_CURRENT ,
+.BR MCL_FUTURE ,
+or both.  Mark all current (with
+.BR MCL_CURRENT )
+or future (with
+.BR MCL_FUTURE )
+mappings to lock pages when they are faulted in.  When used with
+.BR MCL_CURRENT ,
+all present pages are locked, but
+.BR mlockall ()
+will not fault in non-present pages.  When used with
+.BR MCL_FUTURE ,
+all future mappings will be marked to lock pages when they are faulted
+in, but they will not be populated by the lock when the mapping is
+created.
+.B MCL_ONFAULT
+must be used with either
+.B MCL_CURRENT
+or
+.B MCL_FUTURE
+or both.
 .PP
 If
 .B MCL_FUTURE
@@ -148,7 +202,8 @@ to perform the requested operation.
 .\"SVr4 documents an additional EAGAIN error code.
 .LP
 For
-.BR mlock ()
+.BR mlock (),
+.BR mlock2 (),
 and
 .BR munlock ():
 .TP
@@ -157,9 +212,9 @@ Some or all of the specified address range could not be locked.
 .TP
 .B EINVAL
 The result of the addition
-.IR start + len
+.IR addr + len
 was less than
-.IR start
+.IR addr
 (e.g., the addition may have resulted in an overflow).
 .TP
 .B EINVAL
@@ -181,12 +236,23 @@ mapping would result in three mappings:
 two locked mappings at each end and an unlocked mapping in the middle.)
 .LP
 For
-.BR mlockall ():
+.BR mlock2 ():
 .TP
 .B EINVAL
 Unknown \fIflags\fP were specified.
 .LP
 For
+.BR mlockall ():
+.TP
+.B EINVAL
+Unknown \fIflags\fP were specified or
+.B MCL_ONFAULT
+was specified without either
+.B MCL_FUTURE
+or
+.BR MCL_CURRENT .
+.LP
+For
 .BR munlockall ():
 .TP
 .B EPERM
@@ -259,9 +325,11 @@ or when the process terminates.
 The
 .BR mlockall ()
 .B MCL_FUTURE
-setting is not inherited by a child created via
+and
+.B MCL_FUTURE | MCL_ONFAULT
+settings are not inherited by a child created via
 .BR fork (2)
-and is cleared during an
+and are cleared during an
 .BR execve (2).
 
 The memory lock on an address range is automatically removed
@@ -270,7 +338,8 @@ if the address range is unmapped via
 
 Memory locks do not stack, that is, pages which have been locked several times
 by calls to
-.BR mlock ()
+.BR mlock (),
+.BR mlock2 (),
 or
 .BR mlockall ()
 will be unlocked by a single call to
@@ -280,9 +349,19 @@ for the corresponding range or by
 Pages which are mapped to several locations or by several processes stay
 locked into RAM as long as they are locked at least at one location or by
 at least one process.
+
+If a call to
+.BR mlockall ()
+which uses the
+.B MCL_FUTURE
+flag is followed by another call that does not specify this flag, the
+changes made by the
+.B MCL_FUTURE
+call will be lost.
 .SS Linux notes
 Under Linux,
-.BR mlock ()
+.BR mlock (),
+.BR mlock2 (),
 and
 .BR munlock ()
 automatically round
@@ -300,6 +379,7 @@ file shows how many kilobytes of memory the process with ID
 .I PID
 has locked using
 .BR mlock (),
+.BR mlock2 (),
 .BR mlockall (),
 and
 .BR mmap (2)
@@ -342,6 +422,9 @@ resource limit is encountered.
 .\" http://marc.theaimsgroup.com/?l=linux-kernel&m=113801392825023&w=2
 .\" "Rationale for RLIMIT_MEMLOCK"
 .\" 23 Jan 2006
+.SH VERSIONS
+.BR mlock2 (2)
+is available since Linux 4.4.
 .SH SEE ALSO
 .BR mmap (2),
 .BR setrlimit (2),
diff --git a/man2/mlock2.2 b/man2/mlock2.2
new file mode 100644
index 0000000..5e5b3c7
--- /dev/null
+++ b/man2/mlock2.2
@@ -0,0 +1 @@
+.so man2/mlock.2
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
