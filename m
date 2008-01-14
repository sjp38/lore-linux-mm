In-reply-to: <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Mon, 14 Jan 2008 12:08:17 +0100)
Subject: Re: [PATCH 2/2] updating ctime and mtime at syncing
References: <12001991991217-git-send-email-salikhmetov@gmail.com> <12001992023392-git-send-email-salikhmetov@gmail.com> <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu>
Message-Id: <E1JENHf-0007Dl-Q5@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 14 Jan 2008 12:15:15 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

> > http://bugzilla.kernel.org/show_bug.cgi?id=2645
> > 
> > Changes for updating the ctime and mtime fields for memory-mapped files:
> > 
> > 1) new flag triggering update of the inode data;
> > 2) new function to update ctime and mtime for block device files;
> > 3) new helper function to update ctime and mtime when needed;
> > 4) updating time stamps for mapped files in sys_msync() and do_fsync();
> > 5) implementing the feature of auto-updating ctime and mtime.
> 
> How exactly is this done?
> 
> Is this catering for this case:
> 
>  1 page is dirtied through mapping
>  2 app calls msync(MS_ASYNC)
>  3 page is written again through mapping
>  4 app calls msync(MS_ASYNC)
>  5 ...
>  6 page is written back
> 
> What happens at 4?  Do we care about this one at all?

Oh, and here's a test program I wrote, that can be used to check this
behavior.   It has two options:

 -s   use MS_SYNC instead of MS_ASYNC
 -f   fork and do the msync on a different mapping

Back then I haven't found a single OS, that fully conformed to all the
stupid POSIX rules regarding mmaps and ctime/mtime.

Miklos
----

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>

static const char *filename;
static int msync_flag = MS_ASYNC;
static int msync_fork = 0;

static void print_times(const char *msg)
{
    struct stat stbuf;
    stat(filename, &stbuf);
    printf("%s\t%li\t%li\t%li\n", msg, stbuf.st_ctime, stbuf.st_mtime,
           stbuf.st_atime);
}

static void do_msync(void *addr, int len)
{
    int res;
    if (!msync_fork) {
        res = msync(addr, len, msync_flag);
        if (res == -1) {
            perror("msync");
            exit(1);
        }
    } else {
        int pid = fork();
        if (pid == -1) {
            perror("fork");
            exit(1);
        }
        if (!pid) {
            int fd = open(filename, O_RDWR);
            if (fd == -1) {
                perror("open");
                exit(1);
            }
            addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
            if (addr == MAP_FAILED) {
                perror("mmap");
                exit(1);
            }
            res = msync(addr, len, msync_flag);
            if (res == -1) {
                perror("msync");
                exit(1);
            }
            exit(0);
        }
        wait(NULL);
    }
}

static void usage(const char *progname)
{
    fprintf(stderr, "usage: %s filename [-sf]\n", progname);
    exit(1);
}

int main(int argc, char *argv[])
{
    int res;
    char *addr;
    int fd;

    if (argc < 2)
        usage(argv[0]);

    filename = argv[1];
    if (argc > 2) {
        if (argc > 3)
            usage(argv[0]);
        if (strcmp(argv[2], "-s") == 0)
            msync_flag = MS_SYNC;
        else if (strcmp(argv[2], "-f") == 0)
            msync_fork = 1;
        else if (strcmp(argv[2], "-sf") == 0 || strcmp(argv[2], "-fs") == 0) {
            msync_flag = MS_SYNC;
            msync_fork = 1;
        } else
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
    if (addr == MAP_FAILED) {
        perror("mmap");
        return 1;
    }
    print_times("mmap");
    sleep(1);

    addr[1] = 'b';
    print_times("b");
    sleep(1);
    do_msync(addr, 4);
    print_times("msync b");
    sleep(1);

    addr[2] = 'c';
    print_times("c");
    sleep(1);
    do_msync(addr, 4);
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
    print_times("close");
    sleep(1);
    sync();
    print_times("sync");

    return 0;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
