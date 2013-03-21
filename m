Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 5EFE16B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 02:01:49 -0400 (EDT)
Date: Thu, 21 Mar 2013 08:04:32 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/huge_memory.c:1802!
Message-ID: <20130321060432.GA17001@shutemov.name>
References: <bug-923817-176318@bugzilla.redhat.com>
 <20130320150728.GB1746@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130320150728.GB1746@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Fedora Kernel Team <kernel-team@fedoraproject.org>

On Wed, Mar 20, 2013 at 11:07:28AM -0400, Dave Jones wrote:
> More huge page fun reported by one of our users today..
> 
>  > https://bugzilla.redhat.com/show_bug.cgi?id=923817
>  > 
>  > kernel BUG at mm/huge_memory.c:1802!
>  > invalid opcode: 0000 [#1] SMP 
>  > Modules linked in: arc4 md4 nls_utf8 cifs dns_resolver fscache fuse tun lockd
>  > sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_conntrack_ipv4 nf_defrag_ipv6
>  > nf_defrag_ipv4 xt_conntrack nf_conntrack ip6table_filter ip6_tables binfmt_misc
>  > snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
>  > iTCO_wdt iTCO_vendor_support snd_seq snd_seq_device snd_pcm snd_page_alloc
>  > snd_timer snd e1000e coretemp mei lpc_ich soundcore mfd_core kvm_intel dcdbas
>  > kvm serio_raw i2c_i801 microcode uinput dm_crypt crc32c_intel
>  > ghash_clmulni_intel i915 i2c_algo_bit drm_kms_helper drm video i2c_core
>  > CPU 0 
>  > Pid: 2125, comm: JS GC Helper Not tainted 3.8.3-203.fc18.x86_64 #1 Dell Inc.
>  > OptiPlex 790/0J3C2F
>  > RIP: 0010:[<ffffffff8118edd1>]  [<ffffffff8118edd1>]
>  > split_huge_page+0x751/0x7e0
>  > RSP: 0018:ffff8801f9f4db98  EFLAGS: 00010297
>  > RAX: 0000000000000001 RBX: ffffea0000b48000 RCX: 000000000000005b
>  > RDX: 0000000000000008 RSI: 0000000000000046 RDI: 0000000000000246
>  > RBP: ffff8801f9f4dc58 R08: 000000000000000a R09: 000000000000034a
>  > R10: 0000000000000000 R11: 0000000000000349 R12: 0000000000000000
>  > R13: 00007fb66765d000 R14: 00003ffffffff000 R15: ffffea0000b48000
>  > FS:  00007fb6b0f33700(0000) GS:ffff88022dc00000(0000) knlGS:0000000000000000
>  > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  > CR2: 00007fb69a7e8200 CR3: 00000001cfc04000 CR4: 00000000000407f0
>  > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>  > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>  > Process JS GC Helper (pid: 2125, threadinfo ffff8801f9f4c000, task
>  > ffff880200bd9760)
>  > Stack:
>  >  ffff8801f9f4dbe8 0000000000000292 ffff8801f9f4dbc8 0000000000000004
>  >  ffffea0000bbd3c0 ffff8801f7a32d40 0000000000b48000 ffffffff8113a5f7
>  >  0000000000000003 ffffc90000000001 00000000f9f4dbf8 00000007fb667600
>  > Call Trace:
>  >  [<ffffffff8113a5f7>] ? free_pcppages_bulk+0x177/0x4f0
>  >  [<ffffffff81198271>] ? mem_cgroup_bad_page_check+0x21/0x30
>  >  [<ffffffff8113ab8d>] ? free_pages_prepare+0x8d/0x140
>  >  [<ffffffff811903d3>] __split_huge_page_pmd+0x133/0x370
>  >  [<ffffffff8115c4fa>] unmap_single_vma+0x7ea/0x880
>  >  [<ffffffff811709dd>] ? free_pages_and_swap_cache+0xad/0xd0
>  >  [<ffffffff8115ce7d>] zap_page_range+0x9d/0x100
>  >  [<ffffffff8109797f>] ? __dequeue_entity+0x2f/0x50
>  >  [<ffffffff81159863>] sys_madvise+0x263/0x740
>  >  [<ffffffff810df18c>] ? __audit_syscall_exit+0x20c/0x2c0
>  >  [<ffffffff81658699>] system_call_fastpath+0x16/0x1b
>  > Code: 0f 0b 0f 0b f3 90 49 8b 07 a9 00 00 00 01 75 f4 e9 d8 fa ff ff be 45 01
>  > 00 00 48 c7 c7 8d 09 9d 81 e8 a4 f8 ec ff e9 c2 fa ff ff <0f> 0b 41 8b 57 18 8b
>  > 75 94 48 c7 c7 d0 0b 9f 81 31 c0 83 c2 01 
>  > RIP  [<ffffffff8118edd1>] split_huge_page+0x751/0x7e0
>  >  RSP <ffff8801f9f4db98>
> 
> BUG_ON(mapcount != page_mapcount(page));

Hmm.. I wounder if it can be caused by replacing same_anon_vma linked list
with an interval tree[1]. __split_huge_page() is sensible to anon_vma
implementation.

[1] bf181b9 mm anon rmap: replace same_anon_vma linked list with an interval tree.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
