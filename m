Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] modified segq for 2.5
Date: Mon, 9 Sep 2002 07:40:16 -0400
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com>
In-Reply-To: <3D7C6C0A.1BBEBB2D@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209090740.16942.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 9, 2002 05:38 am, Andrew Morton wrote:

> With nonblocking-vm and slabasap, the test took 150 seconds.
> Removing slabasap took it down to 98 seconds.  The slab rework
> seemed to leave an extra megabyte average in cache.  Which is not
> to say that the algorithms in there are wrong, but perhaps we should
> push it a bit harder if there's swapout pressure.

Andrew, One simple change that will make slabasap try harder is to 
use only inactive pages caculating the ratio. 

unsigned int nr_used_zone_pages(void)
{
        unsigned int pages = 0;
        struct zone *zone;

        for_each_zone(zone)
                pages += zone->nr_inactive;

        return pages;
}

This will make it closer to slablru which used the inactive list.

Second item.  Do you run gkrelmon when doing your tests?  If not please
install it and watch it slowly start to eat resources.   This morning (uptime 
12hr) it was using 31% of CPU.  Stopping and starting it did not change this.  
Think we have something we can improve here.  I have inclued an strace
of one (and a bit) update cycle.

This was with 33-mm5 with your varient of slabasap.

Ed

