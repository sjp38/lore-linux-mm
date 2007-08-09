Date: Thu, 9 Aug 2007 09:31:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc2-mm1
Message-Id: <20070809093136.fea96534.akpm@linux-foundation.org>
In-Reply-To: <46BB3499.5090803@googlemail.com>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
	<46BB3499.5090803@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 09 Aug 2007 17:36:57 +0200 Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Andrew Morton pisze:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm1/
> > 
> 
> bash_shared_mapping triggered this
> 
> [  874.714700] INFO: trying to register non-static key.
> [  874.719659] the code is fine but needs lockdep annotation.
> [  874.725133] turning off the locking correctness validator.
> [  874.730606]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
> [  874.735759]  [<c0405ff3>] show_trace+0x12/0x14
> [  874.740218]  [<c0406128>] dump_stack+0x16/0x18
> [  874.744679]  [<c044b936>] __lock_acquire+0x598/0x125c
> [  874.749745]  [<c044c6a1>] lock_acquire+0xa7/0xc1
> [  874.754378]  [<c069f753>] _spin_lock_irqsave+0x41/0x6e
> [  874.759529]  [<c05259db>] prop_norm_single+0x34/0x8a
> [  874.764508]  [<c0473576>] set_page_dirty+0xa1/0x13b
> [  874.769402]  [<c0482bd1>] try_to_unmap_one+0xb8/0x1e7
> [  874.774467]  [<c0482d8f>] try_to_unmap+0x8f/0x40d
> [  874.779187]  [<c04776fd>] shrink_page_list+0x278/0x750
> [  874.784339]  [<c0477ccb>] shrink_inactive_list+0xf6/0x328
> [  874.789749]  [<c0477faa>] shrink_zone+0xad/0x10b
> [  874.794383]  [<c047866e>] try_to_free_pages+0x178/0x274
> [  874.799620]  [<c0472a36>] __alloc_pages+0x169/0x431
> [  874.804514]  [<c047501d>] __do_page_cache_readahead+0x141/0x207
> [  874.810443]  [<c047545c>] do_page_cache_readahead+0x48/0x5c
> [  874.816027]  [<c046f3a3>] filemap_fault+0x2dd/0x4cf
> [  874.820921]  [<c047b5c9>] __do_fault+0xb6/0x42d
> [  874.825466]  [<c047d0d5>] handle_mm_fault+0x1b6/0x750
> [  874.830533]  [<c041cd7b>] do_page_fault+0x334/0x5f9
> [  874.835425]  [<c069fe72>] error_code+0x72/0x78
> [  874.839886]  =======================

I'd assume that the lib/proportions code went and passed a garbage pointer into
spin_lock_irqsave().  Or maybe it has a correct pointer but didn't initialise the
spinlock.

> [  880.621883] BUG: NMI Watchdog detected LOCKUP on CPU1, eip c0529022, registers:
> [  880.629200] Modules linked in: ext2 loop autofs4 af_packet nf_conntrack_netbios_ns nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink ipt_REJECT iptable_filter ip_tables xt_tcpudp ip6t_REJECT ip6table_filter ip6_tables x_tables firmware_class binfmt_misc fan ipv6 nvram snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer evdev snd soundcore i2c_i801 snd_page_alloc intel_agp agpgart rtc
> [  880.672397] CPU:    1

This will be a consequence of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
