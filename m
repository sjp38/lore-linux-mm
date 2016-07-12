Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7EC36B026D
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:48:45 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so5436921lfg.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:48:45 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id i10si3646189wjt.141.2016.07.12.00.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 00:48:44 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id f126so117747926wma.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:48:44 -0700 (PDT)
Date: Tue, 12 Jul 2016 09:48:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return
 value of PageMovable
Message-ID: <20160712074841.GE14586@dhcp22.suse.cz>
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
 <20160711002605.GD31817@bbox>
 <5783F7DE.9020203@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5783F7DE.9020203@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Tue 12-07-16 03:47:42, Chen Gang wrote:
[...]
> In our case, the 2 output size are same, but under x86_64, the insns are
> different. After uses bool, it uses push/pop instead of branch, for me,
> it should be a little better for catching.

The code generated for bool version looks much worse. Look at the fast
path. Gcc tries to reuse the retq from the fast path in the bool case
and so it has to push rbp and rbx on the stack.

That being said, gcc doesn't seem to generate a better code for bool so
I do not think this is really worth it.

> The orig:
> 
>   0000000000001290 <PageMovable>:
>       1290:       48 8b 47 08             mov    0x8(%rdi),%rax
>       1294:       83 e0 03                and    $0x3,%eax
>       1297:       48 83 f8 02             cmp    $0x2,%rax
>       129b:       74 03                   je     12a0 <__SetPageMovable+0x12a0>
>       129d:       31 c0                   xor    %eax,%eax
>       129f:       c3                      retq
>       12a0:       55                      push   %rbp
>       12a1:       48 89 e5                mov    %rsp,%rbp
>       12a4:       e8 00 00 00 00          callq  12a9 <__SetPageMovable+0x12a9>
>       12a9:       48 85 c0                test   %rax,%rax
>       12ac:       74 17                   je     12c5 <__SetPageMovable+0x12c5>
>       12ae:       48 8b 50 68             mov    0x68(%rax),%rdx
>       12b2:       48 85 d2                test   %rdx,%rdx
>       12b5:       74 0e                   je     12c5 <__SetPageMovable+0x12c5>
>       12b7:       48 83 7a 68 00          cmpq   $0x0,0x68(%rdx)
>       12bc:       b8 01 00 00 00          mov    $0x1,%eax
>       12c1:       74 02                   je     12c5 <__SetPageMovable+0x12c5>
>       12c3:       5d                      pop    %rbp
>       12c4:       c3                      retq
>       12c5:       31 c0                   xor    %eax,%eax
>       12c7:       5d                      pop    %rbp
>       12c8:       c3                      retq
>       12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
> 
> The new:
> 
>   0000000000001290 <PageMovable>:
>       1290:       48 8b 47 08             mov    0x8(%rdi),%rax
>       1294:       55                      push   %rbp
>       1295:       48 89 e5                mov    %rsp,%rbp
>       1298:       53                      push   %rbx
>       1299:       31 db                   xor    %ebx,%ebx
>       129b:       83 e0 03                and    $0x3,%eax
>       129e:       48 83 f8 02             cmp    $0x2,%rax
>       12a2:       74 05                   je     12a9 <__SetPageMovable+0x12a9>
>       12a4:       89 d8                   mov    %ebx,%eax
>       12a6:       5b                      pop    %rbx
>       12a7:       5d                      pop    %rbp
>       12a8:       c3                      retq
>       12a9:       e8 00 00 00 00          callq  12ae <__SetPageMovable+0x12ae>
>       12ae:       48 85 c0                test   %rax,%rax
>       12b1:       74 f1                   je     12a4 <__SetPageMovable+0x12a4>
>       12b3:       48 8b 40 68             mov    0x68(%rax),%rax
>       12b7:       48 85 c0                test   %rax,%rax
>       12ba:       74 e8                   je     12a4 <__SetPageMovable+0x12a4>
>       12bc:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
>       12c1:       0f 95 c3                setne  %bl
>       12c4:       89 d8                   mov    %ebx,%eax
>       12c6:       5b                      pop    %rbx
>       12c7:       5d                      pop    %rbp
>       12c8:       c3                      retq
>       12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
> 
> Thanks.
> -- 
> Chen Gang (e??a??)
> 
> Managing Natural Environments is the Duty of Human Beings.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
