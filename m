Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7336B026B
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:08:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a10-v6so33966itc.9
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:08:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k93-v6si8986686iod.6.2018.07.30.08.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:08:05 -0700 (PDT)
Subject: Re: INFO: task hung in generic_file_write_iter
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 00:07:22 +0900
MIME-Version: 1.0
In-Reply-To: <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 2018/07/21 5:06, Andrew Morton wrote:
> On Fri, 20 Jul 2018 19:36:23 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
>>>
>>> This report is stalling after mount() completed and process used remap_file_pages().
>>> I think that we might need to use debug printk(). But I don't know what to examine.
>>>
>>
>> Andrew, can you pick up this debug printk() patch?
>> I guess we can get the result within one week.
> 
> Sure, let's toss it in -next for a while.
> 
>> >From 8f55e00b21fefffbc6abd9085ac503c52a302464 Mon Sep 17 00:00:00 2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Fri, 20 Jul 2018 19:29:06 +0900
>> Subject: [PATCH] fs/buffer.c: add debug print for __getblk_gfp() stall problem
>>
>> Among syzbot's unresolved hung task reports, 18 out of 65 reports contain
>> __getblk_gfp() line in the backtrace. Since there is a comment block that
>> says that __getblk_gfp() will lock up the machine if try_to_free_buffers()
>> attempt from grow_dev_page() is failing, let's start from checking whether
>> syzbot is hitting that case. This change will be removed after the bug is
>> fixed.
> 
> I'm not sure that grow_dev_page() is hanging.  It has often been
> suspected, but always is proven innocent.  Lets see.

syzbot reproduced this problem ( https://syzkaller.appspot.com/text?tag=CrashLog&x=11f2fc44400000 ) .
It says that grow_dev_page() is returning 1 but __find_get_block() is failing forever. Any idea?
