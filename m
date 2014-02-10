Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id B1D4B6B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 19:26:50 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so5541211pbb.11
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 16:26:50 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id ui8si13238080pac.119.2014.02.09.16.26.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Feb 2014 16:26:49 -0800 (PST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 24E4D3EE0BD
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:26:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1389945DE65
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:26:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D609145DE60
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:26:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C812FE08003
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:26:47 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77264E08005
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:26:47 +0900 (JST)
Message-ID: <52F81C5D.6010601@jp.fujitsu.com>
Date: Mon, 10 Feb 2014 09:25:01 +0900
From: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: mm: memcg: A infinite loop in __handle_mm_fault()
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi,

This is a bug report for memory cgroup hang up.
I reproduced this using 3.14-rc1 but I couldn't in 3.7.

When I ran a program (see below) under a limit of memcg, the process hanged up.
Using kprobe trace, I detected the hangup in __handle_mm_fault().
do_huge_pmd_wp_page(), which is called by __handle_mm_fault(), always returns
VM_FAULT_OOM, so it repeats goto retry and the task can't be killed.
--------------------------------------------------
static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
                             unsigned long address, unsigned int flags)
{Hi all,

This is a bug report for memory cgroup hang up.
I reproduced this using 3.14-rc1 but I couldn't in 3.7.

When I ran a program (see below) under a limit of memcg, the process hangs up.
Using kprobe trace, I detected the hangup in __handle_mm_fault().
do_huge_pmd_wp_page(), which is called by __handle_mm_fault(), always returns
VM_FAULT_OOM but the task can't be killed.
It seems to be in infinite loop and the process is never killed.

--------------------------------------------------
static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
                             unsigned long address, unsigned int flags)
{
...
retry:
        pgd = pgd_offset(mm, address);
...
                        if (dirty && !pmd_write(orig_pmd)) {
                                ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
                                                          orig_pmd);
                                /*
                                 * If COW results in an oom, the huge pmd will
                                 * have been split, so retry the fault on the
                                 * pte for a smaller charge.
                                 */
                                if (unlikely(ret & VM_FAULT_OOM))
                                        goto retry;
--------------------------------------------------

[Step to reproduce]

1. Set memory cgroup as follows:

--------------------------------------------------
# mkdir /sys/fs/cgroup/memory/test
# echo "6M" > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
# echo "6M" > /sys/fs/cgroup/memory/test/memory.memsw.limit_in_bytes 
--------------------------------------------------

2. Ran the following process (test.c).

test.c:
--------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#define SIZE 4*1024*1024
#define HUGE 2*1024*1024
#define PAGESIZE 4096
#define NUM SIZE/PAGESIZE

int main(void)
{
	char *a;
	char *c;
	int i;

	/* wait until set cgroup limits */
	sleep(1);

	posix_memalign((void **)&a, HUGE, SIZE);
	posix_memalign((void **)&c, HUGE, SIZE);

	for (i = 0; i<NUM; i++) {
		*(a + i * PAGESIZE) = *(c + i * PAGESIZE);
	}

	for (i = 0; i<NUM; i++) {
		*(c + i * PAGESIZE) = *(a + i * PAGESIZE);
	}

	free(a);
	free(c);
	return 0;
}
--------------------------------------------------

3. Add it to memory cgroup.
--------------------------------------------------
# ./test &
# echo $! > /sys/fs/cgroup/memory/test/tasks
--------------------------------------------------

Then, the process will hangup.
I checked the infinit loop by using kprobetrace.

Setting of kprobetrace:
--------------------------------------------------
# echo 'p:do_huge_pmd_wp_page do_huge_pmd_wp_page address=%dx' > /sys/kernel/debug/tracing/kprobe_events
# echo 'r:do_huge_pmd_wp_page_r do_huge_pmd_wp_page ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:mem_cgroup_newpage_charge mem_cgroup_newpage_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:mem_cgroup_charge_common mem_cgroup_charge_common ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:__mem_cgroup_try_charge __mem_cgroup_try_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page_r/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_newpage_charge/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_charge_common/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/__mem_cgroup_try_charge/enable
--------------------------------------------------

The result:
--------------------------------------------------
test-2721  [001] dN..  2530.635679: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
test-2721  [001] dN..  2530.635723: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635724: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
test-2721  [001] dN..  2530.635725: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635733: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
test-2721  [001] dN..  2530.635735: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
test-2721  [001] dN..  2530.635761: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635761: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
test-2721  [001] dN..  2530.635762: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635768: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
(...repeat...)
--------------------------------------------------

Regards,
Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
...
retry:
        pgd = pgd_offset(mm, address);
...
                        if (dirty && !pmd_write(orig_pmd)) {
                                ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
                                                          orig_pmd);
                                /*
                                 * If COW results in an oom, the huge pmd will
                                 * have been split, so retry the fault on the
                                 * pte for a smaller charge.
                                 */
                                if (unlikely(ret & VM_FAULT_OOM))
                                        goto retry;
--------------------------------------------------

[Step to reproduce]

1. Set memory cgroup as follows:

--------------------------------------------------
# mkdir /sys/fs/cgroup/memory/test
# echo "6M" > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
# echo "6M" > /sys/fs/cgroup/memory/test/memory.memsw.limit_in_bytes 
--------------------------------------------------

2. Ran the following process (test.c).

test.c:
--------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#define SIZE 4*1024*1024
#define HUGE 2*1024*1024
#define PAGESIZE 4096
#define NUM SIZE/PAGESIZE

int main(void)
{
	char *a;
	char *c;
	int i;

	/* wait until set cgroup limits */
	sleep(1);

	posix_memalign((void **)&a, HUGE, SIZE);
	posix_memalign((void **)&c, HUGE, SIZE);

	for (i = 0; i<NUM; i++) {
		*(a + i * PAGESIZE) = *(c + i * PAGESIZE);
	}

	for (i = 0; i<NUM; i++) {
		*(c + i * PAGESIZE) = *(a + i * PAGESIZE);
	}

	free(a);
	free(c);
	return 0;
}
--------------------------------------------------

3. Add it to memory cgroup.
--------------------------------------------------
# ./test &
# echo $! > /sys/fs/cgroup/memory/test/tasks
--------------------------------------------------

Then, the process will hangup.
I checked the infinit loop by using kprobetrace.

Setting of kprobetrace:
--------------------------------------------------
# echo 'p:do_huge_pmd_wp_page do_huge_pmd_wp_page address=%dx' > /sys/kernel/debug/tracing/kprobe_events
# echo 'r:do_huge_pmd_wp_page_r do_huge_pmd_wp_page ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:mem_cgroup_newpage_charge mem_cgroup_newpage_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:mem_cgroup_charge_common mem_cgroup_charge_common ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 'r:__mem_cgroup_try_charge __mem_cgroup_try_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page_r/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_newpage_charge/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_charge_common/enable
# echo 1 > /sys/kernel/debug/tracing/events/kprobes/__mem_cgroup_try_charge/enable
--------------------------------------------------

The result:
--------------------------------------------------
test-2721  [001] dN..  2530.635679: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
test-2721  [001] dN..  2530.635723: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635724: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
test-2721  [001] dN..  2530.635725: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635733: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
test-2721  [001] dN..  2530.635735: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
test-2721  [001] dN..  2530.635761: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635761: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
test-2721  [001] dN..  2530.635762: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
test-2721  [001] dN..  2530.635768: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
(...repeat...)
--------------------------------------------------

Regards,
Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
