Date: Sun, 1 Apr 2001 23:25:01 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: 2.4 kernel memory corruption testing info
Message-ID: <20010401232501.A1285@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, arjanv@redhat.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Alexander Viro <aviro@redhat.com>, Chris Mason <mason@suse.com>, Theodore Ts'o <tytso@valinux.com>, Rik van Riel <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

Hi,

I promised several people at the 2.5 workshop that I'd post info about
what we've been seeing inside Red Hat during severe stress testing of
the 2.4 kernel, and how to reproduce it.

The tests we've seen problems with are Cerberus stress tests.  If I
remember correctly, we're using the standard sourceforge Cerberus
tests with the addition of a directory stresser from Ingo.

The tests we are running in parallel are:

 MMAP_FIFO (performs a ton of IO with regular read/write, mmap, fifos,
shared memory etc)

 FPU test

 memtest

 destructive disk tests

 crashme

 tcpip tests over loopback

 filesystem tests (Ingo's stresser)

The basic footprint we see is that the write pattern used by MMAP_FIFO
(0x39c39c39) keeps turning up elsewhere, most often in ext2 indirect
blocks during truncate but also in places such as the memtest scan.

I am currently on a plane and will be on holiday for the next 10
days with only limited email access, but Ben LaHaise has offered to
post the exact configuration we've been using somewhere public and to
send out the extra directory stresser that we've been using.

Ben did tell me yesterday that we'd been able finally to reproduce the
problem on IDE -- previously only SCSI setups had shown the problem,
but then many of the IDE systems only had one disk and were skipping
the destructive disk test as a result.

destructive disk tests appear to be necessary to cause the problem,
but that may be because of the extra VM pressure of that test rather
than any fundamentail IO layer problem it triggers.  The disk being
used for the descructive testing is never the same disk that the
MMAP_FIFO test runs on.

Reducing the memory on a test box appears to increase the frequency of
the problem.  SMP also increases the frequency, but we have seen this
on IDE too.

I haven't seen this email yet, but Ben told me that he'd seen a report
that this was reproducible right back to 2.3.50.  We have certainly
seen it on Linus and ac* kernels as well as on our own
internally-patched kernel builds.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
