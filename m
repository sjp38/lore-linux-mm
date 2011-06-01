Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 485E26B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 05:29:49 -0400 (EDT)
Message-ID: <4DE60669.9050606@fnarfbargle.com>
Date: Wed, 01 Jun 2011 17:29:13 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
In-Reply-To: <4DE5E29E.7080009@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 01/06/11 14:56, Avi Kivity wrote:
> On 06/01/2011 09:31 AM, Brad Campbell wrote:
>> On 01/06/11 12:52, Hugh Dickins wrote:
>>
>>>
>>> I guess Brad could try SLUB debugging, boot with slub_debug=P
>>> for poisoning perhaps; though it might upset alignments and
>>> drive the problem underground. Or see if the same happens
>>> with SLAB instead of SLUB.
>>
>> Not much use I'm afraid.
>> This is all I get in the log
>>
>> [ 3161.300073]
>> =============================================================================
>>
>> [ 3161.300147] BUG kmalloc-512: Freechain corrupt
>>
>> The qemu process is then frozen, unkillable but reported in state "R"
>>
>> 13881 ? R 3:27 /usr/bin/qemu -S -M pc-0.13 -enable-kvm -m 1024 -smp
>> 2,sockets=2,cores=1,threads=1 -nam
>>
>> The machine then progressively dies until it's frozen solid with no
>> further error messages.
>>
>> I stupidly forgot to do an alt-sysrq-t prior to doing an alt-sysrq-b,
>> but at least it responded to that.
>>
>> On the bright side I can reproduce it at will.
>
> Please try slub_debug=FZPU; that should point the finger (hopefully at
> somebody else).
>

Well the first attempt locked the machine solid. No network, no console..

I saw 
"=========================================================================="

on the console.. nothing after that. Would not respond to sysrq-t or any 
other sysrq combination other than -b, which rebooted the box.


No output on netconsole at all, I had to walk to the other building to 
look at the monitor and reboot it.

The second attempt jammed netconsole again, but I managed to get this 
from an ssh session I already had established. The machine died a slow 
and horrible death, but remained interactive enough for me to reboot it with

echo b > /proc/sysrq-trigger

Nothing else worked.



