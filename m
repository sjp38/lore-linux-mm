Received: from mail.global.co.za (mail.global.co.za [196.3.164.41])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA17068
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 16:46:54 -0400
Received: from mantis.qualica.com (syn02.anx4.rivA.gia.net.za [209.88.76.201])
	by mail.global.co.za (8.9.2/8.9.1) with ESMTP id WAA20859
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 22:45:50 +0200 (GMT)
Received: from vi.qualica.com (vi.qualica.com [172.31.0.31])
	by mantis.qualica.com (8.8.8/8.8.8) with ESMTP id WAA07039
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 22:45:49 +0200
Received: (from oskar@localhost)
	by vi.qualica.com (8.8.8/8.8.8) id WAA00390
	for linux-mm@kvack.org; Tue, 6 Apr 1999 22:45:46 +0200
Resent-Message-Id: <199904062045.WAA00390@vi.qualica.com>
Date: Tue, 6 Apr 1999 21:35:30 +0200
From: Oskar Pearson <oskar@linux.org.za>
Subject: Re: Opening 5000 file descriptors in linux??
Message-ID: <19990406213530.A1581@linux.org.za>
References: <19990329212938Z160486-220+9825@vger.rutgers.edu> <36FFF75C.7BC30B3D@netscape.com> <3700D917.7686EB1B@grips.com> <14082.48568.621877.339352@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14082.48568.621877.339352@dukat.scot.redhat.com>; from Stephen C. Tweedie on Thu, Apr 01, 1999 at 01:28:40AM +0100
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Stephen Tweedie wrote:

> Two things: first of all, the default rlimit for open files is still
> 1024, so you need to raise that to use more in one process.  From bash,
> that's 
> 
> 	ulimit -Hn 100000; ulimit -n 100000

Done.

> or use the setrlimit() kernel call.
> 
> Secondly, the default FD_SET type only has space for 1024 fds in the
> bitmap, so either make sure you are using poll, or define your own,
> sufficiently large, FD_SET if you need to use select.
> 
> Other than that, all should work.

Interesting thing. Someone sent me a simple piece of code that they
were having problems with. Instead of opening /dev/null 5 million
times, they actually opened a network socket. Here is the code:

--------
#include <stdio.h>
#include <sys/socket.h>
main()
{
        int s;
        for(s = 0;; s++)
                if(socket(AF_INET,SOCK_STREAM,0) < 0)
                        break;
        printf("%d\n", s);
}
--------

This breaks much sooner than the ulimit value:

vi:~ # ./test 
508
vi:~ # ./test 
519
vi:~ # ./test 
519
<fiddle around with random things so that the system swaps>
vi:~ # ./test 
552

strace output:
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 552
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 553
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 554
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = -1 ENOBUFS (No buffer space
available)

no dmesg errors.

vi:~ # uname -a
Linux vi.qualica.com 2.2.5-ac1 #2 Sun Apr 4 14:26:31 SAST 1999 i586
unknown

If I add a second delay every 10 seconds, the system seems to free up
enough memory to get to around about 1000 filedescriptors. This points
to a resource management problem, IMHO.

I am not sure if the later ac-? patches do the same thing. I was out
of the country this last weekend.

Oskar
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
