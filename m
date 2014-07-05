Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AD6426B0031
	for <linux-mm@kvack.org>; Sat,  5 Jul 2014 10:47:15 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so3195293pab.3
        for <linux-mm@kvack.org>; Sat, 05 Jul 2014 07:47:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pk4si37316485pbc.252.2014.07.05.07.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 05 Jul 2014 07:47:14 -0700 (PDT)
Message-ID: <53B80EAC.1060107@oracle.com>
Date: Sat, 05 Jul 2014 10:41:48 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: derefing NULL vma->vm_mm when unmapping
References: <53B16B05.20108@gmail.com> <20140630150728.c5f268a0092862f2a7d2b29c@linux-foundation.org> <alpine.LSU.2.11.1406301729500.5074@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406301729500.5074@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 06/30/2014 08:55 PM, Hugh Dickins wrote:
> On Mon, 30 Jun 2014, Andrew Morton wrote:
>> On Mon, 30 Jun 2014 09:49:57 -0400 Sasha Levin <levinsasha928@gmail.com> wrote:
>>
>> Dunno.  You're under KVM and tracing is enabled, yes?  I don't
>> immediately see how that would affect it.
> 
> I am beginning to wonder whether some of Sasha's reports are
> actually problems with KVM, which I cannot help with at all.
> It does add another dimension of doubt.  Or with DEBUG_PAGEALLOC.

The good news are that Oracle are being pretty cool and giving me some
more machines I could fuzz on, so soon I'll be doing fuzzing on physical
hardware as well - that'll tell us about KVM specific issues.

> I took a quick look, but had no more ideas on this crash than many
> other of his recent ones.  Or is there something very (but very
> rarely) wrong with the rmap walk and its trees these days?

It seems I'm hitting page table corruptions here and there, but not
sure if it's related to the report above.

[ 5753.537772] trinity-c43: Corrupted page table at address 7fc9a9fa2000
[ 5753.538893] PGD 3c2508067 PUD 3bbd58067 PMD 2f3b6a067 PTE ffff8800000b0235
[ 5753.540105] Bad pagetable: 0009 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 5753.540105] Dumping ftrace buffer:
[ 5753.542307]    (ftrace buffer empty)
[ 5753.542307] Modules linked in:
[ 5753.542307] CPU: 14 PID: 19432 Comm: trinity-c43 Not tainted 3.16.0-rc3-next-20140703-sasha-00024-g2ad7668-dirty #763
[ 5753.542307] task: ffff880161590000 ti: ffff880168c28000 task.ti: ffff880168c28000
[ 5753.542307] RIP: copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:166)
[ 5753.542307] RSP: 0018:ffff880168c2bf30  EFLAGS: 00010202
[ 5753.542307] RAX: ffff880168c28000 RBX: 00007fc9a9fa2000 RCX: 0000000000000002
[ 5753.542307] RDX: 0000000000000000 RSI: 00007fc9a9fa2000 RDI: ffff880168c2bf48
[ 5753.542307] RBP: ffff880168c2bf78 R08: 00000000001a7d9e R09: 0000000000000000
[ 5753.542307] R10: 0000000000000000 R11: 0000000000000001 R12: 00007fc9a9fa2008
[ 5753.542307] R13: 00007fc9aa16e6a8 R14: 0000000000000000 R15: 00000000000000a4
[ 5753.542307] FS:  00007fc9aa16e700(0000) GS:ffff88036ae00000(0000) knlGS:0000000000000000
[ 5753.542307] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 5753.542307] CR2: 00007fc9a9fa2000 CR3: 000000015157a000 CR4: 00000000000006a0
[ 5753.542307] Stack:
[ 5753.542307]  ffffffff9216ffa1 00007fc9aa16e6a8 0000000000000000 00007fc9a9a1f000
[ 5753.542307]  ffffffff954d6ef0 00000000000000a4 0000000000000000 00000000000000a4
[ 5753.542307]  00007fc9a9a1f000 00007fc9a9a1f000 ffffffff954d6f53 0000000000000246
[ 5753.542307] Call Trace:
[ 5753.542307] ? SyS_settimeofday (kernel/time.c:196 kernel/time.c:189)
[ 5753.542307] ? tracesys (arch/x86/kernel/entry_64.S:531)
[ 5753.542307] tracesys (arch/x86/kernel/entry_64.S:542)
[ 5753.542307] Code: 30 4c 8b 5e 38 4c 89 47 20 4c 89 4f 28 4c 89 57 30 4c 89 5f 38 48 8d 76 40 48 8d 7f 40 ff c9 75 b6 89 d1 83 e2 07 c1 e9 03 74 12 <4c> 8b 06 4c 89 07 48 8d 76 08 48 8d 7f 08 ff c9 75 ee 21 d2 74
All code
========
   0:	30 4c 8b 5e          	xor    %cl,0x5e(%rbx,%rcx,4)
   4:	38 4c 89 47          	cmp    %cl,0x47(%rcx,%rcx,4)
   8:	20 4c 89 4f          	and    %cl,0x4f(%rcx,%rcx,4)
   c:	28 4c 89 57          	sub    %cl,0x57(%rcx,%rcx,4)
  10:	30 4c 89 5f          	xor    %cl,0x5f(%rcx,%rcx,4)
  14:	38 48 8d             	cmp    %cl,-0x73(%rax)
  17:	76 40                	jbe    0x59
  19:	48 8d 7f 40          	lea    0x40(%rdi),%rdi
  1d:	ff c9                	dec    %ecx
  1f:	75 b6                	jne    0xffffffffffffffd7
  21:	89 d1                	mov    %edx,%ecx
  23:	83 e2 07             	and    $0x7,%edx
  26:	c1 e9 03             	shr    $0x3,%ecx
  29:	74 12                	je     0x3d
  2b:*	4c 8b 06             	mov    (%rsi),%r8		<-- trapping instruction
  2e:	4c 89 07             	mov    %r8,(%rdi)
  31:	48 8d 76 08          	lea    0x8(%rsi),%rsi
  35:	48 8d 7f 08          	lea    0x8(%rdi),%rdi
  39:	ff c9                	dec    %ecx
  3b:	75 ee                	jne    0x2b
  3d:	21 d2                	and    %edx,%edx
  3f:	74 00                	je     0x41

Code starting with the faulting instruction
===========================================
   0:	4c 8b 06             	mov    (%rsi),%r8
   3:	4c 89 07             	mov    %r8,(%rdi)
   6:	48 8d 76 08          	lea    0x8(%rsi),%rsi
   a:	48 8d 7f 08          	lea    0x8(%rdi),%rdi
   e:	ff c9                	dec    %ecx
  10:	75 ee                	jne    0x0
  12:	21 d2                	and    %edx,%edx
  14:	74 00                	je     0x16
[ 5753.570683] RIP copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:166)
[ 5753.570683]  RSP <ffff880168c2bf30>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
