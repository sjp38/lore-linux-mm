Message-Id: <6.2.5.6.2.20081206001117.01c86878@binnacle.cx>
Date: Sat, 06 Dec 2008 00:17:14 -0500
From: starlight@binnacle.cx
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment
    from second process more than one time
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_-567485484==_"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

--=====================_-567485484==_
Content-Type: text/plain; charset="us-ascii"

Went back and tried a few things.

Finally figured out that the problem can be reproduced with a 
simple shared memory segment loader utility we have.  No 
threads, no forks, nothing fancy. Just create a segment and read 
the contents of a big file into it.  Two segments actually.  The 
only difference is the accessing program has to be run three 
times instead of two times to produce the failure.  You might be 
able to accomplish the same result just using 'memset()' to 
touch all the memory.

Then tried this out with the F9 kernel 2.6.26.5-45.fc9.x86_64 
and everything worked perfectly.

This is all I can do.  Have burned way to many hours on it and 
am now retreating to the warm safety of the RHEL kernel.  Only 
reason I was playing with the kernel.org kernel is we're trying 
to get an Intel 82575 working with the 'igb' driver in 
multiple-RX-queue mode and the 'e1000-devel' guys said to use 
the latest.  However that's looking like a total bust, so it's 
time to retreat, wait for six months and hope it's all working
by then with a supported kernel.

I've attached the 'strace' files.  Don't know where those 
'mmap's are coming from except that perhaps in a library 
somewhere.  There are none in our code.

Good luck.
--=====================_-567485484==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="create_seg_strace.txt"

