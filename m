Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACA446B0684
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 20:12:34 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p206-v6so1016786itc.0
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 17:12:34 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 189-v6si30474its.23.2018.11.08.17.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 17:12:32 -0800 (PST)
Date: Thu, 8 Nov 2018 17:12:22 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 00/21] swap: Swapout/swapin THP in one piece
Message-ID: <20181109011222.rciqkw25z2lyhxqi@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010071924.18767-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Wed, Oct 10, 2018 at 03:19:03PM +0800, Huang Ying wrote:
> And for all, Any comment is welcome!

Hi Ying, 

Looks like an edge case.  I'd run the program at the bottom like
    ./stress-usage-counts -l 4 -s 4 -U 780g
where the 780g was big enough to cause swapping on the machine.  This allocates
a bunch of THPs in the parent and then forks children that either unmap pieces
of the THPs and then do random reads in the pieces still mapped, or just
randomly read in the whole range without unmapping anything.

I had your patch from the other thread, fyi.

Thanks,
Daniel

[15384.814483] ------------[ cut here ]------------
[15384.820622] kernel BUG at /home/dbbench/src/linux/mm/swapfile.c:4134!
[15384.828793] invalid opcode: 0000 [#1] SMP PTI
[15384.834604] CPU: 15 PID: 27456 Comm: stress-usage-co Kdump: loaded Not tainted 4.19.0-rc6-mm1-thp-swap-v6-gcov+ #3
[15384.847096] Hardware name: Oracle Corporation ORACLE SERVER X7-2/ASM, MB, X7-2, BIOS 41017600 10/06/2017
[15384.858637] RIP: 0010:split_swap_cluster_map+0x172/0x1d0
[15384.865493] Code: 89 4c 01 01 e9 2a ff ff ff 5b 5d 31 c0 48 83 05 1b 89 4c 01 01 41 5c c3 b8 f0 ff ff ff e9 37 ff ff ff 48 83 05 0e 88 4c 01 01 <0f> 0b 48 83 05 14 88 4c 01 01 48 83 05 14 88 4c 01 01 48 83 05 14
[15384.888329] RSP: 0018:ffffaca85fb9bc88 EFLAGS: 00010202
[15384.895075] RAX: 0000000000000000 RBX: 00007f0463800000 RCX: 0000000000000000
[15384.903964] RDX: ffff9154229e28e0 RSI: 00007f0463800000 RDI: 0000000000194ff8
[15384.912834] RBP: ffff9154229e28e0 R08: 0000000000000000 R09: 000fffffffe00000
[15384.921694] R10: 0000000000000000 R11: ffff90f8000008e0 R12: 0000000000194ff8
[15384.930533] R13: ffff9156a8bb1100 R14: ffff915168646c00 R15: ffff9156a8bb1100
[15384.939363] FS:  00007fc763ff5740(0000) GS:ffff9156c07c0000(0000) knlGS:0000000000000000
[15384.949272] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[15384.956567] CR2: 0000000000603090 CR3: 0000005a9a2f8003 CR4: 00000000007606e0
[15384.965373] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[15384.974164] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[15384.982943] PKRU: 55555554
[15384.986756] Call Trace:
[15384.990268]  __split_huge_swap_pmd+0x48/0x170
[15384.995928]  __split_huge_pmd_locked+0x8be/0x1590
[15385.001933]  ? flush_tlb_mm_range+0xa1/0x120
[15385.007439]  ? memcg_check_events+0x2f/0x2e0
[15385.012949]  __split_huge_pmd+0x2d6/0x3e0
[15385.018135]  split_huge_pmd_address+0xbd/0x100
[15385.023794]  vma_adjust_trans_huge+0xe0/0x150
[15385.029344]  __vma_adjust+0xb8/0x770
[15385.034004]  __split_vma+0x182/0x1a0
[15385.038647]  __do_munmap+0xfd/0x340
[15385.043182]  __vm_munmap+0x6d/0xc0
[15385.047600]  __x64_sys_munmap+0x27/0x30
[15385.052509]  do_syscall_64+0x49/0x100
[15385.057206]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[15385.063430] RIP: 0033:0x7fc7638fa087
[15385.068018] Code: 64 89 02 48 83 c8 ff eb 9c 48 8b 15 03 ce 2c 00 f7 d8 64 89 02 e9 6a ff ff ff 66 0f 1f 84 00 00 00 00 00 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d d9 cd 2c 00 f7 d8 64 89 01 48
[15385.090123] RSP: 002b:00007ffec5d40198 EFLAGS: 00000202 ORIG_RAX: 000000000000000b
[15385.099142] RAX: ffffffffffffffda RBX: 000000005be4d221 RCX: 00007fc7638fa087
[15385.107700] RDX: 00007f0463960000 RSI: 00000000000216d6 RDI: 00007f0463960000
[15385.116223] RBP: 00007ffec5d401f0 R08: 0000000000006ab7 R09: 00007ffec5d401f0
[15385.124738] R10: 00007ffec5d3f5a0 R11: 0000000000000202 R12: 0000000000400ca0
[15385.133217] R13: 00007ffec5d40340 R14: 0000000000000000 R15: 0000000000000000
[15385.141684] Modules linked in: sunrpc vfat fat coretemp x86_pkg_temp_thermal crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel aes_x86_64 ext4 crypto_simd cryptd glue_helper jbd2 ext2 mbcache ipmi_ssif ipmi_si ioatdma ipmi_devintf sg iTCO_wdt lpc_ich pcspkr wmi mfd_core i2c_i801 ipmi_msghandler ip_tables xfs libcrc32c sd_mod mgag200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops igb ttm nvme hwmon xhci_pci drm dca megaraid_sas xhci_hcd crc32c_intel nvme_core i2c_algo_bit ahci i2c_core libahci dm_mirror dm_region_hash dm_log dm_mod dax efivarfs ipv6 crc_ccitt autofs4

--------------------------------------8<---------------------------------------

/*
 * stress-usage-counts.c
 *
 * gcc -o stress-usage-counts stress-usage-counts.c -pthread
 *
 * Daniel Jordan <daniel.m.jordan@oracle.com>
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <errno.h>
#include <time.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <assert.h>
#include <fcntl.h>
#include <pthread.h>
#include <time.h>

#define ALIGN(x, a)	((x) & ~((a) - 1))
#define DEBUG 0
#define dprintf		if (DEBUG) printf
#define THP_PGSZ_SYSFS	"/sys/kernel/mm/transparent_hugepage/hpage_pmd_size"

/* Taken from include/linux/kernel.h */
#define __round_mask(x, y) ((__typeof__(x))((y)-1))
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

typedef void * (*start_routine)(void *);

char *ourname;
size_t bytes;
char *memory;
char *memory_unaligned;
char *munmap_arg;
unsigned long munmap_size;
unsigned long munmap_offset;
int random_munmap;
size_t pagesize;
unsigned long thp_size;
size_t nr_thread;

static void usage(int ok)
{
	fprintf(stderr,
	"Usage: %s [options] size[k|m|g|t]\n"
	"    -h                  show this message\n"
	"    -l N                start N large-page processes, default 1\n"
	"    -s N                start N small-page processes, default 1\n"
	"    -u offset,size      munmap in small-page procs at each offset of size\n"
	"    -U                  munmap in small-page procs at random offset and size\n"
	,		ourname);

	exit(ok);
}

/**
 *      [copied from usemem.c - dmj]
 *	memparse - parse a string with mem suffixes into a number
 *	@ptr: Where parse begins
 *	@retptr: (output) Optional pointer to next char after parse completes
 *
 *	Parses a string into a number.	The number stored at @ptr is
 *	potentially suffixed with %K (for kilobytes, or 1024 bytes),
 *	%M (for megabytes, or 1048576 bytes), or %G (for gigabytes, or
 *	1073741824).  If the number is suffixed with K, M, or G, then
 *	the return value is the number multiplied by one kilobyte, one
 *	megabyte, or one gigabyte, respectively.
 */
static unsigned long long memparse(const char *ptr, char **retptr)
{
	char *endptr;	/* local pointer to end of parsed string */

	unsigned long long ret = strtoull(ptr, &endptr, 0);

	switch (*endptr) {
	case 'T':
	case 't':
		ret <<= 10;
	case 'G':
	case 'g':
		ret <<= 10;
	case 'M':
	case 'm':
		ret <<= 10;
	case 'K':
	case 'k':
		ret <<= 10;
		endptr++;
	default:
		break;
	}

	if (retptr)
		*retptr = endptr;

	return ret;
}

static unsigned long read_sysfs_ul(const char *fname)
{
	int fd;
	ssize_t len;
	char buf[64];

	fd = open(fname, O_RDONLY);
	if (fd == -1) {
		perror("sysfs open");
		exit(1);
	}

	len = read(fd, buf, sizeof(buf) - 1);
	if (len == -1) {
		perror("sysfs read");
		exit(1);
	}

	return strtoul(buf, NULL, 10);
}

static inline void os_random_seed(unsigned long seed, struct drand48_data *rs)
{
	srand48_r(seed, rs);
}

static inline long os_random_long(unsigned long max, struct drand48_data *rs)
{
	long val;

	lrand48_r(rs, &val);
	return (unsigned long)((double)max * val / (RAND_MAX + 1.0));
}

struct fault_range {
	size_t start, end;
};

static long fault_thread(void *arg)
{
	size_t i;
	struct fault_range *range = (struct fault_range *)arg;

	for (i = range->start; i < range->end; i += pagesize)
		memory[i] = 'b';
}

static void fault_all(char *memory, size_t bytes)
{
	int ret;
	size_t i;
	long thread_ret;
	pthread_t threads[nr_thread];
	struct fault_range ranges[nr_thread];

	if (nr_thread > bytes) {
		ranges[0].start = 0;
		ranges[0].end   = bytes;
		fault_thread(&ranges[0]);
		return;
	}

	for (i = 0; i < nr_thread; i++) {
		ranges[i].start = bytes * i / nr_thread;
		ranges[i].end   = bytes * (i + 1) / nr_thread;
		ret = pthread_create(&threads[i], NULL, (start_routine)fault_thread, &ranges[i]);
		if (ret) {
			perror("pthread_create");
			exit(1);
		}
	}

	for (i = 0; i < nr_thread; i++) {
		ret = pthread_join(threads[i], (void *)&thread_ret);
		if (ret) {
			perror("pthread_join");
			exit(1);
		}
	}

	dprintf("done faulting\n");
}

static void read_memory(size_t idx)
{
	volatile char c = (volatile char)memory[idx];
}

int do_small_page_task(void)
{
	size_t i;
	struct drand48_data rand_data;

	os_random_seed(time(0) ^ syscall(SYS_gettid), &rand_data);

	/* Unmap parts of the range? */
	if (munmap_size) {
		assert(munmap_offset % pagesize == 0);
		for (i = munmap_offset; i < bytes; i += thp_size) {
			dprintf("munmap(%lx, %lx)\n", memory + i, munmap_size);
			if (munmap(memory + i, munmap_size) == -1) {
				fprintf(stderr, "munmap failed: %s\n",
					strerror(errno));
				exit(1);
			}
		}
	}

	while (1) {
		struct timespec ts;
		size_t thp_offset;

		i = ALIGN(os_random_long(bytes, &rand_data), pagesize);
		thp_offset = i % thp_size;

		if (thp_offset >= munmap_offset &&
		    thp_offset <= munmap_offset + munmap_size)
			continue;

		read_memory(i);

		ts.tv_sec  = 0;
		ts.tv_nsec = 1000;
		if (nanosleep(&ts, NULL) == -1) {
			fprintf(stderr, "nanosleep failed: %s\n", strerror(errno));
			exit(1);
		}
	}
}

int do_large_page_task(void)
{
	size_t i;
	size_t pmd_aligned_start, pmd_aligned_end;
	struct drand48_data rand_data;
	struct timespec ts;

	os_random_seed(time(0) ^ syscall(SYS_gettid), &rand_data);

	while (1) {
		volatile char *c;

		i = ALIGN(os_random_long(bytes, &rand_data), thp_size);

		read_memory(i);

		ts.tv_sec  = 0;
		ts.tv_nsec = 1000;
		if (nanosleep(&ts, NULL) == -1) {
			fprintf(stderr, "nanosleep failed: %s\n", strerror(errno));
			exit(1);
		}
	}
}

int main(int argc, char **argv)
{
	int i, c, child_pid, status;
	struct drand48_data rand_data;
	size_t nr_smallpg_procs = 1;
	size_t nr_largepg_procs = 1;

	ourname = argv[0];

	pagesize = sysconf(_SC_PAGESIZE);
	dprintf("pagesize = %lu\n", pagesize);
	thp_size = read_sysfs_ul(THP_PGSZ_SYSFS);
	dprintf("thp_size = %lu\n", thp_size);

	nr_thread = sysconf(_SC_NPROCESSORS_ONLN);
	dprintf("nr_thread = %lu\n", nr_thread);

	while ((c = getopt(argc, argv, "hl:s:u:U")) != -1) {
		switch (c) {
		case 'h':
			usage(0);
		case 'l':
			nr_largepg_procs = strtol(optarg, NULL, 10);
			break;
		case 's':
			nr_smallpg_procs = strtol(optarg, NULL, 10);
			break;
		case 'u':
                        if ((munmap_arg = strtok(optarg, ",")) == NULL)
                                usage(1);
                        munmap_offset = memparse(munmap_arg, NULL);
                        if ((munmap_arg = strtok(NULL, ",")) == NULL)
                                usage(1);
                        munmap_size = memparse(munmap_arg, NULL);
			break;
		case 'U':
			random_munmap = 1;
			break;
		default:
			usage(1);
		}
	}

	if (optind != argc - 1)
		usage(0);

	bytes = memparse(argv[optind], NULL);

	if (random_munmap) {
		os_random_seed(time(0) ^ syscall(SYS_gettid), &rand_data);
		munmap_offset = ALIGN(os_random_long(thp_size - 1, &rand_data),
				      pagesize);
		printf("random munmap offset = %lu\n", munmap_offset);
		munmap_size = os_random_long(thp_size - munmap_offset,
					     &rand_data);
		printf("random munmap size   = %lu\n", munmap_size);
	}

	memory_unaligned = mmap(NULL, bytes + thp_size, PROT_READ | PROT_WRITE,
				MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	if (memory_unaligned == MAP_FAILED) {
		fprintf(stderr, "mmap failed: %s\n", strerror(errno));
		exit(1);
	}
	if (madvise(memory_unaligned, bytes, MADV_HUGEPAGE) == -1) {
		fprintf(stderr, "madvise failed: %s\n", strerror(errno));
		exit(1);
	}
	memory = (char *)round_up((unsigned long)memory_unaligned, thp_size);

	printf("mmap(%ld, %ld)\n", memory, bytes);

	/* fault it all in */
	fault_all(memory_unaligned, bytes);

	for (i = 0; i < nr_smallpg_procs; i++) {
		if ((child_pid = fork()) == 0)
			return do_small_page_task();
		else if (child_pid < 0)
			fprintf(stderr, "failed to fork: %s\n",
				strerror(errno));
	}

	for (i = 0; i < nr_largepg_procs; i++) {
		if ((child_pid = fork()) == 0)
			return do_large_page_task();
		else if (child_pid < 0)
			fprintf(stderr, "failed to fork: %s\n",
				strerror(errno));
	}

	for (i = 0; i < nr_smallpg_procs + nr_largepg_procs; i++) {
		if (wait3(&status, 0, 0) < 0) {
			if (errno != EINTR) {
				printf("wait3 error on %dth child\n", i);
				perror("wait3");
				return 1;
			}
		}
	}

	dprintf("finished\n");

	return 0;
}

--------------------------------------8<---------------------------------------
