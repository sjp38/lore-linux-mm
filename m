Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A00F6B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:49:38 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so2998416pab.34
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:49:38 -0700 (PDT)
Received: from [80.171.226.66] ([80.171.226.66]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0LsCdj-1VvMGo0VEF-013tNb for <linux-mm@kvack.org>;
 Thu, 10 Oct 2013 18:49:34 +0200
Message-ID: <5256DA9A.5060904@gmx.de>
Date: Thu, 10 Oct 2013 18:49:30 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
References: <524DC675.4020201@gmx.de> <524E57BA.805@nod.at> <52517109.90605@gmx.de> <CAMuHMdXrU0e_6AxvdboMkDs+N+tSWD+b8ou92j28c0vsq2eQQA@mail.gmail.com> <5251C334.3010604@gmx.de> <CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com> <5251CF94.5040101@gmx.de> <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com> <525591AD.4060401@gmx.de> <5255A3E6.6020100@nod.at> <20131009214733.GB25608@quack.suse.cz> <5255D9A6.3010208@nod.at>
In-Reply-To: <5255D9A6.3010208@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, Jan Kara <jack@suse.cz>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>

On 10/10/2013 12:33 AM, Richard Weinberger wrote:
> Am 09.10.2013 23:47, schrieb Jan Kara:
>> On Wed 09-10-13 20:43:50, Richard Weinberger wrote:
>>> CC'ing mm folks.
>>> Please see below.
>>   Added Fenguang to CC since he is the author of this code.
> 
> Thx, get_maintainer.pl didn't list him.
> 
>>> Am 09.10.2013 19:26, schrieb Toralf FA?rster:
>>>> On 10/08/2013 10:07 PM, Geert Uytterhoeven wrote:
>>>>> On Sun, Oct 6, 2013 at 11:01 PM, Toralf FA?rster <toralf.foerster@gmx.de> wrote:
>>>>>>> Hmm, now pages_dirtied is zero, according to the backtrace, but the BUG_ON()
>>>>>>> asserts its strict positive?!?
>>>>>>>
>>>>>>> Can you please try the following instead of the BUG_ON():
>>>>>>>
>>>>>>> if (pause < 0) {
>>>>>>>         printk("pages_dirtied = %lu\n", pages_dirtied);
>>>>>>>         printk("task_ratelimit = %lu\n", task_ratelimit);
>>>>>>>         printk("pause = %ld\n", pause);
>>>>>>> }
>>>>>>>
>>>>>>> Gr{oetje,eeting}s,
>>>>>>>
>>>>>>>                         Geert
>>>>>> I tried it in different ways already - I'm completely unsuccessful in getting any printk output.
>>>>>> As soon as the issue happens I do have a
>>>>>>
>>>>>> BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]
>>>>>>
>>>>>> at stderr of the UML and then no further input is accepted. With uml_mconsole I'm however able
>>>>>> to run very basic commands like a crash dump, sysrq ond so on.
>>>>>
>>>>> You may get an idea of the magnitude of pages_dirtied by using a chain of
>>>>> BUG_ON()s, like:
>>>>>
>>>>> BUG_ON(pages_dirtied > 2000000000);
>>>>> BUG_ON(pages_dirtied > 1000000000);
>>>>> BUG_ON(pages_dirtied > 100000000);
>>>>> BUG_ON(pages_dirtied > 10000000);
>>>>> BUG_ON(pages_dirtied > 1000000);
>>>>>
>>>>> Probably 1 million is already too much for normal operation?
>>>>>
>>>> period = HZ * pages_dirtied / task_ratelimit;
>>>> 		BUG_ON(pages_dirtied > 2000000000);
>>>> 		BUG_ON(pages_dirtied > 1000000000);      <-------------- this is line 1467
>>>
>>> Summary for mm people:
>>>
>>> Toralf runs trinty on UML/i386.
>>> After some time pages_dirtied becomes very large.
>>> More than 1000000000 pages in this case.
>>   Huh, this is really strange. pages_dirtied is passed into
>> balance_dirty_pages() from current->nr_dirtied. So I wonder how a value
>> over 10^9 can get there. After all that is over 4TB so I somewhat doubt the
>> task was ever able to dirty that much during its lifetime (but correct me
>> if I'm wrong here, with UML and memory backed disks it is not totally
>> impossible)... I went through the logic of handling ->nr_dirtied but
>> I didn't find any obvious problem there. Hum, maybe one thing - what
>> 'task_ratelimit' values do you see in balance_dirty_pages? If that one was
>> huge, we could possibly accumulate huge current->nr_dirtied.
> 
> Toralf, you can try a snipplet like this one to get the values printed out:
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index f5236f8..a80e520 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1463,6 +1463,12 @@ static void balance_dirty_pages(struct address_space *mapping,
>                         goto pause;
>                 }
>                 period = HZ * pages_dirtied / task_ratelimit;
> +
> +               {
> +                       extern int printf(char *, ...);
> +                       printf("---> task_ratelimit: %lu\n", task_ratelimit);
> +               }
> +
>                 pause = period;
>                 if (current->dirty_paused_when)
>                         pause -= now - current->dirty_paused_when;
> 
> 
> Yes, printf(), not printk().
> Using this hack we print directly to host's stdout. :)
> 
*head smack* ofc - works fine.
So given this diff :

