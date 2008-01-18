Received: by wa-out-1112.google.com with SMTP id m33so1892043wag.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 11:48:40 -0800 (PST)
Message-ID: <4df4ef0c0801181148y8d446c7ifb23677dbf4ea0c9@mail.gmail.com>
Date: Fri, 18 Jan 2008 22:48:38 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 0/2] Fixing the issue with memory-mapped file times
In-Reply-To: <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/18, Miklos Szeredi <miklos@szeredi.hu>:
> > 4. Performance test was done using the program available from the
> > following link:
> >
> > http://bugzilla.kernel.org/attachment.cgi?id=14493
> >
> > Result: the impact of the changes was negligible for files of a few
> > hundred megabytes.
>
> Could you also test with ext4 and post some numbers?  Afaik, ext4 uses
> nanosecond timestamps, so the time updating code would be exercised
> more during the page faults.
>
> What about performance impact on msync(MS_ASYNC)?  Could you please do
> some measurment of that as well?

Did a quick test on an ext4 partition. This is how it looks like:

debian:~/miklos# ./miklos_test /mnt/file
begin   1200662360      1200662360      1200662353
write   1200662361      1200662361      1200662353
mmap    1200662361      1200662361      1200662362
b       1200662363      1200662363      1200662362
msync b 1200662363      1200662363      1200662362
c       1200662365      1200662365      1200662362
msync c 1200662365      1200662365      1200662362
d       1200662367      1200662367      1200662362
munmap  1200662367      1200662367      1200662362
close   1200662367      1200662367      1200662362
sync    1200662367      1200662367      1200662362
debian:~/miklos# mount | grep /mnt
/root/image.ext4 on /mnt type ext4dev (rw,loop=/dev/loop0)

> What about performance impact on msync(MS_ASYNC)?  Could you please do
> some measurment of that as well?

Following are the results of the measurements. Here are the relevant
portions of the test program:

>>>

#define FILE_SIZE (1024 * 1024 * 512)

p = mmap(0, FILE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

/* Bring the pages in */
for (i = 0; i < FILE_SIZE; i += 4096)
        tmp = p[i];

/* Dirty the pages */
for (i = 0; i < FILE_SIZE; i += 4096)
        p[i] = i;

/* How long did we spend in msync(MS_ASYNC)? */
gettimeofday(&tv_start, NULL);
msync(p, FILE_SIZE, MS_ASYNC);
gettimeofday(&tv_stop, NULL);

<<<

For reference tests, the following platforms were used:

1. HP-UX B.11.31, PA-RISC 8800 processor (800 MHz, 64 MB), Memory: 4 GB.

2. HP-UX B.11.31, 2 Intel(R) Itanium 2 9000 series processors (1.59 GHz, 18 MB),
   Memory: 15.98 GB.

3. FreeBSD 6.2-RELEASE, Intel(R) Pentium(R) III CPU family 1400MHz, 2 CPUs.
   Memory: 4G.

The tests of my solution were performed using the following platform:

A KVM x86_64 guest OS, current Git kernel. Host system: Intel(R) Core(TM)2
Duo CPU T7300 @ 2.00GHz. Further referred to as "the first case".

The following tables give the time difference between the two calls
to gettimeofday(). The test program was run three times in a raw
with a delay of one second between consecutive runs. On Linux
systems, the following commands were issued prior to running the
tests:

echo 80 >/proc/sys/vm/dirty_ratio
echo 80 >/proc/sys/vm/dirty_background_ratio
echo 30000 >/proc/sys/vm/dirty_expire_centisecs
sync

Table 1. Reference platforms.

------------------------------------------------------------
|             | HP-UX/PA-RISC | HP-UX/Itanium | FreeBSD    |
------------------------------------------------------------
| First run   | 263405 usec   | 202283 usec   | 90 SECONDS |
------------------------------------------------------------
| Second run  | 262253 usec   | 172837 usec   | 90 SECONDS |
------------------------------------------------------------
| Third run   | 238465 usec   | 238465 usec   | 90 SECONDS |
------------------------------------------------------------

It looks like FreeBSD is a clear outsider here. Note that FreeBSD
showed an almost liner depencence of the time spent in the
msync(MS_ASYNC) call on the file size.

Table 2. The Qemu system. File size is 512M.

---------------------------------------------------
|            | Before the patch | After the patch |
---------------------------------------------------
| First run  |     35 usec      |   5852 usec     |
---------------------------------------------------
| Second run |     35 usec      |   4444 usec     |
---------------------------------------------------
| Third run  |     35 usec      |   6330 usec     |
---------------------------------------------------

I think that the data above prove the viability of the solution I
presented. Also, I guess that this bug fix is most probably ready
for getting upstream.

Please apply the sixth version of my solution.

>
> Thanks,
> Miklos
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
