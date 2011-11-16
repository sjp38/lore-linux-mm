Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA1856B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 04:07:34 -0500 (EST)
Received: by bke17 with SMTP id 17so365500bke.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 01:07:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111116082759.GD9581@n2100.arm.linux.org.uk>
References: <CAJ8eaTzOtgMzcZeRr6f=+WhtsykK1NZraOGBPoqGncwcAGcTyQ@mail.gmail.com>
	<20111116082759.GD9581@n2100.arm.linux.org.uk>
Date: Wed, 16 Nov 2011 14:37:30 +0530
Message-ID: <CAJ8eaTwCC2e3WKkQzWXhYZ6+SGBg+dabFA380OEoa0vOHM5Odw@mail.gmail.com>
Subject: Re: Crash when memset of shared mapped memory in ARM
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mm <linux-mm@kvack.org>, linux-arm-kernel-request@lists.arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, linux-arm-request@lists.arm.linux.org.uk, linux-kernel@vger.kernel.org

Ok,
On X86, MIPS
#./tc1
mmap: addr 0x20000000
#
#

On ARM (2.6.35.11 ~ 3.0.2)
#tc1
map: addr 0x20000000
tc1: unhandled page fault (7) at 0x20001000, code 0x817
Bus error (core dumped)
#
#
Debug Information
Pid: 179, comm:                  tc1
CPU: 0    Not tainted  (2.6.35.11 #1)
PC is at 0x400da410
LR is at 0x8858
pc : [<400da410>]    lr : [<00008858>]    psr: 20000010
sp : bed84814  ip : 20001080  fp : 00000000
r10: 40025000  r9 : 00000000  r8 : 00000000
r7 : 20000000  r6 : 20001000  r5 : 00000000  r4 : 0000ef80
r3 : 00000000  r2 : 20010000  r1 : 00000000  r0 : 20000000
Flags: nzCv  IRQs on  FIQs on  Mode USER_32  ISA ARM  Segment user

Process Memory map
00008000-00009000 r-xp 00000000 08:01 153 /usb/sda1/tc1
00010000-00011000 rw-p 00000000 08:01 153 /usb/sda1/tc1
00011000-00032000 rw-p 00011000 08:01 153
20000000-20010000 rw-s 00000000 00:0d 249 /dev/shm/shmem_1234
40000000-4001d000 r-xp 00000000 8b:06 163 /lib/ld-2.11.1.so
4001d000-40021000 rw-p 4001d000 8b:06 163
40024000-40025000 r--p 0001c000 8b:06 163 /lib/ld-2.11.1.so
40025000-40026000 rw-p 0001d000 8b:06 163 /lib/ld-2.11.1.so
40026000-4003b000 r-xp 00000000 8b:06 171 /lib/libpthread-2.11.1.so
4003b000-40042000 ---p 00015000 8b:06 171 /lib/libpthread-2.11.1.so
40042000-40043000 r--p 00014000 8b:06 171 /lib/libpthread-2.11.1.so
40043000-40044000 rw-p 00015000 8b:06 171 /lib/libpthread-2.11.1.so
40044000-40046000 rw-p 40044000 8b:06 171
40046000-4004c000 r-xp 00000000 8b:06 161 /lib/librt-2.11.1.so
4004c000-40053000 ---p 00006000 8b:06 161 /lib/librt-2.11.1.so
40053000-40054000 r--p 00005000 8b:06 161 /lib/librt-2.11.1.so
40054000-40055000 rw-p 00006000 8b:06 161 /lib/librt-2.11.1.so
40055000-4005f000 r-xp 00000000 8b:06 165 /lib/libgcc_s.so.1
4005f000-40067000 ---p 0000a000 8b:06 165 /lib/libgcc_s.so.1
40067000-40068000 rw-p 0000a000 8b:06 165 /lib/libgcc_s.so.1
40068000-40185000 r-xp 00000000 8b:06 174 /lib/libc-2.11.1.so
40185000-4018d000 ---p 0011d000 8b:06 174 /lib/libc-2.11.1.so
4018d000-4018f000 r--p 0011d000 8b:06 174 /lib/libc-2.11.1.so
4018f000-40190000 rw-p 0011f000 8b:06 174 /lib/libc-2.11.1.so
40190000-40193000 rw-p 40190000 8b:06 174
bed63000-bed85000 rw-p befde000 8b:06 174

We wish to know why the same application crashes on ARM ?
On Wed, Nov 16, 2011 at 1:57 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Nov 16, 2011 at 11:05:49AM +0530, naveen yadav wrote:
>> Hi All,
>>
>> I am running below Test program on ARM cortex a9/a8 on kernel version
>> 2.6.35.14 as well as on 3.0.
>>
>> Please find the test case where:
>>
>> 1. Create shared memory object using shm_open(If we use normal open
>> then no problem only problem with shm_open)
>>
>> 2. ftruncate to given size
>>
>> 3. memory map the shared object to given memory address ( I haved
>> tested without MAP_SHARED, MAP_FIXED as well, problem exist)
>>
>> 4. Memset the shared memory (got page fault when accessing the second pa=
ge)
>>
>>
>>
>>
>> Observation: Only observed in ARM ( i.e not present in MIPS and X86)
>
> Yes, so, what happens?
>
>>
>>
>> #undef NDEBUG
>> #define _GNU_SOURCE
>> #include <unistd.h>
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <sys/ipc.h>
>> #include <sys/shm.h>
>> #include <errno.h>
>> #include <pthread.h>
>> #include <string.h>
>> #include <signal.h>
>> #include <fcntl.h>
>> #include <sys/types.h>
>> #include <sys/mman.h>
>>
>> enum {
>> =A0SHM_INIT,
>> =A0SHM_GET
>> =A0};
>>
>> enum {
>> =A0PARENT,
>> =A0CHILD
>> =A0};
>>
>> #define FIXED_MMAP_ADDR 0x20000000
>> #define MMAP_SIZE =A0 =A0 0x10000
>>
>> static int shmid;
>> static char shm_name[100];
>> static int sleep_period =3D 100000;
>> void * shmem_init(int flag)
>> {
>> =A0 =A0 =A0 int start =3D FIXED_MMAP_ADDR;
>> =A0 =A0 =A0 int memory_size =3D MMAP_SIZE;
>> =A0 =A0 =A0 int mode =3D 0666;
>> =A0 =A0 =A0 void *addr;
>> =A0 =A0 =A0 int ret;
>> =A0 =A0 =A0 sprintf(shm_name, "/shmem_1234");
>> =A0 =A0 =A0 shmid =3D shm_open (shm_name, O_RDWR | O_EXCL | O_CREAT | O_=
TRUNC, mode);
>> =A0 =A0 =A0 if (shmid < 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (errno =3D=3D EEXIST) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf ("shm_open: %s\n", st=
rerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shmid =3D sh=
m_open (shm_name, O_RDWR, mode);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("failed to shm_open, =
err=3D%s\n", strerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 ret =3D fcntl (shmid, F_SETFD, FD_CLOEXEC);
>> =A0 =A0 =A0 if (ret < 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("fcntl: %s\n", strerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 ret =3D ftruncate (shmid, memory_size);
>> =A0 =A0 =A0 if (ret < 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("ftruncate: %s\n", strerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 addr =3D mmap ((void *)start, memory_size, PROT_READ | PROT_=
WRITE,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAP_SHARED | MAP_=
FIXED, shmid, 0);
>> =A0 =A0 =A0 if (addr =3D=3D MAP_FAILED) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf ("mmap: %s\n", strerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 close (shmid);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shm_unlink (shm_name);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (flag =3D=3D SHM_INIT){
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf ("mmap: addr %p\n", addr);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* memset on arm creates a unhandled page fa=
ult, works fine on mips */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(addr, 0, memory_size);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return (void *)addr;
>> }
>>
>> pthread_mutex_t * shmem_mutex_init(int flag)
>> {
>> =A0 =A0 =A0 pthread_mutex_t * pmutex =3D (pthread_mutex_t *)shmem_init(f=
lag);
>> #if 0
>> =A0 =A0 =A0 pthread_mutexattr_t attr;
>> =A0 =A0 =A0 if (flag =3D=3D SHM_INIT) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_init (&attr);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_setpshared (&attr, PTHREAD=
_PROCESS_SHARED);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_setprotocol (&attr, PTHREA=
D_PRIO_INHERIT);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_setrobust_np (&attr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 PTHREAD_MUTEX_STALLED_NP);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_settype (&attr, PTHREAD_MU=
TEX_ERRORCHECK);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pthread_mutex_init (pmutex, &attr) !=3D =
0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("Init mutex failed, e=
rr=3D%s\n", strerror(errno));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutexattr_destroy (&=
attr);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> #endif
>> =A0 =A0 =A0 return pmutex;
>> }
>>
>> void long_running_task(int flag)
>> {
>> =A0 =A0 =A0 static int counter =3D 0;
>> =A0 =A0 =A0 if (flag =3D=3D PARENT)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 usleep(5*sleep_period);
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 usleep(3*sleep_period);
>> =A0 =A0 =A0 counter =3D (counter + 1) % 100;
>> =A0 =A0 =A0 printf("%d: completed %d computing\n", getpid(), counter);
>> }
>>
>> void sig_handler(int signum)
>> {
>> =A0 =A0 =A0 close(shmid);
>> =A0 =A0 =A0 shm_unlink(shm_name);
>> =A0 =A0 =A0 exit(0);
>> }
>>
>> int main(int argc, char *argv[])
>> {
>> =A0 =A0 =A0 pthread_mutex_t *mutex_parent, *mutex_child;
>> // =A0 =A0signal(SIGUSR1, sig_handler);
>> // =A0 =A0if (fork()) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* parent process */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((mutex_parent =3D shmem_mutex_init(SHM_I=
NIT)) =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("failed to get the sh=
mem_mutex\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 exit(-1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> #if 0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: try to hold the =
lock\n", getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutex_lock(mutex_par=
ent);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: got the lock\n",=
 getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long_running_task(PARENT);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutex_unlock(mutex_p=
arent);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: released the loc=
k\n", getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> #endif
>> // =A0 =A0} else {
>> #if 0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* child process */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 usleep(sleep_period);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((mutex_child =3D shmem_mutex_init(SHM_GE=
T)) =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("failed to get the sh=
mem_mutex\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 exit(-1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: try to hold the =
lock\n", getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutex_lock(mutex_chi=
ld);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: got the lock\n",=
 getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long_running_task(CHILD);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pthread_mutex_unlock(mutex_c=
hild);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("%d: released the loc=
k\n", getpid());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> #endif
>> // =A0 =A0}
>> =A0 =A0 =A0 return 0;
>> }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