iff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f5236f8..5a2c337 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1464,6 +1464,13 @@ static void balance_dirty_pages(struct address_space *mapping,
                }
                period = HZ * pages_dirtied / task_ratelimit;
                pause = period;
+               if (pause < 0)  {
+                       extern int printf(char *, ...);
+                       printf("overflow : pause : %li\n", pause);
+                       printf("overflow : pages_dirtied : %lu\n", pages_dirtied);
+                       printf("overflow :  task_ratelimit: %lu\n", task_ratelimit);
+                       BUG_ON(1);
+               }
                if (current->dirty_paused_when)
                        pause -= now - current->dirty_paused_when;
                /*
@@ -1503,6 +1510,13 @@ static void balance_dirty_pages(struct address_space *mapping,
                }

 pause:
+               if (pause < 0)  {
+                       extern int printf(char *, ...);
+                       printf("ick : pause : %li\n", pause);
+                       printf("ick: pages_dirtied : %lu\n", pages_dirtied);
+                       printf("ick: task_ratelimit: %lu\n", task_ratelimit);
+                       BUG_ON(1);
+               }
                trace_balance_dirty_pages(bdi,
                                          dirty_thresh,
                                          background_thresh,


I got this :




 * Starting local
net.core.warnings = 0                                                                                                                            [ ok ]
ick : pause : -984
                  ick: pages_dirtied : 0
                                        ick: task_ratelimit: 0
                                                              Kernel panic - not syncing: BUG!
CPU: 0 PID: 1434 Comm: trinity-child2 Not tainted 3.12.0-rc4-00029-g0e7a3ed-dirty #12
47397c84 47397cb0 0841b5a0 084c30e8 085f76e0 084b4745 47397cbc 00000000 
       fffffc28 01fff278 085cb4a0 47397d2c 0841c5a0 084b4745 084c5398 000005ee 
       08432cf0 43e47600 471757f8 47397cf0 ffffff0c 47397cdc 5256d8b9 3417ec18 47397c5c:  [<08060b2c>] show_stack+0x7c/0xd0
47397c7c:  [<0841e34d>] dump_stack+0x26/0x28
47397c8c:  [<0841b5a0>] panic+0x7a/0x180
47397cb4:  [<0841c5a0>] balance_dirty_pages.isra.32+0x4e3/0x5ad
47397d30:  [<080d3595>] balance_dirty_pages_ratelimited+0xf5/0x100
47397d44:  [<080e4a3f>] __do_fault+0x3cf/0x440
47397d9c:  [<080e6e0f>] handle_mm_fault+0xef/0x7c0
47397dec:  [<080e7817>] __get_user_pages+0x227/0x420
47397e24:  [<080e7ae3>] get_user_pages+0x63/0x70
47397e4c:  [<08143dc6>] SyS_io_setup+0x3c6/0x760
47397eb0:  [<08062984>] handle_syscall+0x64/0x80
47397ef0:  [<08074fb5>] userspace+0x475/0x5f0
47397fec:  [<0805f750>] fork_handler+0x60/0x70
47397ffc:  [<00000000>] 0x0


EIP: 0073:[<40001282>] CPU: 0 Not tainted ESP: 007b:bfb348f8 EFLAGS: 00000246
    Not tainted
EAX: ffffffda EBX: 00001000 ECX: 080d0000 EDX: 80000048
ESI: 80fbff1f EDI: ffe02f77 EBP: 90f6e2a3 DS: 007b ES: 007b
47397c0c:  [<0807947f>] show_regs+0x10f/0x120
47397c28:  [<080623a9>] panic_exit+0x29/0x50
47397c38:  [<0809ba86>] notifier_call_chain+0x36/0x60
47397c60:  [<0809bba1>] __atomic_notifier_call_chain+0x21/0x30
47397c70:  [<0809bbdf>] atomic_notifier_call_chain+0x2f/0x40
47397c8c:  [<0841b5bc>] panic+0x96/0x180
47397cb4:  [<0841c5a0>] balance_dirty_pages.isra.32+0x4e3/0x5ad
47397d30:  [<080d3595>] balance_dirty_pages_ratelimited+0xf5/0x100
47397d44:  [<080e4a3f>] __do_fault+0x3cf/0x440
47397d9c:  [<080e6e0f>] handle_mm_fault+0xef/0x7c0
47397dec:  [<080e7817>] __get_user_pages+0x227/0x420
47397e24:  [<080e7ae3>] get_user_pages+0x63/0x70
47397e4c:  [<08143dc6>] SyS_io_setup+0x3c6/0x760
47397eb0:  [<08062984>] handle_syscall+0x64/0x80
47397ef0:  [<08074fb5>] userspace+0x475/0x5f0
47397fec:  [<0805f750>] fork_handler+0x60/0x70
47397ffc:  [<00000000>] 0x0

/home/tfoerste/workspace/bin/start_uml.sh: line 115: 18718 Aborted                 (core dumped) $LINUX earlyprintk ubda=$ROOTFS ubdb=$SWAP eth0=$NET mem=$MEM $TTY umid=uml_$NAME rootfstype=ext4 "$ARGS"


>From what I see there are 2 different types of issues - and this is an example of the other of both 

> Thanks,
> //richard
> 


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
