Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7A98C6B0068
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 15:08:49 -0500 (EST)
Date: Wed, 2 Jan 2013 20:08:48 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130102200848.GA4500@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121228014503.GA5017@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

(changing Cc:)

Eric Wong <normalperson@yhbt.net> wrote:
> I'm finding ppoll() unexpectedly stuck when waiting for POLLIN on a
> local TCP socket.  The isolated code below can reproduces the issue
> after many minutes (<1 hour).  It might be easier to reproduce on
> a busy system while disk I/O is happening.

s/might be/is/

Strangely, I've bisected this seemingly networking-related issue down to
the following commit:

  commit 1fb3f8ca0e9222535a39b884cb67a34628411b9f
  Author: Mel Gorman <mgorman@suse.de>
  Date:   Mon Oct 8 16:29:12 2012 -0700

      mm: compaction: capture a suitable high-order page immediately when it is made available

That commit doesn't revert cleanly on v3.7.1, and I don't feel
comfortable touching that code myself.

Instead, I disabled THP+compaction under v3.7.1 and I've been unable to
reproduce the issue without THP+compaction.

As I mention in http://mid.gmane.org/20121229113434.GA13336@dcvr.yhbt.net
I run my below test (`toosleepy') with heavy network and disk activity
for a long time before hitting this.

My disk activity involves copying large files around to different local
drives over loopback[1], so perhaps the duplicate pages get compacted
away?  toosleepy also reuses the same 16K junk data all around.


[1] my full setup is very strange.

    Other than the FUSE component I forgot to mention, little depends on
    the kernel.  With all this, the standalone toosleepy can get stuck.
    I'll try to reproduce it with less...

    (possibly relevant info, I don't expect you to duplicate my setup
     as it requires many, many patched userspace components :x):

    fusedav (with many bugfixes[2]) -> (FUSE device)
    zbatery (Ruby 1.9.3-p362) -> omgdav (in zbatery process) -> (TCP)
    MogileFS (patched[3]) -> (TCP)
    cmogstored

    The (zbatery -> omgdav -> MogileFS -> cmogstored) path is all userspace.
    cmogstored uses sendfile and may talk to itself via MogileFS replication:
    MogileFS(replicate) -> HTTP GET from cmogstored -> HTTP PUT to cmogstored

    (MFS was designed for clusters, but I only have one machine right
    now) MogileFS replicate does not use splice between sockets, just
    read/write, cmogstored does not use splice (yet) either.

    The stuck ppoll() I noticed is from Ruby (zbatery/omgdav) while the
    send() was from fusedav (using neon).

[2] my patches on http://bugs.debian.org/fusedav and
    git clone git://bogomips.org/fusedav.git home
[3] git clone git://bogomips.org/MogileFS-Server.git testing

> This may also be related to an epoll-related issue reported
> by Andreas Voellmy:
> http://thread.gmane.org/gmane.linux.kernel/1408782/

(That epoll issue was unrelated and fixed while I was hunting this bug)

> My example involves a 3 thread data flow between two pairs
> of (4) sockets:
> 
> 	 send_loop ->   recv_loop(recv_send)   -> recv_loop(recv_only)
> 	 pair_a[1] -> (pair_a[0] -> pair_b[1]) -> pair_b[0]
> 
> At least 3.7 and 3.7.1 are affected.
> 
> I have tcp_low_latency=1 set, I will try 0 later
> 
> The last progress message I got was after receiving 2942052597760
> bytes on fd=7 (out of 64-bit ULONG_MAX / 2)
> 
> strace:
> 
> 3644  sendto(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 16384, 0, NULL, 0 <unfinished ...>
> 3643  sendto(6, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 16384, 0, NULL, 0 <unfinished ...>
> 3642  ppoll([{fd=7, events=POLLIN}], 1, NULL, NULL, 8 <unfinished ...>
> 3641  futex(0x7f23ed8129d0, FUTEX_WAIT, 3644, NULL <unfinished ...>
> 
> The first and last lines of the strace are expected:
> 
> + 3644	sendto(4) is blocked because 3643 is blocked on sendto(fd=6)
>   and not able to call recv().
> + 3641 is the main thread calling pthread_join
> 
> What is unexpected is the tid=3643 and tid=3642 interaction.  As confirmed
> by lsof below, fd=6 is sending to wake up fd=7, but ppoll(fd=7) seems
> to not be waking up.
> 
> lsof:
> toosleepy 3641   ew    4u  IPv4  12405      0t0     TCP localhost:55904->localhost:33249 (ESTABLISHED)
> toosleepy 3641   ew    5u  IPv4  12406      0t0     TCP localhost:33249->localhost:55904 (ESTABLISHED)
> toosleepy 3641   ew    6u  IPv4  12408      0t0     TCP localhost:48777->localhost:33348 (ESTABLISHED)
> toosleepy 3641   ew    7u  IPv4  12409      0t0     TCP localhost:33348->localhost:48777 (ESTABLISHED)
> 
> System info: Linux 3.7.1 x86_64 SMP PREEMPT
> AMD Phenom(tm) II X4 945 Processor (4 cores)
> Nothing interesting in dmesg, iptables rules are empty.
> 
> I have not yet been able to reproduce the issue using UNIX sockets,
> only TCP, but you can run:
> 
>   ./toosleepy unix
> 
> ...to test with UNIX sockets intead of TCP.
> 
> The following code is also available via git://bogomips.org/toosleepy
> gcc -o toosleepy -O2 -Wall -lpthread toosleepy.c
> -------------------------------- 8< ------------------------------------
> #define _GNU_SOURCE
> #include <poll.h>
> #include <sys/ioctl.h>
> #include <pthread.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <arpa/inet.h>
> #include <netinet/tcp.h>
> #include <stdint.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <string.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <assert.h>
> #include <limits.h>
> 
> struct receiver {
> 	int rfd;
> 	int sfd;
> };
> 
> /* blocking sender */
> static void * send_loop(void *fdp)
> {
> 	int fd = *(int *)fdp;
> 	char buf[16384];
> 	ssize_t s;
> 	size_t sent = 0;
> 	size_t max = (size_t)ULONG_MAX / 2;
> 
> 	while (sent < max) {
> 		s = send(fd, buf, sizeof(buf), 0);
> 		if (s > 0)
> 			sent += s;
> 		if (s == -1)
> 			assert(errno == EINTR);
> 	}
> 	dprintf(2, "%d done sending: %zu\n", fd, sent);
> 	close(fd);
> 	return NULL;
> }
> 
> /* non-blocking receiver, using ppoll */
> static void * recv_loop(void *p)
> {
> 	const struct receiver *rcvr = p;
> 	char buf[16384];
> 	nfds_t nfds = 1;
> 	struct pollfd fds;
> 	int rc;
> 	ssize_t r, s;
> 	size_t received = 0;
> 	size_t sent = 0;
> 
> 	for (;;) {
> 		r = recv(rcvr->rfd, buf, sizeof(buf), 0);
> 		if (r == 0) {
> 			break;
> 		} else if (r == -1) {
> 			assert(errno == EAGAIN);
> 
> 			fds.fd = rcvr->rfd;
> 			fds.events = POLLIN;
> 			errno = 0;
> 			rc = ppoll(&fds, nfds, NULL, NULL);
> 			assert(rc == 1);
> 		} else {
> 			assert(r > 0);
> 			received += r;
> 			if (rcvr->sfd >= 0) {
> 				s = send(rcvr->sfd, buf, sizeof(buf), 0);
> 				if (s > 0)
> 					sent += s;
> 				if (s == -1)
> 					assert(errno == EINTR);
> 			} else {
> 				/* just burn some cycles */
> 				write(-1, buf, sizeof(buf));
> 			}
> 		}
> 		if ((received % (sizeof(buf) * sizeof(buf) * 16) == 0))
> 			dprintf(2, " %d progress: %zu\n",
> 			        rcvr->rfd, received);
> 	}
> 	dprintf(2, "%d got: %zu\n", rcvr->rfd, received);
> 	if (rcvr->sfd >= 0) {
> 		dprintf(2, "%d sent: %zu\n", rcvr->sfd, sent);
> 		close(rcvr->sfd);
> 	}
> 
> 	return NULL;
> }
> 
> static void tcp_socketpair(int sv[2], int accept_flags)
> {
> 	struct sockaddr_in addr;
> 	socklen_t addrlen = sizeof(addr);
> 	int l = socket(PF_INET, SOCK_STREAM, 0);
> 	int c = socket(PF_INET, SOCK_STREAM, 0);
> 	int a;
> 
> 	addr.sin_family = AF_INET;
> 	addr.sin_addr.s_addr = INADDR_ANY;
> 	addr.sin_port = 0;
> 	assert(0 == bind(l, (struct sockaddr*)&addr, addrlen));
> 	assert(0 == listen(l, 1024));
> 	assert(0 == getsockname(l, (struct sockaddr *)&addr, &addrlen));
> 	assert(0 == connect(c, (struct sockaddr *)&addr, addrlen));
> 	a = accept4(l, NULL, NULL, accept_flags);
> 	assert(a >= 0);
> 	close(l);
> 	sv[0] = a;
> 	sv[1] = c;
> }
> 
> int main(int argc, char *argv[])
> {
> 	int pair_a[2];
> 	int pair_b[2];
> 	pthread_t s, rs, r;
> 	struct receiver recv_only;
> 	struct receiver recv_send;
> 
> 	if (argc == 2 && strcmp(argv[1], "unix") == 0) {
> 		int val;
> 		assert(0 == socketpair(AF_UNIX, SOCK_STREAM, 0, pair_a));
> 		assert(0 == socketpair(AF_UNIX, SOCK_STREAM, 0, pair_b));
> 		/* only make the receiver non-blocking */
> 		val = 1;
> 		assert(0 == ioctl(pair_a[0], FIONBIO, &val));
> 		val = 1;
> 		assert(0 == ioctl(pair_b[0], FIONBIO, &val));
> 	} else {
> 		tcp_socketpair(pair_a, SOCK_NONBLOCK);
> 		tcp_socketpair(pair_b, SOCK_NONBLOCK);
> 	}
> 
> 	recv_send.rfd = pair_a[0];
> 	recv_send.sfd = pair_b[1];
> 	recv_only.rfd = pair_b[0];
> 	recv_only.sfd = -1;
> 
> 	/*
> 	 * data flow:
> 	 * send_loop ->   recv_loop(recv_send)   -> recv_loop(recv_only)
> 	 * pair_a[1] -> (pair_a[0] -> pair_b[1]) -> pair_b[0]
> 	 */
> 	assert(0 == pthread_create(&r, NULL, recv_loop, &recv_only));
> 	assert(0 == pthread_create(&rs, NULL, recv_loop, &recv_send));
> 	assert(0 == pthread_create(&s, NULL, send_loop, &pair_a[1]));
> 	assert(0 == pthread_join(s, NULL));
> 	assert(0 == pthread_join(rs, NULL));
> 	assert(0 == pthread_join(r, NULL));
> 
> 	return 0;
> }
> -------------------------------- 8< ------------------------------------
> Any help/suggestions/test patches would be greatly appreciated.
> Thanks for reading!
> 
> -- 
> Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