open("/proc/meminfo", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "MemTotal:       516920 kB\nMemFre"..., 1024) = 491
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
gettimeofday({1031571076, 678996}, NULL) = 0
write(3, ">\2\7\0\30\2`\2\375\1`\2\35\0`\2\0\0%\0\0\0%\0P\0\3\0>"..., 1956) = 1956
ioctl(3, 0x541b, [0])                   = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}], 2, 262) = 0
gettimeofday({1031571076, 945260}, NULL) = 0
time([1031571076])                      = 1031571076
open("/proc/stat", O_RDONLY)            = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "cpu  418635 1309463 315263 22714"..., 1024) = 591
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/loadavg", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "3.27 2.32 3.38 3/132 14540\n", 1024) = 27
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/dev", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Inter-|   Receive               "..., 1024) = 938
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
gettimeofday({1031571076, 949176}, NULL) = 0
write(3, "F\2\5\0\213\0`\2$\0`\2\0\0\0\0\5\0\6\0>\0\7\0\211\0`\2"..., 784) = 784
ioctl(3, 0x541b, [0])                   = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}], 2, 473) = 0
gettimeofday({1031571077, 424287}, NULL) = 0
time([1031571077])                      = 1031571077
open("/proc/stat", O_RDONLY)            = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "cpu  418639 1309506 315264 22714"..., 1024) = 591
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/loadavg", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "3.27 2.32 3.38 2/132 14540\n", 1024) = 27
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
write(3, "8\2\5\0!\0`\2\4@\0\0\0\0\0\0)\0`\2J\0\5\0m\0`\2!\0`\2"..., 2048) = 2048
open("/proc/net/tcp", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "  sl  local_address rem_address "..., 1024) = 1024
read(6, "                         \n   6: "..., 1024) = 1024
read(6, "dc00040 3000 0 0 2 -1           "..., 1024) = 1024
read(6, "000     0        0 6460 1 da6dfc"..., 1024) = 1024
read(6, "00000000 00:00000000 00000000  1"..., 1024) = 1024
read(6, "0100007F:8001 01 00000000:000000"..., 1024) = 1024
read(6, "     \n  40: 0100007F:866E 010000"..., 1024) = 1024
read(6, "-1                             \n", 1024) = 32
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/tcp6", O_RDONLY)        = -1 ENOENT (No such file or directory)
open("/proc/net/dev", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Inter-|   Receive               "..., 1024) = 938
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/route", O_RDONLY)       = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Iface\tDestination\tGateway \tFlags"..., 1024) = 512
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
time(NULL)                              = 1031571077
open("/proc/meminfo", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "MemTotal:       516920 kB\nMemFre"..., 1024) = 491
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/mounts", O_RDONLY)          = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "rootfs / rootfs rw 0 0\n/dev/root"..., 1024) = 314
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
statfs("/", {f_type="REISERFS_SUPER_MAGIC", f_bsize=4096, f_blocks=786466, f_bfree=120154, f_files=4294967295, f_ffree=4294967295, f_namelen=255}) = 0
statfs("/poola", {f_type="REISERFS_SUPER_MAGIC", f_bsize=4096, f_blocks=2477941, f_bfree=892388, f_files=4294967295, f_ffree=4294967295, f_namelen=255}) = 0
statfs("/poole", {f_type="REISERFS_SUPER_MAGIC", f_bsize=4096, f_blocks=8870498, f_bfree=2468598, f_files=4294967295, f_ffree=4294967295, f_namelen=255}) = 0
statfs("/boot", {f_type="EXT2_SUPER_MAGIC", f_bsize=1024, f_blocks=63925, f_bfree=21000, f_files=16560, f_ffree=14904, f_namelen=255}) = 0
statfs("/tmp", {f_type=0x1021994, f_bsize=4096, f_blocks=192000, f_bfree=191685, f_files=64615, f_ffree=64593, f_namelen=255}) = 0
statfs("/poolg", {f_type="REISERFS_SUPER_MAGIC", f_bsize=4096, f_blocks=8870624, f_bfree=2371206, f_files=4294967295, f_ffree=4294967295, f_namelen=255}) = 0
statfs("/root2", {f_type="EXT2_SUPER_MAGIC", f_bsize=4096, f_blocks=774823, f_bfree=137303, f_files=393600, f_ffree=261747, f_namelen=255}) = 0
gettimeofday({1031571077, 639770}, NULL) = 0
write(3, "8\2\5\0!\0`\2\4@\0\0\0\0\0\0\'\0`\2J\0\5\0k\1`\2!\0`\2"..., 1900) = 1900
ioctl(3, 0x541b, [0])                   = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}], 2, 260) = 0
gettimeofday({1031571077, 916658}, NULL) = 0
time([1031571077])                      = 1031571077
open("/proc/stat", O_RDONLY)            = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "cpu  418649 1309524 315285 22714"..., 1024) = 591
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/loadavg", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "3.27 2.32 3.38 4/132 14540\n", 1024) = 27
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/dev", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Inter-|   Receive               "..., 1024) = 938
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
gettimeofday({1031571077, 920415}, NULL) = 0
write(3, "F\2\5\0\213\0`\2$\0`\2\0\0\0\0\5\0\6\0>\0\7\0\211\0`\2"..., 192) = 192
ioctl(3, 0x541b, [0])                   = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}], 2, 473) = 0
gettimeofday({1031571078, 396278}, NULL) = 0
time([1031571078])                      = 1031571078
open("/proc/stat", O_RDONLY)            = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "cpu  418653 1309567 315286 22714"..., 1024) = 591
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/loadavg", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "3.27 2.32 3.38 3/132 14540\n", 1024) = 27
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
write(3, "8\2\5\0!\0`\2\4@\0\0\0\0\0\0)\0`\2J\0\5\0m\0`\2!\0`\2"..., 2048) = 2048
open("/proc/net/tcp", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "  sl  local_address rem_address "..., 1024) = 1024
read(6, "                         \n   6: "..., 1024) = 1024
read(6, "dc00040 3000 0 0 2 -1           "..., 1024) = 1024
read(6, "000     0        0 6460 1 da6dfc"..., 1024) = 1024
read(6, "00000000 00:00000000 00000000  1"..., 1024) = 1024
read(6, "0100007F:8001 01 00000000:000000"..., 1024) = 1024
read(6, "     \n  40: 0100007F:866E 010000"..., 1024) = 1024
read(6, "-1                             \n", 1024) = 32
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/tcp6", O_RDONLY)        = -1 ENOENT (No such file or directory)
open("/proc/net/dev", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Inter-|   Receive               "..., 1024) = 938
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
writev(3, [{"8\2\5\0!\0`\2\4@\0\0\0\0\0\0\'\0`\2J\0\5\0k\1`\2!\0`\2"..., 2048}, {"\227\320\357\0", 4}], 2) = 2052
open("/proc/net/route", O_RDONLY)       = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Iface\tDestination\tGateway \tFlags"..., 1024) = 512
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
time(NULL)                              = 1031571078
open("/proc/meminfo", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "MemTotal:       516920 kB\nMemFre"..., 1024) = 491
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
gettimeofday({1031571078, 614278}, NULL) = 0
write(3, "J\2\5\0\320\2`\2!\0`\2\2\0\f\0\1\0000\0>\0\7\0\320\2`\2"..., 404) = 404
ioctl(3, 0x541b, [0])                   = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}], 2, 258) = 0
gettimeofday({1031571078, 875241}, NULL) = 0
time([1031571078])                      = 1031571078
open("/proc/stat", O_RDONLY)            = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "cpu  418657 1309592 315306 22714"..., 1024) = 591
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/loadavg", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "3.27 2.32 3.38 2/132 14540\n", 1024) = 27
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
open("/proc/net/dev", O_RDONLY)         = 6
fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x4001d000
read(6, "Inter-|   Receive               "..., 1024) = 938
read(6, "", 1024)                       = 0
close(6)                                = 0
munmap(0x4001d000, 4096)                = 0
gettimeofday({1031571078, 879754}, NULL) = 0
write(3, "F\2\5\0\213\0`\2$\0`\2\0\0\0\0\5\0\6\0>\0\7\0\211\0`\2"..., 700) = 700
ioctl(3, 0x541b, [0])                   = 0
poll( <unfinished ...>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
