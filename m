Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 048A66B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 22:44:52 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so21000195qgz.30
        for <linux-mm@kvack.org>; Wed, 28 May 2014 19:44:52 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id 18si24339327qgs.8.2014.05.28.19.44.52
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 19:44:52 -0700 (PDT)
Date: Wed, 28 May 2014 22:44:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528224448.1c1b1999@gandalf.local.home>
In-Reply-To: <20140529010940.GA10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<20140528090409.GA16795@redhat.com>
	<20140529010940.GA10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter
 Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, Dave Hansen <dave.hansen@intel.com>

On Thu, 29 May 2014 10:09:40 +0900
Minchan Kim <minchan@kernel.org> wrote:

> stacktrace reported that vring_add_indirect used 376byte and objdump says
>=20
> ffffffff8141dc60 <vring_add_indirect>:
> ffffffff8141dc60:       55                      push   %rbp
> ffffffff8141dc61:       48 89 e5                mov    %rsp,%rbp
> ffffffff8141dc64:       41 57                   push   %r15
> ffffffff8141dc66:       41 56                   push   %r14
> ffffffff8141dc68:       41 55                   push   %r13
> ffffffff8141dc6a:       49 89 fd                mov    %rdi,%r13
> ffffffff8141dc6d:       89 cf                   mov    %ecx,%edi
> ffffffff8141dc6f:       48 c1 e7 04             shl    $0x4,%rdi
> ffffffff8141dc73:       41 54                   push   %r12
> ffffffff8141dc75:       49 89 d4                mov    %rdx,%r12
> ffffffff8141dc78:       53                      push   %rbx
> ffffffff8141dc79:       48 89 f3                mov    %rsi,%rbx
> ffffffff8141dc7c:       48 83 ec 28             sub    $0x28,%rsp
> ffffffff8141dc80:       8b 75 20                mov    0x20(%rbp),%esi
> ffffffff8141dc83:       89 4d bc                mov    %ecx,-0x44(%rbp)
> ffffffff8141dc86:       44 89 45 cc             mov    %r8d,-0x34(%rbp)
> ffffffff8141dc8a:       44 89 4d c8             mov    %r9d,-0x38(%rbp)
> ffffffff8141dc8e:       83 e6 dd                and    $0xffffffdd,%esi
> ffffffff8141dc91:       e8 7a d1 d7 ff          callq  ffffffff8119ae10 <=
__kmalloc>
> ffffffff8141dc96:       48 85 c0                test   %rax,%rax
>=20
> So, it's *strange*.
>=20
> I will add .config and .o.
> Maybe someone might find what happens.
>=20

This is really bothering me. I'm trying to figure it out. We have from
the stack trace:

[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:   9)=
     6456      80   __kmalloc+0x1cb/0x200
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  10)=
     6376     376   vring_add_indirect+0x36/0x200
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  11)=
     6000     144   virtqueue_add_sgs+0x2e2/0x320

The way the stack tracer works, is that when it detects a new max stack
it calls save_stack_trace() to get the complete call chain from the
stack. This should be rather accurate as it seems that your kernel was
compiled with frame pointers (confirmed by the objdump as well as the
config file). It then uses that stack trace that it got to examine the
stack to find the locations of the saved return addresses and records
them in an array (in your case, an array of 50 entries).

=46rom your .o file:

vring_add_indirect + 0x36: (0x370 + 0x36 =3D 0x3a6)

0000000000000370 <vring_add_indirect>:

 39e:   83 e6 dd                and    $0xffffffdd,%esi
 3a1:   e8 00 00 00 00          callq  3a6 <vring_add_indirect+0x36>
                        3a2: R_X86_64_PC32      __kmalloc-0x4
 3a6:   48 85 c0                test   %rax,%rax

Definitely the return address to the call to __kmalloc. Then to
determine the size of the stack frame, it is subtracted from the next
one down. In this case, the location of virtqueue_add_sgs+0x2e2.

virtqueue_add_sgs + 0x2e2: (0x880 + 0x2e2 =3D 0xb62)

0000000000000880 <virtqueue_add_sgs>:

b4f:   89 4c 24 08             mov    %ecx,0x8(%rsp)
 b53:   48 c7 c2 00 00 00 00    mov    $0x0,%rdx
                        b56: R_X86_64_32S       .text+0x570
 b5a:   44 89 d1                mov    %r10d,%ecx
 b5d:   e8 0e f8 ff ff          callq  370 <vring_add_indirect>
 b62:   85 c0                   test   %eax,%eax


Which is the return address of where vring_add_indirect was called.

The return address back to virtqueue_add_sgs was found at 6000 bytes of
the stack. The return address back to vring_add_indirect was found at
6376 bytes from the top of the stack.

My question is, why were they so far apart? I see 6 words pushed
(8bytes each, for a total of 48 bytes), and a subtraction of the stack
pointer of 0x28 (40 bytes) giving us a total of 88 bytes. Plus we need
to add the push of the return address itself which would just give us
96 bytes for the stack frame. What is making this show 376 bytes??

Looking more into this, I'm not sure I trust the top numbers anymore.
kmalloc reports a stack frame of 80, and I'm coming up with 104
(perhaps even 112). And slab_alloc only has 8. Something's messed up there.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
