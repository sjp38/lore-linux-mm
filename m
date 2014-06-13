Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 390BD6B0036
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:56:50 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so1946560iec.33
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:56:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id qd10si81746872igc.46.2014.06.12.19.56.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 19:56:49 -0700 (PDT)
Message-ID: <539A6850.4090408@oracle.com>
Date: Thu, 12 Jun 2014 22:56:16 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm/sched/net: BUG when running simple code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's
going on. It seems that we get a "unable to handle kernel paging request" when running
rather simple code, and I can't figure out how it would cause it.

The code in question is (in net/netlink/af_netlink.c):

static int netlink_getsockopt(struct socket *sock, int level, int optname,
                              char __user *optval, int __user *optlen)
{
        struct sock *sk = sock->sk;
        struct netlink_sock *nlk = nlk_sk(sk);
        int len, val, err;

        if (level != SOL_NETLINK)
                return -ENOPROTOOPT;

        if (get_user(len, optlen))
                return -EFAULT;
        if (len < 0)  <==== THIS
                return -EINVAL;

The disassembly I got shows:

        if (get_user(len, optlen))
     b1f:       e8 00 00 00 00          callq  b24 <netlink_getsockopt+0x44>
                        b20: R_X86_64_PC32      might_fault-0x4
     b24:       4c 89 e0                mov    %r12,%rax
     b27:       e8 00 00 00 00          callq  b2c <netlink_getsockopt+0x4c>
                        b28: R_X86_64_PC32      __get_user_4-0x4
     b2c:       85 c0                   test   %eax,%eax
     b2e:       74 10                   je     b40 <netlink_getsockopt+0x60>
                return -EFAULT;
     b30:       bb f2 ff ff ff          mov    $0xfffffff2,%ebx
     b35:       e9 06 01 00 00          jmpq   c40 <netlink_getsockopt+0x160>
     b3a:       66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
        if (len < 0)
     b40:       85 d2                   test   %edx,%edx
     b42:       0f 88 f0 00 00 00       js     c38 <netlink_getsockopt+0x158>
                return -EINVAL;

Which agrees with the trace I got:

[  516.309720] BUG: unable to handle kernel paging request at ffffffffa0f12560
[  516.309720] IP: netlink_getsockopt (net/netlink/af_netlink.c:2271)
[  516.309720] PGD 22031067 PUD 22032063 PMD 8000000020e001e1
[  516.309720] Oops: 0003 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  516.309720] Dumping ftrace buffer:
[  516.309720]    (ftrace buffer empty)
[  516.309720] Modules linked in:
[  516.309720] CPU: 11 PID: 9212 Comm: trinity-c11 Tainted: G        W     3.15.0-next-20140612-sasha-00022-g5e4db85-dirty #645
[  516.309720] task: ffff8803fc860000 ti: ffff8803fc85c000 task.ti: ffff8803fc85c000
[  516.309720] RIP: netlink_getsockopt (net/netlink/af_netlink.c:2271)
[  516.309720] RSP: 0018:ffff8803fc85fed8  EFLAGS: 00010216
[  516.309720] RAX: ffffffffa0f12560 RBX: 00000000ffffffa4 RCX: 0000000000000003
[  516.309720] RDX: 00000000ffff9002 RSI: 0000000049908020 RDI: ffff88025c16a100
[  516.309720] RBP: ffff8803fc85ff18 R08: 0000000000000001 R09: c900000000fd37ff
[  516.309720] R10: 0000000000000001 R11: 0000000000000000 R12: ffffffffffff9002
[  516.309720] R13: ffff88025c16a100 R14: 0000000000000001 R15: ffff88025bfa9bd8
[  516.309720] FS:  00007f54be0a7700(0000) GS:ffff8802c8e00000(0000) knlGS:0000000000000000
[  516.309720] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  516.309720] CR2: ffffffffa0f12560 CR3: 000000040b1fb000 CR4: 00000000000006a0
[  516.309720] Stack:
[  516.309720]  ffff8803fc85ff18 ffff8803fc85ff18 ffff8803fc85fef8 8900200549908020
[  516.309720]  ffff8803fc85ff18 ffffffff9ff66470 ffff8803fc85ff18 0000000000000037
[  516.309720]  ffff8803fc85ff78 ffffffff9ff69d26 0000000000000037 0000000000000004
[  516.309720] Call Trace:
[  516.309720] ? sockfd_lookup_light (net/socket.c:457)
[  516.309720] SyS_getsockopt (net/socket.c:1945 net/socket.c:1929)
[  516.309720] tracesys (arch/x86/kernel/entry_64.S:542)
[ 516.309720] Code: b2 fd 85 c0 74 10 bb f2 ff ff ff e9 06 01 00 00 66 0f 1f 44 00 00 85 d2 0f 88 f0 00 00 00 41 83 fd 04 74 42 41 83 fd 05 0f 84 88 <00> 00 00 41 83 fd 03 0f 85 de 00 00 00 83 fa 03 bb ea ff ff ff
All code
========
   0:	b2 fd                	mov    $0xfd,%dl
   2:	85 c0                	test   %eax,%eax
   4:	74 10                	je     0x16
   6:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
   b:	e9 06 01 00 00       	jmpq   0x116
  10:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  16:	85 d2                	test   %edx,%edx
  18:*	0f 88 f0 00 00 00    	js     0x10e		<-- trapping instruction
  1e:	41 83 fd 04          	cmp    $0x4,%r13d
  22:	74 42                	je     0x66
  24:	41 83 fd 05          	cmp    $0x5,%r13d
  28:	0f 84 88 00 00 00    	je     0xb6
  2e:	41 83 fd 03          	cmp    $0x3,%r13d
  32:	0f 85 de 00 00 00    	jne    0x116
  38:	83 fa 03             	cmp    $0x3,%edx
  3b:	bb ea ff ff ff       	mov    $0xffffffea,%ebx
	...

Code starting with the faulting instruction
===========================================
   0:	00 00                	add    %al,(%rax)
   2:	00 41 83             	add    %al,-0x7d(%rcx)
   5:	fd                   	std
   6:	03 0f                	add    (%rdi),%ecx
   8:	85 de                	test   %ebx,%esi
   a:	00 00                	add    %al,(%rax)
   c:	00 83 fa 03 bb ea    	add    %al,-0x1544fc06(%rbx)
  12:	ff                   	(bad)
  13:	ff                   	(bad)
  14:	ff 00                	incl   (%rax)
[  516.309720] RIP netlink_getsockopt (net/netlink/af_netlink.c:2271)
[  516.309720]  RSP <ffff8803fc85fed8>
[  516.309720] CR2: ffffffffa0f12560

They only theory I had so far is that netlink is a module, and has gone away while the code
was executing, but netlink isn't a module on my kernel.



Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
