Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id E589D6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:00:52 -0400 (EDT)
Received: by igbdj2 with SMTP id dj2so55341060igb.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:00:52 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 81si10373219iop.10.2015.10.22.02.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 02:00:52 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so81802721pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:00:51 -0700 (PDT)
Date: Thu, 22 Oct 2015 18:00:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151022090051.GH23631@bbox>
References: <20151021052836.GB6024@bbox>
 <20151021110723.GC10597@node.shutemov.name>
 <20151022000648.GD23631@bbox>
 <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
 <20151022012136.GG23631@bbox>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Content-Disposition: inline
In-Reply-To: <20151022012136.GG23631@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> Hello Hugh,
> 
> On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > 
> > > I added the code to check it and queued it again but I had another oops
> > > in this time but symptom is related to anon_vma, too.
> > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > at that time but second check of page_mapped right before try_to_unmap seems
> > > to be true.
> > > 
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > 
> > That's interesting, that's one I added in my page migration series.
> > Let me think on it, but it could well relate to the one you got before.
> 
> I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> instead of next-20151021 to remove noise from your migration cleanup
> series and will test it again.
> If it is fixed, I will test again with your migration patchset, then.

I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
Therefore, there is no patchset from Hugh's migration patch in there.
And I added below debug code with request from Kirill to all test kernels.

diff --git a/mm/rmap.c b/mm/rmap.c
index ddfb9be72366..1c23b70b1f57 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -513,6 +513,13 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 
        anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
        root_anon_vma = READ_ONCE(anon_vma->root);
