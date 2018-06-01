Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12B9E6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 15:02:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v134-v6so5160756oia.15
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 12:02:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor17347779oiy.10.2018.06.01.12.02.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 12:02:22 -0700 (PDT)
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com>
Date: Fri, 1 Jun 2018 12:02:19 -0700
MIME-Version: 1.0
In-Reply-To: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Eidelman <anton@lightbitslabs.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>
Cc: linux-hardened@lists.openwall.com

(cc-ing some interested people)


On 05/31/2018 05:03 PM, Anton Eidelman wrote:
> Hello,
> 
> Here's a rare issue I reproduce on 4.12.10 (centos config): full log sample below.
> An innocent process (dhcpclient) is about to receive a datagram, but duringA skb_copy_datagram_iter() usercopy triggers a BUG in:
> usercopy.c:check_heap_object() -> slub.c:__check_heap_object(), because the sk_buff fragment being copied crosses the 64-byte slub object boundary.
> 
> Example __check_heap_object() context:
>  A  n=128A  A  << usually 128, sometimes 192.
>  A  object_size=64
>  A  s->size=64
>  A  page_address(page)=0xffff880233f7c000
>  A  ptr=0xffff880233f7c540
> 
> My take on the root cause:
>  A  When adding data to an skb, new data is appended to the current fragment if the new chunk immediately follows the last one: by simply increasing the frag->size, skb_frag_size_add().
>  A  See include/linux/skbuff.h:skb_can_coalesce() callers.
>  A  This happens very frequently for kmem_cache objects (slub/slab) with intensive kernel level TCP traffic, and produces sk_buff fragments that span multiple kmem_cache objects.
>  A  However, if the same happens to receive data intended for user space, usercopy triggers a BUG.
>  A  This is quite rare but possible: fails after 5-60min of network traffic (needs some unfortunate timing, e.g. only on QEMU, without CONFIG_SLUB_DEBUG_ON etc).
>  A  I used an instrumentation that counts coalesced chunks in the fragment, in order to confirm that the failing fragment was legally constructed from multiple slub objects.
> 
> On 4.17.0.rc3:
>  A  I could not reproduce the issue with the latest kernel, but the changes in usercopy.c and slub.c since 4.12 do not address the issue.
>  A  Moreover, it would be quite hard to do without effectively disabling the heap protection.
>  A  However, looking at the recent changes in include/linux/sk_buff.h I seeA skb_zcopy() that yields negative skb_can_coalesce()A and may have masked the problem.
> 
> Please, let me know what do you think?
> 4.12.10 is the centos official kernel with CONFIG_HARDENED_USERCOPYA enabled: if the problem is real we better have an erratum for it.
> 
> Regards,
> Anton Eidelman
> 
> 
> [ 655.602500] usercopy: kernel memory exposure attempt detected from ffff88022a31aa00 *(kmalloc-64) (192 bytes*)
> [ 655.604254] ----------[ cut here ]----------
> [ 655.604877] kernel BUG at mm/usercopy.c:72!
> [ 655.606302] invalid opcode: 0000 1 SMP
> [ 655.618390] CPU: 3 PID: 2335 Comm: dhclient Tainted: G O 4.12.10-1.el7.elrepo.x86_64 #1
> [ 655.619666] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
> [ 655.620926] task: ffff880229ab2d80 task.stack: ffffc90001198000
> [ 655.621786] RIP: 0010:__check_object_size+0x74/0x190
> [ 655.622489] RSP: 0018:ffffc9000119bbb8 EFLAGS: 00010246
> [ 655.623236] RAX: 0000000000000060 RBX: ffff88022a31aa00 RCX: 0000000000000000
> [ 655.624234] RDX: 0000000000000000 RSI: ffff88023fcce108 RDI: ffff88023fcce108
> [ 655.625237] RBP: ffffc9000119bbd8 R08: 00000000fffffffe R09: 0000000000000271
> [ 655.626248] R10: 0000000000000005 R11: 0000000000000270 R12: 00000000000000c0
> [ 655.627256] R13: ffff88022a31aac0 R14: 0000000000000001 R15: 00000000000000c0
> [ 655.628268] FS: 00007fb54413b880(0000) GS:ffff88023fcc0000(0000) knlGS:0000000000000000
> [ 655.629561] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 655.630289] CR2: 00007fb5439dc5c0 CR3: 000000023211d000 CR4: 00000000003406e0
> [ 655.631268] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 655.632281] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [ 655.633318] Call Trace:
> [ 655.633696] copy_page_to_iter_iovec+0x9c/0x180
> [ 655.634351] copy_page_to_iter+0x22/0x160
> [ 655.634943] skb_copy_datagram_iter+0x157/0x260
> [ 655.635604] packet_recvmsg+0xcb/0x460
> [ 655.636156] ? selinux_socket_recvmsg+0x17/0x20
> [ 655.636816] sock_recvmsg+0x3d/0x50
> [ 655.637330] ___sys_recvmsg+0xd7/0x1f0
> [ 655.637892] ? kvm_clock_get_cycles+0x1e/0x20
> [ 655.638533] ? ktime_get_ts64+0x49/0xf0
> [ 655.639101] ? _copy_to_user+0x26/0x40
> [ 655.639657] __sys_recvmsg+0x51/0x90
> [ 655.640184] SyS_recvmsg+0x12/0x20
> [ 655.640696] entry_SYSCALL_64_fastpath+0x1a/0xa5
> --------------------------------------------------------------------------------------------------------------------------------------------
> 

The analysis makes sense. Kees, any thoughts about what
we might do? It seems unlikely we can fix the networking
code so do we need some kind of override in usercopy?

Thanks,
Laura
