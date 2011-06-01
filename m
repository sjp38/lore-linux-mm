Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 740AC6B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 19:04:01 -0400 (EDT)
Date: Thu, 2 Jun 2011 09:03:42 +1000
From: CaT <cat@zip.com.au>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Message-ID: <20110601230342.GC3956@zip.com.au>
References: <20110601011527.GN19505@random.random>
 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
 <4DE5DCA8.7070704@fnarfbargle.com>
 <4DE5E29E.7080009@redhat.com>
 <4DE60669.9050606@fnarfbargle.com>
 <4DE60918.3010008@redhat.com>
 <4DE60940.1070107@redhat.com>
 <4DE61A2B.7000008@fnarfbargle.com>
 <20110601111841.GB3956@zip.com.au>
 <4DE62801.9080804@fnarfbargle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE62801.9080804@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>

On Wed, Jun 01, 2011 at 07:52:33PM +0800, Brad Campbell wrote:
> Unfortunately the only interface that is mentioned by name anywhere
> in my firewall is $DMZ (which is ppp0 and not part of any bridge).
> 
> All of the nat/dnat and other horrible hacks are based on IP addresses.

Damn. Not referencing the bridge interfaces at all stopped our host from
going down in flames when we passed it a few packets. These are two
of the oopses we got from it. Whilst the kernel here is .35 we got the
same issue from a range of kernels. Seems related.

The oopses may be a bit weird. Copy and paste from an ipmi terminal.


