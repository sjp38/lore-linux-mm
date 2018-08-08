Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7333B6B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 07:54:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t17-v6so817092edr.21
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 04:54:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p62-v6si3629088edb.161.2018.08.08.04.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 04:54:33 -0700 (PDT)
Subject: Re: general protection fault with prefetch_freepointer
References: <333cfb75-1769-c67f-c56f-c9458368751a@molgen.mpg.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4fcc1694-6c29-8c49-1183-fbfb832bf513@suse.cz>
Date: Wed, 8 Aug 2018 13:54:30 +0200
MIME-Version: 1.0
In-Reply-To: <333cfb75-1769-c67f-c56f-c9458368751a@molgen.mpg.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Alex Deucher <alexander.deucher@amd.com>

On 07/18/2018 04:31 PM, Paul Menzel wrote:
> Dear Linux,
> 
> 
> Loading the amdgpu module on Ryzen 3 2{2,4}00G (Raven) systems sometimes
> causes a general protection fault [1]. At least on my system I am unable
> to reliably reproduce the issue.
> 
> ```
> [   35.265941] kfd kfd: kgd2kfd_probe failed
> [   35.537445] general protection fault: 0000 [#1] SMP NOPTI
> [   35.543209] CPU: 0 PID: 367 Comm: systemd-udevd Not tainted 4.18.0-rc5+ #1
> [   35.550371] Hardware name: MSI MS-7A37/B350M MORTAR (MS-7A37), BIOS 1.G1 05/17/2018
> [   35.558562] RIP: 0010:prefetch_freepointer+0x10/0x20
> [   35.563881] Code: 89 d3 e8 c3 fe 4a 00 85 c0 0f 85 31 75 00 00 48 83 c4 08 5b 5d 41 5c 41 5d c3 0f 1f 44 00 00 48 85 f6 74 13 8b 47 20 48 01 c6 <48> 33 36 48 33 b7 38 01 00 00 0f 18 0e c3 66 90 0f 1f 44 00 00 48 
> [   35.584215] RSP: 0018:ffff9c3181f77560 EFLAGS: 00010202
> [   35.589849] RAX: 0000000000000000 RBX: 4b2c8be0a60f6ab9 RCX: 0000000000000ccc
> [   35.597492] RDX: 0000000000000ccb RSI: 4b2c8be0a60f6ab9 RDI: ffff8d5b1e406e80
> [   35.605166] RBP: ffff8d5b1e406e80 R08: ffff8d5b1e824f00 R09: ffffffffc0a45423
> [   35.612808] R10: fffff1b60fff64c0 R11: ffff9c3181f77520 R12: 00000000006080c0
> [   35.620451] R13: 0000000000000230 R14: ffff8d5b1e406e80 R15: ffff8d5b0c304400
> [   35.628116] FS:  00007fb194e4b8c0(0000) GS:ffff8d5b1e800000(0000) knlGS:0000000000000000
> [   35.636771] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   35.642931] CR2: 000055c0661d60d0 CR3: 000000040b9ee000 CR4: 00000000003406f0
> [   35.650566] Call Trace:
> [   35.653198]  kmem_cache_alloc_trace+0xb5/0x1c0
> [   35.658077]  ? dal_ddc_service_create+0x38/0x110 [amdgpu]
> [   35.663962]  dal_ddc_service_create+0x38/0x110 [amdgpu]
> ```

./scripts/decodecode:

All code
========
   0:   89 d3                   mov    %edx,%ebx
   2:   e8 c3 fe 4a 00          callq  0x4afeca
   7:   85 c0                   test   %eax,%eax
   9:   0f 85 31 75 00 00       jne    0x7540
   f:   48 83 c4 08             add    $0x8,%rsp
  13:   5b                      pop    %rbx
  14:   5d                      pop    %rbp
  15:   41 5c                   pop    %r12
  17:   41 5d                   pop    %r13
  19:   c3                      retq   
  1a:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  1f:   48 85 f6                test   %rsi,%rsi
  22:   74 13                   je     0x37
  24:   8b 47 20                mov    0x20(%rdi),%eax
  27:   48 01 c6                add    %rax,%rsi
  2a:*  48 33 36                xor    (%rsi),%rsi <- HERE
  2d:   48 33 b7 38 01 00 00    xor    0x138(%rdi),%rsi
  34:   0f 18 0e                prefetcht0 (%rsi)
  37:   c3                      retq   
  38:   66 90                   xchg   %ax,%ax
  3a:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  3f:   48                      rex.W

