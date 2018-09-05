Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30D806B72B8
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 06:53:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d1-v6so3745303pfo.16
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 03:53:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 7-v6si1685910pgq.637.2018.09.05.03.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 03:53:52 -0700 (PDT)
Subject: Re: INFO: task hung in ext4_da_get_block_prep
References: <0000000000004a6b700575178b5a@google.com>
 <CACT4Y+aPRGUqAdJCMDWM=Zcy8ZQcHyrsB1ZuWS4VB_+wvLfeaQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
Date: Wed, 5 Sep 2018 19:53:38 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aPRGUqAdJCMDWM=Zcy8ZQcHyrsB1ZuWS4VB_+wvLfeaQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>
Cc: 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On 2018/09/05 16:22, Dmitry Vyukov wrote:
> On Wed, Sep 5, 2018 at 5:41 AM, syzbot
> <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com> wrote:
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    f2b6e66e9885 Add linux-next specific files for 20180904
>> git tree:       linux-next
>> console output: https://syzkaller.appspot.com/x/log.txt?x=1735dc92400000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=15ad48400e39c1b3
>> dashboard link: https://syzkaller.appspot.com/bug?extid=f0fc7f62e88b1de99af3
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>> CC:             [adilger.kernel@dilger.ca linux-ext4@vger.kernel.org
>> linux-kernel@vger.kernel.org tytso@mit.edu]
>>
>> Unfortunately, I don't have any reproducer for this crash yet.
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com
>>
>> [   7961]     0  7961    17585     8737   131072        0             0
>> syz-executor3
> 
> Hi Tetsuo,
> 
> Maybe you know what are these repeated lines with numbers?
> We started getting them on linux-next recently, also:
> https://syzkaller.appspot.com/bug?extid=f8fa79b458bcae4d913d
> They seem to cause various hangs/stalls.

Yes, these lines are from the OOM killer. (Thus, if we can, I want to
remove ext4 people before upstreaming this report.)

  dump_tasks mm/oom_kill.c:420 [inline]
  dump_header+0xf0d/0xf70 mm/oom_kill.c:450
  oom_kill_process.cold.28+0x10/0x95a mm/oom_kill.c:953
  out_of_memory+0xa88/0x1430 mm/oom_kill.c:1120

What is annoying is that one for_each_process() traversal with printk() is
taking 52 seconds which is too long to do under RCU section. Under such
situation, invoking the OOM killer for three times will exceed khungtaskd
threshold 140 seconds. Was syzbot trying to test fork bomb situation?

Anyway, we might need to introduce rcu_lock_break() like
check_hung_uninterruptible_tasks() does...

[  999.629589] [  16497]     0 16497    17585     8739   126976        0             0 syz-executor5
[ 1026.435955] [  32764]     0 32764    17585     8739   126976        0             0 syz-executor5
[ 1026.445027] [    311]     0   311    17585     8737   131072        0             0 syz-executor3
[ 1047.914324] [  10315]     0 10315    17585     8271   126976        0             0 syz-executor0
[ 1047.923384] Out of memory: Kill process 4670 (syz-fuzzer) score 53 or sacrifice child
[ 1047.931934] Killed process 5032 (syz-executor1) total-vm:70212kB, anon-rss:60kB, file-rss:0kB, shmem-rss:0kB
[ 1047.988138] syz-executor2 invoked oom-killer: gfp_mask=0x6040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null), order=1, oom_score_adj=0
[ 1048.000015] syz-executor2 cpuset=syz2 mems_allowed=0
[ 1048.005199] CPU: 0 PID: 4700 Comm: syz-executor2 Not tainted 4.19.0-rc2-next-20180904+ #55
[ 1048.740679] [   2347]     0  2347      278      186    32768        0             0 none
[ 1051.319928] [  16497]     0 16497    17585     8739   126976        0             0 syz-executor5
[ 1096.740878] [   8841]     0  8841    17585     8232   126976        0             0 syz-executor5
[ 1078.140677] [  32764]     0 32764    17585     8739   126976        0             0 syz-executor5
[ 1078.149807] [    311]     0   311    17585     8737   131072        0             0 syz-executor3
[ 1096.740878] [   8841]     0  8841    17585     8232   126976        0             0 syz-executor5

Also, another notable thing is that the backtrace for some reason includes

[ 1048.211540]  ? oom_killer_disable+0x3a0/0x3a0

line. Was syzbot testing process freezing functionality?
