Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA9DB6B026A
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 22:04:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so458418pfs.8
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 19:04:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t21si8307045pfh.167.2018.01.18.19.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Jan 2018 19:04:50 -0800 (PST)
Date: Thu, 18 Jan 2018 19:04:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180119030447.GA26245@bombadil.infradead.org>
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, peter@rimuhosting.com

On Thu, Jan 18, 2018 at 02:18:20PM -0800, Laura Abbott wrote:
> On 01/18/2018 01:55 PM, Andrew Morton wrote:
> > > [   24.647744] BUG: unable to handle kernel NULL pointer dereference at
> > > 00000008
> > > [   24.647801] IP: __radix_tree_lookup+0x14/0xa0
> > > [   24.647811] *pdpt = 00000000253d6027 *pde = 0000000000000000
> > > [   24.647828] Oops: 0000 [#1] SMP
> > > [   24.647842] CPU: 5 PID: 3600 Comm: java Not tainted
> > > 4.14.13-rh10-20180115190010.xenU.i386 #1
> > > [   24.647855] task: e52518c0 task.stack: e4e7a000
> > > [   24.647866] EIP: __radix_tree_lookup+0x14/0xa0
> > > [   24.647876] EFLAGS: 00010286 CPU: 5
> > > [   24.647884] EAX: 00000004 EBX: 00000007 ECX: 00000000 EDX: 00000000
> > > [   24.647895] ESI: 00000000 EDI: 00000000 EBP: e4e7bdb8 ESP: e4e7bda0
> > > [   24.647904]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069
> > > [   24.647917] CR0: 80050033 CR2: 00000008 CR3: 25360000 CR4: 00002660
> > > [   24.647930] Call Trace:
> > > [   24.647942]  radix_tree_lookup_slot+0x13/0x30
> > > [   24.647955]  find_get_entry+0x1d/0x120
> > > [   24.647963]  pagecache_get_page+0x1f/0x230
> > > [   24.647975]  lookup_swap_cache+0x42/0x140
> > > [   24.647983]  swap_readahead_detect+0x66/0x2e0
> > > [   24.647993]  do_swap_page+0x1fa/0x860
> > > [   24.648010]  ? __raw_callee_save___pv_queued_spin_unlock+0x9/0x10
> > > [   24.648026]  ? xen_pmd_val+0x10/0x20
> > > [   24.648035]  handle_mm_fault+0x6f8/0x1020
> > > [   24.648046]  __do_page_fault+0x18a/0x450
> > > [   24.648055]  ? vmalloc_sync_all+0x250/0x250
> > > [   24.648063]  do_page_fault+0x21/0x30
> > > [   24.648074]  common_exception+0x45/0x4a
> > > [   24.648082] EIP: 0xb76d873e
> > > [   24.648088] EFLAGS: 00010206 CPU: 5
> > > [   24.648096] EAX: 76a10000 EBX: 76a1cd14 ECX: 00000006 EDX: 00000006
> > > [   24.648105] ESI: 00000040 EDI: b796c380 EBP: 77881008 ESP: 77880ff8
> > > [   24.648115]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> > > [   24.648124] Code: ff ff ff 00 47 03 e9 69 ff ff ff 8b 45 08 89 06 e9 1f ff
> > > ff ff 66 90 55 89 e5 57 89 d7 56 53 83 ec 0c 89 45 ec 89 4d e8 8b 45 ec <8b> 58
> > > 04 89 d8 83 e0 03 48 89 5d f0 75 64 89 d8 83 e0 fe 0f b6
> > > [   24.648195] EIP: __radix_tree_lookup+0x14/0xa0 SS:ESP: 0069:e4e7bda0
> > > [   24.648205] CR2: 0000000000000008
> > > [   24.648273] ---[ end trace ed356e59f215ce07 ]---

Running that code through decodecode, I get:

   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	89 d7                	mov    %edx,%edi
   6:	56                   	push   %esi
   7:	53                   	push   %ebx
   8:	83 ec 0c             	sub    $0xc,%esp
   b:	89 45 ec             	mov    %eax,-0x14(%ebp)
   e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  14:*	8b 58 04             	mov    0x4(%eax),%ebx		<-- trapping instruction
  17:	89 d8                	mov    %ebx,%eax
  19:	83 e0 03             	and    $0x3,%eax

Which I think means it's looking at offset 4 from whichever argument
the x86 calling convention puts in register %eax.  Which I think is
argument 0?  Which is the radix tree root.  And that makes sense; we're
loading the root node from the radix tree root at offset 4.  The problem
is that %eax has the value 4 in it.  That would match with 'page_tree'
being at offset 4 from the start of address_space.  So find_get_page()
got called with a NULL mapping, so pagecache_get_page() got called
with a NULL mapping.

Which means I've tracked it back to:

        page = find_get_page(swap_address_space(entry), swp_offset(entry));

and swap_address_space() is returning NULL.  Has this machine run swapoff
recently, perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
