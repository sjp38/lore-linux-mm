Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3F76B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 09:20:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v140so7502202ita.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 06:20:08 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h204si6037571oia.174.2017.09.19.06.20.05
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 06:20:06 -0700 (PDT)
Date: Tue, 19 Sep 2017 14:18:39 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: userfaultfd use-after-free
Message-ID: <20170919131839.GD30715@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, syzkaller@googlegroups.com

Hi,

Syzkaller found a use-after-free in the userfaultfd code, which is very
easy to trigger on x86_64 and arm64 in v4.13 and v4.14-rc1. I believe
this may go as far back as v4.10, when fork events were introduced.

While fuzzing I've been seeing some other intermittent memory corruption bugs
which I believe are related -- I only tracked this down to userfaultfd after
enabling both KASAN and DEBUG_LIST.

I've included an example log, a (hopefully legible) C reproducer, and Syzkaller
reproducer below. These can also be found on my kernel.org web space, along
with other logs, configs, etc:

  https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20170919-userfaultfd-uaf/

Thanks,
Mark.

arm64 log (v4.13)
----
[    3.286772] ==================================================================
[    3.288470] BUG: KASAN: use-after-free in __list_del_entry_valid+0x148/0x188
[    3.290230] Read of size 8 at addr ffff80000af53b40 by task repro/1374
[    3.291682]
[    3.292099] CPU: 2 PID: 1374 Comm: repro Not tainted 4.13.0 #47
[    3.293653] Hardware name: linux,dummy-virt (DT)
[    3.294862] Call trace:
[    3.295506] [<ffff20000808fd00>] dump_backtrace+0x0/0x420
[    3.296887] [<ffff2000080903ec>] show_stack+0x14/0x20
[    3.298173] [<ffff2000098c1424>] dump_stack+0xcc/0xf8
[    3.299463] [<ffff2000083dc2c0>] print_address_description+0x60/0x250
[    3.301101] [<ffff2000083dc7b0>] kasan_report+0x238/0x2f8
[    3.302474] [<ffff2000083dc8e8>] __asan_report_load8_noabort+0x18/0x20
[    3.304144] [<ffff2000088d74a0>] __list_del_entry_valid+0x148/0x188
[    3.305734] [<ffff2000084dc5d8>] userfaultfd_event_wait_completion+0x278/0x568
[    3.307567] [<ffff2000084e0f38>] dup_userfaultfd_complete+0x110/0x290
[    3.309205] [<ffff200008114df4>] copy_process.isra.6.part.7+0x39b4/0x4768
[    3.310920] [<ffff200008115f60>] _do_fork+0x120/0x590
[    3.312209] [<ffff200008116498>] SyS_clone+0x18/0x20
[    3.313471] [<ffff200008083f30>] el0_svc_naked+0x24/0x28
[    3.314816]
[    3.315212] The buggy address belongs to the page:
[    3.316439] page:ffff7e00002bd4c0 count:0 mapcount:0 mapping:          (null) index:0x0
[    3.318456] flags: 0xfffc00000000000()
[    3.319208] raw: 0fffc00000000000 0000000000000000 0000000000000000 00000000ffffffff
[    3.321177] raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
[    3.323125] page dumped because: kasan: bad access detected
[    3.324542]
[    3.324938] Memory state around the buggy address:
[    3.326155]  ffff80000af53a00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[    3.327983]  ffff80000af53a80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[    3.329808] >ffff80000af53b00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[    3.331635]                                            ^
[    3.332980]  ffff80000af53b80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[    3.334801]  ffff80000af53c00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[    3.336627] ==================================================================
[    3.338447] Disabling lock debugging due to kernel taint
[    3.339915] Kernel panic - not syncing: panic_on_warn set ...
[    3.339915]
[    3.341081] CPU: 2 PID: 1374 Comm: repro Tainted: G    B           4.13.0 #47
[    3.342884] Hardware name: linux,dummy-virt (DT)
[    3.344062] Call trace:
[    3.344698] [<ffff20000808fd00>] dump_backtrace+0x0/0x420
[    3.346066] [<ffff2000080903ec>] show_stack+0x14/0x20
[    3.347346] [<ffff2000098c1424>] dump_stack+0xcc/0xf8
[    3.348637] [<ffff2000081179c4>] panic+0x1e4/0x358
[    3.349855] [<ffff2000083dc230>] kasan_save_enable_multi_shot+0x0/0x30
[    3.351504] [<ffff2000083dc66c>] kasan_report+0xf4/0x2f8
[    3.352860] [<ffff2000083dc8e8>] __asan_report_load8_noabort+0x18/0x20
[    3.354509] [<ffff2000088d74a0>] __list_del_entry_valid+0x148/0x188
[    3.356101] [<ffff2000084dc5d8>] userfaultfd_event_wait_completion+0x278/0x568
[    3.357920] [<ffff2000084e0f38>] dup_userfaultfd_complete+0x110/0x290
[    3.359553] [<ffff200008114df4>] copy_process.isra.6.part.7+0x39b4/0x4768
[    3.361267] [<ffff200008115f60>] _do_fork+0x120/0x590
[    3.362549] [<ffff200008116498>] SyS_clone+0x18/0x20
[    3.363815] [<ffff200008083f30>] el0_svc_naked+0x24/0x28
[    3.365161] SMP: stopping secondary CPUs
[    3.366180] Kernel Offset: disabled
[    3.366784] CPU features: 0x002082
[    3.367362] Memory Limit: none
[    3.367897] Rebooting in 86400 seconds..
----

