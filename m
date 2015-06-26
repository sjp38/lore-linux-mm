Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id C6DA46B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 14:24:42 -0400 (EDT)
Received: by oigx81 with SMTP id x81so81269008oig.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 11:24:42 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id os7si9765245obc.73.2015.06.26.11.24.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 11:24:41 -0700 (PDT)
Received: by obbkm3 with SMTP id km3so72117881obb.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 11:24:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9TON1MTgWjF5Qj05aTtx2RM_r9+FPzoYityZyuN3qssWA@mail.gmail.com>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
	<20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
	<CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
	<CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
	<20150626005808.GA5704@swordfish>
	<CAA25o9TCj0YSw1JhuPVsu9PzEMwnC2pLHNvNdMa+0OpJd1X64Q@mail.gmail.com>
	<20150626014248.GA26543@swordfish>
	<CAA25o9TON1MTgWjF5Qj05aTtx2RM_r9+FPzoYityZyuN3qssWA@mail.gmail.com>
Date: Fri, 26 Jun 2015 11:24:41 -0700
Message-ID: <CAA25o9TXNaoXupm8MwHDBi_w3mtPO=tFBX+TCSLz7qSvaDDp1Q@mail.gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

I've tried both deadline and noop schedulers.  They both seem to
improve the behavior somewhat, in the sense that I no longer see the
panic-inducing two-minute hung tasks.  But the interactive response
can remain poor, with the UI freezing for many seconds, including the
mouse cursor.  The write bandwidth also goes down, from 8-10 MB/s to
2-4 MB/s, but I am not sure that's a concern because of the nature of
the test.

Interestingly, some of the very long blockages with the CFQ scheduler
happen on page faults from reading an mmapped file, as below.

In any case I appreciate all the help.  This request was mostly to
make sure that I am not missing some major change to the I/O scheduler
("oh yes, there was this nasty bug, but it's fixed in 4.x...").  Maybe
this is not the right group though?

Thanks!

[215549.914848] INFO: task update_engine:1249 blocked for more than 120 seconds.
[215549.914858] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[215549.914865] update_engine   D ffff88017425ddb8     0  1249      1 0x00000000
[215549.914875]  ffff88015558d710 0000000000000082 ffff8801780c5280
ffff88015558dfd8
[215549.914887]  ffff88015558dfd8 0000000000011cc0 ffff88017425da00
ffff88017ca91cc0
[215549.914898]  ffff88017cdc3b18 ffff88015558d7b8 ffffffff84d12ca5
0000000000000002
[215549.914909] Call Trace:
[215549.914920]  [<ffffffff84d12ca5>] ? generic_block_bmap+0x65/0x65
[215549.914929]  [<ffffffff850bf38b>] schedule+0x64/0x66
[215549.914935]  [<ffffffff850bf509>] io_schedule+0x57/0x71
[215549.914942]  [<ffffffff84d12cb3>] sleep_on_buffer+0xe/0x12
[215549.914951]  [<ffffffff850bd8d3>] __wait_on_bit+0x46/0x76
[215549.914958]  [<ffffffff850bd984>] out_of_line_wait_on_bit+0x81/0xa0
[215549.914966]  [<ffffffff84d12ca5>] ? generic_block_bmap+0x65/0x65
[215549.914974]  [<ffffffff84c51999>] ? autoremove_wake_function+0x34/0x34
[215549.914981]  [<ffffffff84d13777>] __wait_on_buffer+0x26/0x28
[215549.914988]  [<ffffffff84d13872>] wait_on_buffer+0x1e/0x20
[215549.914994]  [<ffffffff84d1460a>] bh_submit_read+0x49/0x5b
[215549.915004]  [<ffffffff84d7ea00>] ext4_get_branch+0x94/0x117
[215549.915011]  [<ffffffff84d7eb72>] ext4_ind_map_blocks+0xef/0x513
[215549.915019]  [<ffffffff84d4b7bb>] ext4_map_blocks+0x68/0x22a
[215549.915026]  [<ffffffff84d4d724>] _ext4_get_block+0xd6/0x171
[215549.915034]  [<ffffffff84d4d7d5>] ext4_get_block+0x16/0x18
[215549.915041]  [<ffffffff84d1ba95>] do_mpage_readpage+0x1b1/0x50c
[215549.915048]  [<ffffffff84d4d7bf>] ? _ext4_get_block+0x171/0x171
[215549.915057]  [<ffffffff84cbfeef>] ? __lru_cache_add+0x39/0x75
[215549.915064]  [<ffffffff84d4d7bf>] ? _ext4_get_block+0x171/0x171
[215549.915071]  [<ffffffff84d1bee2>] mpage_readpages+0xf2/0x149
[215549.915078]  [<ffffffff84d4d7bf>] ? _ext4_get_block+0x171/0x171
[215549.915085]  [<ffffffff84d49ed5>] ext4_readpages+0x3c/0x43
[215549.915092]  [<ffffffff84cbee01>] __do_page_cache_readahead+0x14d/0x203
[215549.915100]  [<ffffffff84cbf0d1>] ra_submit+0x21/0x25
[215549.915107]  [<ffffffff84cb7745>] filemap_fault+0x197/0x381
[215549.915115]  [<ffffffff84cd14d0>] __do_fault+0xb0/0x34a
[215549.915122]  [<ffffffff84cf9c30>] ? poll_select_copy_remaining+0x11d/0x11d
[215549.915130]  [<ffffffff84cd3320>] handle_pte_fault+0x124/0x4f9
[215549.915137]  [<ffffffff84cd446e>] handle_mm_fault+0x97/0xbb
[215549.915145]  [<ffffffff84c297cd>] __do_page_fault+0x1d4/0x38c
[215549.915152]  [<ffffffff84d23059>] ? eventfd_ctx_read+0x184/0x1aa
[215549.915159]  [<ffffffff84c5f37a>] ? wake_up_state+0x12/0x12
[215549.915168]  [<ffffffff84c39318>] ? timespec_add_safe+0x38/0x7b
[215549.915174]  [<ffffffff84c299b7>] do_page_fault+0xe/0x10
[215549.915182]  [<ffffffff850c05b2>] page_fault+0x22/0x30

On Thu, Jun 25, 2015 at 6:43 PM, Luigi Semenzato <semenzato@google.com> wrote:
> I will try and report, thanks.
>
> On Thu, Jun 25, 2015 at 6:42 PM, Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
>> On (06/25/15 18:31), Luigi Semenzato wrote:
>>> We're using CFQ.
>>>
>>> CONFIG_DEFAULT_IOSCHED="cfq"
>>> ...
>>> CONFIG_IOSCHED_CFQ=y
>>> CONFIG_IOSCHED_DEADLINE=y
>>> CONFIG_IOSCHED_NOOP=y
>>>
>>
>> any chance to try out DEADLINE?
>> CFQ, as far as I understand, doesn't make too much sense for SSDs.
>>
>>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
