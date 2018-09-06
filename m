Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF036B787B
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:24:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w11-v6so5440920plq.8
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:24:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o11-v6si5528357pgf.71.2018.09.06.05.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:24:07 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <CACT4Y+Zx6Jrpjfo_sDMNuHcrPvcN3GRprtJM_bCAts7f3Cp0_g@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1de89f00-42f7-16e3-e718-02fb9f125db1@i-love.sakura.ne.jp>
Date: Thu, 6 Sep 2018 20:25:19 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zx6Jrpjfo_sDMNuHcrPvcN3GRprtJM_bCAts7f3Cp0_g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On 2018/09/06 20:07, Dmitry Vyukov wrote:
>> Since printk() is slow, printing one line takes nearly 0.01 second.
>> As a result, syzbot is stalling for 52 seconds trying to dump 5600
> 
> I wonder why there are so many of them?
> We have at most 8 test processes (each having no more than 16 threads
> if that matters).
> No more than 1 instance of syz-executor1 at a time. But we see output
> like the one below. It has lots of instances of syz-executor1 with
> different pid's. So does it print all tasks that ever existed (kernel
> does not store that info, right)? Or it livelocks picking up new and
> new tasks as they are created slower than they are created? Or we have
> tons of zombies?
> 
> ...

I don't think they are zombies. Since tasks which already released ->mm
are not printed, these tasks are still alive.

  [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> [   8037]     0  8037    17618     8738   131072        0             0 syz-executor1

Maybe something signal / fork() / exit() / wait() related regression?