Syzkaller reproducer
----
mmap(&(0x7f0000000000/0xc72000)=nil, 0xc72000, 0x3, 0x32, 0xffffffffffffffff, 0x0)
r0 = userfaultfd(0x0)
ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000c08000-0x18)={0xaa, 0x2, 0x0})
setrlimit(0x7, &(0x7f0000000000)={0x0, 0x0})
ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000010000)={{&(0x7f0000007000/0x3000)=nil, 0x3000}, 0x1, 0x0})
read(r0, &(0x7f0000015000-0x1000)="0000000000000000000000000000000000000000000000000000000000000000", 0x20)
clone(0x1000000, &(0x7f0000006000)="", &(0x7f0000012000)=0x0, &(0x7f0000014000-0x4)=0x0, &(0x7f0000011000-0x25)="")
----

C reproducer
----
#include <linux/userfaultfd.h>
#include <pthread.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int userfaultfd(int flags)
{
	return syscall(__NR_userfaultfd, flags);
}

// Only exists since v4.10, so not in most distro headers...
#ifndef UFFD_FEATURE_EVENT_FORK
#define UFFD_FEATURE_EVENT_FORK 2
#endif

// Arbitrary; needs to be some PAGE_SIZE multiple
#define REGION_SIZE	(2 * 1024 * 1024)

int uffd_setup(void *base, size_t size)
{
	int uffd;
	struct uffdio_api ufa = {
		.api = UFFD_API,
		.features = UFFD_FEATURE_EVENT_FORK,
		.ioctls = 0,
	};
	struct uffdio_register ufr = {
		.range.start = (unsigned long)base,
		.range.len = size,
		.mode = UFFDIO_REGISTER_MODE_MISSING,
		.ioctls = 0,
	};
	
	uffd = userfaultfd(0);
	ioctl(uffd, UFFDIO_API, &ufa);
	ioctl(uffd, UFFDIO_REGISTER, &ufr);

	return uffd;
}

void *thr_uffd(void *unused)
{
	void *base;
	int uffd;
	struct uffd_msg msg;
	struct rlimit rlimit;

	base = mmap(NULL, REGION_SIZE, PROT_READ | PROT_WRITE,
		    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

	uffd = uffd_setup(base, REGION_SIZE);

	rlimit.rlim_cur = 0;
	rlimit.rlim_max = 0;
	setrlimit(RLIMIT_NOFILE, &rlimit);

	read(uffd, &msg, sizeof(msg));

	return NULL;
}

void *thr_clone(void *unused)
{
	fork();
	return NULL;
}

int main(int argc, char *argv[])
{
	pthread_t p_uffd, p_clone;

	pthread_create(&p_uffd, 0, thr_uffd, NULL);
	usleep(1000);
	pthread_create(&p_clone, 0, thr_clone, NULL);
	usleep(1000);

	return 0;
}
----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
