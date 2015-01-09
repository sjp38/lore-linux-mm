Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8DF6B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 07:49:27 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id w62so7779469wes.11
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 04:49:26 -0800 (PST)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com. [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id cg6si20178089wib.42.2015.01.09.04.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 04:49:24 -0800 (PST)
Received: by mail-we0-f179.google.com with SMTP id q59so7776636wes.10
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 04:49:24 -0800 (PST)
Message-ID: <54AFCE4A.80804@gmail.com>
Date: Fri, 09 Jan 2015 13:49:14 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: File sealing man pages for review (memfd_create(2), fcntl(2))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: mtk.manpages@gmail.com, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Lennart Poettering <lennart@poettering.net>, Andy Lutomirski <luto@amacapital.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Florian Weimer <fweimer@redhat.com>, John Stultz <john.stultz@linaro.org>, Carlos O'Donell <carlos@systemhalted.org>

Hello David at al.

@David: I took your man-page patches (the new memfd_create(2)
page, and your patches to fcntl(2) from 
http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd )
into a branch in man-pages. I've done some very heavy editing of
of the memfd_create(2) page, and added a lot of further detail
under NOTES, as well as some example programs in a new EXAMPLE
section. I've also done some fairly substantial editing
of your patch to fcntl(2).

@all: I'm looking to get review of these new man pages.
In particular, I've added quite a number of FIXMEs on points
that I'd like people to check or where there are details I am
unsure of.

You can find the pages inline below and also in the Git branch at
http://git.kernel.org/cgit/docs/man-pages/man-pages.git/log/?h=draft_memfd_create
My preference review feedback is as inline comments to the text 
below.

Thanks,

Michael

==================== memfd_create.2 ====================

.\" Copyright (C) 2014 Michael Kerrisk <mtk.manpages@gmail.com>
.\" and Copyright (C) 2014 David Herrmann <dh.herrmann@gmail.com>
.\"
.\" %%%LICENSE_START(GPLv2+_SW_3_PARA)
.\"
.\" FIXME What is _SW_3_PARA?
.\" 
.\" This program is free software; you can redistribute it and/or modify
.\" it under the terms of the GNU General Public License as published by
.\" the Free Software Foundation; either version 2 of the License, or
.\" (at your option) any later version.
.\"
.\" This program is distributed in the hope that it will be useful,
.\" but WITHOUT ANY WARRANTY; without even the implied warranty of
.\" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
.\" GNU General Public License for more details.
.\"
.\" You should have received a copy of the GNU General Public
.\" License along with this manual; if not, see
.\" <http://www.gnu.org/licenses/>.
.\" %%%LICENSE_END
.\"
.TH MEMFD_CREATE 2 2014-07-08 Linux "Linux Programmer's Manual"
.SH NAME
memfd_create \- create an anonymous file
.SH SYNOPSIS
.B #include <sys/memfd.h>
.sp
.BI "int memfd_create(const char *" name ", unsigned int " flags ");"
.SH DESCRIPTION
.BR memfd_create ()
creates an anonymous file and returns a file descriptor that refers to it.
The file behaves like a regular file, and so can be modified,
truncated, memory-mapped, and so on.
However, unlike a regular file,
it lives in RAM and has a volatile backing storage.
.\" FIXME In the following sentence I changed "released" to
.\"       "destroyed". Okay?
Once all references to the file are dropped, it is automatically released.
Anonymous memory is used for all backing pages of the file.
.\" FIXME In the following sentence I changed "they" to
.\"       "files created by memfd_create()". Okay?
Therefore, files created by
.BR memfd_create ()
are subject to the same restrictions as other anonymous
.\" FIXME Can you give some examples of some of the restrictions please.
memory allocations such as those allocated using
.BR mmap (2)
with the
.BR MAP_ANONYMOUS
flag.

The initial size of the file is set to 0.
.\" FIXME I added the following sentence. Please review.
Following the call, the file size should be set using
.BR ftruncate (2).

The name supplied in
.I name
is used as an internal filename and will be displayed
.\" FIXME What does "internal" in the previous line mean?
as the target of the corresponding symbolic link in the directory
.\" FIXME I added the previous line. Is it correct?
.IR /proc/self/fd/ .
.\" FIXME In the next line, I added "as displayed in that 
The displayed name is always prefixed with
.IR memfd:
and serves only for debugging purposes.
Names do not affect the behavior of the memfd,
.\" FIXME The term "memfd" appears here without having previously been
.\"       defined. Would the correct definition of "the memfd" be
.\"       "the file descriptor created by memfd_create"?
and as such multiple files can have the same name without any side effects.

The following values may be bitwise ORed in
.IR flags
to change the behaviour of
.BR memfd_create ():
.TP
.BR MFD_CLOEXEC
Set the close-on-exec
.RB ( FD_CLOEXEC )
flag on the new file descriptor.
See the description of the
.B O_CLOEXEC
flag in
.BR open (2)
for reasons why this may be useful.
.TP
.BR MFD_ALLOW_SEALING
Allow sealing operations on this file.
See the discussion of the
.B F_ADD_SEALS
and
.BR F_GET_SEALS
operations in
.BR fcntl (2),
and also NOTES, below.
The initial set of seals is empty.
If this flag is not set, the initial set of seals will be
.BR F_SEAL_SEAL ,
meaning that no other seals can be set on the file.
.\" FIXME Why is the MFD_ALLOW_SEALING behavior not simply the default?
.\"       Is it worth adding some text explaining this?
.PP
Unused bits in
.I flags
must be 0.

As its return value,
.BR memfd_create ()
returns a new file descriptor that can be used to refer to the file.
This file descriptor is opened for both reading and writing
.RB ( O_RDWR )
and
.B O_LARGEFILE
is set for the descriptor.

With respect to
.BR fork (2)
and
.BR execve (2),
the usual semantics apply for the file descriptor created by
.BR memfd_create ().
A copy of the file descriptor is inherited by the child produced by
.BR fork (2)
and refers to the same file.
The file descriptor is preserved across
.BR execve (2),
unless the close-on-exec flag has been set.
.SH RETURN VALUE
On success,
.BR memfd_create ()
returns a new file descriptor.
On error, \-1 is returned and
.I errno
is set to indicate the error.
.SH ERRORS
.TP
.B EFAULT
The address in
.IR name
points to invalid memory.
.TP
.B EINVAL
An unsupported value was specified in one of the arguments:
.I flags
included unknown bits, or
.I name
was too long.
.TP
.B EMFILE
The per-process limit on open file descriptors has been reached.
.TP
.B ENFILE
The system-wide limit on the total number of open files has been reached.
.TP
.B ENOMEM
There was insufficient memory to create a new anonymous file.
.SH VERSIONS
The
.BR memfd_create ()
system call first appeared in Linux 3.17.
.\" FIXME . When glibc support appears, update the following sentence:
Support in the GNU C library is pending.
.SH CONFORMING TO
The
.BR memfd_create ()
system call is Linux-specific.
.\" FIXME I added the NOTES section below. Please review.
.SH NOTES
.\" See also http://lwn.net/Articles/593918/
.\" and http://lwn.net/Articles/594919/ and http://lwn.net/Articles/591108/
The
.BR memfd_create ()
system call provides a simple alternative to manually mounting a
.I tmpfs
filesystem and creating and opening a file in that filesystem.
The primary purpose of
.BR memfd_create ()
is to create files and associated file descriptors that are
used with the file-sealing APIs provided by
.BR fcntl (2).
.SS File sealing
In the absence of file sealing,
processes that communicate via shared memory must either trust each other,
or take measures to deal with the possibility that an untrusted peer
may manipulate the shared memory region in problematic ways.
For example, an untrusted peer might modify the contents of the
shared memory at any time, or shrink the shared memory region.
The former possibility leaves the local process vulnerable to
time-of-check-to-time-of-use race conditions
(typically dealt with by copying data from
the shared memory region before checking and using it).
The latter possibility leaves the local process vulnerable to
.BR SIGBUS
signals when an attempt is made to access a now-nonexistent
location in the shared memory region.
(Dealing with this possibility necessitates the use of a handler for the
.BR SIGBUS
signal.)

Dealing with untrusted peers imposes extra complexity on
code that employs shared memory.
Memory sealing enables that extra complexity to be eliminated,
by allowing a process to operate secure in the knowledge that
its peer can't modify the shared memory in an undesired fashion.

An example of the usage of the sealing mechanism is as follows:

.IP 1. 3
The first process creates a
.I tmpfs
file using 
.BR memfd_create ().
The call yields a file descriptor used in subsequent steps.
.IP 2.
The first process
sizes the file created in the previous step using
.BR ftruncate (2),
maps it using
.BR mmap (2),
and populates the shared memory with the desired data.
.IP 3.
The first process uses the
.BR fcntl (2)
.B F_ADD_SEALS
operation to place one or more seals on the file,
in order to restrict further modifications on the file.
(If placing the seal
.BR F_SEAL_WRITE ,
then it will be necessary to first unmap the shared writable mapping
created in the previous step.)
.IP 4.
A second process obtains a file descriptor for the
.I tmpfs
file and maps it.
This could happen in one of two ways:
.RS
.IP * 3
The second process is created via
.BR fork (2)
and thus automatically inherits the file descriptor and mapping.
.IP *
The second process opens the file 
.IR /proc/<pd>/fd/<fd> ,
where
.I <pid>
is the PID of the first process (the one that called
.BR memfd_create ()),
and
.I <fd>
is the number of the file descriptor returned by the call to
.BR memfd_create ()
in that process.
The second process then maps the file using
.BR mmap (2).
.RE
.IP 5.
The second process uses the
.BR fcntl (2)
.B F_GET_SEALS
operation to retrieve the bit mask of seals
that has been applied to the file.
This bit mask can be inspected in order to determine
what kinds of restrictions have been placed on file modifications.
If desired, the second process can apply further seals
to impose additional restrictions (so long as the
.BR F_SEAL_SEAL
seal has not yet been applied).
.\" FIXME I added the EXAMPLE section below. Please review.
.SH EXAMPLE
Below are shown two example programs that demonstrate the use of
.BR memfd_create ()
and the file sealing API.

The first program,
.IR t_memfd_create.c ,
creates a
.I tmpfs
file using
.BR memfd_create (),
sets a size for the file, maps it into memory,
and optionally places some seals on the file.
The program accepts up to three command-line arguments,
of which the first two are required.
The first argument is the name to associate with the file,
the second argument is the size to be set for the file,
and the optional third is a string of characters that specify
seals to be set on file.

The second program,
.IR t_get_seals.c ,
can be used to open an existing file that was created via
.BR memfd_create ()
and inspect the set of seals that have been applied to that file.

The following shell session demonstrates the use of these programs.
First we create a
.I tmpfs
file and set some seals on it:

.in +4n
.nf
$ \fB./t_memfd_create my_memfd_file 4096 sw &\fP
[1] 11775
PID: 11775; fd: 3; /proc/11775/fd/3
.fi
.in

At this point, the
.I t_memfd_create
program continues to run in the background.
>From another program, we can obtain a file descriptor for the
memfd file by opening the
.IR /proc/PID/fd
file that corresponds to the descriptor opened by
.BR memfd_create ().
Using that pathname, we inspect the content of the
.IR /proc/PID/fd
symbolic link, and use our
.I t_get_seals
program to view the seals that have been placed on the file:

.in +4n
.nf
$ \fBreadlink /proc/11775/fd/3\fP
/memfd:my_memfd_file (deleted)
$ \fB./t_get_seals /proc/11775/fd/3\fP
Existing seals: WRITE SHRINK
.fi
.in
.SS Program source: t_memfd_create.c
\&
.nf
#include <sys/memfd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \\
                        } while (0)

