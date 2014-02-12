Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 05D046B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 20:07:16 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so8510015pbc.32
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 17:07:16 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id fl7si20700866pad.142.2014.02.11.17.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 17:07:16 -0800 (PST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6931A3EE1B9
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:07:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5572945DE5A
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:07:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CE1145DE53
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:07:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E2901DB8047
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:07:14 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD8711DB803C
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:07:13 +0900 (JST)
Message-ID: <52FAC8A2.1080607@jp.fujitsu.com>
Date: Wed, 12 Feb 2014 10:04:34 +0900
From: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mm: memcg: A infinite loop in __handle_mm_fault()
References: <52F81C5D.6010601@jp.fujitsu.com> <20140210111928.GA7117@dhcp22.suse.cz> <20140210125655.4AB48E0090@blue.fi.intel.com>
In-Reply-To: <20140210125655.4AB48E0090@blue.fi.intel.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, 10 Feb 2014 14:56:55 +0200 Kirill A. Shutemov wrote:
> Michal Hocko wrote:
>> [CCing Kirill]
>>
>> On Mon 10-02-14 09:25:01, Mizuma, Masayoshi wrote:
>>> Hi,
>>
>> Hi,
>>
>>> This is a bug report for memory cgroup hang up.
>>> I reproduced this using 3.14-rc1 but I couldn't in 3.7.
>>>
>>> When I ran a program (see below) under a limit of memcg, the process hanged up.
>>> Using kprobe trace, I detected the hangup in __handle_mm_fault().
>>> do_huge_pmd_wp_page(), which is called by __handle_mm_fault(), always returns
>>> VM_FAULT_OOM, so it repeats goto retry and the task can't be killed.
>>
>> Thanks a lot for this very good report. I would bet the issue is related
>> to the THP zero page.
>>
>> __handle_mm_fault retry loop for VM_FAULT_OOM from do_huge_pmd_wp_page
>> expects that the pmd is marked for splitting so that it can break out
>> and retry the fault. This is not the case for THP zero page though.
>> do_huge_pmd_wp_page checks is_huge_zero_pmd and goes to allocate a new
>> huge page which will succeed in your case because you are hitting memcg
>> limit not the global memory pressure. But then a new page is charged by
>> mem_cgroup_newpage_charge which fails. An existing page is then split
>> and we are returning VM_FAULT_OOM. But we do not have page initialized
>> in that path because page = pmd_page(orig_pmd) is called after
>> is_huge_zero_pmd check.
>>
>> I am not familiar with THP zero page code much but I guess splitting
>> such a zero page is not a way to go. Instead we should simply drop the
>> zero page and retry the fault. I would assume that one of
>> do_huge_pmd_wp_zero_page_fallback or do_huge_pmd_wp_page_fallback should
>> do the trick but both of them try to charge new page(s) before the
>> current zero page is uncharged. That makes it prone to the same issue
>> AFAICS.
>>
>> But may be Kirill has a better idea.
> 
> Your analysis looks accurate. Although I was not able to reproduce
> hang up.
> 
> The problem with do_huge_pmd_wp_zero_page_fallback() that it can return
> VM_FAULT_OOM if it failed to allocate new *small* page, so it's real OOM.
> 
> Untested patch below tries to fix. Masayoshi, could you test.

I applied the patch to 3.14-rc2.
Then, I confirmed this issue does not happen and the process is killed by
oom-killer normally.
Thank you for analyzing the root cause and providing the fix!

Regards,
Masayoshi Mizuma

> 
> BTW, Michal, I've triggered sleep-in-atomic bug in
> mem_cgroup_print_oom_info():
> 
> [    2.386563] Task in /test killed as a result of limit of /test
> [    2.387326] memory: usage 10240kB, limit 10240kB, failcnt 51
> [    2.388098] memory+swap: usage 10240kB, limit 10240kB, failcnt 0
> [    2.388861] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> [    2.389640] Memory cgroup stats for /test:
> [    2.390178] BUG: sleeping function called from invalid context at /home/space/kas/git/public/linux/kernel/cpu.c:68
> [    2.391516] in_atomic(): 1, irqs_disabled(): 0, pid: 66, name: memcg_test
> [    2.392416] 2 locks held by memcg_test/66:
> [    2.392945]  #0:  (memcg_oom_lock#2){+.+...}, at: [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
> [    2.394233]  #1:  (oom_info_lock){+.+...}, at: [<ffffffff81197b2a>] mem_cgroup_print_oom_info+0x2a/0x390
> [    2.395496] CPU: 2 PID: 66 Comm: memcg_test Not tainted 3.14.0-rc1-dirty #745
> [    2.396536] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Bochs 01/01/2011
> [    2.397540]  ffffffff81a3cc90 ffff88081d26dba0 ffffffff81776ea3 0000000000000000
> [    2.398541]  ffff88081d26dbc8 ffffffff8108418a 0000000000000000 ffff88081d15c000
> [    2.399533]  0000000000000000 ffff88081d26dbd8 ffffffff8104f6bc ffff88081d26dc10
> [    2.400588] Call Trace:
> [    2.400908]  [<ffffffff81776ea3>] dump_stack+0x4d/0x66
> [    2.401578]  [<ffffffff8108418a>] __might_sleep+0x16a/0x210
> [    2.402295]  [<ffffffff8104f6bc>] get_online_cpus+0x1c/0x60
> [    2.403005]  [<ffffffff8118fb67>] mem_cgroup_read_stat+0x27/0xb0
> [    2.403769]  [<ffffffff81197d60>] mem_cgroup_print_oom_info+0x260/0x390
> [    2.404653]  [<ffffffff8177314e>] dump_header+0x88/0x251
> [    2.405342]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
> [    2.406098]  [<ffffffff81130618>] oom_kill_process+0x258/0x3d0
> [    2.406833]  [<ffffffff81198746>] mem_cgroup_oom_synchronize+0x656/0x6c0
> [    2.407674]  [<ffffffff811973a0>] ? mem_cgroup_charge_common+0xd0/0xd0
> [    2.408553]  [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
> [    2.409354]  [<ffffffff817712f7>] mm_fault_error+0x91/0x189
> [    2.410069]  [<ffffffff81783eae>] __do_page_fault+0x48e/0x580
> [    2.410791]  [<ffffffff8108f656>] ? local_clock+0x16/0x30
> [    2.411467]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
> [    2.412248]  [<ffffffff8177f6fc>] ? _raw_spin_unlock_irq+0x2c/0x40
> [    2.413039]  [<ffffffff8108312b>] ? finish_task_switch+0x7b/0x100
> [    2.413821]  [<ffffffff813b954a>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> [    2.414652]  [<ffffffff81783fae>] do_page_fault+0xe/0x10
> [    2.415330]  [<ffffffff81780552>] page_fault+0x22/0x30
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 82166bf974e1..974eb9eea2c0 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1166,8 +1166,10 @@ alloc:
>   		} else {
>   			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
>   					pmd, orig_pmd, page, haddr);
> -			if (ret & VM_FAULT_OOM)
> +			if (ret & VM_FAULT_OOM) {
>   				split_huge_page(page);
> +				ret |= VM_FAULT_FALLBACK;
> +			}
>   			put_page(page);
>   		}
>   		count_vm_event(THP_FAULT_FALLBACK);
> @@ -1179,9 +1181,12 @@ alloc:
>   		if (page) {
>   			split_huge_page(page);
>   			put_page(page);
> +			ret |= VM_FAULT_FALLBACK;
> +		} else {
> +			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
> +					address, pmd, orig_pmd, haddr);
>   		}
>   		count_vm_event(THP_FAULT_FALLBACK);
> -		ret |= VM_FAULT_OOM;
>   		goto out;
>   	}
>   
> diff --git a/mm/memory.c b/mm/memory.c
> index be6a0c0d4ae0..3b57b7864667 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3703,7 +3703,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   	if (unlikely(is_vm_hugetlb_page(vma)))
>   		return hugetlb_fault(mm, vma, address, flags);
>   
> -retry:
>   	pgd = pgd_offset(mm, address);
>   	pud = pud_alloc(mm, pgd, address);
>   	if (!pud)
> @@ -3741,20 +3740,13 @@ retry:
>   			if (dirty && !pmd_write(orig_pmd)) {
>   				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
>   							  orig_pmd);
> -				/*
> -				 * If COW results in an oom, the huge pmd will
> -				 * have been split, so retry the fault on the
> -				 * pte for a smaller charge.
> -				 */
> -				if (unlikely(ret & VM_FAULT_OOM))
> -					goto retry;
> -				return ret;
> +				if (!(ret & VM_FAULT_FALLBACK))
> +					return ret;
>   			} else {
>   				huge_pmd_set_accessed(mm, vma, address, pmd,
>   						      orig_pmd, dirty);
> +				return 0;
>   			}
> -
> -			return 0;
>   		}
>   	}
>   
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