rsi contains 4b2c8be0a60f6ab9, so reading from that clearly bogus
address faults. Dunno though why CR2 is 000055c0661d60d0 as that
should contain the same value. The XORs suggests you have
CONFIG_SLAB_FREELIST_HARDENED enabled, I wonder does the bug
reproduce with that disabled?

mov    0x20(%rdi),%eax is reading s->offset, so RDI=ffff8d5b1e406e80
is kmem_cache pointer, RAX=0 means offset was 0. This means
RSI=4b2c8be0a60f6ab9 is "object" parameter of prefetch_freepointer(),
i.e. the "next_object" variable in slab_alloc_node(), obtained from
the previous object. But I don't know much about SLUB internals to be
honest.

> Do you have more ideas, how to debug that? The progress in bug report
> kind of stalled as people have run out of ideas.
> 
> I thought about a hardware/firmware problem, but then searching for the
> error, I found the stack trace with Linux 4.17.2 from Fedora [2][3].
> This looks a little similar, but can of course be something totally
> different.
 
Hmm I have looked at the splats in all the bugs you referenced and the
Code part always has the de-obfuscation XORs. Then in comment 36 of
[1] jian-hong says the problem disappeared, and in comment 40 posts
a config that has CONFIG_SLAB_FREELIST_HARDENED disabled. Earlier
posting of his config has it enabled and confirms the disassembly.
Very suspicious, huh.

> general protection fault: 0000 [#1] SMP PTI
> Modules linked in: sctp netlink_diag nfsv3 nfnetlink_queue nfnetlink_log nfnetlink cfg80211 rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache rfcomm fuse hidp xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_conntrack tun devlink ebtable_filter ebtables ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge stp llc bnep it87 hwmon_vid btrfs xor zstd_compress raid6_pq libcrc32c zstd_decompress xxhash intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm gpio_ich iTCO_wdt iTCO_vendor_support ppdev irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_cstate intel_uncore intel_rapl_perf btusb btrtl btbcm btintel bluetooth snd_hda_codec_realtek snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel
>  snd_hda_codec ecdh_generic rfkill snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer i2c_i801 lpc_ich mei_me mei shpchp snd soundcore parport_pc parport nfsd binfmt_misc nfs_acl lockd auth_rpcgss grace sunrpc i915 crc32c_intel i2c_algo_bit drm_kms_helper serio_raw drm r8169 sata_via mii video
> CPU: 0 PID: 2690 Comm: nfsd Not tainted 4.17.2-200.fc28.x86_64 #1
> Hardware name: Gigabyte Technology Co., Ltd. H81M-S2PV/H81M-S2PV, BIOS F8 06/19/2014
> RIP: 0010:prefetch_freepointer+0x10/0x20
> RSP: 0018:ffffa33fca4ebc58 EFLAGS: 00010202
> RAX: 0000000000000000 RBX: 49f929d076783c7f RCX: 0000000000000f2a
> RDX: 0000000000000f29 RSI: 49f929d076783c7f RDI: ffff8da88c9ffe00
> RBP: ffff8da88c9ffe00 R08: ffff8da89ee2b100 R09: 0000000000000004
> R10: 0000000000000000 R11: 000000000000002c R12: 00000000014080c0
> R13: ffffffffc07e0ac1 R14: ffff8da4bc958ae1 R15: ffff8da88c9ffe00
> FS:  0000000000000000(0000) GS:ffff8da89ee00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00002001a1783000 CR3: 000000012920a001 CR4: 00000000000606f0
> Call Trace:
>  kmem_cache_alloc+0xb4/0x1d0
>  ? nfsd4_free_file_rcu+0x20/0x20 [nfsd]
> ```
> 
> Help on how to debug this is appreciated.
> 
> 
> Kind regards,
> 
> Paul
> 
> 
> [1]: https://bugs.freedesktop.org/show_bug.cgi?id=105684
> [2]: https://bugzilla.redhat.com/show_bug.cgi?id=1600482
> [3]: https://retrace.fedoraproject.org/faf/reports/2243945/
> 
