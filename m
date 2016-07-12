Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 480706B0267
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:15:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so6674309wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:15:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si3531731wjr.229.2016.07.12.00.15.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 00:15:06 -0700 (PDT)
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return value
 of PageMovable
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
 <20160711002605.GD31817@bbox> <5783F7DE.9020203@emindsoft.com.cn>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3e4d01ff-3fad-457e-b015-e06c35f8f714@suse.cz>
Date: Tue, 12 Jul 2016 09:15:00 +0200
MIME-Version: 1.0
In-Reply-To: <5783F7DE.9020203@emindsoft.com.cn>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>, Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 07/11/2016 09:47 PM, Chen Gang wrote:
>
> On 7/11/16 08:26, Minchan Kim wrote:
>> On Sat, Jul 09, 2016 at 11:55:04PM +0800, chengang@emindsoft.com.cn wrote:
>>> From: Chen Gang <chengang@emindsoft.com.cn>
>>>
>>> For pure bool function's return value, bool is a little better more or
>>> less than int.
>>>
>>> And return boolean result directly, since 'if' statement is also for
>>> boolean checking, and return boolean result, too.
>>
>> I just wanted to consistent with other PageXXX flags functions, PageAnon,
>> PageMappingFlags which returns int rather than bool. Although I agree bool
>> is natural, I want to be consistent with others rather than breaking at
>> the moment.
>>
>> Maybe if you feel it's really helpful, you might be able to handle all
>> of places I mentioned for better readability and keeping consistency.
>
> OK, I guess, we can send another patch for include/linux/page-flags.h
> for PageXXX.
>
>> But I doubt it's worth.
>>
>
> In our case, the 2 output size are same, but under x86_64, the insns are
> different. After uses bool, it uses push/pop instead of branch, for me,
> it should be a little better for catching.

You mean "caching"? I don't see how this is better for caching. After 
the push/pop, the same branch is still there, so it's not eliminated 
(which would be indeed better). Somehow the original version just avoids 
the function prologue (push rbp, mov rsp, rbp) for the 
!__PageMovable(page) case. That's something I would expect e.g. if it 
was marked likely(), but here it's probably just accidental that the 
heuristics think it's likely in the "int" case and not "bool". So it's 
not a valid reason for prefering int over bool. The question is perhaps 
if it's indeed likely or unlikely and should be marked as such :)

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
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
