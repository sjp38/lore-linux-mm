Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FB8A6B0096
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:24:27 -0500 (EST)
Subject: Re: 2.6.36.2 reliably panics in VFS
From: Peter Steiner <sp@med-2-med.com>
In-Reply-To: <1292153208.4213.8.camel@hp>
References: <1292153208.4213.8.camel@hp>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 13 Dec 2010 18:24:43 +0100
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <20101213172416.1F7256FD9C@nx.neverkill.us>
Sender: owner-linux-mm@kvack.org
To: viro@zeniv.linux.org.uk
Cc: sarah.a.sharp@linux.intel.com, linux-mm@kvack.org, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Just paste for you the asm here from 2.6.36.2:

ffffffff81038220 <task_rq_lock>:
ffffffff81038220:       48 83 ec 28             sub    $0x28,%rsp
ffffffff81038224:       48 89 5c 24 08          mov    %rbx,0x8(%rsp)
ffffffff81038229:       48 89 6c 24 10          mov    %rbp,0x10(%rsp)
ffffffff8103822e:       4c 89 64 24 18          mov    %r12,0x18(%rsp)
ffffffff81038233:       48 c7 c3 80 24 01 00    mov    $0x12480,%rbx
ffffffff8103823a:       4c 89 6c 24 20          mov    %r13,0x20(%rsp)
ffffffff8103823f:       48 89 fd                mov    %rdi,%rbp
ffffffff81038242:       49 89 f4                mov    %rsi,%r12
ffffffff81038245:       ff 14 25 e0 0d 57 81    callq
*0xffffffff81570de0
ffffffff8103824c:       48 89 c2                mov    %rax,%rdx
ffffffff8103824f:       ff 14 25 f0 0d 57 81    callq
*0xffffffff81570df0
ffffffff81038256:       49 89 14 24             mov    %rdx,(%r12)
ffffffff8103825a:       49 89 dd                mov    %rbx,%r13
ffffffff8103825d:       48 8b 45 08             mov    0x8(%rbp),%rax
ffffffff81038261:       8b 40 18                mov    0x18(%rax),%eax
ffffffff81038264:       4c 03 2c c5 a0 26 5c    add    -0x7ea3d960(,%
rax,8),%r13 <============ PANICS
ffffffff8103826b:       81 
ffffffff8103826c:       4c 89 ef                mov    %r13,%rdi
ffffffff8103826f:       e8 2c ff 3c 00          callq  ffffffff814081a0
<_raw_spin_lock>
ffffffff81038274:       48 8b 45 08             mov    0x8(%rbp),%rax
ffffffff81038278:       8b 40 18                mov    0x18(%rax),%eax
ffffffff8103827b:       48 8b 04 c5 a0 26 5c    mov    -0x7ea3d960(,%
rax,8),%rax
ffffffff81038282:       81 
ffffffff81038283:       48 8d 04 03             lea    (%rbx,%rax,1),%
rax
ffffffff81038287:       49 39 c5                cmp    %rax,%r13
ffffffff8103828a:       75 1c                   jne    ffffffff810382a8
<task_rq_lock+0x88>
ffffffff8103828c:       4c 89 e8                mov    %r13,%rax
ffffffff8103828f:       48 8b 5c 24 08          mov    0x8(%rsp),%rbx
ffffffff81038294:       48 8b 6c 24 10          mov    0x10(%rsp),%rbp
ffffffff81038299:       4c 8b 64 24 18          mov    0x18(%rsp),%r12
ffffffff8103829e:       4c 8b 6c 24 20          mov    0x20(%rsp),%r13
ffffffff810382a3:       48 83 c4 28             add    $0x28,%rsp
ffffffff810382a7:       c3                      retq   
ffffffff810382a8:       49 8b 34 24             mov    (%r12),%rsi
ffffffff810382ac:       4c 89 ef                mov    %r13,%rdi
ffffffff810382af:       e8 9c 03 3d 00          callq  ffffffff81408650
<_raw_spin_unlock_irqrestore>
ffffffff810382b4:       eb 8f                   jmp    ffffffff81038245
<task_rq_lock+0x25>
ffffffff810382b6:       66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%
rax,1)
ffffffff810382bd:       00 00 00 


looks like a bogus value in RAX, then page fault in kernel space =>
panics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
