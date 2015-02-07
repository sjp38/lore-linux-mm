Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id AE72E6B00A8
	for <linux-mm@kvack.org>; Sat,  7 Feb 2015 17:27:40 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id i50so15807745qgf.0
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 14:27:40 -0800 (PST)
Received: from remote.erley.org ([2600:3c03:e000:15::1])
        by mx.google.com with ESMTP id j10si8211750qga.33.2015.02.07.14.27.39
        for <linux-mm@kvack.org>;
        Sat, 07 Feb 2015 14:27:39 -0800 (PST)
Message-ID: <54D69157.9040700@erley.org>
Date: Sat, 07 Feb 2015 16:27:35 -0600
From: Pat Erley <pat-lkml@erley.org>
MIME-Version: 1.0
Subject: Re: BUG: non-zero nr_pmds on freeing mm: 1
References: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>	<CA+icZUVt_8wquKTq=A0tE7erL5iqQ7KsVDiJg_2CXd0Fu-VkcQ@mail.gmail.com>	<54D5D348.70408@erley.org>	<CA+icZUXPukpUw_xBsK9An+7KL_gyyyWSV7a_ip6uB8kJjTFoHg@mail.gmail.com> <CA+icZUXJ=H+X2toQW4LksxaqBvyZyco=scT_OoV=bAG6ScuwMg@mail.gmail.com>
In-Reply-To: <CA+icZUXJ=H+X2toQW4LksxaqBvyZyco=scT_OoV=bAG6ScuwMg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Linux-Next <linux-next@vger.kernel.org>, kirill.shutemov@linux.intel.com, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On 02/07/2015 03:30 AM, Sedat Dilek wrote:
> On Sat, Feb 7, 2015 at 10:20 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>> On Sat, Feb 7, 2015 at 9:56 AM, Pat Erley <pat-lkml@erley.org> wrote:
>>> On 02/07/2015 02:42 AM, Sedat Dilek wrote:
>>>>
>>>> On Sat, Feb 7, 2015 at 8:33 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>>>>
>>>>> On Sat, Feb 7, 2015 at 6:12 AM, Pat Erley <pat-lkml@erley.org> wrote:
>>>>>>
>>>>>> I'm seeing the message in $subject on my Xen DOM0 on next-20150204 on
>>>>>> x86_64.  I haven't had time to bisect it, but have seen some discussion
>>>>>> on
>>>>>> similar topics here recently.  I can trigger this pretty reliably by
>>>>>> watching Netflix.  At some point (minutes to hours) into it, the netflix
>>>>>> video goes black (audio keeps going, so it still thinks it's working)
>>>>>> and
>>>>>> the error appears in dmesg.  Refreshing the page gets the video going
>>>>>> again,
>>>>>> and it will continue playing for some indeterminate amount of time.
>>>>>>
>>>>>> Kirill, I've CC'd you as looking in the logs, you've patched a false
>>>>>> positive trigger of this very recently(patch in kernel I'm running).  Am
>>>>>> I
>>>>>> actually hitting a problem, or is this another false positive case? Any
>>>>>> additional details that might help?
>>>>>>
>>>>>> Dmesg from system attached.
>>>>>
>>>>>
>>>>> [ CC some mm folks ]
>>>>>
>>>>> I have seen this, too.
>>>>>
>>>>> root# grep "BUG: non-zero nr_pmds on freeing mm:" /var/log/kern.log | wc
>>>>> -l
>>>>> 21
>>>>>
>>>>> Checking my logs: On next-20150203 and next-20150204.
>>>>>
>>>>> I am here not in a VM environment and cannot say what causes these
>>>>> messages.
>>>>>
>>>>
>>>> I checked a bit the logs and commits in mm.git and linux-next.git.
>>>>
>>>> [1] lists:
>>>>
>>>> Kirill A. Shutemov (1): mm: do not use mm->nr_pmds on !MMU configurations
>>>>
>>>> NOTE: next-20150204 has this commit, but next-20150203 not (seen the
>>>> BUG: line in both releases).
>>>>
>>>> Looking at Kirill's commit...
>>>>
>>>> At my 1st quick look I thought Kirill mixed mm_nr_pmds_init() in the
>>>> case of defined(__PAGETABLE_PMD_FOLDED), but I was wrong.
>>>>
>>>> @@ -1440,13 +1440,15 @@ static inline int __pud_alloc(struct mm_struct
>>>> *mm, pgd_t *pgd,
>>>> ...
>>>> #if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
>>>> ...
>>>> static inline void mm_nr_pmds_init(struct mm_struct *mm)
>>>> {
>>>>     atomic_long_set(&mm->nr_pmds, 0);
>>>> }
>>>> ...
>>>> #else
>>>> ...
>>>> static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
>>>> ...
>>>> #endif
>>>>
>>>> So, I drop my idea of reverting Kirill's commit.
>>>>
>>>> Pat, not sure how often you build linux-next.
>>>> When doing a daily linux-next testing... Before bisecting I normally
>>>> checked which version of linux-next was the last good and which one
>>>> was the first bad.
>>>> I cannot say which strategy is better.
>>>> But you seem to have a reliable test with watching Netflix.
>>>>
>>>> Regards,
>>>> - Sedat -
>>>>
>>>> [1]
>>>> http://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/tag/?id=mmotm-2015-02-03-16-38
>>>> [2]
>>>> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=e060ff1f1f00caab403bd208ffa78ed1b7ee0c4d
>>>
>>>
>>> Yeah, I only recently found a patch that lets me boot xen on a recent -next
>>> kernel:
>>>
>>> diff --git a/arch/x86/kernel/cpu/microcode/core.c
>>> b/arch/x86/kernel/cpu/microcode/core.c
>>> index 15c2909..36a8361 100644
>>> --- a/arch/x86/kernel/cpu/microcode/core.c
>>> +++ b/arch/x86/kernel/cpu/microcode/core.c
>>> @@ -552,7 +552,7 @@ static int __init microcode_init(void)
>>>          int error;
>>>
>>>          if (paravirt_enabled() || dis_ucode_ldr)
>>> -               return 0;
>>> +               return -EINVAL;
>>>
>>>          if (c->x86_vendor == X86_VENDOR_INTEL)
>>>                  microcode_ops = init_intel_microcode();
>>>
>>> that I found on it's way to upstream.  The last 'known good' Xen setup for
>>> me was a 3.18.0 rc6 kernel.  I only use Xen to experiment with, so I don't
>>> boot every kernel with Xen enabled, only when I'm working on learning it.
>>> So as far as a bisect window goes, that's a pretty large one.  I'll wait to
>>> see if anyone else chimes in before attempting the bisect(mostly because
>>> it's 3am here, and they'll all likely have a chance to see this chain of
>>> e-mails before I can get going on the bisect tomorrow).  I'll also check to
>>> see if I can trigger it on this kernel without booting in xen.
>>>
>>
>> I have run ltp (20150119) in special the mm testsuite.
>> It produces call-traces here when running OOM tests (oom03, oom04 and oom05).
>>
>> # cd /opt/ltp
>>
>> # cat Version
>> 20150119
>>
>> root# LC_ALL=C ./runltp -f mm 2>&1 | tee
>> results-ltp_mm-testsuite_$(uname -r).txt
>>
>> 1st snippet in dmesg:
>> ...
>> [ 2808.331428] BUG: non-zero nr_pmds on freeing mm: 17
>> [ 3283.043499] oom03 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
>> [ 3283.043505] oom03 cpuset=/ mems_allowed=0
>> [ 3283.043551] CPU: 2 PID: 14892 Comm: oom03 Not tainted
>> 3.19.0-rc7-next-20150204.14-iniza-small #1
>> [ 3283.043553] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
>> 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
>> [ 3283.043555]  0000000000000000 ffff88005402fca8 ffffffff817e392d
>> 000000000000000a
>> [ 3283.043559]  ffff8800bcf04000 ffff88005402fd38 ffffffff817e1a16
>> ffff88005402fcd8
>> [ 3283.043562]  ffffffff810d827d 0000000000000206 ffffffff81c6e800
>> ffff88005402fce8
>> [ 3283.043565] Call Trace:
>> [ 3283.043571]  [<ffffffff817e392d>] dump_stack+0x4c/0x65
>> [ 3283.043576]  [<ffffffff817e1a16>] dump_header+0x9e/0x261
>> [ 3283.043580]  [<ffffffff810d827d>] ? trace_hardirqs_on_caller+0x15d/0x200
>> [ 3283.043583]  [<ffffffff810d832d>] ? trace_hardirqs_on+0xd/0x10
>> [ 3283.043587]  [<ffffffff811a8abc>] oom_kill_process+0x1dc/0x3d0
>> [ 3283.043590]  [<ffffffff81217658>] mem_cgroup_oom_synchronize+0x6b8/0x6f0
>> [ 3283.043594]  [<ffffffff81211a50>] ? mem_cgroup_reset+0xb0/0xb0
>> [ 3283.043597]  [<ffffffff811a95b4>] pagefault_out_of_memory+0x24/0xe0
>> [ 3283.043600]  [<ffffffff8106c4ad>] mm_fault_error+0x8d/0x190
>> [ 3283.043603]  [<ffffffff8106ca60>] __do_page_fault+0x4b0/0x4c0
>> [ 3283.043605]  [<ffffffff8106caa1>] do_page_fault+0x31/0x70
>> [ 3283.043609]  [<ffffffff817f0818>] page_fault+0x28/0x30
>> [ 3283.043657] Task in /1 killed as a result of limit of /1
>> [ 3283.043790] memory: usage 1048576kB, limit 1048576kB, failcnt 28578
>> [ 3283.043792] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
>> [ 3283.043793] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
>> [ 3283.043795] Memory cgroup stats for /1: cache:0KB rss:1048576KB
>> rss_huge:0KB mapped_file:0KB writeback:4316KB inactive_anon:524296KB
>> active_anon:524228KB inactive_file:0KB active_file:0KB unevictable:0KB
>> [ 3283.043867] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
>> swapents oom_score_adj name
>> [ 3283.044061] [14891]     0 14891     1618      427       9       3
>>       0             0 oom03
>> [ 3283.044066] [14892]     0 14892   788050   252632     631       6
>>   65535             0 oom03
>> [ 3283.044069] Memory cgroup out of memory: Kill process 14892 (oom03)
>> score 943 or sacrifice child
>> [ 3283.044103] Killed process 14892 (oom03) total-vm:3152200kB,
>> anon-rss:1009556kB, file-rss:972kB
>> ...
>>
>> Hope this helps to get the beast.
>>
>
>  From results-ltp file...
>
> <<<test_start>>>
> tag=oom03 stime=1423299759
> cmdline="oom03"
> contacts=""
> analysis=exit
> <<<test_output>>>
> oom03       0  TINFO  :  set overcommit_memory to 1
> oom03       0  TINFO  :  start normal OOM testing.
> oom03       0  TINFO  :  expected victim is 14892.
> oom03       1  TPASS  :  victim signalled: (9) SIGKILL
> oom03       0  TINFO  :  start OOM testing for mlocked pages.
> oom03       0  TINFO  :  expected victim is 14893.
> oom03       2  TPASS  :  victim signalled: (9) SIGKILL
> oom03       0  TINFO  :  start OOM testing for KSM pages.
> oom03       0  TINFO  :  expected victim is 14894.
> oom03       3  TPASS  :  victim signalled: (9) SIGKILL
> oom03       4  TCONF  :  oom03.c:74: memcg swap accounting is disabled
> oom03       0  TINFO  :  set overcommit_memory to 0
> <<<execution_status>>>
> initiation_status="ok"
> duration=9 termination_type=exited termination_id=32 corefile=no
> cutime=80 cstime=564
> <<<test_end>>>
>
> Do you have "memcg swap accounting is disabled" (see above)?
> Can you try with CONFIG_MEMCG_SWAP_ENABLED=y to see if this has an effect?
>
> Here I have it disabled and the following memcg kernel-options set...
>
> $ grep -i memcg /boot/config-3.19.0-rc7-next-20150204.14-iniza-small
> CONFIG_MEMCG=y
> CONFIG_MEMCG_SWAP=y
> # CONFIG_MEMCG_SWAP_ENABLED is not set
> # CONFIG_MEMCG_KMEM is not set
>
> Hope the mm folk can explain if this option is relevant for the issue or not.
>

linux-next $ grep -i memcg /boot/config-3.19.0-rc7
# CONFIG_MEMCG is not set

I have MEMCG completely disabled, so it doesn't appear to be required 
for this issue.  I'm slowly searching back for a 'good' build to start 
the bisection.  Unfortunately, it can take a while to reproduce the 
issue, so I'm only 2 tries into finding a recent good kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
