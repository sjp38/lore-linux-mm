Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 621486B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 05:41:16 -0400 (EDT)
Message-ID: <4DE60918.3010008@redhat.com>
Date: Wed, 01 Jun 2011 12:40:40 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com>
In-Reply-To: <4DE60669.9050606@fnarfbargle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 06/01/2011 12:29 PM, Brad Campbell wrote:
> On 01/06/11 14:56, Avi Kivity wrote:
>> On 06/01/2011 09:31 AM, Brad Campbell wrote:
>>> On 01/06/11 12:52, Hugh Dickins wrote:
>>>
>>>>
>>>> I guess Brad could try SLUB debugging, boot with slub_debug=P
>>>> for poisoning perhaps; though it might upset alignments and
>>>> drive the problem underground. Or see if the same happens
>>>> with SLAB instead of SLUB.
>>>
>>> Not much use I'm afraid.
>>> This is all I get in the log
>>>
>>> [ 3161.300073]
>>> ============================================================================= 
>>>
>>>
>>> [ 3161.300147] BUG kmalloc-512: Freechain corrupt
>>>
>>> The qemu process is then frozen, unkillable but reported in state "R"
>>>
>>> 13881 ? R 3:27 /usr/bin/qemu -S -M pc-0.13 -enable-kvm -m 1024 -smp
>>> 2,sockets=2,cores=1,threads=1 -nam
>>>
>>> The machine then progressively dies until it's frozen solid with no
>>> further error messages.
>>>
>>> I stupidly forgot to do an alt-sysrq-t prior to doing an alt-sysrq-b,
>>> but at least it responded to that.
>>>
>>> On the bright side I can reproduce it at will.
>>
>> Please try slub_debug=FZPU; that should point the finger (hopefully at
>> somebody else).
>>
>
> Well the first attempt locked the machine solid. No network, no console..
>
> I saw 
> "=========================================================================="
>
> on the console.. nothing after that. Would not respond to sysrq-t or 
> any other sysrq combination other than -b, which rebooted the box.
>
>
> No output on netconsole at all, I had to walk to the other building to 
> look at the monitor and reboot it.
>
> The second attempt jammed netconsole again, but I managed to get this 
> from an ssh session I already had established. The machine died a slow 
> and horrible death, but remained interactive enough for me to reboot 
> it with
>
> echo b > /proc/sysrq-trigger
>
> Nothing else worked.
>
>
> [  413.756416]  [<ffffffff81318f1c>] ? pskb_expand_head+0x15c/0x250
> [  413.756424]  [<ffffffff813a6c45>] ? nf_bridge_copy_header+0x145/0x160
> [  413.756431]  [<ffffffff8139f78d>] ? br_dev_queue_push_xmit+0x6d/0x80
> [  413.756439]  [<ffffffff813a55a0>] ? br_nf_post_routing+0x2a0/0x2f0
> [  413.756447]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
> [  413.756453]  [<ffffffff8139f720>] ? br_flood_deliver+0x20/0x20
> [  413.756459]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
> [  413.756465]  [<ffffffff8139f720>] ? br_flood_deliver+0x20/0x20
> [  413.756472]  [<ffffffff8139f7da>] ? br_forward_finish+0x3a/0x60
> [  413.756479]  [<ffffffff813a5758>] ? br_nf_forward_finish+0x168/0x170
> [  413.756487]  [<ffffffff813a5c90>] ? br_nf_forward_ip+0x360/0x3a0
> [  413.756492]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
> [  413.756498]  [<ffffffff8139f7a0>] ? br_dev_queue_push_xmit+0x80/0x80
> [  413.756504]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
> [  413.756510]  [<ffffffff8139f7a0>] ? br_dev_queue_push_xmit+0x80/0x80
> [  413.756516]  [<ffffffff8139f800>] ? br_forward_finish+0x60/0x60
> [  413.756522]  [<ffffffff8139f800>] ? br_forward_finish+0x60/0x60
> [  413.756528]  [<ffffffff8139f875>] ? __br_forward+0x75/0xc0
> [  413.756534]  [<ffffffff8139f426>] ? deliver_clone+0x36/0x60
> [  413.756540]  [<ffffffff8139f69d>] ? br_flood+0xbd/0x100
> [  413.756546]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
> [  413.756552]  [<ffffffff813a080e>] ? br_handle_frame_finish+0x25e/0x280
> [  413.756560]  [<ffffffff813a60f0>] ? 
> br_nf_pre_routing_finish+0x1a0/0x330
> [  413.756568]  [<ffffffff813a6958>] ? br_nf_pre_routing+0x6d8/0x800
> [  413.756577]  [<ffffffff8102d46a>] ? enqueue_task+0x3a/0x90
> [  413.756582]  [<ffffffff81346bc4>] ? nf_iterate+0x84/0xb0
> [  413.756589]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
> [  413.756594]  [<ffffffff81346c64>] ? nf_hook_slow+0x74/0x120
> [  413.756600]  [<ffffffff813a05b0>] ? br_handle_local_finish+0x40/0x40
> [  413.756607]  [<ffffffff810339b0>] ? try_to_wake_up+0x2c0/0x2c0
> [  413.756613]  [<ffffffff813a09d9>] ? br_handle_frame+0x1a9/0x280
> [  413.756620]  [<ffffffff813a0830>] ? br_handle_frame_finish+0x280/0x280
> [  413.756627]  [<ffffffff81320ef7>] ? __netif_receive_skb+0x157/0x5c0
> [  413.756634]  [<ffffffff81321443>] ? process_backlog+0xe3/0x1d0
> [  413.756641]  [<ffffffff81321da5>] ? net_rx_action+0xc5/0x1d0
> [  413.756650]  [<ffffffff8103df11>] ? __do_softirq+0x91/0x120
> [  413.756657]  [<ffffffff813d838c>] ? call_softirq+0x1c/0x30
> [  413.756660] <EOI>  [<ffffffff81003cbd>] ? do_softirq+0x4d/0x80
> [  413.756673]  [<ffffffff81321ece>] ? netif_rx_ni+0x1e/0x30
> [  413.756681]  [<ffffffff812b3ae2>] ? tun_chr_aio_write+0x332/0x4e0
> [  413.756688]  [<ffffffff812b37b0>] ? tun_sendmsg+0x4d0/0x4d0
> [  413.756697]  [<ffffffff810c24e9>] ? do_sync_readv_writev+0xa9/0xf0
> [  413.756704]  [<ffffffff81063f9c>] ? do_futex+0x13c/0xa70
> [  413.756711]  [<ffffffff811d6730>] ? timerqueue_add+0x60/0xb0
> [  413.756719]  [<ffffffff81056ab7>] ? 
> __hrtimer_start_range_ns+0x1e7/0x410
> [  413.756726]  [<ffffffff810c231b>] ? rw_copy_check_uvector+0x7b/0x140
> [  413.756734]  [<ffffffff810c2bcf>] ? do_readv_writev+0xdf/0x210
> [  413.756742]  [<ffffffff810c2e7e>] ? sys_writev+0x4e/0xc0
> [  413.756750]  [<ffffffff813d753b>] ? system_call_fastpath+0x16/0x1b
> [  413.756756] FIX kmalloc-1024: Restoring 
> 0xffff880417179566-0xffff880417179567=0x5a

bridge and netfilter, IIRC this was also the problem last time.

Do you have any ebtables loaded?

Can you try building a kernel without ebtables?  Without netfilter at all?

Please run all tests with slub_debug=FZPU.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