execve("load", [""], [/* 43 vars */]) = 0
brk(0)                                  = 0x14cf000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04edac000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04edab000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=16678, ...}) = 0
mmap(NULL, 16678, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fb04eda6000
close(3)                                = 0
open("/lib64/librt.so.1", O_RDONLY)     = 3
read(3, ..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=53448, ...}) = 0
mmap(0x3df4000000, 2132944, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df4000000
mprotect(0x3df4007000, 2097152, PROT_NONE) = 0
mmap(0x3df4207000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) = 0x3df4207000
close(3)                                = 0
open("/w/lib/libstdc++.so.6", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\26\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0750, st_size=5121519, ...}) = 0
mmap(NULL, 2127000, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fb04eb9e000
mprotect(0x7fb04ec8a000, 1048576, PROT_NONE) = 0
mmap(0x7fb04ed8a000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xec000) = 0x7fb04ed8a000
mmap(0x7fb04ed93000, 74904, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb04ed93000
close(3)                                = 0
open("/lib64/libm.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 >\200\363=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=619320, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04eb9d000
mmap(0x3df3800000, 2638024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df3800000
mprotect(0x3df3884000, 2093056, PROT_NONE) = 0
mmap(0x3df3a83000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x83000) = 0x3df3a83000
close(3)                                = 0
open("/w/lib/libgcc_s.so.1", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220(\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0640, st_size=472511, ...}) = 0
mmap(NULL, 1137848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fb04ea87000
mprotect(0x7fb04ea9d000, 1044480, PROT_NONE) = 0
mmap(0x7fb04eb9c000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7fb04eb9c000
close(3)                                = 0
open("/lib64/libpthread.so.0", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240W\300\363=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=143096, ...}) = 0
mmap(0x3df3c00000, 2204496, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df3c00000
mprotect(0x3df3c16000, 2093056, PROT_NONE) = 0
mmap(0x3df3e15000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x3df3e15000
mmap(0x3df3e17000, 13136, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3df3e17000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\344\301\362=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1804104, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04ea86000
mmap(0x3df2c00000, 3584632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df2c00000
mprotect(0x3df2d62000, 2097152, PROT_NONE) = 0
mmap(0x3df2f62000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x162000) = 0x3df2f62000
mmap(0x3df2f67000, 17016, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3df2f67000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04ea85000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04ea84000
arch_prctl(ARCH_SET_FS, 0x7fb04ea84700) = 0
mprotect(0x3df2f62000, 16384, PROT_READ) = 0
mprotect(0x3df3e15000, 4096, PROT_READ) = 0
mprotect(0x3df3a83000, 4096, PROT_READ) = 0
mprotect(0x7fb04ed8a000, 8192, PROT_READ) = 0
mprotect(0x3df4207000, 4096, PROT_READ) = 0
mprotect(0x3df2a1c000, 4096, PROT_READ) = 0
munmap(0x7fb04eda6000, 16678)           = 0
set_tid_address(0x7fb04ea84790)         = 2788
set_robust_list(0x7fb04ea847a0, 0x18)   = 0
futex(0x7fff56daa5ec, FUTEX_WAKE_PRIVATE, 1) = 0
rt_sigaction(SIGRTMIN, {0x3df3c05630, [], SA_RESTORER|SA_SIGINFO, 0x3df3c0ed30}, NULL, 8) = 0
rt_sigaction(SIGRT_1, {0x3df3c056c0, [], SA_RESTORER|SA_RESTART|SA_SIGINFO, 0x3df3c0ed30}, NULL, 8) = 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM_INFINITY}) = 0
futex(0x7fb04ed93c48, FUTEX_WAKE_PRIVATE, 2147483647) = 0
brk(0)                                  = 0x14cf000
brk(0x14f0000)                          = 0x14f0000
futex(0x524c60, FUTEX_WAKE_PRIVATE, 2147483647) = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c1, 1073741824, IPC_CREAT|IPC_EXCL|SHM_HUGETLB|0640) = 0
shmat(0, 0x400000000, 0)                = ?
shmctl(0, IPC_STAT, 0x7fff56daa170)     = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c0, 268435456, IPC_CREAT|IPC_EXCL|SHM_HUGETLB|0640) = 32769
shmat(32769, 0x580000000, 0)            = ?
shmctl(32769, IPC_STAT, 0x7fff56daa1a0) = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
open("", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=3519, ...}) = 0
fstat(3, {st_mode=S_IFREG|0644, st_size=3519, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb04edaa000
read(3, ..., 4096) = 3519
lseek(3, -2252, SEEK_CUR)               = 1267
read(3, ..., 4096) = 2252
close(3)                                = 0
munmap(0x7fb04edaa000, 4096)            = 0
write(2, ...) = 69
open("", O_RDONLY|O_NOCTTY) = 3
lseek(3, 0, SEEK_END)                   = 761545448
lseek(3, 0, SEEK_SET)                   = 0
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 2376424) = 2376424
close(3)                                = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
write(2, ...) = 66
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
write(2, ...) = 67
open("", O_RDONLY|O_NOCTTY) = 3
lseek(3, 0, SEEK_END)                   = 24186116
lseek(3, 0, SEEK_SET)                   = 0
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 4194304) = 4194304
read(3, ..., 3214596) = 3214596
close(3)                                = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
write(2, ...) = 64
shmdt(0x580000000)                      = 0
shmdt(0x400000000)                      = 0
exit_group(0)                           = ?

--=====================_-567485484==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="access_seg_strace3.txt"

execve("access", ["access"], [/* 43 vars */]) = 0
brk(0)                                  = 0x1e99000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067e14b000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067e14a000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=16678, ...}) = 0
mmap(NULL, 16678, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f067e145000
close(3)                                = 0
open("/w/lib/libstdc++.so.6", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\26\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0750, st_size=5121519, ...}) = 0
mmap(NULL, 2127000, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f067df3d000
mprotect(0x7f067e029000, 1048576, PROT_NONE) = 0
mmap(0x7f067e129000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xec000) = 0x7f067e129000
mmap(0x7f067e132000, 74904, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f067e132000
close(3)                                = 0
open("/lib64/libm.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 >\200\363=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=619320, ...}) = 0
mmap(0x3df3800000, 2638024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df3800000
mprotect(0x3df3884000, 2093056, PROT_NONE) = 0
mmap(0x3df3a83000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x83000) = 0x3df3a83000
close(3)                                = 0
open("/w/lib/libgcc_s.so.1", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220(\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0640, st_size=472511, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067df3c000
mmap(NULL, 1137848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f067de26000
mprotect(0x7f067de3c000, 1044480, PROT_NONE) = 0
mmap(0x7f067df3b000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7f067df3b000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\344\301\362=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1804104, ...}) = 0
mmap(0x3df2c00000, 3584632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df2c00000
mprotect(0x3df2d62000, 2097152, PROT_NONE) = 0
mmap(0x3df2f62000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x162000) = 0x3df2f62000
mmap(0x3df2f67000, 17016, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3df2f67000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067de25000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067de24000
arch_prctl(ARCH_SET_FS, 0x7f067de24700) = 0
mprotect(0x3df2f62000, 16384, PROT_READ) = 0
mprotect(0x3df3a83000, 4096, PROT_READ) = 0
mprotect(0x7f067e129000, 8192, PROT_READ) = 0
mprotect(0x3df2a1c000, 4096, PROT_READ) = 0
munmap(0x7f067e145000, 16678)           = 0
brk(0)                                  = 0x1e99000
brk(0x1eba000)                          = 0x1eba000
getpid()                                = 2802
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c1, 0, 0)                 = 0
shmat(0, 0x400000000, SHM_RDONLY)       = -1 ENOMEM (Cannot allocate memory)
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
open("", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=3519, ...}) = 0
fstat(3, {st_mode=S_IFREG|0644, st_size=3519, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f067e149000
read(3, ..., 4096) = 3519
lseek(3, -2252, SEEK_CUR)               = 1267
read(3, ..., 4096) = 2252
close(3)                                = 0
munmap(0x7f067e149000, 4096)            = 0
write(2, ...) = 83
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
write(2, ...) = 59
write(2, ...) = 48
write(2, ...) = 24
write(2, "", 2'
)                     = 2
rt_sigprocmask(SIG_UNBLOCK, [ABRT], NULL, 8) = 0
tgkill(2802, 2802, SIGABRT)             = 0
--- SIGABRT (Aborted) @ 0 (0) ---
+++ killed by SIGABRT +++

--=====================_-567485484==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="access_seg_strace2.txt"

execve("access", ["access"], [/* 43 vars */]) = 0
brk(0)                                  = 0xd6c000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab7f6000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab7f5000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=16678, ...}) = 0
mmap(NULL, 16678, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f97ab7f0000
close(3)                                = 0
open("/w/lib/libstdc++.so.6", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\26\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0750, st_size=5121519, ...}) = 0
mmap(NULL, 2127000, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f97ab5e8000
mprotect(0x7f97ab6d4000, 1048576, PROT_NONE) = 0
mmap(0x7f97ab7d4000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xec000) = 0x7f97ab7d4000
mmap(0x7f97ab7dd000, 74904, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f97ab7dd000
close(3)                                = 0
open("/lib64/libm.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 >\200\363=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=619320, ...}) = 0
mmap(0x3df3800000, 2638024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df3800000
mprotect(0x3df3884000, 2093056, PROT_NONE) = 0
mmap(0x3df3a83000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x83000) = 0x3df3a83000
close(3)                                = 0
open("/w/lib/libgcc_s.so.1", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220(\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0640, st_size=472511, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab5e7000
mmap(NULL, 1137848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f97ab4d1000
mprotect(0x7f97ab4e7000, 1044480, PROT_NONE) = 0
mmap(0x7f97ab5e6000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7f97ab5e6000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\344\301\362=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1804104, ...}) = 0
mmap(0x3df2c00000, 3584632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df2c00000
mprotect(0x3df2d62000, 2097152, PROT_NONE) = 0
mmap(0x3df2f62000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x162000) = 0x3df2f62000
mmap(0x3df2f67000, 17016, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3df2f67000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab4d0000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab4cf000
arch_prctl(ARCH_SET_FS, 0x7f97ab4cf700) = 0
mprotect(0x3df2f62000, 16384, PROT_READ) = 0
mprotect(0x3df3a83000, 4096, PROT_READ) = 0
mprotect(0x7f97ab7d4000, 8192, PROT_READ) = 0
mprotect(0x3df2a1c000, 4096, PROT_READ) = 0
munmap(0x7f97ab7f0000, 16678)           = 0
brk(0)                                  = 0xd6c000
brk(0xd8d000)                           = 0xd8d000
getpid()                                = 2800
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c1, 0, 0)                 = 0
shmat(0, 0x400000000, SHM_RDONLY)       = ?
shmctl(0, IPC_STAT, 0x7fffb37f5cc0)     = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c0, 0, 0)                 = 32769
shmat(32769, 0x580000000, SHM_RDONLY)   = ?
shmctl(32769, IPC_STAT, 0x7fffb37f5cc0) = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f97ab7f4000
shmdt(0x580000000)                      = 0
shmdt(0x400000000)                      = 0
exit_group(0)                           = ?

--=====================_-567485484==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="access_seg_strace1.txt"

execve("access", ["access"], [/* 43 vars */]) = 0
brk(0)                                  = 0x95c000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb66c000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb66b000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=16678, ...}) = 0
mmap(NULL, 16678, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f1bbb666000
close(3)                                = 0
open("/w/lib/libstdc++.so.6", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\26\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0750, st_size=5121519, ...}) = 0
mmap(NULL, 2127000, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f1bbb45e000
mprotect(0x7f1bbb54a000, 1048576, PROT_NONE) = 0
mmap(0x7f1bbb64a000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xec000) = 0x7f1bbb64a000
mmap(0x7f1bbb653000, 74904, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb653000
close(3)                                = 0
open("/lib64/libm.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 >\200\363=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=619320, ...}) = 0
mmap(0x3df3800000, 2638024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df3800000
mprotect(0x3df3884000, 2093056, PROT_NONE) = 0
mmap(0x3df3a83000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x83000) = 0x3df3a83000
close(3)                                = 0
open("/w/lib/libgcc_s.so.1", O_RDONLY) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220(\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0640, st_size=472511, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb45d000
mmap(NULL, 1137848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f1bbb347000
mprotect(0x7f1bbb35d000, 1044480, PROT_NONE) = 0
mmap(0x7f1bbb45c000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7f1bbb45c000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\344\301\362=\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1804104, ...}) = 0
mmap(0x3df2c00000, 3584632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3df2c00000
mprotect(0x3df2d62000, 2097152, PROT_NONE) = 0
mmap(0x3df2f62000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x162000) = 0x3df2f62000
mmap(0x3df2f67000, 17016, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3df2f67000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb346000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb345000
arch_prctl(ARCH_SET_FS, 0x7f1bbb345700) = 0
mprotect(0x3df2f62000, 16384, PROT_READ) = 0
mprotect(0x3df3a83000, 4096, PROT_READ) = 0
mprotect(0x7f1bbb64a000, 8192, PROT_READ) = 0
mprotect(0x3df2a1c000, 4096, PROT_READ) = 0
munmap(0x7f1bbb666000, 16678)           = 0
brk(0)                                  = 0x95c000
brk(0x97d000)                           = 0x97d000
getpid()                                = 2798
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
msgget(0x20342be, 0)                    = -1 ENOENT (No such file or directory)
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c1, 0, 0)                 = 0
shmat(0, 0x400000000, SHM_RDONLY)       = ?
shmctl(0, IPC_STAT, 0x7fffc366bb40)     = 0
stat("", {st_mode=S_IFREG|0640, st_size=0, ...}) = 0
shmget(0x20342c0, 0, 0)                 = 32769
shmat(32769, 0x580000000, SHM_RDONLY)   = ?
shmctl(32769, IPC_STAT, 0x7fffc366bb40) = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1bbb66a000
shmdt(0x580000000)                      = 0
shmdt(0x400000000)                      = 0
exit_group(0)                           = ?

--=====================_-567485484==_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
