Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3032B6B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 11:21:15 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id x97so13881476wrb.3
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 08:21:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m187si7463103wmg.35.2018.02.27.08.21.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 08:21:13 -0800 (PST)
Subject: Re: GPF in wb_congested due to null bdi_writeback
From: Nikolay Borisov <nborisov@suse.com>
References: <c4032fd5-ab49-1756-31bb-6e31088eac7b@suse.com>
Message-ID: <d22ad3b5-df45-b282-e2a7-123f15bdc7eb@suse.com>
Date: Tue, 27 Feb 2018 18:21:11 +0200
MIME-Version: 1.0
In-Reply-To: <c4032fd5-ab49-1756-31bb-6e31088eac7b@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>



On 27.02.2018 18:05, Nikolay Borisov wrote:
> Hello Tejun, 
> 
> So while running some fs tests I hit the following GPF. Btw the
> warning taint flag was due to a debugging WARN_ON in btrfs 100 or so 
> tests ago so is unrelated to this gpf: 
> 
> [ 4255.628110] general protection fault: 0000 [#1] SMP PTI
> [ 4255.628303] Modules linked in:
> [ 4255.628446] CPU: 4 PID: 58 Comm: kswapd0 Tainted: G        W        4.16.0-rc3-nbor #488
> [ 4255.628666] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> [ 4255.628928] RIP: 0010:shrink_page_list+0x320/0x1180
> [ 4255.629072] RSP: 0018:ffffc90000b2fb38 EFLAGS: 00010287
> [ 4255.629220] RAX: 26c74ca226c74ca2 RBX: ffffea000444aea0 RCX: 0000000000000000
> [ 4255.629394] RDX: 0000000000000000 RSI: 00000000ffffffff RDI: ffff880136761450
> [ 4255.629568] RBP: ffffc90000b2fea0 R08: ffff880136761640 R09: 0000000000000000
> [ 4255.629742] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc90000b2fc68
> [ 4255.629913] R13: ffffea000444ae80 R14: ffffc90000b2fba8 R15: 0000000000000001
> [ 4255.630125] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) knlGS:0000000000000000
> [ 4255.630339] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 4255.630494] CR2: 00007fb16b3955f8 CR3: 0000000135108000 CR4: 00000000000006a0
> [ 4255.630667] Call Trace:
> [ 4255.630790]  shrink_inactive_list+0x27b/0x800
> [ 4255.630951]  shrink_node_memcg+0x3b0/0x7e0
> [ 4255.631181]  ? mem_cgroup_iter+0xe3/0x730
> [ 4255.631374]  ? mem_cgroup_iter+0xe3/0x730
> [ 4255.631509]  ? shrink_node+0xcc/0x350
> [ 4255.631651]  shrink_node+0xcc/0x350
> [ 4255.631780]  kswapd+0x307/0x910
> [ 4255.631913]  kthread+0x103/0x140
> [ 4255.632033]  ? mem_cgroup_shrink_node+0x2f0/0x2f0
> [ 4255.632201]  ? kthread_create_on_node+0x40/0x40
> [ 4255.632348]  ret_from_fork+0x3a/0x50
> [ 4255.632499] Code: 85 c0 74 59 49 8b 38 48 c7 c0 60 2f 16 82 48 85 ff 74 18 48 8b 47 28 48 3b 05 75 b6 0f 01 0f 84 42 0a 00 00 48 8b 80 28 01 00 00 <48> 8b 48 58 48 8b 51 20 48 85 d2 0f 84 69 04 00 00 4c 89 04 24 
> [ 4255.633055] RIP: shrink_page_list+0x320/0x1180 RSP: ffffc90000b2fb38
> [ 4255.633456] ---[ end trace 5c1558c67347a58d ]---
>  
> shrink_page_list+0x320/0x1180 is:
> wb_congested at include/linux/backing-dev.h:170
>  (inlined by) inode_congested at include/linux/backing-dev.h:456
>  (inlined by) inode_write_congested at include/linux/backing-dev.h:468
>  (inlined by) shrink_page_list at mm/vmscan.c:957
> 
> So the actual faulting code is in wb_congested's first line: 
> 
> struct backing_dev_info *bdi = wb->bdi;                                 
> 
> So this means wb_congested is called with a null bdi_writeback. 
> This is the first time I've seen it so it's likely new. 
> I haven't tried bisecting. FWIW I triggered it with xfstest 
> generic/176 running on btrfs. But from the looks the filesystem 
> wasn't a play here. 
> 

I should read more carefully - it's not due to null wb but rather 
having garbage in rax. The actual (annotated) disassembly: 
All code
========
   0:	85 c0                	test   %eax,%eax
   2:	74 59                	je     0x5d
   4:	49 8b 38             	mov    (%r8),%rdi
   7:	48 c7 c0 60 2f 16 82 	mov    $0xffffffff82162f60,%rax
   e:	48 85 ff             	test   %rdi,%rdi
  11:	74 18                	je     0x2b
  13:	48 8b 47 28          	mov    0x28(%rdi),%rax    ; rax = inode->i_sb (in inode_to_bdi )
  17:	48 3b 05 75 b6 0f 01 	cmp    0x10fb675(%rip),%rax        # 0x10fb693
  1e:	0f 84 42 0a 00 00    	je     0xa66
  24:	48 8b 80 28 01 00 00 	mov    0x128(%rax),%rax ; rax = sb->s_bdi
  2b:*	48 8b 48 58          	mov    0x58(%rax),%rcx		<-- trapping instruction
  2f:	48 8b 51 20          	mov    0x20(%rcx),%rdx
  33:	48 85 d2             	test   %rdx,%rdx
  36:	0f 84 69 04 00 00    	je     0x4a5
  3c:	4c 89 04 24          	mov    %r8,(%rsp)


SO somehow the inode's i_sb is bogus  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
