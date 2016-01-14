Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id CDD22828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 16:06:20 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id is5so94019785obc.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 13:06:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e10si9395610oey.40.2016.01.14.13.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 13:06:20 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
 <CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
 <alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
 <CAPub14_fh0vZDZ+dHP1Jihi1_x0k54p_rO4NL2TqXGXGia9qYA@mail.gmail.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56980DC7.908@oracle.com>
Date: Thu, 14 Jan 2016 16:06:15 -0500
MIME-Version: 1.0
In-Reply-To: <CAPub14_fh0vZDZ+dHP1Jihi1_x0k54p_rO4NL2TqXGXGia9qYA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shiraz.linux.kernel@gmail.com>, Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/13/2016 06:36 AM, Shiraz Hashim wrote:
> Hi Sasha,
> 
> On Tue, Jan 12, 2016 at 5:53 PM, Christoph Lameter <cl@linux.com> wrote:
>> On Tue, 12 Jan 2016, Shiraz Hashim wrote:
>>
>>>> +       refresh_cpu_vm_stats(false);
>>>> +       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>>>>
>>>
>>> shouldn't this be cancel_delayed_work_sync ?
>>
>> Hmmm... This is executed with preemption off and the work is on the same
>> cpu. If it would be able to run concurrently then we would need this.
>>
>> Ok but it could run from the timer interrupt if that is still on and
>> occuring shortly before we go idle. Guess this needs to be similar to
>> the code we execute on cpu down in the vmstat notifiers (see
>> vmstat_cpuup_callback).
>>
>> Does this fix it? I have not been able to reproduce the issue so far.
>>
>> Patch against -next.
>>
>>
>>
>> Subject: vmstat: Use delayed work_sync and avoid loop.
>>
>> Signed-off-by: Christoph Lameter <cl@linux.com>
>>
>> Index: linux/mm/vmstat.c
>> ===================================================================
>> --- linux.orig/mm/vmstat.c
>> +++ linux/mm/vmstat.c
>> @@ -1419,11 +1419,9 @@ void quiet_vmstat(void)
>>         if (system_state != SYSTEM_RUNNING)
>>                 return;
>>
>> -       do {
>> -               if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
>> -                       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>> -
>> -       } while (refresh_cpu_vm_stats(false));
>> +       refresh_cpu_vm_stats(false);
>> +       cancel_delayed_work_sync(this_cpu_ptr(&vmstat_work));
>> +       cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
>>  }
>>
>>  /*
> 
> Can you please give it a try, seems it is reproducing easily at your end.
> 

I'm seeing:

[3637853.902081] BUG: sleeping function called from invalid context at kernel/workqueue.c:2725
[3637853.904291] in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper/0
[3637853.905488] no locks held by swapper/0/0.
[3637853.906387] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-next-20160114-sasha-00021-gf1273d1-dirty #2797
[3637853.908369]  1ffffffff5dc0f42 0f76d753b1b5b625 ffffffffaee07a90 ffffffffa2433eee
[3637853.909561]  0000000041b58ab3 ffffffffae960c30 ffffffffa2433e26 ffffffffaee49bc0
[3637853.911601]  0000000000000000 0000000000000000 0000000000000000 ffffffffaee07a78
[3637853.913281] Call Trace:
[3637853.913775]  [<ffffffffa2433eee>] dump_stack+0xc8/0x12a
[3637853.914649]  [<ffffffffa2433e26>] ? _atomic_dec_and_lock+0x106/0x106
[3637853.915824]  [<ffffffffa0440125>] ___might_sleep+0x2c5/0x480
[3637853.917056]  [<ffffffffa044033b>] __might_sleep+0x5b/0x260
[3637853.918310]  [<ffffffffa040a890>] flush_work+0xe0/0x820
[3637853.919270]  [<ffffffffa040a7b0>] ? __queue_delayed_work+0x460/0x460
[3637853.921561]  [<ffffffffa040a7b0>] ? __queue_delayed_work+0x460/0x460
[3637853.922898]  [<ffffffffa054d367>] ? del_timer+0x107/0x170
[3637853.924395]  [<ffffffffa054d260>] ? lock_timer_base+0x220/0x220
[3637853.925827]  [<ffffffffa0411445>] ? try_to_grab_pending+0x115/0x680
[3637853.926924]  [<ffffffffa0411b87>] ? __cancel_work_timer+0x1d7/0x5f0
[3637853.928215]  [<ffffffffa04d4b58>] ? mark_held_locks+0x1a8/0x220
[3637853.929075]  [<ffffffffa0411bdb>] __cancel_work_timer+0x22b/0x5f0
[3637853.930765]  [<ffffffffa04119b0>] ? try_to_grab_pending+0x680/0x680
[3637853.931642]  [<ffffffffa075fb60>] ? fill_contig_page_info+0x2e0/0x2e0
[3637853.932774]  [<ffffffffa0411fda>] cancel_delayed_work_sync+0x1a/0x20
[3637853.933897]  [<ffffffffa0766754>] quiet_vmstat+0x74/0x140
[3637853.934991]  [<ffffffffa04c20eb>] cpu_startup_entry+0x12b/0x6d0
[3637853.936174]  [<ffffffffa04c1fc0>] ? call_cpuidle+0x160/0x160
[3637853.937420]  [<ffffffffabfe3816>] rest_init+0x1d6/0x1e0
[3637853.938799]  [<ffffffffbb7e4c2a>] start_kernel+0x66c/0x6a6
[3637853.940742]  [<ffffffffbb7e45be>] ? thread_info_cache_init+0xb/0xb
[3637853.942416]  [<ffffffffbb9b0ae7>] ? memblock_reserve+0x59/0x5e
[3637853.943880]  [<ffffffffbb7e3120>] ? early_idt_handler_array+0x120/0x120
[3637853.945161]  [<ffffffffbb7e33c4>] x86_64_start_reservations+0x2a/0x2c
[3637853.946005]  [<ffffffffbb7e351d>] x86_64_start_kernel+0x157/0x17a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