+
+       if (root_anon_vma == NULL) {
+               printk("anon_vma %p refcount %d\n", anon_vma,
+                       atomic_read(&anon_vma->refcount));
+               VM_BUG_ON_PAGE(1, page);
+       }
+
        if (down_read_trylock(&root_anon_vma->rwsem)) {
                /*
                 * If the page is still mapped, then this anon_vma is still


1. mmotm-2015-10-15-15-20 + kirill's pte_mkdirty

1st trial:
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: Bad rss-counter state mm:ffff88007f1ed780 idx:1 val:488
BUG: Bad rss-counter state mm:ffff88007f1ed780 idx:2 val:24

2nd trial:

Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: Bad rss-counter state mm:ffff8800a5cca680 idx:1 val:512
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS

2. mmotm-2015-10-15-15-20-no-madvise_free, IOW it means git head for
54bad5da4834 arm64: add pmd_[dirty|mkclean] for THP.

1st trial:
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: Bad rss-counter state mm:ffff88007f4c2d80 idx:1 val:511
BUG: Bad rss-counter state mm:ffff88007f4c2d80 idx:2 val:1

2nd trial:
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
anon_vma ffff880000089aa0 refcount 0
page:ffffea0001a2ea40 count:3 mapcount:1 mapping:ffff880000089aa1 index:0x6000047a9

I tested it with KVM which guest system has 12 core and 3G memory.
In mmotm-2015-10-15-15-20-no-madvise_free, I tweaked test program does
madvise_dontneed intead of madvise_free via below patch

For the testing,

        gcc -o oops oops.c
        ./memcg_test.sh

I will be off from now on so please understand late response
but I hope my test program will reproduce it in your machine.

diff --git a/oops.c b/oops.c
index e50330a..c8298f8 100644
--- a/oops.c
+++ b/oops.c
@@ -8,7 +8,7 @@
 #include <errno.h>
 #include <signal.h>
 
-#define MADV_FREE 5
+#define MADV_FREE 4
 
 int pid;


--TB36FDmn/VVEgNH/
Content-Type: application/x-sh
Content-Disposition: attachment; filename="memcg_move_task.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0ATASKS=3D`cat /cgroup/testA/tasks`=0Afor TASK in $TASKS=0Ad=
o=0A	echo "move $TASK to testB"=0A	echo $TASK > /cgroup/testB/tasks=0Adone=
=0A=0Asleep 1=0A=0Aswapoff -a=0Aecho "swapoff done"=0A=0Asleep 1=0Aswapon -=
a=0Aecho "swapon done"=0A=0Afor TASK in $TASKS=0Ado=0A	echo "move $TASK to =
testA"=0A	echo $TASK > /cgroup/testA/tasks=0Adone=0A=0Asleep 30=0A
--TB36FDmn/VVEgNH/
Content-Type: application/x-sh
Content-Disposition: attachment; filename="memcg_test.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0A./setup_memcg.sh=0A=0Awhile :=0Ado=0A	echo fork processes=
=0A	echo $i=0A	./oops.sh 20 &=0A	sleep 10=0A=0A	echo move processes=0A	./me=
mcg_move_task.sh &=0A=0A	sleep 10=0A=0A	echo kill processes=0A	pkill -INT o=
ops=0A	sleep 5=0Adone=0A
--TB36FDmn/VVEgNH/
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="oops.c"

#include <sys/types.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

#define MADV_FREE 4

int pid;

void sig_handler(int signo)
{
        printf("pid %d sig received %d\n", pid, signo);
	exit(1);
}

void free_bufs(void **bufs, unsigned long buf_count, unsigned long buf_size)
{
	int i;

	for (i = 0; i < buf_count; i++) {
		if (bufs[i] != NULL) {
			munmap(bufs[i],  buf_size);
			bufs[i] = NULL;
		}
	}
}

void alloc_bufs(void **bufs, unsigned long buf_count, unsigned long buf_size)
{
	int i;
	time_t rawtime;
	struct tm * timeinfo;
	void *addr = (void*)0x600000000000;

	for (i = 0; i < buf_count; i++) {
		void *ptr = NULL;

		ptr = mmap(addr, buf_size, PROT_READ|PROT_WRITE,
			MAP_ANON|MAP_PRIVATE|MAP_FIXED, 0, 0);

		if (ptr == MAP_FAILED) {
			char bufs[64];

			sprintf(bufs, "cat /proc/%d/maps", pid);
			printf("error to allocate %p\n", addr);

			system(bufs);
			exit(1);
		}

		addr += buf_size;
		bufs[i] = ptr;
	}
}

void fill_bufs(void **bufs, unsigned long buf_count, unsigned long buf_size)
{
	int i;
	char msg[64] = {0, };

	for (i = 0; i < buf_count; i++)
		memset(bufs[i], 'a' + i, buf_size);

	sprintf(msg, "pid %d buf_count %ld complete", pid, buf_count);
}

void madvise_bufs(void **bufs, unsigned long buf_count,
			unsigned long buf_size, int advise)
{
	int i, ret;

	for (i = 0; i < buf_count; i++) {
retry:
		if (ret = madvise(bufs[i], buf_size, advise)) {
			perror("fail to madvise\n");
			if (ret == EAGAIN) {
				sleep(1);
				goto retry;
			}
			exit(1);
		}
	}
}

void madvise_free_bufs(void **bufs, unsigned long buf_count,
			unsigned long buf_size)
{
	int i;

	for (i = 0; i < buf_count; i++) {
		if (madvise(bufs[i], buf_size, MADV_FREE)) {
			printf("[%d] bufs[%d] %p madvise_free fail\n",
				pid, i, bufs[i]);
		}
	}
}

void check_madvise_bufs(void **bufs, unsigned long buf_count,
			unsigned long buf_size, int freeable)
{
	int i, j;

	for (i = 0; i < buf_count; i++) {
		char tmp;
		void *buf = bufs[i];

		for (j = 0; j < buf_size; j++) {
			int ret;
			unsigned long addr;

			tmp = *(char*)(buf + j);
			/* The page was not purged */
			if (tmp == 'a' + i)
				continue;

			/* The page was purged */
			if (freeable && (int)tmp == 0)
				continue;

			/* Something wrong happens */
			addr = (unsigned long)(buf + j);
			printf("pid %d bufaddr %p ofs %d freeable %d expected %c but %c\n",
					pid, buf, j, freeable, 'a' + i, tmp);
			exit(1);
		}

	}
}

