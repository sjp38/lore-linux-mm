Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 80145828E2
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:32:02 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so104569273wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 03:32:02 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id cf10si40041296wjc.167.2016.02.15.03.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 03:32:01 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id b205so63467057wmb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 03:32:01 -0800 (PST)
Date: Mon, 15 Feb 2016 13:31:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160215113159.GA28832@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160212231510.GB15142@node.shutemov.name>
 <alpine.LFD.2.20.1602131238260.1910@schleppi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.20.1602131238260.1910@schleppi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Sat, Feb 13, 2016 at 12:58:31PM +0100, Sebastian Ott wrote:
> 
> On Sat, 13 Feb 2016, Kirill A. Shutemov wrote:
> > Could you check if revert of fecffad25458 helps?
> 
> I reverted fecffad25458 on top of 721675fcf277cf - it oopsed with:
> 
> c 1851.721062! Unable to handle kernel pointer dereference in virtual kernel address space
> c 1851.721075! failing address: 0000000000000000 TEID: 0000000000000483
> c 1851.721078! Fault in home space mode while using kernel ASCE.
> c 1851.721085! AS:0000000000d5c007 R3:00000000ffff0007 S:00000000ffffa800 P:000000000000003d
> c 1851.721128! Oops: 0004 ilc:3 c#1! PREEMPT SMP DEBUG_PAGEALLOC
> c 1851.721135! Modules linked in: bridge stp llc btrfs mlx4_ib mlx4_en ib_sa ib_mad vxlan xor ip6_udp_tunnel ib_core udp_tunnel ptp pps_core ib_addr ghash_s390raid6_pq prng ecb aes_s390 mlx4_core des_s390 des_generic genwqe_card sha512_s390 sha256_s390 sha1_s390 sha_common crc_itu_t dm_mod scm_block vhost_net tun vhost eadm_sch macvtap macvlan kvm autofs4
> c 1851.721183! CPU: 7 PID: 256422 Comm: bash Not tainted 4.5.0-rc3-00058-g07923d7-dirty #178
> c 1851.721186! task: 000000007fbfd290 ti: 000000008c604000 task.ti: 000000008c604000
> c 1851.721189! Krnl PSW : 0704d00180000000 000000000045d3b8 (__rb_erase_color+0x280/0x308)
> c 1851.721200!            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
>                Krnl GPRS: 0000000000000001 0000000000000020 0000000000000000 00000000bd07eff1
> c 1851.721205!            000000000027ca10 0000000000000000 0000000083e45898 0000000077b61198
> c 1851.721207!            000000007ce1a490 00000000bd07eff0 000000007ce1a548 000000000027ca10
> c 1851.721210!            00000000bd07c350 00000000bd07eff0 000000008c607aa8 000000008c607a68
> c 1851.721221! Krnl Code: 000000000045d3aa: e3c0d0080024       stg     %%r12,8(%%r13)
>                           000000000045d3b0: b9040039           lgr     %%r3,%%r9
>                          #000000000045d3b4: a53b0001           oill    %%r3,1
>                          >000000000045d3b8: e33010000024       stg     %%r3,0(%%r1)
>                           000000000045d3be: ec28000e007c       cgij    %%r2,0,8,45d3da
>                           000000000045d3c4: e34020000004       lg      %%r4,0(%%r2)
>                           000000000045d3ca: b904001c           lgr     %%r1,%%r12
>                           000000000045d3ce: ec143f3f0056       rosbg   %%r1,%%r4,63,63,0
> c 1851.721269! Call Trace:
> c 1851.721273! (c<0000000083e45898>! 0x83e45898)
> c 1851.721279!  c<000000000029342a>! unlink_anon_vmas+0x9a/0x1d8
> c 1851.721282!  c<0000000000283f34>! free_pgtables+0xcc/0x148
> c 1851.721285!  c<000000000028c376>! exit_mmap+0xd6/0x300
> c 1851.721289!  c<0000000000134db8>! mmput+0x90/0x118
> c 1851.721294!  c<00000000002d76bc>! flush_old_exec+0x5d4/0x700
> c 1851.721298!  c<00000000003369f4>! load_elf_binary+0x2f4/0x13e8
> c 1851.721301!  c<00000000002d6e4a>! search_binary_handler+0x9a/0x1f8
> c 1851.721304!  c<00000000002d8970>! do_execveat_common.isra.32+0x668/0x9a0
> c 1851.721307!  c<00000000002d8cec>! do_execve+0x44/0x58
> c 1851.721310!  c<00000000002d8f92>! SyS_execve+0x3a/0x48
> c 1851.721315!  c<00000000006fb096>! system_call+0xd6/0x258
> c 1851.721317!  c<000003ff997436d6>! 0x3ff997436d6
> c 1851.721319! INFO: lockdep is turned off.
> c 1851.721321! Last Breaking-Event-Address:
> c 1851.721323!  c<000000000045d31a>! __rb_erase_color+0x1e2/0x308
> c 1851.721327!
> c 1851.721329! ---c end trace 0d80041ac00cfae2 !---
> 
> 
> > 
> > And could you share how crashes looks like? I haven't seen backtraces yet.
> > 
> 
> Sure. I didn't because they really looked random to me. Most of the time
> in rcu or list debugging but I thought these have just been the messenger
> observing a corruption first. Anyhow, here is an older one that might look
> interesting:
> 
> [   59.851421] list_del corruption. next->prev should be 000000006e1eb000, but was 0000000000000400

This kinda interesting: 0x400 is TAIL_MAPPING.. Hm..

Could you check if you see the problem on commit 1c290f642101 and its
immediate parent?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