int
main(int argc, char *argv[])
{
    int fd;
    unsigned int seals;
    char *addr;
    char *name, *seals_arg;
    ssize_t len;

    if (argc < 3) {
        fprintf(stderr, "%s name size [seals]\\n", argv[0]);
        fprintf(stderr, "\\t\(aqseals\(aq can contain any of the "
                "following characters:\\n");
        fprintf(stderr, "\\t\\tg \- F_SEAL_GROW\\n");
        fprintf(stderr, "\\t\\ts \- F_SEAL_SHRINK\\n");
        fprintf(stderr, "\\t\\tw \- F_SEAL_WRITE\\n");
        fprintf(stderr, "\\t\\tS \- F_SEAL_SEAL\\n");
        exit(EXIT_FAILURE);
    }

    name = argv[1];
    len = atoi(argv[2]);
    seals_arg = argv[3];

    /* Create an anonymous file in tmpfs; allow seals to be
       placed on the file */

    fd = memfd_create(name, MFD_ALLOW_SEALING);
    if (fd == \-1)
        errExit("memfd_create");

    /* Size the file as specified on the command line */

    if (ftruncate(fd, len) == \-1)
        errExit("truncate");

    printf("PID: %ld; fd: %d; /proc/%ld/fd/%d\\n",
            (long) getpid(), fd, (long) getpid(), fd);

    /* Code to map the file and populate the mapping with data
       omitted */

    /* If a \(aqseals\(aq command\-line argument was supplied, set some
       seals on the file */

    if (seals_arg != NULL) {
        seals = 0;

        if (strchr(seals_arg, \(aqg\(aq) != NULL)
            seals |= F_SEAL_GROW;
        if (strchr(seals_arg, \(aqs\(aq) != NULL)
            seals |= F_SEAL_SHRINK;
        if (strchr(seals_arg, \(aqw\(aq) != NULL)
            seals |= F_SEAL_WRITE;
        if (strchr(seals_arg, \(aqS\(aq) != NULL)
            seals |= F_SEAL_SEAL;

        if (fcntl(fd, F_ADD_SEALS, seals) == \-1)
            errExit("fcntl");
    }

    /* Keep running, so that the file created by memfd_create()
       continues to exist */

    pause();

    exit(EXIT_SUCCESS);
}
.fi
.SS Program source: t_get_seals.c
\&
.nf
#include <sys/memfd.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \\
                        } while (0)

int
main(int argc, char *argv[])
{
    int fd;
    unsigned int seals;

    if (argc != 2) {
        fprintf(stderr, "%s /proc/PID/fd/FD\\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    fd = open(argv[1], O_RDWR);
    if (fd == \-1)
        errExit("open");

    seals = fcntl(fd, F_GET_SEALS);
    if (seals == \-1)
        errExit("fcntl");

    printf("Existing seals:");
    if (seals & F_SEAL_SEAL)
        printf(" SEAL");
    if (seals & F_SEAL_GROW)
        printf(" GROW");
    if (seals & F_SEAL_WRITE)
        printf(" WRITE");
    if (seals & F_SEAL_SHRINK)
        printf(" SHRINK");
    printf("\\n");

    /* Code to map the file and access the contents of the
       resulting mapping omitted */

    exit(EXIT_SUCCESS);
}
.fi
.SH SEE ALSO
.BR fcntl (2),
.BR ftruncate (2),
.BR mmap (2),
.\" FIXME Why the reference to shmget(2) in particular (and not,
.\"       e.g., shm_open(3))?
.BR shmget (2)

==================== fcntl.2 (partial) ====================
...
.SH DESCRIPTION
...
.SS File Sealing
File seals limit the set of allowed operations on a given file.
For each seal that is set on a file,
a specific set of operations will fail with
.B EPERM
on this file from now on.
The file is said to be sealed.
The default set of seals depends on the type of the underlying
file and filesystem.
For an overview of file sealing, a discussion of its purpose,
and some code examples, see
.BR memfd_create (2).

.\" FIXME I changed "shmem" to "tmpfs" in the next sentence. Okay?
Currently, only the
.I tmpfs
filesystem supports sealing.
On other filesystems, all
.BR fcntl (2)
operations that operate on seals will return
.BR EINVAL .

Seals are a property of an inode.
.\" FIXME: I reworded the following sentence a little. Please check it.
Thus, all open file descriptors referring to the same inode share
the same set of seals.
Furthermore, seals can never be removed, only added.
.TP
.BR F_ADD_SEALS " (\fIint\fP; since Linux 3.17)"
Add the seals given in the bit-mask argument
.I arg
to the set of seals of the inode referred to by the file descriptor
.IR fd .
Seals cannot be removed again.
Once this call succeeds, the seals are enforced by the kernel immediately.
If the current set of seals includes
.BR F_SEAL_SEAL
(see below), then this call will be rejected with
.BR EPERM .
Adding a seal that is already set is a no-op, in case
.B F_SEAL_SEAL
is not set already.
In order to place a seal, the file descriptor
.I fd
must be writable.
.TP
.BR F_GET_SEALS " (\fIvoid\fP; since Linux 3.17)"
Return (as the function result) the current set of seals
of the inode referred to by
.IR fd .
If no seals are set, 0 is returned.
If the file does not support sealing, \-1 is returned and
.I errno
is set to
.BR EINVAL .
.PP
The following set of seals is available so far:
.TP
.BR F_SEAL_SEAL
If this seal is set, any further call to
.BR fcntl (2)
with
.B F_ADD_SEALS
will fail with
.BR EPERM .
Therefore, this seal prevents any modifications to the set of seals itself.
If the initial set of seals of a file includes
.BR F_SEAL_SEAL ,
then this effectively causes the set of seals to be constant and locked.
.TP
.BR F_SEAL_SHRINK
If this seal is set, the file in question cannot be reduced in size.
This affects
.BR open (2)
with the
.B O_TRUNC
flag and
.BR ftruncate (2).
.\" FIXME and also truncate(2)?
Those calls will fail with
.B EPERM
if you try to shrink the file in question.
Increasing the file size is still possible.
.TP
.BR F_SEAL_GROW
If this seal is set, the size of the file in question cannot be increased.
This affects
.BR write (2)
if you write across size boundaries,
.BR ftruncate (2),
.\" FIXME and also truncate(2)?
and
.BR fallocate (2).
These calls will fail with
.B EPERM
if you use them to increase the file size or write beyond size boundaries.
.\" FIXME What does "size boundaries" mean here?
If you keep the size or shrink it, those calls still work as expected.
.TP
.BR F_SEAL_WRITE
If this seal is set, you cannot modify the contents of the file.
Note that shrinking or growing the size of the file is
still possible and allowed.
.\" FIXME So, just to confirm my understanding of the previous sentence:
.\"       Given a file with the F_SEAL_WRITE seal set, then:
.\"
.\"       * Writing zeros into (say) the last 100 bytes of the file is
.\"         NOT be permitted.
.\"
.\"       * Shrinking the file by 100 bytes using ftruncate(), and then
.\"         increasing the file size by 100 bytes, which would have the
.\"         effect of replacing the last hundred bytes by zeros, IS
.\"         permitted.
.\"
.\"       Either my understanding is incorrect, or the above two cases
.\"       seem a little anomalous. Can you comment?
.\"
Thus, this seal is normally used in combination with one of the other seals.
This seal affects
.BR write (2)
and
.BR fallocate (2)
(only in combination with the
.B FALLOC_FL_PUNCH_HOLE
flag).
Those calls will fail with
.B EPERM
if this seal is set.
Furthermore, trying to create new shared, writable memory-mappings via
.BR mmap (2)
will also fail with
.BR EPERM .

Setting
.B F_SEAL_WRITE
via
.BR fcntl (2)
with
.B F_ADD_SEALS
will fail with
.B EBUSY
if any writable, shared mapping exists.
Such mappings must be unmapped before you can add this seal.
Furthermore, if there are any asynchronous
.\" FIXME Does this mean io_submit(2)?
I/O operations pending on the file,
all outstanding writes will be discarded.

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