slab error in cache_alloc_debugcheck_after(): cache `size-64': double 
free, or n
Pid: 2431, comm: kvm Tainted: G      D     
2.6.35.9-local.20110314-141930 #1
Call Trace:
<IRQ>  [<ffffffff810fb8bf>] ? __slab_error+0x1f/0x30
  [<ffffffff810fc22b>] ? cache_alloc_debugcheck_after+0x6b/0x1f0
  [<ffffffff81530a00>] ? br_nf_pre_routing_finish+0x0/0x370
  [<ffffffff8153106b>] ? br_nf_pre_routing+0x2fb/0x980
  [<ffffffff810fdd3d>] ? kmem_cache_alloc_notrace+0x7d/0xf0

  [<ffffffff8153106b>] ? br_nf_pre_routing+0x2fb/0x980
  [<ffffffff81466e66>] ? nf_iterate+0x66/0xb0
  [<ffffffff8152b9f0>] ? br_handle_frame_finish+0x0/0x1c0
  [<ffffffff81466f14>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff8152b9f0>] ? br_handle_frame_finish+0x0/0x1c0
  [<ffffffff8152bd3c>] ? br_handle_frame+0x18c/0x250
  [<ffffffff81445459>] ? __netif_receive_skb+0x169/0x2a0
  [<ffffffff81445673>] ? process_backlog+0xe3/0x1d0
  [<ffffffff81446347>] ? net_rx_action+0x87/0x1c0
  [<ffffffff810793f7>] ? __do_softirq+0xa7/0x1d0
  [<ffffffff81035b8c>] ? call_softirq+0x1c/0x30
<EOI>  [<ffffffff81037c6d>] ? do_softirq+0x4d/0x80
  [<ffffffff81446b4e>] ? netif_rx_ni+0x1e/0x30
  [<ffffffff8139541a>] ? tun_chr_aio_write+0x36a/0x510
  [<ffffffff813950b0>] ? tun_chr_aio_write+0x0/0x510
  [<ffffffff81102859>] ? do_sync_readv_writev+0xa9/0xf0
  [<ffffffff810973fb>] ? ktime_get+0x5b/0xe0
  [<ffffffff8104f958>] ? lapic_next_event+0x18/0x20
  [<ffffffff8109be18>] ? tick_dev_program_event+0x38/0x100
  [<ffffffff81102697>] ? rw_copy_check_uvector+0x77/0x130
  [<ffffffff81102f0c>] ? do_readv_writev+0xdc/0x200
  [<ffffffff8108dfec>] ? sys_timer_settime+0x13c/0x2e0
  [<ffffffff8110317e>] ? sys_writev+0x4e/0x90
  [<ffffffff81034d6b>] ? system_call_fastpath+0x16/0x1b
ffff8801e7621500: redzone 1:0xbf05bd0100000006, redzone 2:0x9f911029d74e35b

----------

Code: 40 01 00 00 4c 8b a4 24 48 01 00 00 4c 8b ac 24 50 01 00 00 4c 8b 
b4 24 5
RIP  [<ffffffff81652c67>] icmp_send+0x297/0x650
  RSP <ffff880001c036b8>
---[ end trace 9d3f7be7684ac91e ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     
2.6.35.9-local.20110314-144920 #2
Call Trace:
<IRQ>  [<ffffffff8170eada>] ? panic+0x94/0x116
  [<ffffffff81711326>] ? _raw_spin_lock_irqsave+0x26/0x40
  [<ffffffff8103a05f>] ? oops_end+0xef/0xf0
  [<ffffffff81711a15>] ? general_protection+0x25/0x30
  [<ffffffff81652c2f>] ? icmp_send+0x25f/0x650
  [<ffffffff81652c67>] ? icmp_send+0x297/0x650
  [<ffffffff815fd8e6>] ? nf_iterate+0x66/0xb0
  [<ffffffff816dbfa0>] ? br_nf_forward_finish+0x0/0x170
  [<ffffffff815fd994>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff816dbfa0>] ? br_nf_forward_finish+0x0/0x170
  [<ffffffff816dc461>] ? br_nf_forward_ip+0x201/0x3e0
  [<ffffffff815fd8e6>] ? nf_iterate+0x66/0xb0
  [<ffffffff816d6620>] ? br_forward_finish+0x0/0x60
  [<ffffffff815fd994>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff816d6620>] ? br_forward_finish+0x0/0x60
  [<ffffffff816d66e9>] ? __br_forward+0x69/0xb0
  [<ffffffff816d741a>] ? br_handle_frame_finish+0x12a/0x280
  [<ffffffff816dcac8>] ? br_nf_pre_routing_finish+0x208/0x370
  [<ffffffff815fd994>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff816dc8c0>] ? br_nf_pre_routing_finish+0x0/0x370
  [<ffffffff816dc538>] ? br_nf_forward_ip+0x2d8/0x3e0
  [<ffffffff816dd3b5>] ? br_nf_pre_routing+0x785/0x980
  [<ffffffff815fd8e6>] ? nf_iterate+0x66/0xb0
  [<ffffffff815fd994>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff816d72f0>] ? br_handle_frame_finish+0x0/0x280
  [<ffffffff815fd994>] ? nf_hook_slow+0x64/0xf0
  [<ffffffff816d72f0>] ? br_handle_frame_finish+0x0/0x280
  [<ffffffff816d76fc>] ? br_handle_frame+0x18c/0x250
  [<ffffffff815dec5b>] ? __netif_receive_skb+0x1cb/0x350
  [<ffffffff8103d115>] ? read_tsc+0x5/0x20
  [<ffffffff815dfa18>] ? netif_receive_skb+0x78/0x80
  [<ffffffff815e0217>] ? napi_gro_receive+0x27/0x40
  [<ffffffff815e01d8>] ? napi_skb_finish+0x38/0x50
  [<ffffffff8152586d>] ? bnx2_poll_work+0xd0d/0x13d0
  [<ffffffff8160c950>] ? ctnetlink_conntrack_event+0x210/0x7d0
  [<ffffffff81092029>] ? autoremove_wake_function+0x9/0x30
  [<ffffffff8109a71b>] ? ktime_get+0x5b/0xe0
  [<ffffffff81526051>] ? bnx2_poll+0x61/0x230
  [<ffffffff81051db8>] ? lapic_next_event+0x18/0x20
  [<ffffffff815dfbef>] ? net_rx_action+0x9f/0x200
  [<ffffffff8109636f>] ? __hrtimer_start_range_ns+0x22f/0x410
  [<ffffffff8107c35f>] ? __do_softirq+0xaf/0x1e0
  [<ffffffff810ab547>] ? handle_IRQ_event+0x47/0x160
  [<ffffffff81036d5c>] ? call_softirq+0x1c/0x30
  [<ffffffff81038c85>] ? do_softirq+0x65/0xa0
  [<ffffffff8107c235>] ? irq_exit+0x85/0x90
  [<ffffffff8103820b>] ? do_IRQ+0x6b/0xe0
  [<ffffffff817117d3>] ? ret_from_intr+0x0/0x11
<EOI>  [<ffffffff81269340>] ? intel_idle+0xf0/0x180
  [<ffffffff81269320>] ? intel_idle+0xd0/0x180
  [<ffffffff815b0b0f>] ? cpuidle_idle_call+0x9f/0x140
  [<ffffffff81035032>] ? cpu_idle+0x62/0xb0
  [<ffffffff81a40c77>] ? start_kernel+0x2ef/0x2fa
  [<ffffffff81a403e3>] ? x86_64_start_kernel+0xfb/0x10a



-- 
  "A search of his car uncovered pornography, a homemade sex aid, women's 
  stockings and a Jack Russell terrier."
    - http://www.dailytelegraph.com.au/news/wacky/indeed/story-e6frev20-1111118083480

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
