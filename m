Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B79426B0253
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:37:23 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n5so32625828wmn.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 06:37:23 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 79si40970594wmb.9.2016.01.20.06.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 06:37:22 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id r129so133756777wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 06:37:22 -0800 (PST)
Date: Wed, 20 Jan 2016 15:37:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160120143719.GF14187@dhcp22.suse.cz>
References: <5674A5C3.1050504@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5674A5C3.1050504@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@gentwo.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

[CCing Andrew]

I am just reading through this old discussion again because "vmstat:
make vmstat_updater deferrable again and shut down on idle" which seems
to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
any follow up fix merged to linus tree

On Fri 18-12-15 19:33:07, Sasha Levin wrote:
> Hi all,
> 
> I've started seeing the following in the latest -next kernel.
> 
> [  531.127489] kernel BUG at mm/vmstat.c:1408!
> [  531.128157] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> [  531.128872] Modules linked in:
> [  531.129324] CPU: 6 PID: 407 Comm: kworker/6:1 Not tainted 4.4.0-rc5-next-20151218-sasha-00021-gaba8d84-dirty #2750
> [  531.130939] Workqueue: vmstat vmstat_update
> [  531.131741] task: ffff880204070000 ti: ffff880204078000 task.ti: ffff880204078000
> [  531.133189] RIP: vmstat_update (mm/vmstat.c:1408)
> [  531.134466] RSP: 0018:ffff88020407fbf8  EFLAGS: 00010293
> [  531.135132] RAX: 0000000000000006 RBX: ffff8800418e2fd8 RCX: 0000000000000000
> [  531.135995] RDX: 0000000000000007 RSI: ffffffff8c0982a0 RDI: ffffffff9b8bd6e4
> [  531.137475] RBP: ffff88020407fc18 R08: 0000000000000000 R09: ffff880204070230
> [  531.138304] R10: ffffffff8c0982a0 R11: 00000000e272b4f2 R12: ffff880204c1bf60
> [  531.139329] R13: ffff880204ab09c8 R14: ffff880204ab09b8 R15: ffff880204ab09b0
> [  531.140261] FS:  0000000000000000(0000) GS:ffff880204c00000(0000) knlGS:0000000000000000
> [  531.141218] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  531.142036] CR2: 00007f039a8c1944 CR3: 000000000ea28000 CR4: 00000000000006a0
> [  531.142752] Stack:
> [  531.142963]  ffff880204c21000 ffff880204c21000 ffff880204c1bf60 ffff880204ab09c8
> [  531.144095]  ffff88020407fd40 ffffffff813a8fea 0000000041b58ab3 ffffffff8e667cdb
> [  531.145258]  ffff880204ab09f8 ffff880204c1bf68 ffff880204ab09c0 ffff880200000000
> [  531.146475] Call Trace:
> [  531.147037] process_one_work (./arch/x86/include/asm/preempt.h:22 kernel/workqueue.c:2045)
> [  531.150790] worker_thread (include/linux/compiler.h:218 include/linux/list.h:206 kernel/workqueue.c:2171)
> [  531.155176] kthread (kernel/kthread.c:209)
> [  531.158941] ret_from_fork (arch/x86/entry/entry_64.S:469)
> [ 531.160654] Code: 75 1e be 79 00 00 00 48 c7 c7 80 0f 10 8c 89 45 e4 e8 cd 92 cd ff 8b 45 e4 c6 05 e1 c4 13 1a 01 89 c0 f0 48 0f ab 03 72 02 eb 0e <0f> 0b 48 c7 c7 c0 f1 47 90 e8 3d 03 ae 01 48 83 c4 08 5b 41 5c
> All code
> ========
>    0:   75 1e                   jne    0x20
>    2:   be 79 00 00 00          mov    $0x79,%esi
>    7:   48 c7 c7 80 0f 10 8c    mov    $0xffffffff8c100f80,%rdi
>    e:   89 45 e4                mov    %eax,-0x1c(%rbp)
>   11:   e8 cd 92 cd ff          callq  0xffffffffffcd92e3
>   16:   8b 45 e4                mov    -0x1c(%rbp),%eax
>   19:   c6 05 e1 c4 13 1a 01    movb   $0x1,0x1a13c4e1(%rip)        # 0x1a13c501
>   20:   89 c0                   mov    %eax,%eax
>   22:   f0 48 0f ab 03          lock bts %rax,(%rbx)
>   27:   72 02                   jb     0x2b
>   29:   eb 0e                   jmp    0x39
>   2b:*  0f 0b                   ud2             <-- trapping instruction
>   2d:   48 c7 c7 c0 f1 47 90    mov    $0xffffffff9047f1c0,%rdi
>   34:   e8 3d 03 ae 01          callq  0x1ae0376
>   39:   48 83 c4 08             add    $0x8,%rsp
>   3d:   5b                      pop    %rbx
>   3e:   41 5c                   pop    %r12
>         ...
> 
> Code starting with the faulting instruction
> ===========================================
>    0:   0f 0b                   ud2
>    2:   48 c7 c7 c0 f1 47 90    mov    $0xffffffff9047f1c0,%rdi
>    9:   e8 3d 03 ae 01          callq  0x1ae034b
>    e:   48 83 c4 08             add    $0x8,%rsp
>   12:   5b                      pop    %rbx
>   13:   41 5c                   pop    %r12
>         ...
> [  531.164630] RIP vmstat_update (mm/vmstat.c:1408)
> [  531.165523]  RSP <ffff88020407fbf8>
> 
> 
> Thanks,
> Sasha

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
