Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 152E86B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 15:41:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so137862000pfx.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 12:41:42 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id k29si1022009pfk.57.2016.07.11.12.41.40
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 12:41:41 -0700 (PDT)
Message-ID: <5783F7DE.9020203@emindsoft.com.cn>
Date: Tue, 12 Jul 2016 03:47:42 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return value
 of PageMovable
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn> <20160711002605.GD31817@bbox>
In-Reply-To: <20160711002605.GD31817@bbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 7/11/16 08:26, Minchan Kim wrote:
> On Sat, Jul 09, 2016 at 11:55:04PM +0800, chengang@emindsoft.com.cn wrote:
>> From: Chen Gang <chengang@emindsoft.com.cn>
>>
>> For pure bool function's return value, bool is a little better more or
>> less than int.
>>
>> And return boolean result directly, since 'if' statement is also for
>> boolean checking, and return boolean result, too.
> 
> I just wanted to consistent with other PageXXX flags functions, PageAnon,
> PageMappingFlags which returns int rather than bool. Although I agree bool
> is natural, I want to be consistent with others rather than breaking at
> the moment.
> 
> Maybe if you feel it's really helpful, you might be able to handle all
> of places I mentioned for better readability and keeping consistency.

OK, I guess, we can send another patch for include/linux/page-flags.h
for PageXXX.

> But I doubt it's worth.
> 

In our case, the 2 output size are same, but under x86_64, the insns are
different. After uses bool, it uses push/pop instead of branch, for me,
it should be a little better for catching.

The orig:

  0000000000001290 <PageMovable>:
      1290:       48 8b 47 08             mov    0x8(%rdi),%rax
      1294:       83 e0 03                and    $0x3,%eax
      1297:       48 83 f8 02             cmp    $0x2,%rax
      129b:       74 03                   je     12a0 <__SetPageMovable+0x12a0>
      129d:       31 c0                   xor    %eax,%eax
      129f:       c3                      retq
      12a0:       55                      push   %rbp
      12a1:       48 89 e5                mov    %rsp,%rbp
      12a4:       e8 00 00 00 00          callq  12a9 <__SetPageMovable+0x12a9>
      12a9:       48 85 c0                test   %rax,%rax
      12ac:       74 17                   je     12c5 <__SetPageMovable+0x12c5>
      12ae:       48 8b 50 68             mov    0x68(%rax),%rdx
      12b2:       48 85 d2                test   %rdx,%rdx
      12b5:       74 0e                   je     12c5 <__SetPageMovable+0x12c5>
      12b7:       48 83 7a 68 00          cmpq   $0x0,0x68(%rdx)
      12bc:       b8 01 00 00 00          mov    $0x1,%eax
      12c1:       74 02                   je     12c5 <__SetPageMovable+0x12c5>
      12c3:       5d                      pop    %rbp
      12c4:       c3                      retq
      12c5:       31 c0                   xor    %eax,%eax
      12c7:       5d                      pop    %rbp
      12c8:       c3                      retq
      12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)

The new:

  0000000000001290 <PageMovable>:
      1290:       48 8b 47 08             mov    0x8(%rdi),%rax
      1294:       55                      push   %rbp
      1295:       48 89 e5                mov    %rsp,%rbp
      1298:       53                      push   %rbx
      1299:       31 db                   xor    %ebx,%ebx
      129b:       83 e0 03                and    $0x3,%eax
      129e:       48 83 f8 02             cmp    $0x2,%rax
      12a2:       74 05                   je     12a9 <__SetPageMovable+0x12a9>
      12a4:       89 d8                   mov    %ebx,%eax
      12a6:       5b                      pop    %rbx
      12a7:       5d                      pop    %rbp
      12a8:       c3                      retq
      12a9:       e8 00 00 00 00          callq  12ae <__SetPageMovable+0x12ae>
      12ae:       48 85 c0                test   %rax,%rax
      12b1:       74 f1                   je     12a4 <__SetPageMovable+0x12a4>
      12b3:       48 8b 40 68             mov    0x68(%rax),%rax
      12b7:       48 85 c0                test   %rax,%rax
      12ba:       74 e8                   je     12a4 <__SetPageMovable+0x12a4>
      12bc:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
      12c1:       0f 95 c3                setne  %bl
      12c4:       89 d8                   mov    %ebx,%eax
      12c6:       5b                      pop    %rbx
      12c7:       5d                      pop    %rbp
      12c8:       c3                      retq
      12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
