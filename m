Received: by ug-out-1314.google.com with SMTP id c2so404065ugf
        for <linux-mm@kvack.org>; Thu, 09 Aug 2007 09:45:14 -0700 (PDT)
Message-ID: <46BB3E92.5040007@googlemail.com>
Date: Thu, 09 Aug 2007 18:19:30 +0200
MIME-Version: 1.0
Subject: Re: 2.6.23-rc2-mm1
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org> <46BB3499.5090803@googlemail.com>
In-Reply-To: <46BB3499.5090803@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@googlemail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Piotrowski pisze:
> Andrew Morton pisze:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm1/
>>
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
> [  880.621883] BUG: NMI Watchdog detected LOCKUP on CPU1, eip c0529022, registers:
> [  880.629200] Modules linked in: ext2 loop autofs4 af_packet nf_conntrack_netbios_ns nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink ipt_REJECT iptable_filter ip_tables xt_tcpudp ip6t_REJECT ip6table_filter ip6_tables x_tables firmware_class binfmt_misc fan ipv6 nvram snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer evdev snd soundcore i2c_i801 snd_page_alloc intel_agp agpgart rtc
> [  880.672397] CPU:    1
> [  880.672398] EIP:    0060:[<c0529022>]    Not tainted VLI
> [  880.672400] EFLAGS: 00000046   (2.6.23-rc2-mm1 #3)
> [  880.684735] EIP is at delay_tsc+0xe/0x17
> 
> l *delay_tsc+0xe
> 0xc1129022 is in delay_tsc (/home/devel/linux-mm/arch/i386/lib/delay.c:49).
> 44
> 45              rdtscl(bclock);
> 46              do {
> 47                      rep_nop();
> 48                      rdtscl(now);
> 49              } while ((now-bclock) < loops);
> 50      }
> 51
> 52      /*
> 53       * Since we calibrate only once at boot, this
> 
> 
> [  880.688646] eax: 393e5d7c   ebx: 00000001   ecx: 393e5d04   edx: 0000023f
> [  880.695414] esi: 00000000   edi: cabbf5cc   ebp: caf29ae8   esp: caf29ae4
> [  880.702183] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> [  880.708002] Process firefox-bin (pid: 2625, ti=caf29000 task=cabbe900 task.ti=caf29000)
> [  880.715805] Stack: 02e6eb94 caf29af0 c0528fdd caf29b28 c05375ac 00000046 00000000 caf29b28 
> [  880.724345]        00000046 00000000 a6c999f0 00000001 a6c999f0 00000000 cabbf5e0 cabbf5cc 
> [  880.732887]        00000086 caf29b48 c069f76f 00000000 00000002 c05259db cabbf5c0 00008000 
> [  880.741425] Call Trace:
> [  880.744073]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
> [  880.749233]  [<c040542a>] show_stack_log_lvl+0xa9/0xd5
> [  880.754386]  [<c0405670>] show_registers+0x21a/0x3ac
> [  880.759365]  [<c04061ae>] die_nmi+0x84/0xd7
> [  880.763566]  [<c041859f>] nmi_watchdog_tick+0x14d/0x168
> [  880.768803]  [<c0406582>] do_nmi+0x8b/0x284
> [  880.773004]  [<c069ff1b>] nmi_stack_correct+0x26/0x2b
> [  880.778069]  [<c0528fdd>] __delay+0x9/0xb
> [  880.782098]  [<c05375ac>] _raw_spin_lock+0xd8/0x18a
> [  880.786991]  [<c069f76f>] _spin_lock_irqsave+0x5d/0x6e
> [  880.792143]  [<c05259db>] prop_norm_single+0x34/0x8a
> [  880.797122]  [<c0473576>] set_page_dirty+0xa1/0x13b
> [  880.802015]  [<c0482bd1>] try_to_unmap_one+0xb8/0x1e7
> [  880.807079]  [<c0482d8f>] try_to_unmap+0x8f/0x40d
> [  880.811798]  [<c04776fd>] shrink_page_list+0x278/0x750
> [  880.816950]  [<c0477ccb>] shrink_inactive_list+0xf6/0x328
> [  880.822362]  [<c0477faa>] shrink_zone+0xad/0x10b
> [  880.826997]  [<c047866e>] try_to_free_pages+0x178/0x274
> [  880.832235]  [<c0472a36>] __alloc_pages+0x169/0x431
> [  880.837126]  [<c047501d>] __do_page_cache_readahead+0x141/0x207
> [  880.843056]  [<c047545c>] do_page_cache_readahead+0x48/0x5c
> [  880.848641]  [<c046f3a3>] filemap_fault+0x2dd/0x4cf
> [  880.853534]  [<c047b5c9>] __do_fault+0xb6/0x42d
> [  880.858081]  [<c047d0d5>] handle_mm_fault+0x1b6/0x750
> [  880.863146]  [<c041cd7b>] do_page_fault+0x334/0x5f9
> [  880.868037]  [<c069fe72>] error_code+0x72/0x78
> [  880.872497]  =======================
> [  880.876068] INFO: lockdep is turned off.
> [  880.879983] Code: 8d 0c 1b 01 c9 89 da c1 e2 07 29 ca 01 da 01 d2 f7 e2 8d 42 01 e8 c3 ff ff ff 5b 5d c3 55 89 e5 53 89 c3 0f 31 89 c1 f3 90 0f 31 <29> c8 39 d8 72 f6 5b 5d c3 55 89 e5 53 69 c0 1c 43 00 00 64 8b 
> [  880.900092] Kernel panic - not syncing: Aiee, killing interrupt handler!
> [  880.906791] WARNING: at /home/devel/linux-mm/arch/i386/kernel/smp.c:474 native_smp_send_reschedule()
> [  880.915892]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
> [  880.921043]  [<c0405ff3>] show_trace+0x12/0x14
> [  880.925504]  [<c0406128>] dump_stack+0x16/0x18
> [  880.929964]  [<c0416093>] native_smp_send_reschedule+0x8b/0x98
> [  880.935808]  [<c04203ea>] resched_task+0x81/0x83
> [  880.940440]  [<c04203fa>] check_preempt_curr_idle+0xe/0x10
> [  880.945939]  [<c0422364>] try_to_wake_up+0x2ca/0x3ec
> [  880.950916]  [<c04224ae>] wake_up_process+0xf/0x11
> [  880.955714]  [<c04403e5>] hrtimer_wakeup+0x18/0x1c
> [  880.960513]  [<c044100e>] hrtimer_interrupt+0x15e/0x1e8
> [  880.965751]  [<c0418292>] smp_apic_timer_interrupt+0x57/0x88
> [  880.971420]  [<c0404e0f>] apic_timer_interrupt+0x33/0x38
> [  880.976736]  [<c042d27b>] do_exit+0x639/0xa04
> [  880.981103]  [<c04061e8>] die_nmi+0xbe/0xd7
> [  880.985302]  [<c041859f>] nmi_watchdog_tick+0x14d/0x168
> [  880.990533]  [<c0406582>] do_nmi+0x8b/0x284
> [  880.994735]  [<c069ff1b>] nmi_stack_correct+0x26/0x2b
> [  880.999800]  [<c0528fdd>] __delay+0x9/0xb
> [  881.003827]  [<c05375ac>] _raw_spin_lock+0xd8/0x18a
> [  881.008712]  [<c069f76f>] _spin_lock_irqsave+0x5d/0x6e
> [  881.013865]  [<c05259db>] prop_norm_single+0x34/0x8a
> [  881.018842]  [<c0473576>] set_page_dirty+0xa1/0x13b
> [  881.023728]  [<c0482bd1>] try_to_unmap_one+0xb8/0x1e7
> [  881.028793]  [<c0482d8f>] try_to_unmap+0x8f/0x40d
> [  881.033511]  [<c04776fd>] shrink_page_list+0x278/0x750
> [  881.038664]  [<c0477ccb>] shrink_inactive_list+0xf6/0x328
> [  881.044075]  [<c0477faa>] shrink_zone+0xad/0x10b
> [  881.048709]  [<c047866e>] try_to_free_pages+0x178/0x274
> [  881.053947]  [<c0472a36>] __alloc_pages+0x169/0x431
> [  881.058838]  [<c047501d>] __do_page_cache_readahead+0x141/0x207
> [  881.064760]  [<c047545c>] do_page_cache_readahead+0x48/0x5c
> [  881.070344]  [<c046f3a3>] filemap_fault+0x2dd/0x4cf
> [  881.075229]  [<c047b5c9>] __do_fault+0xb6/0x42d
> [  881.079774]  [<c047d0d5>] handle_mm_fault+0x1b6/0x750
> [  881.084832]  [<c041cd7b>] do_page_fault+0x334/0x5f9
> [  881.089724]  [<c069fe72>] error_code+0x72/0x78
> [  881.094177]  =======================
> [  881.097748] WARNING: at /home/devel/linux-mm/arch/i386/kernel/smp.c:209 send_IPI_mask_bitmask()
> [  881.106417]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
> [  881.111569]  [<c0405ff3>] show_trace+0x12/0x14
> [  881.116029]  [<c0406128>] dump_stack+0x16/0x18
> [  881.120489]  [<c041589a>] send_IPI_mask_bitmask+0xf0/0xf5
> [  881.125900]  [<c0416063>] native_smp_send_reschedule+0x5b/0x98
> [  881.131743]  [<c04203ea>] resched_task+0x81/0x83
> [  881.136367]  [<c04203fa>] check_preempt_curr_idle+0xe/0x10
> [  881.141857]  [<c0422364>] try_to_wake_up+0x2ca/0x3ec
> [  881.146827]  [<c04224ae>] wake_up_process+0xf/0x11
> [  881.151625]  [<c04403e5>] hrtimer_wakeup+0x18/0x1c
> [  881.156422]  [<c044100e>] hrtimer_interrupt+0x15e/0x1e8
> [  881.161653]  [<c0418292>] smp_apic_timer_interrupt+0x57/0x88
> [  881.167322]  [<c0404e0f>] apic_timer_interrupt+0x33/0x38
> [  881.172639]  [<c042d27b>] do_exit+0x639/0xa04
> [  881.177004]  [<c04061e8>] die_nmi+0xbe/0xd7
> [  881.181197]  [<c041859f>] nmi_watchdog_tick+0x14d/0x168
> [  881.186434]  [<c0406582>] do_nmi+0x8b/0x284
> [  881.190627]  [<c069ff1b>] nmi_stack_correct+0x26/0x2b
> [  881.195685]  [<c0528fdd>] __delay+0x9/0xb
> [  881.199713]  [<c05375ac>] _raw_spin_lock+0xd8/0x18a
> [  881.204605]  [<c069f76f>] _spin_lock_irqsave+0x5d/0x6e
> [  881.209748]  [<c05259db>] prop_norm_single+0x34/0x8a
> [  881.214718]  [<c0473576>] set_page_dirty+0xa1/0x13b
> [  881.219603]  [<c0482bd1>] try_to_unmap_one+0xb8/0x1e7
> [  881.224668]  [<c0482d8f>] try_to_unmap+0x8f/0x40d
> [  881.229389]  [<c04776fd>] shrink_page_list+0x278/0x750
> [  881.234539]  [<c0477ccb>] shrink_inactive_list+0xf6/0x328
> [  881.239951]  [<c0477faa>] shrink_zone+0xad/0x10b
> [  881.244584]  [<c047866e>] try_to_free_pages+0x178/0x274
> [  881.249822]  [<c0472a36>] __alloc_pages+0x169/0x431
> [  881.254707]  [<c047501d>] __do_page_cache_readahead+0x141/0x207
> [  881.260637]  [<c047545c>] do_page_cache_readahead+0x48/0x5c
> [  881.266221]  [<c046f3a3>] filemap_fault+0x2dd/0x4cf
> [  881.271113]  [<c047b5c9>] __do_fault+0xb6/0x42d
> [  881.275652]  [<c047d0d5>] handle_mm_fault+0x1b6/0x750
> [  881.280716]  [<c041cd7b>] do_page_fault+0x334/0x5f9
> [  881.285601]  [<c069fe72>] error_code+0x72/0x78
> [  881.290061]  =======================
> 
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/console.log
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-config

This might be related. The kernel is tainted because I hit
kernel BUG at /home/devel/linux-mm/mm/swap_state.c:78!

[ 2599.530633] BUG: NMI Watchdog detected LOCKUP on CPU0, eip c053759e, registers:
[ 2599.537953] Modules linked in: loop isofs nls_base zlib_inflate autofs4 af_packet nf_conntrack_netbios_ns nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink ipt_REJECT iptable_filter ip_tables xt_tcpudp ip6t_REJECT ip6table_filter ip6_tables x_tables firmware_class binfmt_misc fan ipv6 nvram snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc evdev i2c_i801 intel_agp agpgart rtc
[ 2599.583078] CPU:    0
[ 2599.583079] EIP:    0060:[<c053759e>]    Tainted: G      D VLI
[ 2599.583081] EFLAGS: 00200046   (2.6.23-rc2-mm1 #3)
[ 2599.595933] EIP is at _raw_spin_lock+0xca/0x18a
[ 2599.600451] eax: 00000000   ebx: 02821a83   ecx: 047ccfb8   edx: a45a5513
[ 2599.607217] esi: 00000000   edi: c7688ccc   ebp: e9c5ce68   esp: e9c5ce38
[ 2599.613986] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[ 2599.619805] Process fsx-linux (pid: 15528, ti=e9c5c000 task=c7688000 task.ti=e9c5c000)
[ 2599.627522] Stack: 00200046 00000000 e9c5ce68 00200046 00000000 a6d84f90 00000001 a6d84f90 
[ 2599.636021]        00000000 c7688ce0 c7688ccc 00200082 e9c5ce88 c069f76f 00000000 00000002 
[ 2599.644526]        c05259db c7688cc0 00008000 c0bbdf84 e9c5cea8 c05259db c7688ccc 00008000 
[ 2599.653031] Call Trace:
[ 2599.655670]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
[ 2599.660821]  [<c040542a>] show_stack_log_lvl+0xa9/0xd5
[ 2599.665972]  [<c0405670>] show_registers+0x21a/0x3ac
[ 2599.670952]  [<c04061ae>] die_nmi+0x84/0xd7
[ 2599.675161]  [<c041859f>] nmi_watchdog_tick+0x14d/0x168
[ 2599.680408]  [<c0406582>] do_nmi+0x8b/0x284
[ 2599.684637]  [<c069ff1b>] nmi_stack_correct+0x26/0x2b
[ 2599.689729]  [<c069f76f>] _spin_lock_irqsave+0x5d/0x6e
[ 2599.694915]  [<c05259db>] prop_norm_single+0x34/0x8a
[ 2599.699916]  [<c0473576>] set_page_dirty+0xa1/0x13b
[ 2599.704825]  [<c0474909>] set_page_dirty_balance+0xc/0x75
[ 2599.710249]  [<c047b8c8>] __do_fault+0x3b5/0x42d
[ 2599.714892]  [<c047d0d5>] handle_mm_fault+0x1b6/0x750
[ 2599.719957]  [<c041cd7b>] do_page_fault+0x334/0x5f9
[ 2599.724851]  [<c069fe72>] error_code+0x72/0x78
[ 2599.729310]  =======================
[ 2599.732879] INFO: lockdep is turned off.
[ 2599.736796] Code: e4 89 45 ec c7 45 f0 00 00 00 00 c7 45 e8 01 00 00 00 8b 75 e4 85 f6 74 34 31 c0 86 07 84 c0 7f 7d 31 db 31 f6 eb 08 31 c0 86 07 <84> c0 7f 6f b8 01 00 00 00 e8 28 1a ff ff 83 c3 01 83 d6 00 8b 
[ 2599.757294] Kernel panic - not syncing: Aiee, killing interrupt handler!

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/console2.log
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-config

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
