Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97C06900146
	for <linux-mm@kvack.org>; Sun,  4 Sep 2011 20:57:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4C6F13EE0BB
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:57:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3133F45DEB2
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:57:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15D9D45DE9E
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:57:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A2281DB803B
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:57:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDDDD1DB8037
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:57:24 +0900 (JST)
Date: Mon, 5 Sep 2011 09:49:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 3.0.3 oops. memory related?
Message-Id: <20110905094956.186d3830.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E63C846.10606@gmail.com>
References: <4E63C846.10606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anders <aeriksson2@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Sun, 04 Sep 2011 20:49:42 +0200
Anders <aeriksson2@gmail.com> wrote:

> I've got kdump setup to collect oopes. I found this in the log. Not sure
> what it's related to.
> 

> <4>[47900.533010]  [<ffffffff810ab79f>] ?
> mem_cgroup_count_vm_event+0x15/0x67
> <4>[47900.533010]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
> <4>[47900.533010]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
> <4>[47900.533010]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
> <4>[47900.533010]  [<ffffffff81022b80>] ? check_preempt_curr+0x36/0x62
> <4>[47900.533010]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
> <4>[47900.533010]  [<ffffffff810bfd2c>] ?
> poll_select_copy_remaining+0xce/0xed
> <4>[47900.533010]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30

I'll check memcg but...not sure what parts in above log are garbage.
At quick glance, mem_cgroup_count_vm_event() does enough NULL check
but faulted address was..

> <0>[47900.533010] CR2: ffffc5217e257cf0

This seems not NULL referencing.

#define VMALLOC_START    _AC(0xffffc90000000000, UL)
#define VMALLOC_END      _AC(0xffffe8ffffffffff, UL)

This is not vmalloc area...hmm. could you show your disassemble of
mem_cgroup_count_vm_event() ? and .config ?

Thanks,
-Kame 





> -Anders
> 
> 
> <0>[47900.532505] Oops: 0000 [#1] PREEMPT SMP
> <4>[47900.532618] CPU 1
> <4>[47900.532668] Modules linked in: saa7134_alsa tda1004x saa7134_dvb
> videobuf_dvb dvb_core ir_kbd_i2c tda827x snd_hda_codec_realtek tda8290
> tuner saa7134 videobuf_dma_sg snd_hda_intel videobuf_core v4l2_common
> videodev snd_hda_codec ir_lirc_codec lirc_dev sg ir_sony_decoder
> ir_jvc_decoder v4l2_compat_ioctl32 tveeprom ir_rc6_decoder rc_imon_mce
> ir_rc5_decoder atiixp rtc_cmos ir_nec_decoder imon rc_core parport_pc
> parport i2c_piix4 pcspkr snd_hwdep asus_atk0110
> <4>[47900.533010]
> <4>[47900.533010] Pid: 23858, comm: mencoder Not tainted 3.0.3-dirty #37
> System manufacturer System Product Name/M2A-VM HDMI
> <4>[47900.533010] RIP: 0010:[<ffffffff81097d18>]  [<ffffffff81097d18>]
> handle_pte_fault+0x24/0x70a
> <4>[47900.533010] RSP: 0000:ffff880024c27db8  EFLAGS: 00010296
> <4>[47900.533010] RAX: 0000000000000cf0 RBX: ffff88006c3b2a68 RCX:
> ffffc5217e257cf0
> <4>[47900.533010] RDX: 000000000059effe RSI: ffff88006c3b2a68 RDI:
> ffff88006d6d2ac0
> <4>[47900.533010] RBP: ffffc5217e257cf0 R08: ffff880024d3b010 R09:
> 0000000000000028
> <4>[47900.533010] R10: ffffffff81049bb3 R11: ffff880077c10a80 R12:
> ffff88006d6d2ac0
> <4>[47900.533010] R13: ffff880025ee4050 R14: ffff88006c3b2a68 R15:
> 000000000059effe
> <4>[47900.533010] FS:  00007fe0ee868700(0000) GS:ffff880077c80000(0000)
> knlGS:0000000000000000
> <4>[47900.533010] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> <4>[47900.533010] CR2: ffffc5217e257cf0 CR3: 000000006eb49000 CR4:
> 00000000000006e0
> <4>[47900.533010] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> <4>[47900.533010] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> <4>[47900.533010] Process mencoder (pid: 23858, threadinfo
> ffff880024c26000, task ffff880025ee4050)
> <0>[47900.533010] Stack:
> <4>[47900.533010]  0000000000004000 0000000000000000 0000000000000000
> 0000000000004000
> <4>[47900.533010]  0000000000000028 0000000000000000 ffff880024d3b010
> ffffffff810ab79f
> <4>[47900.533010]  0000000000000000 000000000059effe 000000000059effe
> ffffffff810987e5
> <0>[47900.533010] Call Trace:
> <4>[47900.533010]  [<ffffffff810ab79f>] ?
> mem_cgroup_count_vm_event+0x15/0x67
> <4>[47900.533010]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
> <4>[47900.533010]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
> <4>[47900.533010]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
> <4>[47900.533010]  [<ffffffff81022b80>] ? check_preempt_curr+0x36/0x62
> <4>[47900.533010]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
> <4>[47900.533010]  [<ffffffff810bfd2c>] ?
> poll_select_copy_remaining+0xce/0xed
> <4>[47900.533010]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30
> <0>[47900.533010] Code: 41 5d 41 5e 41 5f c3 41 57 49 89 d7 41 56 41 55
> 41 54 49 89 fc 55 48 89 cd 53 48 89 f3 48 83 ec 68 4c 89 44 24 30 44 89
> 4c 24 20 <4c> 8b 31 44 89 f0 25 ff 0f 00 00 a9 01 01 00 00 0f 85 22 06 00
> <1>[47900.533010] RIP  [<ffffffff81097d18>] handle_pte_fault+0x24/0x70a
> <4>[47900.533010]  RSP <ffff880024c27db8>
> <0>[47900.533010] CR2: ffffc5217e257cf0
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