[  376.269051] 
=============================================================================
[  413.755328] 
=============================================================================
[  413.755337] BUG kmalloc-1024: Object padding overwritten
[  413.755341] 
-----------------------------------------------------------------------------
[  413.755344]
[  413.755349] INFO: 0xffff880417179566-0xffff880417179567. First byte 
0x0 instead of 0x5a
[  413.755363] INFO: Allocated in tcp_send_ack+0x26/0x120 age=5320 cpu=5 
pid=0
[  413.755374] INFO: Freed in __kfree_skb+0x11/0x90 age=5320 cpu=5 pid=0
[  413.755380] INFO: Slab 0xffffea000e50d240 objects=29 used=5 
fp=0xffff880417179120 flags=0x80000000000040c1
[  413.755386] INFO: Object 0xffff880417179120 @offset=4384 
fp=0xffff8804171799b0
[  413.755389]
[  413.755392] Bytes b4 0xffff880417179110:  d9 2b 00 00 01 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a A?+......ZZZZZZZZ
[  413.755408]   Object 0xffff880417179120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755423]   Object 0xffff880417179130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755438]   Object 0xffff880417179140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755452]   Object 0xffff880417179150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755466]   Object 0xffff880417179160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755480]   Object 0xffff880417179170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755494]   Object 0xffff880417179180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755508]   Object 0xffff880417179190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755522]   Object 0xffff8804171791a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755536]   Object 0xffff8804171791b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755551]   Object 0xffff8804171791c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755565]   Object 0xffff8804171791d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755579]   Object 0xffff8804171791e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755593]   Object 0xffff8804171791f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755607]   Object 0xffff880417179200:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755621]   Object 0xffff880417179210:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755635]   Object 0xffff880417179220:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755650]   Object 0xffff880417179230:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755664]   Object 0xffff880417179240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755678]   Object 0xffff880417179250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755692]   Object 0xffff880417179260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755706]   Object 0xffff880417179270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755720]   Object 0xffff880417179280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755734]   Object 0xffff880417179290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755749]   Object 0xffff8804171792a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755763]   Object 0xffff8804171792b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755777]   Object 0xffff8804171792c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755791]   Object 0xffff8804171792d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755805]   Object 0xffff8804171792e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755819]   Object 0xffff8804171792f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755834]   Object 0xffff880417179300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755848]   Object 0xffff880417179310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755862]   Object 0xffff880417179320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755876]   Object 0xffff880417179330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755890]   Object 0xffff880417179340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755904]   Object 0xffff880417179350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755919]   Object 0xffff880417179360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755933]   Object 0xffff880417179370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755947]   Object 0xffff880417179380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755961]   Object 0xffff880417179390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755975]   Object 0xffff8804171793a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.755989]   Object 0xffff8804171793b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756004]   Object 0xffff8804171793c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756018]   Object 0xffff8804171793d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756032]   Object 0xffff8804171793e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756046]   Object 0xffff8804171793f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756060]   Object 0xffff880417179400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756074]   Object 0xffff880417179410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756089]   Object 0xffff880417179420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756103]   Object 0xffff880417179430:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756117]   Object 0xffff880417179440:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756131]   Object 0xffff880417179450:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756145]   Object 0xffff880417179460:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756160]   Object 0xffff880417179470:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756174]   Object 0xffff880417179480:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756188]   Object 0xffff880417179490:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756202]   Object 0xffff8804171794a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756216]   Object 0xffff8804171794b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756230]   Object 0xffff8804171794c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756245]   Object 0xffff8804171794d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756259]   Object 0xffff8804171794e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756273]   Object 0xffff8804171794f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756287]   Object 0xffff880417179500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  413.756301]   Object 0xffff880417179510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  413.756316]  Redzone 0xffff880417179520:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  413.756329]  Padding 0xffff880417179560:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  413.756345] Pid: 5247, comm: qemu Not tainted 2.6.39 #2
[  413.756349] Call Trace:
[  413.756353]  <IRQ>  [<ffffffff810b7ccd>] ? 
check_bytes_and_report+0x10d/0x150
[  413.756372]  [<ffffffff81318f1c>] ? pskb_expand_head+0x15c/0x250
[  413.756379]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  413.756387]  [<ffffffff81318f1c>] ? pskb_expand_head+0x15c/0x250
[  413.756393]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  413.756400]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  413.756409]  [<ffffffff810ba59d>] ? __kmalloc+0x10d/0x160
[  413.756416]  [<ffffffff81318f1c>] ? pskb_expand_head+0x15c/0x250
[  413.756424]  [<ffffffff813a6c45>] ? nf_bridge_copy_header+0x145/0x160
[  413.756431]  [<ffffffff8139f78d>] ? br_dev_queue_push_xmit+0x6d/0x80
[  413.756439]  [<ffffffff813a55a0>] ? br_nf_post_routing+0x2a0/0x2f0
[  413.756447]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
[  413.756453]  [<ffffffff8139f720>] ? br_flood_deliver+0x20/0x20
[  413.756459]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
[  413.756465]  [<ffffffff8139f720>] ? br_flood_deliver+0x20/0x20
[  413.756472]  [<ffffffff8139f7da>] ? br_forward_finish+0x3a/0x60
[  413.756479]  [<ffffffff813a5758>] ? br_nf_forward_finish+0x168/0x170
[  413.756487]  [<ffffffff813a5c90>] ? br_nf_forward_ip+0x360/0x3a0
[  413.756492]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
[  413.756498]  [<ffffffff8139f7a0>] ? br_dev_queue_push_xmit+0x80/0x80
[  413.756504]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
[  413.756510]  [<ffffffff8139f7a0>] ? br_dev_queue_push_xmit+0x80/0x80
[  413.756516]  [<ffffffff8139f800>] ? br_forward_finish+0x60/0x60
[  413.756522]  [<ffffffff8139f800>] ? br_forward_finish+0x60/0x60
[  413.756528]  [<ffffffff8139f875>] ? __br_forward+0x75/0xc0
[  413.756534]  [<ffffffff8139f426>] ? deliver_clone+0x36/0x60
[  413.756540]  [<ffffffff8139f69d>] ? br_flood+0xbd/0x100
[  413.756546]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
[  413.756552]  [<ffffffff813a080e>] ? br_handle_frame_finish+0x25e/0x280
[  413.756560]  [<ffffffff813a60f0>] ? br_nf_pre_routing_finish+0x1a0/0x330
[  413.756568]  [<ffffffff813a6958>] ? br_nf_pre_routing+0x6d8/0x800
[  413.756577]  [<ffffffff8102d46a>] ? enqueue_task+0x3a/0x90
[  413.756582]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
[  413.756589]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
[  413.756594]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
[  413.756600]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
[  413.756607]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  413.756613]  [<ffffffff813a09d9>] ? br_handle_frame+0x1a9/0x280
[  413.756620]  [<ffffffff813a0830>] ? br_handle_frame_finish+0x280/0x280
[  413.756627]  [<ffffffff81320ef7>] ? __netif_receive_skb+0x157/0x5c0
[  413.756634]  [<ffffffff81321443>] ? process_backlog+0xe3/0x1d0
[  413.756641]  [<ffffffff81321da5>] ? net_rx_action+0xc5/0x1d0
[  413.756650]  [<ffffffff8103df11>] ? __do_softirq+0x91/0x120
[  413.756657]  [<ffffffff813d838c>] ? call_softirq+0x1c/0x30
[  413.756660]  <EOI>  [<ffffffff81003cbd>] ? do_softirq+0x4d/0x80
[  413.756673]  [<ffffffff81321ece>] ? netif_rx_ni+0x1e/0x30
[  413.756681]  [<ffffffff812b3ae2>] ? tun_chr_aio_write+0x332/0x4e0
[  413.756688]  [<ffffffff812b37b0>] ? tun_sendmsg+0x4d0/0x4d0
[  413.756697]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
[  413.756704]  [<ffffffff81063f9c>] ? do_futex+0x13c/0xa70
[  413.756711]  [<ffffffff811d6730>] ? timerqueue_add+0x60/0xb0
[  413.756719]  [<ffffffff81056ab7>] ? __hrtimer_start_range_ns+0x1e7/0x410
[  413.756726]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
[  413.756734]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
[  413.756742]  [<ffffffff810c2e7e>] ? sys_writev+0x4e/0xc0
[  413.756750]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
[  413.756756] FIX kmalloc-1024: Restoring 
0xffff880417179566-0xffff880417179567=0x5a
[  413.756760]
[  556.640033] 
=============================================================================
[  556.640041] BUG kmalloc-512: Object padding overwritten
[  556.640045] 
-----------------------------------------------------------------------------
[  556.640048]
[  556.640053] INFO: 0xffff880403bf091e-0xffff880403bf091f. First byte 
0x0 instead of 0x5a
[  556.640069] INFO: Allocated in sock_alloc_send_pskb+0x1d0/0x320 
age=21401 cpu=2 pid=5630
[  556.640080] INFO: Freed in __kfree_skb+0x11/0x90 age=21386 cpu=2 pid=3753
[  556.640086] INFO: Slab 0xffffea000e0d1c80 objects=28 used=10 
fp=0xffff880403bf06d8 flags=0x80000000000040c1
[  556.640092] INFO: Object 0xffff880403bf06d8 @offset=1752 
fp=0xffff880403bf1488
[  556.640096]
[  556.640099] Bytes b4 0xffff880403bf06c8:  90 c4 ff ff 00 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a .A?A?A?....ZZZZZZZZ
[  556.640115]   Object 0xffff880403bf06d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640130]   Object 0xffff880403bf06e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640144]   Object 0xffff880403bf06f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640158]   Object 0xffff880403bf0708:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640172]   Object 0xffff880403bf0718:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640187]   Object 0xffff880403bf0728:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640201]   Object 0xffff880403bf0738:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640215]   Object 0xffff880403bf0748:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640229]   Object 0xffff880403bf0758:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640243]   Object 0xffff880403bf0768:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640257]   Object 0xffff880403bf0778:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640271]   Object 0xffff880403bf0788:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640286]   Object 0xffff880403bf0798:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640300]   Object 0xffff880403bf07a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640314]   Object 0xffff880403bf07b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640328]   Object 0xffff880403bf07c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640343]   Object 0xffff880403bf07d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640357]   Object 0xffff880403bf07e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640371]   Object 0xffff880403bf07f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640385]   Object 0xffff880403bf0808:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640399]   Object 0xffff880403bf0818:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640413]   Object 0xffff880403bf0828:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640428]   Object 0xffff880403bf0838:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640442]   Object 0xffff880403bf0848:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640456]   Object 0xffff880403bf0858:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640471]   Object 0xffff880403bf0868:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640485]   Object 0xffff880403bf0878:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640499]   Object 0xffff880403bf0888:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640513]   Object 0xffff880403bf0898:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640527]   Object 0xffff880403bf08a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640542]   Object 0xffff880403bf08b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  556.640556]   Object 0xffff880403bf08c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  556.640570]  Redzone 0xffff880403bf08d8:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  556.640583]  Padding 0xffff880403bf0918:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  556.640599] Pid: 4809, comm: qemu Not tainted 2.6.39 #2
[  556.640603] Call Trace:
[  556.640607]  <IRQ>  [<ffffffff810b7ccd>] ? 
check_bytes_and_report+0x10d/0x150
[  556.640626]  [<ffffffff8131aae7>] ? __netdev_alloc_skb+0x17/0x40
[  556.640632]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  556.640640]  [<ffffffff8131aae7>] ? __netdev_alloc_skb+0x17/0x40
[  556.640647]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  556.640654]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  556.640661]  [<ffffffff810bb70d>] ? __kmalloc_track_caller+0x10d/0x160
[  556.640668]  [<ffffffff813198c2>] ? __alloc_skb+0x72/0x160
[  556.640676]  [<ffffffff8131aae7>] ? __netdev_alloc_skb+0x17/0x40
[  556.640684]  [<ffffffff813a7b93>] ? 
br_ip4_multicast_alloc_query+0x23/0x1c0
[  556.640690]  [<ffffffff813a7e76>] ? br_multicast_send_query+0x76/0x130
[  556.640698]  [<ffffffff8104dba8>] ? wq_worker_waking_up+0x8/0x30
[  556.640706]  [<ffffffff8102ca81>] ? sched_slice+0x51/0x80
[  556.640711]  [<ffffffff813a7fb5>] ? 
br_multicast_port_query_expired+0x45/0x70
[  556.640719]  [<ffffffff81043f77>] ? run_timer_softirq+0x137/0x270
[  556.640725]  [<ffffffff81033fe9>] ? scheduler_tick+0x289/0x2d0
[  556.640731]  [<ffffffff813a7f70>] ? br_multicast_query_expired+0x40/0x40
[  556.640740]  [<ffffffff8103df11>] ? __do_softirq+0x91/0x120
[  556.640747]  [<ffffffff813d838c>] ? call_softirq+0x1c/0x30
[  556.640755]  [<ffffffff81003cbd>] ? do_softirq+0x4d/0x80
[  556.640762]  [<ffffffff8103ddbe>] ? irq_exit+0x8e/0xb0
[  556.640770]  [<ffffffff81019d1a>] ? smp_apic_timer_interrupt+0x6a/0xa0
[  556.640776]  [<ffffffff813d7e53>] ? apic_timer_interrupt+0x13/0x20
[  556.640780]  <EOI>  [<ffffffff8102965a>] ? 
flush_tlb_others_ipi+0x11a/0x130
[  556.640791]  [<ffffffff81029647>] ? flush_tlb_others_ipi+0x107/0x130
[  556.640799]  [<ffffffff810aadab>] ? ptep_clear_flush+0xb/0x10
[  556.640806]  [<ffffffff8109a40b>] ? do_wp_page+0x34b/0x7a0
[  556.640836]  [<ffffffffa00a188a>] ? kvm_read_guest_page+0x5a/0x70 [kvm]
[  556.640863]  [<ffffffffa00b7db4>] ? 
paging64_walk_addr_generic+0x264/0x4c0 [kvm]
[  556.640871]  [<ffffffff8109acad>] ? handle_pte_fault+0x44d/0x990
[  556.640878]  [<ffffffff8109b4e8>] ? follow_page+0x268/0x440
[  556.640886]  [<ffffffff8109bd4d>] ? __get_user_pages+0x12d/0x530
[  556.640892]  [<ffffffff81028dbb>] ? gup_pud_range+0x12b/0x1b0
[  556.640914]  [<ffffffffa00a2d2e>] ? get_user_page_nowait+0x2e/0x40 [kvm]
[  556.640935]  [<ffffffffa00a2e7b>] ? hva_to_pfn+0x13b/0x440 [kvm]
[  556.640956]  [<ffffffffa00a31e9>] ? __gfn_to_pfn+0x39/0xf0 [kvm]
[  556.640979]  [<ffffffffa00b825d>] ? try_async_pf+0x4d/0x190 [kvm]
[  556.641002]  [<ffffffffa00b92be>] ? tdp_page_fault+0x10e/0x200 [kvm]
[  556.641026]  [<ffffffffa00b968c>] ? kvm_mmu_page_fault+0x1c/0x80 [kvm]
[  556.641050]  [<ffffffffa00b0a7a>] ? 
kvm_arch_vcpu_ioctl_run+0x3fa/0xcf0 [kvm]
[  556.641058]  [<ffffffff8106239f>] ? futex_wake+0x10f/0x120
[  556.641065]  [<ffffffff81063f7b>] ? do_futex+0x11b/0xa70
[  556.641086]  [<ffffffffa00a517f>] ? kvm_vcpu_ioctl+0x4df/0x5e0 [kvm]
[  556.641097]  [<ffffffff81046671>] ? __dequeue_signal+0xe1/0x170
[  556.641104]  [<ffffffff8104821c>] ? do_send_sig_info+0x6c/0x90
[  556.641112]  [<ffffffff81046aac>] ? dequeue_signal+0x3c/0x170
[  556.641119]  [<ffffffff8104551f>] ? copy_siginfo_to_user+0xef/0x1d0
[  556.641125]  [<ffffffff810d26db>] ? do_vfs_ioctl+0x9b/0x4f0
[  556.641132]  [<ffffffff8106494a>] ? sys_futex+0x7a/0x180
[  556.641137]  [<ffffffff810d2b79>] ? sys_ioctl+0x49/0x80
[  556.641145]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
[  556.641152] FIX kmalloc-512: Restoring 
0xffff880403bf091e-0xffff880403bf091f=0x5a
[  556.641155]
[  602.610062] INFO: task ksmd:552 blocked for more than 120 seconds.
[  602.610068] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  602.610073] ksmd            D 0000000000000000     0   552      2 
0x00000000
[  602.610083]  ffff88041db68ca0 0000000000000046 000212d01fc11d00 
ffff880400000000
[  602.610090]  ffffffff81593020 ffff88041c1a9fd8 0000000000004000 
ffff88041c1a8010
[  602.610097]  ffff88041c1a9fd8 ffff88041db68ca0 0000000000000000 
0000000200000002
[  602.610104] Call Trace:
[  602.610121]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  602.610132]  [<ffffffff8102f69c>] ? enqueue_task_fair+0x14c/0x190
[  602.610141]  [<ffffffff8102db27>] ? task_rq_lock+0x47/0x90
[  602.610148]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  602.610154]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  602.610162]  [<ffffffff8104cb94>] ? flush_work+0x24/0x30
[  602.610167]  [<ffffffff8104be10>] ? do_work_for_cpu+0x20/0x20
[  602.610174]  [<ffffffff8104e0ab>] ? schedule_on_each_cpu+0xab/0xe0
[  602.610181]  [<ffffffff810b5c05>] ? ksm_scan_thread+0x7f5/0xc20
[  602.610189]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  602.610194]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  602.610200]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  602.610207]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  602.610214]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  602.610221]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  602.610227]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  602.610233] INFO: task fsnotify_mark:662 blocked for more than 120 
seconds.
[  602.610237] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  602.610241] fsnotify_mark   D 0000000000000000     0   662      2 
0x00000000
[  602.610248]  ffff88041c31d860 0000000000000046 0000000000000000 
0000000000000000
[  602.610255]  ffffffff81593020 ffff88041c365fd8 0000000000004000 
ffff88041c364010
[  602.610262]  ffff88041c365fd8 ffff88041c31d860 0000000000000000 
0000000000000000
[  602.610268] Call Trace:
[  602.610275]  [<ffffffff81035521>] ? load_balance+0x91/0x5e0
[  602.610282]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  602.610289]  [<ffffffff8102f323>] ? pick_next_task_fair+0x103/0x190
[  602.610295]  [<ffffffff813d4a6d>] ? schedule+0x28d/0x910
[  602.610302]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  602.610307]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  602.610314]  [<ffffffff81074420>] ? synchronize_rcu_bh+0x50/0x50
[  602.610320]  [<ffffffff8107446a>] ? synchronize_sched+0x4a/0x50
[  602.610326]  [<ffffffff8104f940>] ? find_ge_pid+0x40/0x40
[  602.610333]  [<ffffffff8105742b>] ? __synchronize_srcu+0x5b/0xc0
[  602.610342]  [<ffffffff810f5f63>] ? fsnotify_mark_destroy+0x83/0x150
[  602.610348]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  602.610356]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  602.610364]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  602.610371]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  602.610377]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  602.610385]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  602.610390]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  644.689408] 
=============================================================================
[  644.689416] BUG kmalloc-512: Object padding overwritten
[  644.689420] 
-----------------------------------------------------------------------------
[  644.689423]
[  644.689428] INFO: 0xffff88041411f476-0xffff88041411f477. First byte 
0x0 instead of 0x5a
[  644.689444] INFO: Allocated in load_elf_binary+0xa6c/0x1c00 age=18648 
cpu=3 pid=5915
[  644.689454] INFO: Freed in load_elf_binary+0xab8/0x1c00 age=18648 
cpu=3 pid=5915
[  644.689461] INFO: Slab 0xffffea000e463e20 objects=28 used=10 
fp=0xffff88041411f230 flags=0x80000000000040c1
[  644.689467] INFO: Object 0xffff88041411f230 @offset=12848 
fp=0xffff88041411eda0
[  644.689470]
[  644.689474] Bytes b4 0xffff88041411f220:  22 6f 00 00 01 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a "o......ZZZZZZZZ
[  644.689490]   Object 0xffff88041411f230:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689505]   Object 0xffff88041411f240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689519]   Object 0xffff88041411f250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689533]   Object 0xffff88041411f260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689547]   Object 0xffff88041411f270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689562]   Object 0xffff88041411f280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689576]   Object 0xffff88041411f290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689590]   Object 0xffff88041411f2a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689604]   Object 0xffff88041411f2b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689618]   Object 0xffff88041411f2c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689632]   Object 0xffff88041411f2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689647]   Object 0xffff88041411f2e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689661]   Object 0xffff88041411f2f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689675]   Object 0xffff88041411f300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689689]   Object 0xffff88041411f310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689703]   Object 0xffff88041411f320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689717]   Object 0xffff88041411f330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689732]   Object 0xffff88041411f340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689746]   Object 0xffff88041411f350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689760]   Object 0xffff88041411f360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689774]   Object 0xffff88041411f370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689788]   Object 0xffff88041411f380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689802]   Object 0xffff88041411f390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689817]   Object 0xffff88041411f3a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689831]   Object 0xffff88041411f3b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689845]   Object 0xffff88041411f3c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689859]   Object 0xffff88041411f3d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689873]   Object 0xffff88041411f3e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689888]   Object 0xffff88041411f3f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689902]   Object 0xffff88041411f400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689916]   Object 0xffff88041411f410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  644.689930]   Object 0xffff88041411f420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  644.689945]  Redzone 0xffff88041411f430:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  644.689957]  Padding 0xffff88041411f470:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  644.689974] Pid: 6597, comm: awk Not tainted 2.6.39 #2
[  644.689978] Call Trace:
[  644.689989]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  644.689998]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  644.690005]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  644.690012]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  644.690019]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  644.690026]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  644.690032]  [<ffffffff810ba59d>] ? __kmalloc+0x10d/0x160
[  644.690039]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  644.690047]  [<ffffffff8109bd9d>] ? __get_user_pages+0x17d/0x530
[  644.690055]  [<ffffffff810c9556>] ? get_arg_page+0x56/0x100
[  644.690062]  [<ffffffff810c8070>] ? search_binary_handler+0x90/0x240
[  644.690069]  [<ffffffff810c9e9f>] ? do_execve+0x22f/0x2f0
[  644.690076]  [<ffffffff810094a6>] ? sys_execve+0x36/0x60
[  644.690085]  [<ffffffff813d78dc>] ? stub_execve+0x6c/0xc0
[  644.690092] FIX kmalloc-512: Restoring 
0xffff88041411f476-0xffff88041411f477=0x5a
[  644.690095]
[  704.979481] 
=============================================================================
[  704.979488] BUG kmalloc-512: Object padding overwritten
[  704.979492] 
-----------------------------------------------------------------------------
[  704.979496]
[  704.979501] INFO: 0xffff8804168c1fee-0xffff8804168c1fef. First byte 
0x0 instead of 0x5a
[  704.979517] INFO: Allocated in load_elf_binary+0xa6c/0x1c00 age=24184 
cpu=0 pid=5999
[  704.979527] INFO: Freed in load_elf_binary+0xab8/0x1c00 age=24184 
cpu=0 pid=5999
[  704.979534] INFO: Slab 0xffffea000e4eea00 objects=28 used=10 
fp=0xffff8804168c1da8 flags=0x80000000000040c1
[  704.979540] INFO: Object 0xffff8804168c1da8 @offset=7592 
fp=0xffff8804168c2910
[  704.979543]
[  704.979547] Bytes b4 0xffff8804168c1d98:  93 98 ff ff 00 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a ..A?A?....ZZZZZZZZ
[  704.979563]   Object 0xffff8804168c1da8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979578]   Object 0xffff8804168c1db8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979592]   Object 0xffff8804168c1dc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979606]   Object 0xffff8804168c1dd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979620]   Object 0xffff8804168c1de8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979634]   Object 0xffff8804168c1df8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979648]   Object 0xffff8804168c1e08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979662]   Object 0xffff8804168c1e18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979676]   Object 0xffff8804168c1e28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979690]   Object 0xffff8804168c1e38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979704]   Object 0xffff8804168c1e48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979719]   Object 0xffff8804168c1e58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979733]   Object 0xffff8804168c1e68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979747]   Object 0xffff8804168c1e78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979761]   Object 0xffff8804168c1e88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979775]   Object 0xffff8804168c1e98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979789]   Object 0xffff8804168c1ea8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979803]   Object 0xffff8804168c1eb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979817]   Object 0xffff8804168c1ec8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979831]   Object 0xffff8804168c1ed8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979845]   Object 0xffff8804168c1ee8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979859]   Object 0xffff8804168c1ef8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979873]   Object 0xffff8804168c1f08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979888]   Object 0xffff8804168c1f18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979902]   Object 0xffff8804168c1f28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979916]   Object 0xffff8804168c1f38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979930]   Object 0xffff8804168c1f48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979944]   Object 0xffff8804168c1f58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979958]   Object 0xffff8804168c1f68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979972]   Object 0xffff8804168c1f78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.979986]   Object 0xffff8804168c1f88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  704.980000]   Object 0xffff8804168c1f98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  704.980015]  Redzone 0xffff8804168c1fa8:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  704.980028]  Padding 0xffff8804168c1fe8:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  704.980044] Pid: 6812, comm: get-rrdtool-dat Not tainted 2.6.39 #2
[  704.980048] Call Trace:
[  704.980060]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  704.980069]  [<ffffffff81106e49>] ? load_elf_binary+0x179/0x1c00
[  704.980075]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  704.980083]  [<ffffffff81106e49>] ? load_elf_binary+0x179/0x1c00
[  704.980090]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  704.980096]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  704.980102]  [<ffffffff810ba59d>] ? __kmalloc+0x10d/0x160
[  704.980109]  [<ffffffff81106e49>] ? load_elf_binary+0x179/0x1c00
[  704.980117]  [<ffffffff8109b782>] ? __pte_alloc+0x42/0x130
[  704.980123]  [<ffffffff8109b5a5>] ? follow_page+0x325/0x440
[  704.980130]  [<ffffffff8109b5a5>] ? follow_page+0x325/0x440
[  704.980137]  [<ffffffff8109bd9d>] ? __get_user_pages+0x17d/0x530
[  704.980145]  [<ffffffff810c9556>] ? get_arg_page+0x56/0x100
[  704.980152]  [<ffffffff810c8070>] ? search_binary_handler+0x90/0x240
[  704.980158]  [<ffffffff810c9e9f>] ? do_execve+0x22f/0x2f0
[  704.980166]  [<ffffffff810094a6>] ? sys_execve+0x36/0x60
[  704.980175]  [<ffffffff813d78dc>] ? stub_execve+0x6c/0xc0
[  704.980182] FIX kmalloc-512: Restoring 
0xffff8804168c1fee-0xffff8804168c1fef=0x5a
[  704.980185]
[  722.610058] INFO: task ksmd:552 blocked for more than 120 seconds.
[  722.610063] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  722.610069] ksmd            D 0000000000000000     0   552      2 
0x00000000
[  722.610078]  ffff88041db68ca0 0000000000000046 000212d01fc11d00 
ffff880400000000
[  722.610085]  ffffffff81593020 ffff88041c1a9fd8 0000000000004000 
ffff88041c1a8010
[  722.610092]  ffff88041c1a9fd8 ffff88041db68ca0 0000000000000000 
0000000200000002
[  722.610099] Call Trace:
[  722.610115]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  722.610127]  [<ffffffff8102f69c>] ? enqueue_task_fair+0x14c/0x190
[  722.610135]  [<ffffffff8102db27>] ? task_rq_lock+0x47/0x90
[  722.610142]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  722.610148]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  722.610156]  [<ffffffff8104cb94>] ? flush_work+0x24/0x30
[  722.610162]  [<ffffffff8104be10>] ? do_work_for_cpu+0x20/0x20
[  722.610168]  [<ffffffff8104e0ab>] ? schedule_on_each_cpu+0xab/0xe0
[  722.610175]  [<ffffffff810b5c05>] ? ksm_scan_thread+0x7f5/0xc20
[  722.610182]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  722.610188]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  722.610194]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  722.610201]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  722.610208]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  722.610215]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  722.610221]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  722.610226] INFO: task fsnotify_mark:662 blocked for more than 120 
seconds.
[  722.610230] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  722.610235] fsnotify_mark   D 0000000000000000     0   662      2 
0x00000000
[  722.610241]  ffff88041c31d860 0000000000000046 0000000000000000 
0000000000000000
[  722.610248]  ffffffff81593020 ffff88041c365fd8 0000000000004000 
ffff88041c364010
[  722.610255]  ffff88041c365fd8 ffff88041c31d860 0000000000000000 
0000000000000000
[  722.610261] Call Trace:
[  722.610268]  [<ffffffff81035521>] ? load_balance+0x91/0x5e0
[  722.610275]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  722.610282]  [<ffffffff8102f323>] ? pick_next_task_fair+0x103/0x190
[  722.610289]  [<ffffffff813d4a6d>] ? schedule+0x28d/0x910
[  722.610295]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  722.610301]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  722.610308]  [<ffffffff81074420>] ? synchronize_rcu_bh+0x50/0x50
[  722.610313]  [<ffffffff8107446a>] ? synchronize_sched+0x4a/0x50
[  722.610319]  [<ffffffff8104f940>] ? find_ge_pid+0x40/0x40
[  722.610326]  [<ffffffff8105742b>] ? __synchronize_srcu+0x5b/0xc0
[  722.610335]  [<ffffffff810f5f63>] ? fsnotify_mark_destroy+0x83/0x150
[  722.610342]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  722.610350]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  722.610358]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  722.610365]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  722.610371]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  722.610378]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  722.610384]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  722.610392] INFO: task jbd2/md0-8:2528 blocked for more than 120 seconds.
[  722.610396] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  722.610400] jbd2/md0-8      D 0000000000000005     0  2528      2 
0x00000000
[  722.610407]  ffff88041d91c570 0000000000000046 ffff88041baeea28 
ffffea0000000000
[  722.610413]  ffff88041d91a5e0 ffff880419f9bfd8 0000000000004000 
ffff880419f9a010
[  722.610420]  ffff880419f9bfd8 ffff88041d91c570 ffff88041baeea28 
ffffffff810b8495
[  722.610426] Call Trace:
[  722.610432]  [<ffffffff810b8495>] ? init_object+0x85/0xa0
[  722.610438]  [<ffffffff810b8916>] ? free_debug_processing+0x196/0x250
[  722.610447]  [<ffffffff8105adae>] ? ktime_get_ts+0x6e/0xf0
[  722.610455]  [<ffffffff810810f0>] ? __lock_page+0x70/0x70
[  722.610461]  [<ffffffff813d5174>] ? io_schedule+0x84/0xd0
[  722.610469]  [<ffffffff811d4403>] ? 
radix_tree_gang_lookup_tag_slot+0x93/0xf0
[  722.610476]  [<ffffffff810810f9>] ? sleep_on_page+0x9/0x10
[  722.610482]  [<ffffffff813d57df>] ? __wait_on_bit+0x4f/0x80
[  722.610489]  [<ffffffff810812eb>] ? wait_on_page_bit+0x6b/0x80
[  722.610496]  [<ffffffff81052a50>] ? autoremove_wake_function+0x30/0x30
[  722.610504]  [<ffffffff8108a458>] ? pagevec_lookup_tag+0x18/0x20
[  722.610509]  [<ffffffff81081f2a>] ? filemap_fdatawait_range+0xfa/0x180
[  722.610518]  [<ffffffff811be09f>] ? submit_bio+0x6f/0xf0
[  722.610526]  [<ffffffff81176276>] ? 
jbd2_journal_commit_transaction+0x796/0x1270
[  722.610536]  [<ffffffff81179ed1>] ? kjournald2+0xb1/0x1e0
[  722.610542]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  722.610549]  [<ffffffff81179e20>] ? commit_timeout+0x10/0x10
[  722.610556]  [<ffffffff81179e20>] ? commit_timeout+0x10/0x10
[  722.610563]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  722.610569]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  722.610576]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  722.610582]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  722.610591] INFO: task nfsd:4326 blocked for more than 120 seconds.
[  722.610594] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  722.610598] nfsd            D 0000000000000000     0  4326      2 
0x00000000
[  722.610605]  ffff88041b604bc0 0000000000000046 0000000000000016 
ffffffff00000000
[  722.610611]  ffff88041d8fa5e0 ffff88041c527fd8 0000000000004000 
ffff88041c526010
[  722.610617]  ffff88041c527fd8 ffff88041b604bc0 000000000000009c 
ffff880000000000
[  722.610623] Call Trace:
[  722.610630]  [<ffffffff8101e845>] ? amd_flush_garts+0x105/0x140
[  722.610637]  [<ffffffff8101fa80>] ? gart_map_sg+0x480/0x480
[  722.610643]  [<ffffffff8101f5d3>] ? flush_gart+0x23/0x50
[  722.610650]  [<ffffffff81080f98>] ? find_get_page+0x18/0x90
[  722.610657]  [<ffffffff81174b95>] ? do_get_write_access+0x265/0x4a0
[  722.610665]  [<ffffffff81052a50>] ? autoremove_wake_function+0x30/0x30
[  722.610672]  [<ffffffff81174ef9>] ? 
jbd2_journal_get_write_access+0x29/0x50
[  722.610680]  [<ffffffff8115f122>] ? 
__ext4_journal_get_write_access+0x32/0x80
[  722.610689]  [<ffffffff81143908>] ? ext4_reserve_inode_write+0x78/0xa0
[  722.610696]  [<ffffffff81143970>] ? ext4_mark_inode_dirty+0x40/0x1e0
[  722.610703]  [<ffffffff81156c0b>] ? ext4_journal_start_sb+0x6b/0x160
[  722.610711]  [<ffffffff81322645>] ? dev_hard_start_xmit+0x305/0x5f0
[  722.610719]  [<ffffffff81352fd0>] ? ip_finish_output2+0x290/0x290
[  722.610726]  [<ffffffff81143c65>] ? ext4_dirty_inode+0x35/0x70
[  722.610733]  [<ffffffff810e4a08>] ? __mark_inode_dirty+0x38/0x210
[  722.610741]  [<ffffffff810d9317>] ? file_update_time+0xf7/0x180
[  722.610747]  [<ffffffff81082458>] ? __generic_file_aio_write+0x1f8/0x430
[  722.610755]  [<ffffffff81373ef9>] ? udp_sendmsg+0x3c9/0x7e0
[  722.610763]  [<ffffffff81314260>] ? sock_alloc_send_pskb+0x1d0/0x320
[  722.610769]  [<ffffffff81082703>] ? generic_file_aio_write+0x73/0xf0
[  722.610776]  [<ffffffff8113f74e>] ? ext4_file_write+0x6e/0x2b0
[  722.610783]  [<ffffffff810da8ac>] ? iget_locked+0x4c/0x140
[  722.610789]  [<ffffffff8119a590>] ? fh_compose+0x4c0/0x4c0
[  722.610795]  [<ffffffff8113f6e0>] ? ext4_llseek+0x110/0x110
[  722.610803]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
[  722.610811]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
[  722.610819]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
[  722.610825]  [<ffffffff810b8735>] ? alloc_debug_processing+0x145/0x190
[  722.610831]  [<ffffffff810b9bc5>] ? kmem_cache_alloc+0xa5/0xb0
[  722.610838]  [<ffffffff8113f463>] ? ext4_file_open+0x63/0x180
[  722.610844]  [<ffffffff8119c21d>] ? nfsd_vfs_write+0xed/0x3a0
[  722.610851]  [<ffffffff810c1127>] ? __dentry_open+0x1f7/0x2b0
[  722.610857]  [<ffffffff8119c892>] ? nfsd_open+0xf2/0x1b0
[  722.610862]  [<ffffffff8119cd34>] ? nfsd_write+0xf4/0x110
[  722.610868]  [<ffffffff81199930>] ? nfsd_proc_write+0xb0/0x120
[  722.610876]  [<ffffffff811971c5>] ? nfsd_dispatch+0xf5/0x230
[  722.610882]  [<ffffffff813b456f>] ? svc_process+0x4af/0x820
[  722.610887]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  722.610894]  [<ffffffff811977a0>] ? nfsd_svc+0x1b0/0x1b0
[  722.610901]  [<ffffffff8119784d>] ? nfsd+0xad/0x150
[  722.610907]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  722.610913]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  722.610921]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  722.610926]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  765.241265] 
=============================================================================
[  765.241267] BUG kmalloc-512: Object padding overwritten
[  765.241268] 
-----------------------------------------------------------------------------
[  765.241269]
[  765.241271] INFO: 0xffff8804168c1486-0xffff8804168c1487. First byte 
0x0 instead of 0x5a
[  765.241277] INFO: Allocated in bio_kmalloc+0x2d/0x70 age=73010 cpu=5 
pid=2495
[  765.241281] INFO: Freed in r10buf_pool_free+0x71/0x90 age=72999 cpu=5 
pid=1728
[  765.241283] INFO: Slab 0xffffea000e4eea00 objects=28 used=13 
fp=0xffff8804168c1240 flags=0x80000000000040c1
[  765.241284] INFO: Object 0xffff8804168c1240 @offset=4672 
fp=0xffff8804168c0ff8
[  765.241285]
[  765.241286] Bytes b4 0xffff8804168c1230:  95 98 ff ff 00 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a ..A?A?....ZZZZZZZZ
[  765.241291]   Object 0xffff8804168c1240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241294]   Object 0xffff8804168c1250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241298]   Object 0xffff8804168c1260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241301]   Object 0xffff8804168c1270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241305]   Object 0xffff8804168c1280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241308]   Object 0xffff8804168c1290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241312]   Object 0xffff8804168c12a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241315]   Object 0xffff8804168c12b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241319]   Object 0xffff8804168c12c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241322]   Object 0xffff8804168c12d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241326]   Object 0xffff8804168c12e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241329]   Object 0xffff8804168c12f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241332]   Object 0xffff8804168c1300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241336]   Object 0xffff8804168c1310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241339]   Object 0xffff8804168c1320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241343]   Object 0xffff8804168c1330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241346]   Object 0xffff8804168c1340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241350]   Object 0xffff8804168c1350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241353]   Object 0xffff8804168c1360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241357]   Object 0xffff8804168c1370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241360]   Object 0xffff8804168c1380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241364]   Object 0xffff8804168c1390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241367]   Object 0xffff8804168c13a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241371]   Object 0xffff8804168c13b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241374]   Object 0xffff8804168c13c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241378]   Object 0xffff8804168c13d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241381]   Object 0xffff8804168c13e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241385]   Object 0xffff8804168c13f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241388]   Object 0xffff8804168c1400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241392]   Object 0xffff8804168c1410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241395]   Object 0xffff8804168c1420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  765.241399]   Object 0xffff8804168c1430:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  765.241402]  Redzone 0xffff8804168c1440:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  765.241406]  Padding 0xffff8804168c1480:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  765.241410] Pid: 7147, comm: apcaccess Not tainted 2.6.39 #2
[  765.241411] Call Trace:
[  765.241416]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  765.241419]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  765.241421]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  765.241423]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  765.241424]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  765.241426]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  765.241428]  [<ffffffff810ba59d>] ? __kmalloc+0x10d/0x160
[  765.241429]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  765.241432]  [<ffffffff8109bd9d>] ? __get_user_pages+0x17d/0x530
[  765.241434]  [<ffffffff810c9556>] ? get_arg_page+0x56/0x100
[  765.241437]  [<ffffffff811da4ad>] ? strnlen_user+0x2d/0x80
[  765.241439]  [<ffffffff810c8070>] ? search_binary_handler+0x90/0x240
[  765.241440]  [<ffffffff810c9e9f>] ? do_execve+0x22f/0x2f0
[  765.241443]  [<ffffffff810094a6>] ? sys_execve+0x36/0x60
[  765.241446]  [<ffffffff813d78dc>] ? stub_execve+0x6c/0xc0
[  765.241448] FIX kmalloc-512: Restoring 
0xffff8804168c1486-0xffff8804168c1487=0x5a
[  765.241449]
[  789.536436] 
=============================================================================
[  789.536444] BUG kmalloc-2048: Object padding overwritten
[  789.536448] 
-----------------------------------------------------------------------------
[  789.536451]
[  789.536456] INFO: 0xffff8802c8b1a11e-0xffff8802c8b1a11f. First byte 
0x0 instead of 0x5a
[  789.536471] INFO: Allocated in sk_stream_alloc_skb+0x3a/0x110 age=63 
cpu=3 pid=5169
[  789.536482] INFO: Freed in __kfree_skb+0x11/0x90 age=63 cpu=5 pid=0
[  789.536488] INFO: Slab 0xffffea0009be6d40 objects=15 used=4 
fp=0xffff8802c8b198d8 flags=0x80000000000040c1
[  789.536494] INFO: Object 0xffff8802c8b198d8 @offset=6360 
fp=0xffff8802c8b1a968
[  789.536497]
[  789.536501] Bytes b4 0xffff8802c8b198c8:  cc be 00 00 01 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a A?A,......ZZZZZZZZ
[  789.536517]   Object 0xffff8802c8b198d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536532]   Object 0xffff8802c8b198e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536546]   Object 0xffff8802c8b198f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536560]   Object 0xffff8802c8b19908:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536575]   Object 0xffff8802c8b19918:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536589]   Object 0xffff8802c8b19928:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536603]   Object 0xffff8802c8b19938:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536617]   Object 0xffff8802c8b19948:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536631]   Object 0xffff8802c8b19958:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536645]   Object 0xffff8802c8b19968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536660]   Object 0xffff8802c8b19978:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536674]   Object 0xffff8802c8b19988:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536688]   Object 0xffff8802c8b19998:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536702]   Object 0xffff8802c8b199a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536716]   Object 0xffff8802c8b199b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536730]   Object 0xffff8802c8b199c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536745]   Object 0xffff8802c8b199d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536759]   Object 0xffff8802c8b199e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536773]   Object 0xffff8802c8b199f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536787]   Object 0xffff8802c8b19a08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536801]   Object 0xffff8802c8b19a18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536816]   Object 0xffff8802c8b19a28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536830]   Object 0xffff8802c8b19a38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536844]   Object 0xffff8802c8b19a48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536858]   Object 0xffff8802c8b19a58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536872]   Object 0xffff8802c8b19a68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536887]   Object 0xffff8802c8b19a78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536901]   Object 0xffff8802c8b19a88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536915]   Object 0xffff8802c8b19a98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536929]   Object 0xffff8802c8b19aa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536943]   Object 0xffff8802c8b19ab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536958]   Object 0xffff8802c8b19ac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536972]   Object 0xffff8802c8b19ad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.536986]   Object 0xffff8802c8b19ae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537000]   Object 0xffff8802c8b19af8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537014]   Object 0xffff8802c8b19b08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537029]   Object 0xffff8802c8b19b18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537043]   Object 0xffff8802c8b19b28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537057]   Object 0xffff8802c8b19b38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537071]   Object 0xffff8802c8b19b48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537085]   Object 0xffff8802c8b19b58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537100]   Object 0xffff8802c8b19b68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537114]   Object 0xffff8802c8b19b78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537128]   Object 0xffff8802c8b19b88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537143]   Object 0xffff8802c8b19b98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537158]   Object 0xffff8802c8b19ba8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537172]   Object 0xffff8802c8b19bb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537187]   Object 0xffff8802c8b19bc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537201]   Object 0xffff8802c8b19bd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537215]   Object 0xffff8802c8b19be8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537229]   Object 0xffff8802c8b19bf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537244]   Object 0xffff8802c8b19c08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537258]   Object 0xffff8802c8b19c18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537272]   Object 0xffff8802c8b19c28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537286]   Object 0xffff8802c8b19c38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537301]   Object 0xffff8802c8b19c48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537315]   Object 0xffff8802c8b19c58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537329]   Object 0xffff8802c8b19c68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537343]   Object 0xffff8802c8b19c78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537357]   Object 0xffff8802c8b19c88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537372]   Object 0xffff8802c8b19c98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537386]   Object 0xffff8802c8b19ca8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537400]   Object 0xffff8802c8b19cb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537414]   Object 0xffff8802c8b19cc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537428]   Object 0xffff8802c8b19cd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537443]   Object 0xffff8802c8b19ce8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537457]   Object 0xffff8802c8b19cf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537471]   Object 0xffff8802c8b19d08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537485]   Object 0xffff8802c8b19d18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537500]   Object 0xffff8802c8b19d28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537514]   Object 0xffff8802c8b19d38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537528]   Object 0xffff8802c8b19d48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537542]   Object 0xffff8802c8b19d58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537557]   Object 0xffff8802c8b19d68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537571]   Object 0xffff8802c8b19d78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537585]   Object 0xffff8802c8b19d88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537599]   Object 0xffff8802c8b19d98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537613]   Object 0xffff8802c8b19da8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537628]   Object 0xffff8802c8b19db8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537642]   Object 0xffff8802c8b19dc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537656]   Object 0xffff8802c8b19dd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537670]   Object 0xffff8802c8b19de8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537685]   Object 0xffff8802c8b19df8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537699]   Object 0xffff8802c8b19e08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537713]   Object 0xffff8802c8b19e18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537727]   Object 0xffff8802c8b19e28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537742]   Object 0xffff8802c8b19e38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537756]   Object 0xffff8802c8b19e48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537770]   Object 0xffff8802c8b19e58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537784]   Object 0xffff8802c8b19e68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537799]   Object 0xffff8802c8b19e78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537813]   Object 0xffff8802c8b19e88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537827]   Object 0xffff8802c8b19e98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537841]   Object 0xffff8802c8b19ea8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537856]   Object 0xffff8802c8b19eb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537870]   Object 0xffff8802c8b19ec8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537884]   Object 0xffff8802c8b19ed8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537898]   Object 0xffff8802c8b19ee8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537912]   Object 0xffff8802c8b19ef8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537927]   Object 0xffff8802c8b19f08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537941]   Object 0xffff8802c8b19f18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537955]   Object 0xffff8802c8b19f28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537969]   Object 0xffff8802c8b19f38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537984]   Object 0xffff8802c8b19f48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.537998]   Object 0xffff8802c8b19f58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538012]   Object 0xffff8802c8b19f68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538026]   Object 0xffff8802c8b19f78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538041]   Object 0xffff8802c8b19f88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538055]   Object 0xffff8802c8b19f98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538069]   Object 0xffff8802c8b19fa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538083]   Object 0xffff8802c8b19fb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538097]   Object 0xffff8802c8b19fc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538112]   Object 0xffff8802c8b19fd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538126]   Object 0xffff8802c8b19fe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538140]   Object 0xffff8802c8b19ff8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538154]   Object 0xffff8802c8b1a008:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538169]   Object 0xffff8802c8b1a018:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538183]   Object 0xffff8802c8b1a028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538197]   Object 0xffff8802c8b1a038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538211]   Object 0xffff8802c8b1a048:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538226]   Object 0xffff8802c8b1a058:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538240]   Object 0xffff8802c8b1a068:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538254]   Object 0xffff8802c8b1a078:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538268]   Object 0xffff8802c8b1a088:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538283]   Object 0xffff8802c8b1a098:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538297]   Object 0xffff8802c8b1a0a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538311]   Object 0xffff8802c8b1a0b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  789.538325]   Object 0xffff8802c8b1a0c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  789.538340]  Redzone 0xffff8802c8b1a0d8:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  789.538353]  Padding 0xffff8802c8b1a118:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  789.538369] Pid: 5247, comm: qemu Not tainted 2.6.39 #2
[  789.538373] Call Trace:
[  789.538385]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  789.538394]  [<ffffffff81314260>] ? sock_alloc_send_pskb+0x1d0/0x320
[  789.538400]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  789.538407]  [<ffffffff81314260>] ? sock_alloc_send_pskb+0x1d0/0x320
[  789.538414]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  789.538420]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  789.538427]  [<ffffffff810bb70d>] ? __kmalloc_track_caller+0x10d/0x160
[  789.538434]  [<ffffffff813198c2>] ? __alloc_skb+0x72/0x160
[  789.538441]  [<ffffffff81314260>] ? sock_alloc_send_pskb+0x1d0/0x320
[  789.538450]  [<ffffffff8105af7b>] ? getnstimeofday+0x4b/0xd0
[  789.538457]  [<ffffffff81320d32>] ? netif_rx+0xb2/0x120
[  789.538465]  [<ffffffff812b393e>] ? tun_chr_aio_write+0x18e/0x4e0
[  789.538472]  [<ffffffff812b37b0>] ? tun_sendmsg+0x4d0/0x4d0
[  789.538481]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
[  789.538489]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
[  789.538496]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
[  789.538504]  [<ffffffff810c2e7e>] ? sys_writev+0x4e/0xc0
[  789.538513]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
[  789.538519] FIX kmalloc-2048: Restoring 
0xffff8802c8b1a11e-0xffff8802c8b1a11f=0x5a
[  789.538522]
[  825.601291] 
=============================================================================
[  825.601298] BUG kmalloc-512: Object padding overwritten
[  825.601302] 
-----------------------------------------------------------------------------
[  825.601306]
[  825.601311] INFO: 0xffff88041411efe6-0xffff88041411efe7. First byte 
0x0 instead of 0x5a
[  825.601327] INFO: Allocated in sock_alloc_send_pskb+0x1d0/0x320 
age=36742 cpu=3 pid=4846
[  825.601338] INFO: Freed in __kfree_skb+0x11/0x90 age=36742 cpu=3 pid=3781
[  825.601344] INFO: Slab 0xffffea000e463e20 objects=28 used=11 
fp=0xffff88041411eda0 flags=0x80000000000040c1
[  825.601350] INFO: Object 0xffff88041411eda0 @offset=11680 
fp=0xffff88041411cdb0
[  825.601353]
[  825.601357] Bytes b4 0xffff88041411ed90:  e2 96 ff ff 00 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a Ac.A?A?....ZZZZZZZZ
[  825.601373]   Object 0xffff88041411eda0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601388]   Object 0xffff88041411edb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601402]   Object 0xffff88041411edc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601416]   Object 0xffff88041411edd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601430]   Object 0xffff88041411ede0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601444]   Object 0xffff88041411edf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601459]   Object 0xffff88041411ee00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601473]   Object 0xffff88041411ee10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601487]   Object 0xffff88041411ee20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601501]   Object 0xffff88041411ee30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601515]   Object 0xffff88041411ee40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601529]   Object 0xffff88041411ee50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601543]   Object 0xffff88041411ee60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601557]   Object 0xffff88041411ee70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601571]   Object 0xffff88041411ee80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601586]   Object 0xffff88041411ee90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601600]   Object 0xffff88041411eea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601614]   Object 0xffff88041411eeb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601628]   Object 0xffff88041411eec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601642]   Object 0xffff88041411eed0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601656]   Object 0xffff88041411eee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601670]   Object 0xffff88041411eef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601684]   Object 0xffff88041411ef00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601699]   Object 0xffff88041411ef10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601713]   Object 0xffff88041411ef20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601727]   Object 0xffff88041411ef30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601741]   Object 0xffff88041411ef40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601755]   Object 0xffff88041411ef50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601769]   Object 0xffff88041411ef60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601783]   Object 0xffff88041411ef70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601797]   Object 0xffff88041411ef80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  825.601812]   Object 0xffff88041411ef90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  825.601826]  Redzone 0xffff88041411efa0:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  825.601839]  Padding 0xffff88041411efe0:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  825.601855] Pid: 7353, comm: apcaccess Not tainted 2.6.39 #2
[  825.601859] Call Trace:
[  825.601871]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  825.601881]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  825.601887]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  825.601895]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  825.601902]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  825.601908]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  825.601914]  [<ffffffff810ba59d>] ? __kmalloc+0x10d/0x160
[  825.601922]  [<ffffffff8110773c>] ? load_elf_binary+0xa6c/0x1c00
[  825.601930]  [<ffffffff8109bd9d>] ? __get_user_pages+0x17d/0x530
[  825.601938]  [<ffffffff810c9556>] ? get_arg_page+0x56/0x100
[  825.601945]  [<ffffffff810c8070>] ? search_binary_handler+0x90/0x240
[  825.601951]  [<ffffffff810c9e9f>] ? do_execve+0x22f/0x2f0
[  825.601959]  [<ffffffff810094a6>] ? sys_execve+0x36/0x60
[  825.601968]  [<ffffffff813d78dc>] ? stub_execve+0x6c/0xc0
[  825.601975] FIX kmalloc-512: Restoring 
0xffff88041411efe6-0xffff88041411efe7=0x5a
[  825.601978]
[  842.610057] INFO: task ksmd:552 blocked for more than 120 seconds.
[  842.610063] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  842.610069] ksmd            D 0000000000000000     0   552      2 
0x00000000
[  842.610078]  ffff88041db68ca0 0000000000000046 000212d01fc11d00 
ffff880400000000
[  842.610086]  ffffffff81593020 ffff88041c1a9fd8 0000000000004000 
ffff88041c1a8010
[  842.610093]  ffff88041c1a9fd8 ffff88041db68ca0 0000000000000000 
0000000200000002
[  842.610100] Call Trace:
[  842.610116]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  842.610128]  [<ffffffff8102f69c>] ? enqueue_task_fair+0x14c/0x190
[  842.610137]  [<ffffffff8102db27>] ? task_rq_lock+0x47/0x90
[  842.610143]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  842.610150]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  842.610157]  [<ffffffff8104cb94>] ? flush_work+0x24/0x30
[  842.610163]  [<ffffffff8104be10>] ? do_work_for_cpu+0x20/0x20
[  842.610170]  [<ffffffff8104e0ab>] ? schedule_on_each_cpu+0xab/0xe0
[  842.610177]  [<ffffffff810b5c05>] ? ksm_scan_thread+0x7f5/0xc20
[  842.610184]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  842.610190]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  842.610196]  [<ffffffff810b5410>] ? 
try_to_merge_with_ksm_page+0x570/0x570
[  842.610203]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  842.610210]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  842.610218]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  842.610223]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  842.610229] INFO: task fsnotify_mark:662 blocked for more than 120 
seconds.
[  842.610233] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  842.610237] fsnotify_mark   D 0000000000000000     0   662      2 
0x00000000
[  842.610244]  ffff88041c31d860 0000000000000046 0000000000000000 
0000000000000000
[  842.610251]  ffffffff81593020 ffff88041c365fd8 0000000000004000 
ffff88041c364010
[  842.610257]  ffff88041c365fd8 ffff88041c31d860 0000000000000000 
0000000000000000
[  842.610263] Call Trace:
[  842.610270]  [<ffffffff81035521>] ? load_balance+0x91/0x5e0
[  842.610278]  [<ffffffff813d5595>] ? schedule_timeout+0x1c5/0x230
[  842.610285]  [<ffffffff8102f323>] ? pick_next_task_fair+0x103/0x190
[  842.610291]  [<ffffffff813d4a6d>] ? schedule+0x28d/0x910
[  842.610297]  [<ffffffff813d4562>] ? wait_for_common+0xd2/0x180
[  842.610303]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  842.610310]  [<ffffffff81074420>] ? synchronize_rcu_bh+0x50/0x50
[  842.610316]  [<ffffffff8107446a>] ? synchronize_sched+0x4a/0x50
[  842.610322]  [<ffffffff8104f940>] ? find_ge_pid+0x40/0x40
[  842.610329]  [<ffffffff8105742b>] ? __synchronize_srcu+0x5b/0xc0
[  842.610338]  [<ffffffff810f5f63>] ? fsnotify_mark_destroy+0x83/0x150
[  842.610344]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  842.610352]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  842.610360]  [<ffffffff810f5ee0>] ? 
fsnotify_set_mark_ignored_mask_locked+0x20/0x20
[  842.610367]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  842.610373]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  842.610381]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  842.610386]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  842.610395] INFO: task jbd2/md0-8:2528 blocked for more than 120 seconds.
[  842.610399] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  842.610403] jbd2/md0-8      D 0000000000000005     0  2528      2 
0x00000000
[  842.610410]  ffff88041d91c570 0000000000000046 ffff88041baeea28 
ffffea0000000000
[  842.610417]  ffff88041d91a5e0 ffff880419f9bfd8 0000000000004000 
ffff880419f9a010
[  842.610423]  ffff880419f9bfd8 ffff88041d91c570 ffff88041baeea28 
ffffffff810b8495
[  842.610429] Call Trace:
[  842.610435]  [<ffffffff810b8495>] ? init_object+0x85/0xa0
[  842.610442]  [<ffffffff810b8916>] ? free_debug_processing+0x196/0x250
[  842.610450]  [<ffffffff8105adae>] ? ktime_get_ts+0x6e/0xf0
[  842.610458]  [<ffffffff810810f0>] ? __lock_page+0x70/0x70
[  842.610464]  [<ffffffff813d5174>] ? io_schedule+0x84/0xd0
[  842.610473]  [<ffffffff811d4403>] ? 
radix_tree_gang_lookup_tag_slot+0x93/0xf0
[  842.610480]  [<ffffffff810810f9>] ? sleep_on_page+0x9/0x10
[  842.610486]  [<ffffffff813d57df>] ? __wait_on_bit+0x4f/0x80
[  842.610492]  [<ffffffff810812eb>] ? wait_on_page_bit+0x6b/0x80
[  842.610499]  [<ffffffff81052a50>] ? autoremove_wake_function+0x30/0x30
[  842.610507]  [<ffffffff8108a458>] ? pagevec_lookup_tag+0x18/0x20
[  842.610512]  [<ffffffff81081f2a>] ? filemap_fdatawait_range+0xfa/0x180
[  842.610521]  [<ffffffff811be09f>] ? submit_bio+0x6f/0xf0
[  842.610530]  [<ffffffff81176276>] ? 
jbd2_journal_commit_transaction+0x796/0x1270
[  842.610539]  [<ffffffff81179ed1>] ? kjournald2+0xb1/0x1e0
[  842.610546]  [<ffffffff81052a20>] ? wake_up_bit+0x40/0x40
[  842.610553]  [<ffffffff81179e20>] ? commit_timeout+0x10/0x10
[  842.610560]  [<ffffffff81179e20>] ? commit_timeout+0x10/0x10
[  842.610566]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  842.610572]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  842.610580]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  842.610585]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  842.610594] INFO: task nfsd:4326 blocked for more than 120 seconds.
[  842.610598] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  842.610602] nfsd            D 0000000000000000     0  4326      2 
0x00000000
[  842.610608]  ffff88041b604bc0 0000000000000046 0000000000000016 
ffffffff00000000
[  842.610614]  ffff88041d8fa5e0 ffff88041c527fd8 0000000000004000 
ffff88041c526010
[  842.610621]  ffff88041c527fd8 ffff88041b604bc0 000000000000009c 
ffff880000000000
[  842.610626] Call Trace:
[  842.610634]  [<ffffffff8101e845>] ? amd_flush_garts+0x105/0x140
[  842.610640]  [<ffffffff8101fa80>] ? gart_map_sg+0x480/0x480
[  842.610646]  [<ffffffff8101f5d3>] ? flush_gart+0x23/0x50
[  842.610653]  [<ffffffff81080f98>] ? find_get_page+0x18/0x90
[  842.610660]  [<ffffffff81174b95>] ? do_get_write_access+0x265/0x4a0
[  842.610668]  [<ffffffff81052a50>] ? autoremove_wake_function+0x30/0x30
[  842.610675]  [<ffffffff81174ef9>] ? 
jbd2_journal_get_write_access+0x29/0x50
[  842.610684]  [<ffffffff8115f122>] ? 
__ext4_journal_get_write_access+0x32/0x80
[  842.610692]  [<ffffffff81143908>] ? ext4_reserve_inode_write+0x78/0xa0
[  842.610700]  [<ffffffff81143970>] ? ext4_mark_inode_dirty+0x40/0x1e0
[  842.610706]  [<ffffffff81156c0b>] ? ext4_journal_start_sb+0x6b/0x160
[  842.610715]  [<ffffffff81322645>] ? dev_hard_start_xmit+0x305/0x5f0
[  842.610723]  [<ffffffff81352fd0>] ? ip_finish_output2+0x290/0x290
[  842.610730]  [<ffffffff81143c65>] ? ext4_dirty_inode+0x35/0x70
[  842.610738]  [<ffffffff810e4a08>] ? __mark_inode_dirty+0x38/0x210
[  842.610745]  [<ffffffff810d9317>] ? file_update_time+0xf7/0x180
[  842.610751]  [<ffffffff81082458>] ? __generic_file_aio_write+0x1f8/0x430
[  842.610760]  [<ffffffff81373ef9>] ? udp_sendmsg+0x3c9/0x7e0
[  842.610767]  [<ffffffff81314260>] ? sock_alloc_send_pskb+0x1d0/0x320
[  842.610774]  [<ffffffff81082703>] ? generic_file_aio_write+0x73/0xf0
[  842.610781]  [<ffffffff8113f74e>] ? ext4_file_write+0x6e/0x2b0
[  842.610788]  [<ffffffff810da8ac>] ? iget_locked+0x4c/0x140
[  842.610794]  [<ffffffff8119a590>] ? fh_compose+0x4c0/0x4c0
[  842.610800]  [<ffffffff8113f6e0>] ? ext4_llseek+0x110/0x110
[  842.610808]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
[  842.610816]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
[  842.610824]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
[  842.610830]  [<ffffffff810b8735>] ? alloc_debug_processing+0x145/0x190
[  842.610836]  [<ffffffff810b9bc5>] ? kmem_cache_alloc+0xa5/0xb0
[  842.610843]  [<ffffffff8113f463>] ? ext4_file_open+0x63/0x180
[  842.610849]  [<ffffffff8119c21d>] ? nfsd_vfs_write+0xed/0x3a0
[  842.610856]  [<ffffffff810c1127>] ? __dentry_open+0x1f7/0x2b0
[  842.610862]  [<ffffffff8119c892>] ? nfsd_open+0xf2/0x1b0
[  842.610867]  [<ffffffff8119cd34>] ? nfsd_write+0xf4/0x110
[  842.610873]  [<ffffffff81199930>] ? nfsd_proc_write+0xb0/0x120
[  842.610880]  [<ffffffff811971c5>] ? nfsd_dispatch+0xf5/0x230
[  842.610886]  [<ffffffff813b456f>] ? svc_process+0x4af/0x820
[  842.610892]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
[  842.610899]  [<ffffffff811977a0>] ? nfsd_svc+0x1b0/0x1b0
[  842.610906]  [<ffffffff8119784d>] ? nfsd+0xad/0x150
[  842.610912]  [<ffffffff810525b6>] ? kthread+0x96/0xa0
[  842.610918]  [<ffffffff813d8294>] ? kernel_thread_helper+0x4/0x10
[  842.610926]  [<ffffffff81052520>] ? kthread_worker_fn+0x120/0x120
[  842.610931]  [<ffffffff813d8290>] ? gs_change+0xb/0xb
[  854.241450] 
=============================================================================
[  854.241459] BUG kmalloc-1024: Object padding overwritten
[  854.241463] 
-----------------------------------------------------------------------------
[  854.241466]
[  854.241471] INFO: 0xffff8802c86059e6-0xffff8802c86059e7. First byte 
0x0 instead of 0x5a
[  854.241488] INFO: Allocated in __blockdev_direct_IO+0x16c/0xa90 
age=518 cpu=5 pid=7094
[  854.241500] INFO: Freed in __kfree_skb+0x11/0x90 age=519 cpu=5 pid=5247
[  854.241507] INFO: Slab 0xffffea0009bd5000 objects=29 used=22 
fp=0xffff8802c8606f50 flags=0x80000000000040c1
[  854.241513] INFO: Object 0xffff8802c86055a0 @offset=21920 
fp=0xffff8802c86066c0
[  854.241516]
[  854.241520] Bytes b4 0xffff8802c8605590:  00 00 00 00 00 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
[  854.241536]   Object 0xffff8802c86055a0:  00 00 00 00 00 00 00 00 e0 
61 29 fa 03 88 ff ff ........A a)Ao..A?A?
[  854.241551]   Object 0xffff8802c86055b0:  00 00 00 00 00 00 00 00 00 
00 41 ce 04 00 00 00 ..........AA?....
[  854.241565]   Object 0xffff8802c86055c0:  03 00 00 00 0c 00 00 00 00 
00 00 00 01 00 00 00 ................
[  854.241579]   Object 0xffff8802c86055d0:  00 00 00 00 00 00 00 00 00 
60 00 00 00 00 00 00 .........`......
[  854.241593]   Object 0xffff8802c86055e0:  b7 2c 0a 00 00 00 00 00 00 
00 00 00 00 00 00 00 A.,..............
[  854.241607]   Object 0xffff8802c86055f0:  b7 2c 0a 00 00 00 00 00 00 
00 00 00 00 00 00 00 A.,..............
[  854.241621]   Object 0xffff8802c8605600:  01 00 00 00 00 00 00 00 f0 
77 14 81 ff ff ff ff ........A?w..A?A?A?A?
[  854.241635]   Object 0xffff8802c8605610:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241649]   Object 0xffff8802c8605620:  00 00 00 00 00 00 00 00 b7 
54 3b 02 00 00 00 00 ........A.T;.....
[  854.241663]   Object 0xffff8802c8605630:  b7 54 3b 02 00 00 00 00 20 
00 00 00 00 00 00 00 A.T;.............
[  854.241677]   Object 0xffff8802c8605640:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241691]   Object 0xffff8802c8605650:  b6 54 3b 02 00 00 00 00 00 
10 00 00 00 00 00 00 A?T;.............
[  854.241705]   Object 0xffff8802c8605660:  00 00 00 00 00 00 00 00 00 
80 8e 1a 04 88 ff ff ..............A?A?
[  854.241719]   Object 0xffff8802c8605670:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241733]   Object 0xffff8802c8605680:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241747]   Object 0xffff8802c8605690:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241761]   Object 0xffff8802c86056a0:  00 00 00 00 00 00 00 00 00 
00 00 00 00 10 00 00 ................
[  854.241775]   Object 0xffff8802c86056b0:  b6 54 3b 02 00 00 00 00 00 
60 cb a2 00 00 00 00 A?T;......`A?Ac....
[  854.241789]   Object 0xffff8802c86056c0:  06 06 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241803]   Object 0xffff8802c86056d0:  00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 ................
[  854.241817]   Object 0xffff8802c86056e0:  68 fd 1c c9 02 88 ff ff 00 
00 00 00 00 00 00 00 hA 1/2 .A?..A?A?........
[  854.241831]   Object 0xffff8802c86056f0:  00 60 00 00 00 00 00 00 01 
00 00 00 01 00 00 00 .`..............
[  854.241845]   Object 0xffff8802c8605700:  00 80 c9 dd 39 7f 00 00 01 
00 00 00 01 00 00 00 ..A?A?9...........
[  854.241860]   Object 0xffff8802c8605710:  00 00 00 00 00 00 00 00 08 
81 bb 0c 00 ea ff ff ..........A>>..AaA?A?
[  854.241874]   Object 0xffff8802c8605720:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241888]   Object 0xffff8802c8605730:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241902]   Object 0xffff8802c8605740:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241916]   Object 0xffff8802c8605750:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241930]   Object 0xffff8802c8605760:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241944]   Object 0xffff8802c8605770:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241959]   Object 0xffff8802c8605780:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241973]   Object 0xffff8802c8605790:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.241987]   Object 0xffff8802c86057a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242001]   Object 0xffff8802c86057b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242015]   Object 0xffff8802c86057c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242029]   Object 0xffff8802c86057d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242043]   Object 0xffff8802c86057e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242058]   Object 0xffff8802c86057f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242072]   Object 0xffff8802c8605800:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242086]   Object 0xffff8802c8605810:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242100]   Object 0xffff8802c8605820:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242114]   Object 0xffff8802c8605830:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242128]   Object 0xffff8802c8605840:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242142]   Object 0xffff8802c8605850:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242157]   Object 0xffff8802c8605860:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242171]   Object 0xffff8802c8605870:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242185]   Object 0xffff8802c8605880:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242199]   Object 0xffff8802c8605890:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242213]   Object 0xffff8802c86058a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242227]   Object 0xffff8802c86058b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242241]   Object 0xffff8802c86058c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242256]   Object 0xffff8802c86058d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242270]   Object 0xffff8802c86058e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242284]   Object 0xffff8802c86058f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242298]   Object 0xffff8802c8605900:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242312]   Object 0xffff8802c8605910:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242326]   Object 0xffff8802c8605920:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242340]   Object 0xffff8802c8605930:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242355]   Object 0xffff8802c8605940:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242369]   Object 0xffff8802c8605950:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242383]   Object 0xffff8802c8605960:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242397]   Object 0xffff8802c8605970:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242411]   Object 0xffff8802c8605980:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  854.242425]   Object 0xffff8802c8605990:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  854.242440]  Redzone 0xffff8802c86059a0:  cc cc cc cc cc cc cc cc 
                      A?A?A?A?A?A?A?A?
[  854.242453]  Padding 0xffff8802c86059e0:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  854.242470] Pid: 7094, comm: qemu Not tainted 2.6.39 #2
[  854.242474] Call Trace:
[  854.242485]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  854.242492]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  854.242500]  [<ffffffff810f3126>] ? __blockdev_direct_IO+0xa16/0xa90
[  854.242507]  [<ffffffff810b88b3>] ? free_debug_processing+0x133/0x250
[  854.242513]  [<ffffffff810b8afb>] ? __slab_free+0x12b/0x140
[  854.242520]  [<ffffffff810f3126>] ? __blockdev_direct_IO+0xa16/0xa90
[  854.242530]  [<ffffffff81144a17>] ? ext4_ind_direct_IO+0xf7/0x410
[  854.242536]  [<ffffffff811477f0>] ? noalloc_get_block_write+0x30/0x30
[  854.242543]  [<ffffffff81082029>] ? __filemap_fdatawrite_range+0x49/0x50
[  854.242550]  [<ffffffff810830c3>] ? generic_file_aio_read+0x653/0x6d0
[  854.242558]  [<ffffffff810567a2>] ? hrtimer_cancel+0x12/0x20
[  854.242565]  [<ffffffff81062137>] ? futex_wait+0x197/0x240
[  854.242572]  [<ffffffff81082a70>] ? delete_from_page_cache+0x70/0x70
[  854.242580]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
[  854.242587]  [<ffffffff8106239f>] ? futex_wake+0x10f/0x120
[  854.242594]  [<ffffffff81063f7b>] ? do_futex+0x11b/0xa70
[  854.242601]  [<ffffffff810471cc>] ? T.680+0x13c/0x280
[  854.242608]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
[  854.242616]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
[  854.242624]  [<ffffffff810c3003>] ? sys_preadv+0xc3/0xd0
[  854.242633]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
[  854.242640] FIX kmalloc-1024: Restoring 
0xffff8802c86059e6-0xffff8802c86059e7=0x5a
[  854.242643]
[  860.203918] 
=============================================================================
[  860.203927] BUG kmalloc-1024: Object padding overwritten
[  860.203931] 
-----------------------------------------------------------------------------
[  860.203934]
[  860.203939] INFO: 0xffff88041ad15156-0xffff88041ad15157. First byte 
0x0 instead of 0x5a
[  860.203955] INFO: Allocated in __blockdev_direct_IO+0x16c/0xa90 
age=1609 cpu=3 pid=7094
[  860.203965] INFO: Freed in __blockdev_direct_IO+0xa16/0xa90 age=1609 
cpu=3 pid=7094
[  860.203972] INFO: Slab 0xffffea000e5ddb80 objects=29 used=25 
fp=0xffff88041ad14d10 flags=0x80000000000040c1
[  860.203977] INFO: Object 0xffff88041ad14d10 @offset=19728 
fp=0xffff88041ad10000
[  860.203981]
[  860.203984] Bytes b4 0xffff88041ad14d00:  62 28 00 00 01 00 00 00 5a 
5a 5a 5a 5a 5a 5a 5a b(......ZZZZZZZZ
[  860.204000]   Object 0xffff88041ad14d10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204015]   Object 0xffff88041ad14d20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204030]   Object 0xffff88041ad14d30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204044]   Object 0xffff88041ad14d40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204058]   Object 0xffff88041ad14d50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204073]   Object 0xffff88041ad14d60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204087]   Object 0xffff88041ad14d70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204101]   Object 0xffff88041ad14d80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204116]   Object 0xffff88041ad14d90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204130]   Object 0xffff88041ad14da0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204144]   Object 0xffff88041ad14db0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204159]   Object 0xffff88041ad14dc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204173]   Object 0xffff88041ad14dd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204187]   Object 0xffff88041ad14de0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204202]   Object 0xffff88041ad14df0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204216]   Object 0xffff88041ad14e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204230]   Object 0xffff88041ad14e10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204245]   Object 0xffff88041ad14e20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204259]   Object 0xffff88041ad14e30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204273]   Object 0xffff88041ad14e40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204288]   Object 0xffff88041ad14e50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204302]   Object 0xffff88041ad14e60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204316]   Object 0xffff88041ad14e70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204331]   Object 0xffff88041ad14e80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204345]   Object 0xffff88041ad14e90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204359]   Object 0xffff88041ad14ea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204374]   Object 0xffff88041ad14eb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204388]   Object 0xffff88041ad14ec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204402]   Object 0xffff88041ad14ed0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204417]   Object 0xffff88041ad14ee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204431]   Object 0xffff88041ad14ef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204445]   Object 0xffff88041ad14f00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204460]   Object 0xffff88041ad14f10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204474]   Object 0xffff88041ad14f20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204488]   Object 0xffff88041ad14f30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204503]   Object 0xffff88041ad14f40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204517]   Object 0xffff88041ad14f50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204531]   Object 0xffff88041ad14f60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204546]   Object 0xffff88041ad14f70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204560]   Object 0xffff88041ad14f80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204574]   Object 0xffff88041ad14f90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204589]   Object 0xffff88041ad14fa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204603]   Object 0xffff88041ad14fb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204618]   Object 0xffff88041ad14fc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204632]   Object 0xffff88041ad14fd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204646]   Object 0xffff88041ad14fe0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204661]   Object 0xffff88041ad14ff0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204675]   Object 0xffff88041ad15000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204689]   Object 0xffff88041ad15010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204704]   Object 0xffff88041ad15020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204718]   Object 0xffff88041ad15030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204732]   Object 0xffff88041ad15040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204747]   Object 0xffff88041ad15050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204761]   Object 0xffff88041ad15060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204775]   Object 0xffff88041ad15070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204790]   Object 0xffff88041ad15080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204804]   Object 0xffff88041ad15090:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204818]   Object 0xffff88041ad150a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204833]   Object 0xffff88041ad150b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204847]   Object 0xffff88041ad150c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204861]   Object 0xffff88041ad150d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204876]   Object 0xffff88041ad150e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204890]   Object 0xffff88041ad150f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  860.204904]   Object 0xffff88041ad15100:  6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkkAJPY
[  860.204919]  Redzone 0xffff88041ad15110:  bb bb bb bb bb bb bb bb 
                      A>>A>>A>>A>>A>>A>>A>>A>>
[  860.204932]  Padding 0xffff88041ad15150:  5a 5a 5a 5a 5a 5a 00 00 
                      ZZZZZZ..
[  860.204949] Pid: 7100, comm: qemu Not tainted 2.6.39 #2
[  860.204953] Call Trace:
[  860.204964]  [<ffffffff810b7ccd>] ? check_bytes_and_report+0x10d/0x150
[  860.204973]  [<ffffffff810f287c>] ? __blockdev_direct_IO+0x16c/0xa90
[  860.204979]  [<ffffffff810b7db9>] ? check_object+0xa9/0x260
[  860.204986]  [<ffffffff810f287c>] ? __blockdev_direct_IO+0x16c/0xa90
[  860.204993]  [<ffffffff810b86f4>] ? alloc_debug_processing+0x104/0x190
[  860.204999]  [<ffffffff810b9ac2>] ? T.912+0x272/0x2d0
[  860.205006]  [<ffffffff810b9bc5>] ? kmem_cache_alloc+0xa5/0xb0
[  860.205013]  [<ffffffff810f287c>] ? __blockdev_direct_IO+0x16c/0xa90
[  860.205022]  [<ffffffff8108a475>] ? pagevec_lookup+0x15/0x20
[  860.205029]  [<ffffffff8108b5b7>] ? 
invalidate_inode_pages2_range+0x87/0x300
[  860.205039]  [<ffffffff81144e41>] ? ext4_direct_IO+0x111/0x1f0
[  860.205045]  [<ffffffff811477a0>] ? _ext4_get_block+0x160/0x160
[  860.205052]  [<ffffffff81144f20>] ? ext4_direct_IO+0x1f0/0x1f0
[  860.205058]  [<ffffffff81082182>] ? generic_file_direct_write+0xd2/0x1b0
[  860.205064]  [<ffffffff8108252b>] ? __generic_file_aio_write+0x2cb/0x430
[  860.205071]  [<ffffffff81082703>] ? generic_file_aio_write+0x73/0xf0
[  860.205079]  [<ffffffff8113f74e>] ? ext4_file_write+0x6e/0x2b0
[  860.205087]  [<ffffffff810c25ef>] ? do_sync_write+0xbf/0x100
[  860.205095]  [<ffffffff810471cc>] ? T.680+0x13c/0x280
[  860.205103]  [<ffffffff810485a8>] ? kill_pid_info+0x38/0x60
[  860.205110]  [<ffffffff81048854>] ? sys_kill+0x94/0x1b0
[  860.205117]  [<ffffffff810c3198>] ? vfs_write+0xc8/0x190
[  860.205124]  [<ffffffff810c32fb>] ? sys_pwrite64+0x9b/0xb0
[  860.205134]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
[  860.205140] FIX kmalloc-1024: Restoring 
0xffff88041ad15156-0xffff88041ad15157=0x5a
[  860.205143]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
