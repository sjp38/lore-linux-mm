In-reply-to: <20070327095220.4bc76cdc.akpm@linux-foundation.org> (message from
	Andrew Morton on Tue, 27 Mar 2007 09:52:20 -0800)
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu>
	<20070326232214.ee92d8c4.akpm@linux-foundation.org>
	<E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
	<20070326234957.6b287dda.akpm@linux-foundation.org>
	<E1HW6eb-0003WX-00@dorka.pomaz.szeredi.hu>
	<20070327001834.04dc375e.akpm@linux-foundation.org>
	<E1HW72O-0003ZB-00@dorka.pomaz.szeredi.hu>
	<20070327005150.9177ae02.akpm@linux-foundation.org>
	<E1HW7tS-0003em-00@dorka.pomaz.szeredi.hu> <20070327095220.4bc76cdc.akpm@linux-foundation.org>
Message-Id: <E1HWGQD-0004T8-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 27 Mar 2007 20:29:29 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> that's simpler ;) Is it correct enough though?  The place where it will
> become inaccurate is for repeated modification via an established map.  ie:
> 
> 	p = mmap(..., MAP_SHARED);
> 	for ( ; ; )
> 		*p = 1;
> 
> in which case I think the timestamp will only get updated once per
> writeback interval (ie: 30 seconds).

Which is perfectly OK, we really can't do any better in any sane way.

My concern is only about MS_ASYNC, it would be really nice to know
what other OSs do.  I've checked on a Solaris 5.7 (not exactly a
modern OS) and that is as good as current Linux.

If someone has access to others pls. find my test program at the end.

The logical way to handle msync is IMO:

   write to memory + msync(MS_ASYNC) == write()
   write to memory + msync(MS_SYNC) == write() + fdatasync()

Yes, it would add some overhead for MS_ASYNC, but that's what the user
wants isn't it?  If the user doesn't want correctly updated
timestamps, it should not call msync().

Miklos

=== msync_time.c ==============================================
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>

static const char *filename;

static void print_times(const char *msg)
{
    struct stat stbuf;
    stat(filename, &stbuf);
    printf("%s\t%li\t%li\t%li\n", msg, stbuf.st_ctime, stbuf.st_mtime,
           stbuf.st_atime);
}

static void usage(const char *progname)
{
    fprintf(stderr, "usage: %s filename [-s]\n", progname);
    exit(1);
}

int main(int argc, char *argv[])
{
    int res;
    char *addr;
    int msync_flag = MS_ASYNC;
    int fd;

    if (argc < 2)
        usage(argv[0]);

    filename = argv[1];
    if (argc > 2) {
        if (argc > 3)
            usage(argv[0]);
        if (strcmp(argv[2], "-s") == 0)
            msync_flag = MS_SYNC;
        else
            usage(argv[0]);
    }

    fd = open(filename, O_RDWR | O_TRUNC | O_CREAT, 0666);
    if (fd == -1) {
        perror(filename);
        return 1;
    }
    print_times("begin");
    sleep(1);
    write(fd, "aaaa\n", 4);
    print_times("write");
    sleep(1);
    addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr == (char *) -1) {
        perror("mmap");
        return 1;
    }
    print_times("mmap");
    sleep(1);

    addr[1] = 'b';
    print_times("b");
    sleep(1);
    res = msync(addr, 4, msync_flag);
    if (res == -1) {
        perror("msync");
        return 1;
    }
    print_times("msync b");
    sleep(1);

    addr[2] = 'c';
    print_times("c");
    sleep(1);
    res = msync(addr, 4, msync_flag);
    if (res == -1) {
        perror("msync");
        return 1;
    }
    print_times("msync c");
    sleep(1);

    addr[3] = 'd';
    print_times("d");
    sleep(1);
    res = munmap(addr, 4);
    if (res == -1) {
        perror("munmap");
        return 1;
    }
    print_times("munmap");
    sleep(1);

    res = close(fd);
    if (res == -1) {
        perror("close");
        return 1;
    }
    print_times("end");
    return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
