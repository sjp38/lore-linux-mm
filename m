Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 425B26B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:51:55 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so6125023pab.9
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 03:51:54 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id d4si15101625pao.244.2014.02.10.03.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 03:51:53 -0800 (PST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A05F23EE1A4
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 20:51:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EEFA45DE65
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 20:51:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7576E45DE5C
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 20:51:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61701E0800D
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 20:51:51 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 080A0E08008
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 20:51:51 +0900 (JST)
Message-ID: <52F8BD24.8020009@jp.fujitsu.com>
Date: Mon, 10 Feb 2014 20:51:00 +0900
From: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mm: memcg: A infinite loop in __handle_mm_fault()
References: <52F81C5D.6010601@jp.fujitsu.com> <20140210111928.GA7117@dhcp22.suse.cz>
In-Reply-To: <20140210111928.GA7117@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>



(2014/02/10 20:19), Michal Hocko wrote:
> [CCing Kirill]
>
> On Mon 10-02-14 09:25:01, Mizuma, Masayoshi wrote:
>> Hi,
>
> Hi,

Thank you for response and sorry for my broken mail text (I mistook copy and paste...).

>
>> This is a bug report for memory cgroup hang up.
>> I reproduced this using 3.14-rc1 but I couldn't in 3.7.
>>
>> When I ran a program (see below) under a limit of memcg, the process hanged up.
>> Using kprobe trace, I detected the hangup in __handle_mm_fault().
>> do_huge_pmd_wp_page(), which is called by __handle_mm_fault(), always returns
>> VM_FAULT_OOM, so it repeats goto retry and the task can't be killed.
>
> Thanks a lot for this very good report. I would bet the issue is related
> to the THP zero page.
>
> __handle_mm_fault retry loop for VM_FAULT_OOM from do_huge_pmd_wp_page
> expects that the pmd is marked for splitting so that it can break out
> and retry the fault. This is not the case for THP zero page though.
> do_huge_pmd_wp_page checks is_huge_zero_pmd and goes to allocate a new
> huge page which will succeed in your case because you are hitting memcg
> limit not the global memory pressure. But then a new page is charged by
> mem_cgroup_newpage_charge which fails. An existing page is then split
> and we are returning VM_FAULT_OOM. But we do not have page initialized
> in that path because page = pmd_page(orig_pmd) is called after
> is_huge_zero_pmd check.
>
> I am not familiar with THP zero page code much but I guess splitting
> such a zero page is not a way to go. Instead we should simply drop the
> zero page and retry the fault. I would assume that one of
> do_huge_pmd_wp_zero_page_fallback or do_huge_pmd_wp_page_fallback should
> do the trick but both of them try to charge new page(s) before the
> current zero page is uncharged. That makes it prone to the same issue
> AFAICS.
>
> But may be Kirill has a better idea.

I think this issue is related to THP, too. Because, it is not reproduced when
THP is disabled as following.

# echo never > /sys/kernel/mm/transparent_hugepage/enabled

Regards,
Masayoshi Mizuma

>
> But may be Kirill has a better idea.
>
>> --------------------------------------------------
>> static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>>                               unsigned long address, unsigned int flags)
>> {Hi all,
>>
>> This is a bug report for memory cgroup hang up.
>> I reproduced this using 3.14-rc1 but I couldn't in 3.7.
>>
>> When I ran a program (see below) under a limit of memcg, the process hangs up.
>> Using kprobe trace, I detected the hangup in __handle_mm_fault().
>> do_huge_pmd_wp_page(), which is called by __handle_mm_fault(), always returns
>> VM_FAULT_OOM but the task can't be killed.
>> It seems to be in infinite loop and the process is never killed.
>>
>> --------------------------------------------------
>> static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>>                               unsigned long address, unsigned int flags)
>> {
>> ...
>> retry:
>>          pgd = pgd_offset(mm, address);
>> ...
>>                          if (dirty && !pmd_write(orig_pmd)) {
>>                                  ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
>>                                                            orig_pmd);
>>                                  /*
>>                                   * If COW results in an oom, the huge pmd will
>>                                   * have been split, so retry the fault on the
>>                                   * pte for a smaller charge.
>>                                   */
>>                                  if (unlikely(ret & VM_FAULT_OOM))
>>                                          goto retry;
>> --------------------------------------------------
>>
>> [Step to reproduce]
>>
>> 1. Set memory cgroup as follows:
>>
>> --------------------------------------------------
>> # mkdir /sys/fs/cgroup/memory/test
>> # echo "6M" > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>> # echo "6M" > /sys/fs/cgroup/memory/test/memory.memsw.limit_in_bytes
>> --------------------------------------------------
>>
>> 2. Ran the following process (test.c).
>>
>> test.c:
>> --------------------------------------------------
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <unistd.h>
>> #define SIZE 4*1024*1024
>> #define HUGE 2*1024*1024
>> #define PAGESIZE 4096
>> #define NUM SIZE/PAGESIZE
>>
>> int main(void)
>> {
>> 	char *a;
>> 	char *c;
>> 	int i;
>>
>> 	/* wait until set cgroup limits */
>> 	sleep(1);
>>
>> 	posix_memalign((void **)&a, HUGE, SIZE);
>> 	posix_memalign((void **)&c, HUGE, SIZE);
>>
>> 	for (i = 0; i<NUM; i++) {
>> 		*(a + i * PAGESIZE) = *(c + i * PAGESIZE);
>> 	}
>>
>> 	for (i = 0; i<NUM; i++) {
>> 		*(c + i * PAGESIZE) = *(a + i * PAGESIZE);
>> 	}
>>
>> 	free(a);
>> 	free(c);
>> 	return 0;
>> }
>> --------------------------------------------------
>>
>> 3. Add it to memory cgroup.
>> --------------------------------------------------
>> # ./test &
>> # echo $! > /sys/fs/cgroup/memory/test/tasks
>> --------------------------------------------------
>>
>> Then, the process will hangup.
>> I checked the infinit loop by using kprobetrace.
>>
>> Setting of kprobetrace:
>> --------------------------------------------------
>> # echo 'p:do_huge_pmd_wp_page do_huge_pmd_wp_page address=%dx' > /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:do_huge_pmd_wp_page_r do_huge_pmd_wp_page ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:mem_cgroup_newpage_charge mem_cgroup_newpage_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:mem_cgroup_charge_common mem_cgroup_charge_common ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:__mem_cgroup_try_charge __mem_cgroup_try_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page_r/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_newpage_charge/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_charge_common/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/__mem_cgroup_try_charge/enable
>> --------------------------------------------------
>>
>> The result:
>> --------------------------------------------------
>> test-2721  [001] dN..  2530.635679: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
>> test-2721  [001] dN..  2530.635723: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635724: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635725: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635733: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
>> test-2721  [001] dN..  2530.635735: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
>> test-2721  [001] dN..  2530.635761: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635761: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635762: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635768: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
>> (...repeat...)
>> --------------------------------------------------
>>
>> Regards,
>> Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>> ...
>> retry:
>>          pgd = pgd_offset(mm, address);
>> ...
>>                          if (dirty && !pmd_write(orig_pmd)) {
>>                                  ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
>>                                                            orig_pmd);
>>                                  /*
>>                                   * If COW results in an oom, the huge pmd will
>>                                   * have been split, so retry the fault on the
>>                                   * pte for a smaller charge.
>>                                   */
>>                                  if (unlikely(ret & VM_FAULT_OOM))
>>                                          goto retry;
>> --------------------------------------------------
>>
>> [Step to reproduce]
>>
>> 1. Set memory cgroup as follows:
>>
>> --------------------------------------------------
>> # mkdir /sys/fs/cgroup/memory/test
>> # echo "6M" > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>> # echo "6M" > /sys/fs/cgroup/memory/test/memory.memsw.limit_in_bytes
>> --------------------------------------------------
>>
>> 2. Ran the following process (test.c).
>>
>> test.c:
>> --------------------------------------------------
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <unistd.h>
>> #define SIZE 4*1024*1024
>> #define HUGE 2*1024*1024
>> #define PAGESIZE 4096
>> #define NUM SIZE/PAGESIZE
>>
>> int main(void)
>> {
>> 	char *a;
>> 	char *c;
>> 	int i;
>>
>> 	/* wait until set cgroup limits */
>> 	sleep(1);
>>
>> 	posix_memalign((void **)&a, HUGE, SIZE);
>> 	posix_memalign((void **)&c, HUGE, SIZE);
>>
>> 	for (i = 0; i<NUM; i++) {
>> 		*(a + i * PAGESIZE) = *(c + i * PAGESIZE);
>> 	}
>>
>> 	for (i = 0; i<NUM; i++) {
>> 		*(c + i * PAGESIZE) = *(a + i * PAGESIZE);
>> 	}
>>
>> 	free(a);
>> 	free(c);
>> 	return 0;
>> }
>> --------------------------------------------------
>>
>> 3. Add it to memory cgroup.
>> --------------------------------------------------
>> # ./test &
>> # echo $! > /sys/fs/cgroup/memory/test/tasks
>> --------------------------------------------------
>>
>> Then, the process will hangup.
>> I checked the infinit loop by using kprobetrace.
>>
>> Setting of kprobetrace:
>> --------------------------------------------------
>> # echo 'p:do_huge_pmd_wp_page do_huge_pmd_wp_page address=%dx' > /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:do_huge_pmd_wp_page_r do_huge_pmd_wp_page ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:mem_cgroup_newpage_charge mem_cgroup_newpage_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:mem_cgroup_charge_common mem_cgroup_charge_common ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 'r:__mem_cgroup_try_charge __mem_cgroup_try_charge ret=$retval' >> /sys/kernel/debug/tracing/kprobe_events
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/do_huge_pmd_wp_page_r/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_newpage_charge/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/mem_cgroup_charge_common/enable
>> # echo 1 > /sys/kernel/debug/tracing/events/kprobes/__mem_cgroup_try_charge/enable
>> --------------------------------------------------
>>
>> The result:
>> --------------------------------------------------
>> test-2721  [001] dN..  2530.635679: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
>> test-2721  [001] dN..  2530.635723: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635724: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635725: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635733: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
>> test-2721  [001] dN..  2530.635735: do_huge_pmd_wp_page: (do_huge_pmd_wp_page+0x0/0xa90) address=0x7f55a4400000
>> test-2721  [001] dN..  2530.635761: __mem_cgroup_try_charge: (mem_cgroup_charge_common+0x4a/0xa0 <- __mem_cgroup_try_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635761: mem_cgroup_charge_common: (mem_cgroup_newpage_charge+0x26/0x30 <- mem_cgroup_charge_common) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635762: mem_cgroup_newpage_charge: (do_huge_pmd_wp_page+0x125/0xa90 <- mem_cgroup_newpage_charge) ret=0xfffffff4
>> test-2721  [001] dN..  2530.635768: do_huge_pmd_wp_page_r: (handle_mm_fault+0x19e/0x4b0 <- do_huge_pmd_wp_page) ret=0x1
>> (...repeat...)
>> --------------------------------------------------
>>
>> Regards,
>> Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
