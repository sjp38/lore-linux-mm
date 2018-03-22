Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 444A36B025E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 16:03:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t69so5168401pfi.20
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:03:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v15sor2212277pfk.45.2018.03.22.13.03.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 13:03:15 -0700 (PDT)
Date: Thu, 22 Mar 2018 13:03:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
In-Reply-To: <20180322121003.4177af15@gandalf.local.home>
Message-ID: <alpine.DEB.2.20.1803221302570.3268@chino.kir.corp.google.com>
References: <20180322121003.4177af15@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>

On Thu, 22 Mar 2018, Steven Rostedt wrote:

> 
> The trace event trace_mm_vmscan_lru_shrink_inactive() currently has 12
> parameters! Seven of them are from the reclaim_stat structure. This
> structure is currently local to mm/vmscan.c. By moving it to the global
> vmstat.h header, we can also reference it from the vmscan tracepoints. In
> moving it, it brings down the overhead of passing so many arguments to the
> trace event. In the future, we may limit the number of arguments that a
> trace event may pass (ideally just 6, but more realistically it may be 8).
> 
> Before this patch, the code to call the trace event is this:
> 
>  0f 83 aa fe ff ff       jae    ffffffff811e6261 <shrink_inactive_list+0x1e1>
>  48 8b 45 a0             mov    -0x60(%rbp),%rax
>  45 8b 64 24 20          mov    0x20(%r12),%r12d
>  44 8b 6d d4             mov    -0x2c(%rbp),%r13d
>  8b 4d d0                mov    -0x30(%rbp),%ecx
>  44 8b 75 cc             mov    -0x34(%rbp),%r14d
>  44 8b 7d c8             mov    -0x38(%rbp),%r15d
>  48 89 45 90             mov    %rax,-0x70(%rbp)
>  8b 83 b8 fe ff ff       mov    -0x148(%rbx),%eax
>  8b 55 c0                mov    -0x40(%rbp),%edx
>  8b 7d c4                mov    -0x3c(%rbp),%edi
>  8b 75 b8                mov    -0x48(%rbp),%esi
>  89 45 80                mov    %eax,-0x80(%rbp)
>  65 ff 05 e4 f7 e2 7e    incl   %gs:0x7ee2f7e4(%rip)        # 15bd0 <__preempt_count>
>  48 8b 05 75 5b 13 01    mov    0x1135b75(%rip),%rax        # ffffffff8231bf68 <__tracepoint_mm_vmscan_lru_shrink_inactive+0x28>
>  48 85 c0                test   %rax,%rax
>  74 72                   je     ffffffff811e646a <shrink_inactive_list+0x3ea>
>  48 89 c3                mov    %rax,%rbx
>  4c 8b 10                mov    (%rax),%r10
>  89 f8                   mov    %edi,%eax
>  48 89 85 68 ff ff ff    mov    %rax,-0x98(%rbp)
>  89 f0                   mov    %esi,%eax
>  48 89 85 60 ff ff ff    mov    %rax,-0xa0(%rbp)
>  89 c8                   mov    %ecx,%eax
>  48 89 85 78 ff ff ff    mov    %rax,-0x88(%rbp)
>  89 d0                   mov    %edx,%eax
>  48 89 85 70 ff ff ff    mov    %rax,-0x90(%rbp)
>  8b 45 8c                mov    -0x74(%rbp),%eax
>  48 8b 7b 08             mov    0x8(%rbx),%rdi
>  48 83 c3 18             add    $0x18,%rbx
>  50                      push   %rax
>  41 54                   push   %r12
>  41 55                   push   %r13
>  ff b5 78 ff ff ff       pushq  -0x88(%rbp)
>  41 56                   push   %r14
>  41 57                   push   %r15
>  ff b5 70 ff ff ff       pushq  -0x90(%rbp)
>  4c 8b 8d 68 ff ff ff    mov    -0x98(%rbp),%r9
>  4c 8b 85 60 ff ff ff    mov    -0xa0(%rbp),%r8
>  48 8b 4d 98             mov    -0x68(%rbp),%rcx
>  48 8b 55 90             mov    -0x70(%rbp),%rdx
>  8b 75 80                mov    -0x80(%rbp),%esi
>  41 ff d2                callq  *%r10
> 
> After the patch:
> 
>  0f 83 a8 fe ff ff       jae    ffffffff811e626d <shrink_inactive_list+0x1cd>
>  8b 9b b8 fe ff ff       mov    -0x148(%rbx),%ebx
>  45 8b 64 24 20          mov    0x20(%r12),%r12d
>  4c 8b 6d a0             mov    -0x60(%rbp),%r13
>  65 ff 05 f5 f7 e2 7e    incl   %gs:0x7ee2f7f5(%rip)        # 15bd0 <__preempt_count>
>  4c 8b 35 86 5b 13 01    mov    0x1135b86(%rip),%r14        # ffffffff8231bf68 <__tracepoint_mm_vmscan_lru_shrink_inactive+0x28>
>  4d 85 f6                test   %r14,%r14
>  74 2a                   je     ffffffff811e6411 <shrink_inactive_list+0x371>
>  49 8b 06                mov    (%r14),%rax
>  8b 4d 8c                mov    -0x74(%rbp),%ecx
>  49 8b 7e 08             mov    0x8(%r14),%rdi
>  49 83 c6 18             add    $0x18,%r14
>  4c 89 ea                mov    %r13,%rdx
>  45 89 e1                mov    %r12d,%r9d
>  4c 8d 45 b8             lea    -0x48(%rbp),%r8
>  89 de                   mov    %ebx,%esi
>  51                      push   %rcx
>  48 8b 4d 98             mov    -0x68(%rbp),%rcx
>  ff d0                   callq  *%rax
> 
> Link: http://lkml.kernel.org/r/2559d7cb-ec60-1200-2362-04fa34fd02bb@fb.com
> 
> Reported-by: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

Acked-by: David Rientjes <rientjes@google.com>
