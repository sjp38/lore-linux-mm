Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BE4286B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 08:06:30 -0400 (EDT)
Message-ID: <51B9B5BC.4090702@nod.at>
Date: Thu, 13 Jun 2013 14:06:20 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: mem_cgroup_page_lruvec: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000001a8
References: <CAFLxGvzKes7mGknTJgqFamr_-ODPBArf6BajF+m5x-S4AEtdmQ@mail.gmail.com> <20130613120248.GB23070@dhcp22.suse.cz>
In-Reply-To: <20130613120248.GB23070@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups mailinglist <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, bsingharora@gmail.com, hannes@cmpxchg.org

Am 13.06.2013 14:02, schrieb Michal Hocko:
> On Thu 13-06-13 13:48:27, richard -rw- weinberger wrote:
>> Hi!
>>
>> While playing with user namespaces my kernel crashed under heavy load.
>> Kernel is 3.9.0 plus some trivial patches.
>
> Could you post disassembly for mem_cgroup_page_lruvec?

Sure!

00000000000035e0 <mem_cgroup_page_lruvec>:
     35e0:       55                      push   %rbp
     35e1:       48 8d 86 c8 03 00 00    lea    0x3c8(%rsi),%rax
     35e8:       48 89 e5                mov    %rsp,%rbp
     35eb:       48 83 ec 10             sub    $0x10,%rsp
     35ef:       48 89 5d f0             mov    %rbx,-0x10(%rbp)
     35f3:       48 89 f3                mov    %rsi,%rbx
     35f6:       8b 35 00 00 00 00       mov    0x0(%rip),%esi        # 35fc <mem_cgroup_page_lruvec+0x1c>
     35fc:       4c 89 65 f8             mov    %r12,-0x8(%rbp)
     3600:       85 f6                   test   %esi,%esi
     3602:       75 55                   jne    3659 <mem_cgroup_page_lruvec+0x79>
     3604:       49 89 fc                mov    %rdi,%r12
     3607:       e8 00 00 00 00          callq  360c <mem_cgroup_page_lruvec+0x2c>
     360c:       49 8b 14 24             mov    (%r12),%rdx
     3610:       48 8b 48 08             mov    0x8(%rax),%rcx
     3614:       83 e2 20                and    $0x20,%edx
     3617:       75 1f                   jne    3638 <mem_cgroup_page_lruvec+0x58>
     3619:       48 8b 10                mov    (%rax),%rdx
     361c:       83 e2 02                and    $0x2,%edx
     361f:       75 17                   jne    3638 <mem_cgroup_page_lruvec+0x58>
     3621:       48 8b 15 00 00 00 00    mov    0x0(%rip),%rdx        # 3628 <mem_cgroup_page_lruvec+0x48>
     3628:       48 39 d1                cmp    %rdx,%rcx
     362b:       74 0b                   je     3638 <mem_cgroup_page_lruvec+0x58>
     362d:       48 89 50 08             mov    %rdx,0x8(%rax)
     3631:       48 89 d1                mov    %rdx,%rcx
     3634:       0f 1f 40 00             nopl   0x0(%rax)
     3638:       49 8b 04 24             mov    (%r12),%rax
     363c:       48 89 c2                mov    %rax,%rdx
     363f:       48 c1 e8 38             shr    $0x38,%rax
     3643:       83 e0 03                and    $0x3,%eax
     3646:       48 c1 ea 3a             shr    $0x3a,%rdx
     364a:       48 69 c0 38 01 00 00    imul   $0x138,%rax,%rax
     3651:       48 03 84 d1 e0 02 00    add    0x2e0(%rcx,%rdx,8),%rax
     3658:       00
     3659:       48 3b 58 70             cmp    0x70(%rax),%rbx
     365d:       75 0a                   jne    3669 <mem_cgroup_page_lruvec+0x89>
     365f:       48 8b 5d f0             mov    -0x10(%rbp),%rbx
     3663:       4c 8b 65 f8             mov    -0x8(%rbp),%r12
     3667:       c9                      leaveq
     3668:       c3                      retq
     3669:       48 89 58 70             mov    %rbx,0x70(%rax)
     366d:       eb f0                   jmp    365f <mem_cgroup_page_lruvec+0x7f>
     366f:       90                      nop

FWIW the ./scripts/decodecode output:

All code
========
    0:   89 50 08                mov    %edx,0x8(%rax)
    3:   48 89 d1                mov    %rdx,%rcx
    6:   0f 1f 40 00             nopl   0x0(%rax)
    a:   49 8b 04 24             mov    (%r12),%rax
    e:   48 89 c2                mov    %rax,%rdx
   11:   48 c1 e8 38             shr    $0x38,%rax
   15:   83 e0 03                and    $0x3,%eax
   18:   48 c1 ea 3a             shr    $0x3a,%rdx
   1c:   48 69 c0 38 01 00 00    imul   $0x138,%rax,%rax
   23:   48 03 84 d1 e0 02 00    add    0x2e0(%rcx,%rdx,8),%rax
   2a:   00
   2b:*  48 3b 58 70             cmp    0x70(%rax),%rbx     <-- trapping instruction
   2f:   75 0a                   jne    0x3b
   31:   48 8b 5d f0             mov    -0x10(%rbp),%rbx
   35:   4c 8b 65 f8             mov    -0x8(%rbp),%r12
   39:   c9                      leaveq
   3a:   c3                      retq
   3b:   48 89 58 70             mov    %rbx,0x70(%rax)
   3f:   eb                      .byte 0xeb

Code starting with the faulting instruction
===========================================
    0:   48 3b 58 70             cmp    0x70(%rax),%rbx
    4:   75 0a                   jne    0x10
    6:   48 8b 5d f0             mov    -0x10(%rbp),%rbx
    a:   4c 8b 65 f8             mov    -0x8(%rbp),%r12
    e:   c9                      leaveq
    f:   c3                      retq
   10:   48 89 58 70             mov    %rbx,0x70(%rax)
   14:   eb                      .byte 0xeb


Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
