Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9F66B0260
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 21:55:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so136071341pfa.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 18:55:56 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y80si6489515pfi.205.2016.07.20.18.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 18:55:55 -0700 (PDT)
Message-ID: <57902B8A.8040907@huawei.com>
Date: Thu, 21 Jul 2016 09:55:22 +0800
From: zhouchengming <zhouchengming1@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] make __section_nr more efficient
References: <1468988310-11560-1-git-send-email-zhouchengming1@huawei.com> <578FEEC4.9060209@intel.com>
In-Reply-To: <578FEEC4.9060209@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, tj@kernel.org, guohanjun@huawei.com, huawei.libin@huawei.com

On 2016/7/21 5:36, Dave Hansen wrote:
> On 07/19/2016 09:18 PM, Zhou Chengming wrote:
>> When CONFIG_SPARSEMEM_EXTREME is disabled, __section_nr can get
>> the section number with a subtraction directly.
>
> Does this actually *do* anything?
>
> It was a long time ago, but if I remember correctly, the entire loop in
> __section_nr() goes away because root_nr==NR_SECTION_ROOTS, so
> root_nr=1, and the compiler optimizes away the entire subtraction.
>
> So this basically adds an #ifdef and gets us nothing, although it makes
> the situation much more explicit.  Perhaps the comment should say that
> this works *and* is efficient because the compiler can optimize all the
> extreme complexity away.
>
> .
>

Thanks for your reply. I don't know the compiler will optimize the loop.
But when I see the assembly code of __section_nr, it seems to still have
the loop in it.

My gcc version: gcc version 4.9.0 (GCC)
CONFIG_SPARSEMEM_EXTREME: disabled

Before this patch:

0000000000000000 <__section_nr>:
    0:   55                      push   %rbp
    1:   48 c7 c2 00 00 00 00    mov    $0x0,%rdx
                         4: R_X86_64_32S mem_section
    8:   31 c0                   xor    %eax,%eax
    a:   48 89 e5                mov    %rsp,%rbp
    d:   eb 0d                   jmp    1c <__section_nr+0x1c>
    f:   48 83 c0 01             add    $0x1,%rax
   13:   48 81 fa 00 00 00 00    cmp    $0x0,%rdx
                         16: R_X86_64_32S        mem_section+0x800000
   1a:   74 26                   je     42 <__section_nr+0x42>
   1c:   48 89 d1                mov    %rdx,%rcx
   1f:   ba 10 00 00 00          mov    $0x10,%edx
   24:   48 85 c9                test   %rcx,%rcx
   27:   74 e6                   je     f <__section_nr+0xf>
   29:   48 39 cf                cmp    %rcx,%rdi
   2c:   48 8d 51 10             lea    0x10(%rcx),%rdx
   30:   72 dd                   jb     f <__section_nr+0xf>
   32:   48 39 d7                cmp    %rdx,%rdi
   35:   73 d8                   jae    f <__section_nr+0xf>
   37:   48 29 cf                sub    %rcx,%rdi
   3a:   48 c1 ff 04             sar    $0x4,%rdi
   3e:   01 f8                   add    %edi,%eax
   40:   5d                      pop    %rbp
   41:   c3                      retq
   42:   48 29 cf                sub    %rcx,%rdi
   45:   b8 00 00 08 00          mov    $0x80000,%eax
   4a:   48 c1 ff 04             sar    $0x4,%rdi
   4e:   01 f8                   add    %edi,%eax
   50:   5d                      pop    %rbp
   51:   c3                      retq
   52:   66 66 66 66 66 2e 0f    data32 data32 data32 data32 nopw %cs:0x0(%rax,%rax,1)
   59:   1f 84 00 00 00 00 00

After this patch:

0000000000000000 <__section_nr>:
    0:   55                      push   %rbp
    1:   48 89 f8                mov    %rdi,%rax
    4:   48 2d 00 00 00 00       sub    $0x0,%rax
                         6: R_X86_64_32S mem_section
    a:   48 89 e5                mov    %rsp,%rbp
    d:   48 c1 f8 04             sar    $0x4,%rax
   11:   5d                      pop    %rbp
   12:   c3                      retq
   13:   66 66 66 66 2e 0f 1f    data32 data32 data32 nopw %cs:0x0(%rax,%rax,1)
   1a:   84 00 00 00 00 00


Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
