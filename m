Date: Sun, 3 Jun 2001 19:04:50 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
Message-ID: <20010603190450.A26234@home.ds9a.nl>
References: <20010527222020.A25390@home.ds9a.nl> <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva> <20010530234806.C8629@home.ds9a.nl> <20010531191729.E754@nightmaster.csn.tu-chemnitz.de> <20010531235326.A14566@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20010531235326.A14566@home.ds9a.nl>; from ahu@ds9a.nl on Thu, May 31, 2001 at 11:53:27PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, aeb@cwi.nl
List-ID: <linux-mm.kvack.org>

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 31, 2001 at 11:53:27PM +0200, bert hubert wrote:
> > > Oh, if anybody has ideas on statistics that should be exported, please let
> > > me know. On the agenda is a bitmap that describes which pages are actually
> > > in the cache.
> > 
> > You mean sth. like the mincore() syscall?
> 
> If you first mmap() the file that would probably work. In dire need of a
> manpage though - I'll whip one up and send it to Andries. Probably explains
> its relative lack of popularity - I'd never heard of mincore() although it's
> been around since BSD4.4 it appears.

As promised, a manpage. I alreasy sent it to Andries but the people over
here may also have comments.

Regards,

bert

-- 
http://www.PowerDNS.com      Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mincore.2"

.\" Hey Emacs! This file is -*- nroff -*- source.
.\"
.\" Copyright (C) 2001 Andries Brouwer (aeb@cwi.nl)
.\"
.\" Permission is granted to make and distribute verbatim copies of this
.\" manual provided the copyright notice and this permission notice are
.\" preserved on all copies.
.\"
.\" Permission is granted to copy and distribute modified versions of this
.\" manual under the conditions for verbatim copying, provided that the
.\" entire resulting derived work is distributed under the terms of a
.\" permission notice identical to this one
.\" 
.\" Since the Linux kernel and libraries are constantly changing, this
.\" manual page may be incorrect or out-of-date.  The author(s) assume no
.\" responsibility for errors or omissions, or for damages resulting from
.\" the use of the information contained herein.  The author(s) may not
.\" have taken the same level of care in the production of this manual,
.\" which is licensed free of charge, as they might when working
.\" professionally.
.\" 
.\" Formatted or processed versions of this manual, if unaccompanied by
.\" the source, must acknowledge the copyright and authors of this work.
.\"
.\" Created Sun Jun 3 17:23:32 2001 by bert hubert <ahu@ds9a.nl>
.\"
.TH MINCORE 2 "3 June 2001" "Linux 2.4.5" "Linux Programmer's Manual"
.SH NAME
mincore \- get information on whether pages are in core
.SH SYNOPSIS
.B #include <unistd.h>
.br
.B #include <sys/mman.h>
.sp
.BI "int mincore(void *" start ", size_t " length ", unsigned char * " vec );
.SH DESCRIPTION
The
.B mincore
function requests a vector describing which pages of a file are in core and
can be read without disk access. The kernel will supply data for
.I length
bytes following the 
.I start
address. On return, the kernel will have filled
.I vec
with bytes, of which the least significant bit indicates if a page is 
core resident.

For
.B mincore
to return succesfully, 
.I start
must lie on a page boundary. It is the caller's responsibility to round up to the nearest page. The
.I length
parameter need not be a multiple of the page size. The vector
.I vec
must be large enough to contain length/PAGE_SIZE bytes.

.SH "RETURN VALUE"
On success,
.B mincore
returns zero.
On error, \-1 is returned, and
.I errno
is set appropriately.
.SH ERRORS
.B EAGAIN
kernel is temporarily out of resources
.TP
.B EINVAL
.i start
is not a multiple of PAGE_CACHE_SIZE (PAGE_SIZE) or 
.i len
has a non-positive value
.TP
.B EFAULT
.I vec
points to an illegal address
.TP
.B ENOMEM
.I address
to
.I address
+
.I length
contained unmapped memory, or memory not part of a file.

.SH "BUGS"
.B mincore
should return a bit vector and not a byte vector. As of Linux 2.4.5, it is not
possible to gain information on the core residency of pages which are not backed by a file. 
In other words, calling 
.B mincore
on an region returned by an anonymous
.B mmap(2)
does not work and sets errno to ENOMEM. Unless pages are locked in memory, the contents of
.I vec
may be stale by the time they reach userspace.

.SH "CONFORMING TO"
.B mincore
does not appear to be part of POSIX or the Single Unix Specification. 
.SH HISTORY
The mincore() function first appeared in 4.4BSD

.SH "SEE ALSO"
.BR getpagesize (2),
.BR mmap (2)


--MGYHOYXEY6WxJCY8--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