int main(int argc, char *argv[])
{
	int i, ret, advise;
	unsigned long buf_size, buf_count, loop;
	void **bufs;

	pid = getpid();

	if (argc != 4) {
		printf("check your argument\n");
		return 1;
	}

	buf_size = atol(argv[1]);
	buf_count = atol(argv[2]);
	advise = atol(argv[3]);

	if (buf_size & ((2<<20) - 1)) {
		printf("buf_size should be 2M aligned\n");
		return 1;
	}

	printf("[%d] buf size %ld buf_count %ld advise %d\n",
			pid, buf_size, buf_count, advise);

        if (signal(SIGINT, sig_handler) == SIG_ERR) {
                printf("Fail to register signal handler\n");
                return 1;
        }

        if (signal(SIGHUP, sig_handler) == SIG_ERR) {
                printf("Fail to register signal handler\n");
                return 1;
        }

	bufs = malloc(sizeof(void *) * buf_count);
	if (!bufs)
		return 1;

	memset(bufs, 0, sizeof(void *) * buf_count);

	srandom(pid);

	while (1) {
		int madvise_free = madvise_free = random() % 2;

		alloc_bufs(bufs, buf_count, buf_size);

		fill_bufs(bufs, buf_count, buf_size);

		/* We touched buffers so MADV_FREE cannot free pages */
		check_madvise_bufs(bufs, buf_count, buf_size, 0);

		madvise_bufs(bufs, buf_count, buf_size, advise);

		sleep(1);

		/* syscall MADV_FREE */
		madvise_free_bufs(bufs, buf_count, buf_size);

		sleep(1);

		check_madvise_bufs(bufs, buf_count, buf_size, 1);
		free_bufs(bufs, buf_count, buf_size);
	}

	return 0;
}

--TB36FDmn/VVEgNH/
Content-Type: application/x-sh
Content-Disposition: attachment; filename="oops.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0ANR_THP_PROC=3D$1=0AWAIT_TIME=3D1000000=0A=0A# make anonymo=
us page reclaim easily=0Asudo sh -c "echo 100 > /proc/sys/vm/swappiness"=0A=
=0A# make khugepaged cpu's hogger=0Asudo sh -c "echo madvise > /sys/kernel/=
mm/transparent_hugepage/enabled"=0Asudo sh -c "echo 102400 > /sys/kernel/mm=
/transparent_hugepage/khugepaged/pages_to_scan"=0Asudo sh -c "echo 0 > /sys=
/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs"=0Asudo sh=
 -c "echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_mil=
lisecs"=0A=0A# For v4.0=0AMADV_HUGEPAGE=3D14=0A=0Afor (( i=3D0; i < $NR_THP=
_PROC; i++ ))=0Ado=0A	./oops $((8<<20)) 10 $MADV_HUGEPAGE &=0A	PID=3D$!=0A	=
sudo sh -c "echo -1000 > /proc/$PID/oom_score_adj"=0A	echo "move $PID to /c=
group/testA"=0A	sudo sh -c "echo $PID > /cgroup/testA/tasks"=0Adone=0A=0Asl=
eep $WAIT_TIME=0A=0A# madvise_test will report statistics when it get SIGIN=
T=0Apkill -INT oops=0A
--TB36FDmn/VVEgNH/
Content-Type: application/x-sh
Content-Disposition: attachment; filename="setup_memcg.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0Amount -t cgroup none /cgroup -o memory=0Amkdir /cgroup/tes=
tA=0Amkdir /cgroup/testB=0A=0Aecho 1 > /cgroup/testA/memory.move_charge_at_=
immigrate=0A=0Aecho 1G > /cgroup/testA/memory.limit_in_bytes=0Aecho 3G > /c=
group/testB/memory.limit_in_bytes=0Aecho 0 > /cgroup/testA/tasks=0Aecho 0 >=
 /cgroup/testB/tasks=0A
--TB36FDmn/VVEgNH/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
