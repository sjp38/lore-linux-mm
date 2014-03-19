Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id AB5BE6B0177
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 15:08:03 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id 6so649517bkj.27
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:08:03 -0700 (PDT)
Received: from mail-bk0-x22c.google.com (mail-bk0-x22c.google.com [2a00:1450:4008:c01::22c])
        by mx.google.com with ESMTPS id oq2si10033475bkb.25.2014.03.19.12.08.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 12:08:02 -0700 (PDT)
Received: by mail-bk0-f44.google.com with SMTP id mz13so641653bkb.31
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:08:01 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH man-pages 5/6] fcntl.2: document SHMEM_SET/GET_SEALS commands
Date: Wed, 19 Mar 2014 20:06:50 +0100
Message-Id: <1395256011-2423-6-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, David Herrmann <dh.herrmann@gmail.com>

The SHMEM_GET_SEALS and SHMEM_SET_SEALS commands allow retrieving and
modifying the active set of seals on a file. They're only supported on
selected file-systems (currently shmfs) and are linux-only.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 man2/fcntl.2 | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/man2/fcntl.2 b/man2/fcntl.2
index c010a49..53d55a5 100644
--- a/man2/fcntl.2
+++ b/man2/fcntl.2
@@ -57,6 +57,8 @@
 .\"     Document F_SETOWN_EX and F_GETOWN_EX
 .\" 2010-06-17, Michael Kerrisk
 .\"	Document F_SETPIPE_SZ and F_GETPIPE_SZ.
+.\" 2014-03-19, David Herrmann <dh.herrmann@gmail.com>
+.\"	Document SHMEM_SET_SEALS and SHMEM_GET_SEALS
 .\"
 .TH FCNTL 2 2014-02-20 "Linux" "Linux Programmer's Manual"
 .SH NAME
@@ -1064,6 +1066,94 @@ of buffer space currently used to store data produces the error
 .BR F_GETPIPE_SZ " (\fIvoid\fP; since Linux 2.6.35)"
 Return (as the function result) the capacity of the pipe referred to by
 .IR fd .
+.SS File Sealing
+Sealing files limits the set of allowed operations on a given file. For each
+seal that is set on a file, a specific set of operations will fail with
+.B EPERM
+on this file from now on. The file is said to be sealed. A file does not have
+any seals set by default. Moreover, most filesystems do not support sealing
+(only shmfs implements it right now). The following seals are available:
+.RS
+.TP
+.BR SHMEM_SEAL_SHRINK
+If this seal is set, the file in question cannot be reduced in size. This
+affects
+.BR open (2)
+with the
+.B O_TRUNC
+flag and
+.BR ftruncate (2).
+They will fail with
+.B EPERM
+if you try to shrink the file in question. Increasing the file size is still
+possible.
+.TP
+.BR SHMEM_SEAL_GROW
+If this seal is set, the size of the file in question cannot be increased. This
+affects
+.BR write (2)
+if you write across size boundaries,
+.BR ftruncate (2)
+and
+.BR fallocate (2).
+These calls will fail with
+.B EPERM
+if you use them to increase the file size or write beyond size boundaries. If
+you keep the size or shrink it, those calls still work as expected.
+.TP
+.BR SHMEM_SEAL_WRITE
+If this seal is set, you cannot modify data contents of the file. Note that
+shrinking or growing the size of the file is still possible and allowed. Thus,
+this seal is normally used in combination with one of the other seals. This seal
+affects
+.BR write (2)
+and
+.BR fallocate (2)
+(only in combination with the
+.B FALLOC_FL_PUNCH_HOLE
+flag). Those calls will fail with
+.B EPERM
+if this seal is set. Furthermore, trying to create new memory-mappings via
+.BR mmap (2)
+in combination with
+.B MAP_SHARED
+will also fail with
+.BR EPERM .
+.RE
+.TP
+.BR SHMEM_SET_SEALS " (\fIint\fP; since Linux TBD)"
+Change the set of seals of the file referred to by
+.I fd
+to
+.IR arg .
+You are required to own an exclusive reference to the file in question in order
+to modify the seals. Otherwise, this call will fail with
+.BR EPERM .
+There is one exception: If no seals are set, this restriction does not apply and
+you can set seals even if you don't own an exclusive reference. However, in any
+case there may not exist any shared writable mapping or this call will always
+fail with
+.BR EPERM .
+These semantics guarantee that once you verified a specific set of seals is set
+on a given file, nobody besides you (in case you own an exclusive reference) can
+modify the seals, anymore.
+
+You own an exclusive reference to a file if, and only if, the file-descriptor
+passed to
+.BR fcntl (2)
+is the only reference to the underlying inode. There must not be any duplicates
+of this file-descriptor, no other open files to the same underlying inode, no
+hard-links or any active memory mappings.
+.TP
+.BR SHMEM_GET_SEALS " (\fIvoid\fP; since Linux TBD)"
+Return (as the function result) the current set of seals of the file referred to
+by
+.IR fd .
+If no seals are set, 0 is returned. If the file does not support sealing, -1 is
+returned and
+.I errno
+is set to
+.BR EINVAL .
 .SH RETURN VALUE
 For a successful call, the return value depends on the operation:
 .TP 0.9i
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
