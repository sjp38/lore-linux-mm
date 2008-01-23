Received: by wa-out-1112.google.com with SMTP id m33so4920451wag.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2008 04:25:37 -0800 (PST)
Message-ID: <4df4ef0c0801230425o13a1f3a6p87298c6767eb62ce@mail.gmail.com>
Date: Wed, 23 Jan 2008 15:25:37 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v8 4/4] The design document for memory-mapped file times update
In-Reply-To: <E1JHdav-0002MW-GH@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	 <1201044083554-git-send-email-salikhmetov@gmail.com>
	 <E1JHbs1-00025n-Ac@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801230237g2f26f0d1j2d2ada2ce62ba284@mail.gmail.com>
	 <E1JHdE4-0002Jk-QG@pomaz-ex.szeredi.hu>
	 <E1JHdav-0002MW-GH@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/23, Miklos Szeredi <miklos@szeredi.hu>:
> > Ah, OK, this is becuase mmap doesn't actually set up the page tables
> > by default.   Try adding MAP_POPULATE to the flags.
>
> Here's an updated version of the program, with an added a '-r' option,
> that performs a read access on the mapping before doing the write
> (basically equivalent to MAP_POPULATE, but portable).
>
> Please try this on a tmpfs file.
>
> Thanks,
> Miklos
>
> ---
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <string.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> #include <sys/stat.h>
> #include <sys/wait.h>
>
> static const char *filename;
> static int msync_flag = MS_ASYNC;
> static int msync_fork = 0;
> static int msync_read = 0;
>
> static void print_times(const char *msg)
> {
>         struct stat stbuf;
>         stat(filename, &stbuf);
>         printf("%s\t%li\t%li\t%li\n", msg, stbuf.st_ctime, stbuf.st_mtime,
>                stbuf.st_atime);
> }
>
> static void do_msync(void *addr, int len)
> {
>         int res;
>         if (!msync_fork) {
>                 res = msync(addr, len, msync_flag);
>                 if (res == -1) {
>                         perror("msync");
>                         exit(1);
>                 }
>         } else {
>                 int pid = fork();
>                 if (pid == -1) {
>                         perror("fork");
>                         exit(1);
>                 }
>                 if (!pid) {
>                         int fd = open(filename, O_RDWR);
>                         if (fd == -1) {
>                                 perror("open");
>                                 exit(1);
>                         }
>                         addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>                         if (addr == MAP_FAILED) {
>                                 perror("mmap");
>                                 exit(1);
>                         }
>                         res = msync(addr, len, msync_flag);
>                         if (res == -1) {
>                                 perror("msync");
>                                 exit(1);
>                         }
>                         exit(0);
>                 }
>                 wait(NULL);
>         }
> }
>
> static void usage(const char *progname)
> {
>         fprintf(stderr, "usage: %s filename [-sfr]\n", progname);
>         fprintf(stderr, " -s: use MS_SYNC instead of MS_ASYNC\n");
>         fprintf(stderr, " -f: fork and perform msync in a different process\n");
>         fprintf(stderr, " -r: do a read access before each write access\n");
>         exit(1);
> }
>
> int main(int argc, char *argv[])
> {
>         int res;
>         char *addr;
>         char tmp[32];
>         int fd;
>
>         if (argc < 2)
>                 usage(argv[0]);
>
>         filename = argv[1];
>         if (argc > 2) {
>                 char *s;
>                 if (argc > 3)
>                         usage(argv[0]);
>                 s = argv[2];
>                 if (s[0] != '-' || !s[1])
>                         usage(argv[0]);
>                 for (s++; *s; s++) {
>                         switch (*s) {
>                         case 's':
>                                 msync_flag = MS_SYNC;
>                                 break;
>                         case 'f':
>                                 msync_fork = 1;
>                                 break;
>                         case 'r':
>                                 msync_read = 1;
>                                 break;
>                         default:
>                                 usage(argv[0]);
>                         }
>                 }
>         }
>
>         fd = open(filename, O_RDWR | O_TRUNC | O_CREAT, 0666);
>         if (fd == -1) {
>                 perror(filename);
>                 return 1;
>         }
>         print_times("begin");
>         sleep(1);
>         write(fd, "wxyz\n", 4);
>         print_times("write");
>         sleep(1);
>         addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>         if (addr == MAP_FAILED) {
>                 perror("mmap");
>                 return 1;
>         }
>         print_times("mmap");
>         sleep(1);
>
>         if (msync_read) {
>                 sprintf(tmp, "fetch %c", addr[1]);
>                 print_times(tmp);
>                 sleep(1);
>         }
>         addr[1] = 'b';
>         print_times("store b");
>         sleep(1);
>         do_msync(addr, 4);
>         print_times("msync");
>         sleep(1);
>
>         if (msync_read) {
>                 sprintf(tmp, "fetch %c", addr[2]);
>                 print_times(tmp);
>                 sleep(1);
>         }
>         addr[2] = 'c';
>         print_times("store c");
>         sleep(1);
>         do_msync(addr, 4);
>         print_times("msync");
>         sleep(1);
>
>         if (msync_read) {
>                 sprintf(tmp, "fetch %c", addr[3]);
>                 print_times(tmp);
>                 sleep(1);
>         }
>         addr[3] = 'd';
>         print_times("store d");
>         sleep(1);
>         res = munmap(addr, 4);
>         if (res == -1) {
>                 perror("munmap");
>                 return 1;
>         }
>         print_times("munmap");
>         sleep(1);
>
>         res = close(fd);
>         if (res == -1) {
>                 perror("close");
>                 return 1;
>         }
>         print_times("close");
>         sleep(1);
>         sync();
>         print_times("sync");
>
>         return 0;
> }
>

Miklos, thanks for your program. Its output is given below.

debian:~/miklos# mount | grep mnt
tmpfs on /mnt type tmpfs (rw)
debian:~/miklos# ./miklos /mnt/file
begin   1201089989      1201089989      1201085868
write   1201089990      1201089990      1201085868
mmap    1201089990      1201089990      1201089991
store b 1201089992      1201089992      1201089991
msync   1201089992      1201089992      1201089991
store c 1201089994      1201089994      1201089991
msync   1201089994      1201089994      1201089991
store d 1201089996      1201089996      1201089991
munmap  1201089996      1201089996      1201089991
close   1201089996      1201089996      1201089991
sync    1201089996      1201089996      1201089991
debian:~/miklos# ./miklos /mnt/file -r
begin   1201090025      1201090025      1201089991
write   1201090026      1201090026      1201089991
mmap    1201090026      1201090026      1201090027
fetch x 1201090026      1201090026      1201090027
store b 1201090026      1201090026      1201090027
msync   1201090026      1201090026      1201090027
fetch y 1201090026      1201090026      1201090027
store c 1201090032      1201090032      1201090027
msync   1201090032      1201090032      1201090027
fetch z 1201090032      1201090032      1201090027
store d 1201090036      1201090036      1201090027
munmap  1201090036      1201090036      1201090027
close   1201090036      1201090036      1201090027
sync    1201090036      1201090036      1201090027
debian:~/miklos#

I think that after the patches applied the msync() system call does
everything, which it is expected to do. The issue you're now talking
about is one belonging to do_fsync() and the design of the tmpfs
driver itself, I believe. Indeed, when the first write in the "-r"
version of the test did not update the stamps, this is obviously not
an msync() guilt.

By the way, I would not like to move the "4/4" patch to the earlier
place, because then it would describe the functionality, which had not
been introduced yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
