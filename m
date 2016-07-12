Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21B5B6B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:36:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w207so35413489oiw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:36:30 -0700 (PDT)
Received: from out1134-233.mail.aliyun.com (out1134-233.mail.aliyun.com. [42.120.134.233])
        by mx.google.com with ESMTP id n64si12500005itb.52.2016.07.12.09.36.27
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 09:36:28 -0700 (PDT)
Message-ID: <57851DFF.2010202@emindsoft.com.cn>
Date: Wed, 13 Jul 2016 00:42:39 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return value
 of PageMovable
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn> <20160711002605.GD31817@bbox> <5783F7DE.9020203@emindsoft.com.cn> <3e4d01ff-3fad-457e-b015-e06c35f8f714@suse.cz>
In-Reply-To: <3e4d01ff-3fad-457e-b015-e06c35f8f714@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 7/12/16 15:15, Vlastimil Babka wrote:
> On 07/11/2016 09:47 PM, Chen Gang wrote:
>>
>>
>> In our case, the 2 output size are same, but under x86_64, the insns are
>> different. After uses bool, it uses push/pop instead of branch, for me,
>> it should be a little better for catching.
> 
> You mean "caching"? I don't see how this is better for caching. After the push/pop, the same branch is still there, so it's not eliminated (which would be indeed better). Somehow the original version just avoids the function prologue (push rbp, mov rsp, rbp) for the !__PageMovable(page) case. That's something I would expect e.g. if it was marked likely(), but here it's probably just accidental that the heuristics think it's likely in the "int" case and not "bool". So it's not a valid reason for prefering int over bool. The question is perhaps if it's indeed likely or unlikely and should be marked as such :)
>

Oh, sorry, after check the details, the result is a little complex (2
things are mixed together, and likely can be also considered):

 - One return statement instead of the 3 statements which will change
   the detail instructions (in fact, it has negative effect).

 - gcc 6.0 and redhat gcc 4.8 generate the different results.


The related output are:

 - If use one return statement instead of the 3 statements with gcc 6.0,
   the result is my original outputs which we discussed before.

 - If still use 3 statements (only use true, false instead of 1, 0) with
   gcc 6.0, the 2 outputs are equal.

 - If still use 3 statements (only use true, false instead of 1, 0) with
   gcc 4.8, the 2 outputs are different, and obviously, the bool will be
   a little better (no "xor %ebx,%ebx").

 - If use one return statement instead of the 3 statements with gcc 4.8,
   the result is a little bad than keeping 3 statements.

 - If we add likely(), can get the same result: bool is a little better
   (no "movzbl %al,%eax").


All together:

 - For return statement, merging multi-statement together is not a good
   idea, it will let compiler generates a little bad code.

 - For gcc 6.0, in our case, the outputs are the same (and both enable
   'likely', too).

 - For gcc 4.8, in our case, 'bool' output is a little better than 'int'
   (after enable 'likely', also get the same result)


The int output by gcc 4.8:

  0000000000001150 <PageMovable>:
      1150:       48 8b 57 08             mov    0x8(%rdi),%rdx
      1154:       55                      push   %rbp
      1155:       48 89 e5                mov    %rsp,%rbp
      1158:       53                      push   %rbx
      1159:       31 db                   xor    %ebx,%ebx
      115b:       83 e2 03                and    $0x3,%edx
      115e:       48 83 fa 02             cmp    $0x2,%rdx
      1162:       74 05                   je     1169 <__SetPageMovable+0x1169>
      1164:       89 d8                   mov    %ebx,%eax
      1166:       5b                      pop    %rbx
      1167:       5d                      pop    %rbp
      1168:       c3                      retq
      1169:       e8 00 00 00 00          callq  116e <__SetPageMovable+0x116e>
      116e:       48 85 c0                test   %rax,%rax
      1171:       74 f1                   je     1164 <__SetPageMovable+0x1164>
      1173:       48 8b 40 68             mov    0x68(%rax),%rax
      1177:       48 85 c0                test   %rax,%rax
      117a:       74 e8                   je     1164 <__SetPageMovable+0x1164>
      117c:       31 db                   xor    %ebx,%ebx
      117e:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
      1183:       0f 95 c3                setne  %bl
      1186:       89 d8                   mov    %ebx,%eax
      1188:       5b                      pop    %rbx
      1189:       5d                      pop    %rbp
      118a:       c3                      retq
      118b:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)

The bool output by gcc 4.8:

  0000000000001150 <PageMovable>:
      1150:       48 8b 57 08             mov    0x8(%rdi),%rdx
      1154:       55                      push   %rbp
      1155:       48 89 e5                mov    %rsp,%rbp
      1158:       53                      push   %rbx
      1159:       31 db                   xor    %ebx,%ebx
      115b:       83 e2 03                and    $0x3,%edx
      115e:       48 83 fa 02             cmp    $0x2,%rdx
      1162:       74 05                   je     1169 <__SetPageMovable+0x1169>
      1164:       89 d8                   mov    %ebx,%eax
      1166:       5b                      pop    %rbx
      1167:       5d                      pop    %rbp
      1168:       c3                      retq
      1169:       e8 00 00 00 00          callq  116e <__SetPageMovable+0x116e>
      116e:       48 85 c0                test   %rax,%rax
      1171:       74 f1                   je     1164 <__SetPageMovable+0x1164>
      1173:       48 8b 40 68             mov    0x68(%rax),%rax
      1177:       48 85 c0                test   %rax,%rax
      117a:       74 e8                   je     1164 <__SetPageMovable+0x1164>
      117c:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
      1181:       0f 95 c3                setne  %bl
      1184:       89 d8                   mov    %ebx,%eax
      1186:       5b                      pop    %rbx
      1187:       5d                      pop    %rbp
      1188:       c3                      retq
      1189:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)

The int output by gcc 4.8 with likely():

  0000000000001150 <PageMovable>:
      1150:       48 8b 47 08             mov    0x8(%rdi),%rax
      1154:       83 e0 03                and    $0x3,%eax
      1157:       48 83 f8 02             cmp    $0x2,%rax
      115b:       74 03                   je     1160 <__SetPageMovable+0x1160>
      115d:       31 c0                   xor    %eax,%eax
      115f:       c3                      retq
      1160:       55                      push   %rbp
      1161:       48 89 e5                mov    %rsp,%rbp
      1164:       e8 00 00 00 00          callq  1169 <__SetPageMovable+0x1169>
      1169:       48 85 c0                test   %rax,%rax
      116c:       74 16                   je     1184 <__SetPageMovable+0x1184>
      116e:       48 8b 40 68             mov    0x68(%rax),%rax
      1172:       48 85 c0                test   %rax,%rax
      1175:       74 0d                   je     1184 <__SetPageMovable+0x1184>
      1177:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
      117c:       5d                      pop    %rbp
      117d:       0f 95 c0                setne  %al
      1180:       0f b6 c0                movzbl %al,%eax
      1183:       c3                      retq
      1184:       31 c0                   xor    %eax,%eax
      1186:       5d                      pop    %rbp
      1187:       c3                      retq
      1188:       0f 1f 84 00 00 00 00    nopl   0x0(%rax,%rax,1)
      118f:       00 

The bool output by gcc 4.8 with likely():

  0000000000001150 <PageMovable>:
      1150:       48 8b 47 08             mov    0x8(%rdi),%rax
      1154:       83 e0 03                and    $0x3,%eax
      1157:       48 83 f8 02             cmp    $0x2,%rax
      115b:       74 03                   je     1160 <__SetPageMovable+0x1160>
      115d:       31 c0                   xor    %eax,%eax
      115f:       c3                      retq
      1160:       55                      push   %rbp
      1161:       48 89 e5                mov    %rsp,%rbp
      1164:       e8 00 00 00 00          callq  1169 <__SetPageMovable+0x1169>
      1169:       48 85 c0                test   %rax,%rax
      116c:       74 13                   je     1181 <__SetPageMovable+0x1181>
      116e:       48 8b 40 68             mov    0x68(%rax),%rax
      1172:       48 85 c0                test   %rax,%rax
      1175:       74 0a                   je     1181 <__SetPageMovable+0x1181>
      1177:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
      117c:       5d                      pop    %rbp
      117d:       0f 95 c0                setne  %al
      1180:       c3                      retq
      1181:       31 c0                   xor    %eax,%eax
      1183:       5d                      pop    %rbp
      1184:       c3                      retq
      1185:       66 66 2e 0f 1f 84 00    data32 nopw %cs:0x0(%rax,%rax,1)
      118c:       00 00 00 00 

Thanks.
 
>> The orig:
>>
>>   0000000000001290 <PageMovable>:
>>       1290:       48 8b 47 08             mov    0x8(%rdi),%rax
>>       1294:       83 e0 03                and    $0x3,%eax
>>       1297:       48 83 f8 02             cmp    $0x2,%rax
>>       129b:       74 03                   je     12a0 <__SetPageMovable+0x12a0>
>>       129d:       31 c0                   xor    %eax,%eax
>>       129f:       c3                      retq
>>       12a0:       55                      push   %rbp
>>       12a1:       48 89 e5                mov    %rsp,%rbp
>>       12a4:       e8 00 00 00 00          callq  12a9 <__SetPageMovable+0x12a9>
>>       12a9:       48 85 c0                test   %rax,%rax
>>       12ac:       74 17                   je     12c5 <__SetPageMovable+0x12c5>
>>       12ae:       48 8b 50 68             mov    0x68(%rax),%rdx
>>       12b2:       48 85 d2                test   %rdx,%rdx
>>       12b5:       74 0e                   je     12c5 <__SetPageMovable+0x12c5>
>>       12b7:       48 83 7a 68 00          cmpq   $0x0,0x68(%rdx)
>>       12bc:       b8 01 00 00 00          mov    $0x1,%eax
>>       12c1:       74 02                   je     12c5 <__SetPageMovable+0x12c5>
>>       12c3:       5d                      pop    %rbp
>>       12c4:       c3                      retq
>>       12c5:       31 c0                   xor    %eax,%eax
>>       12c7:       5d                      pop    %rbp
>>       12c8:       c3                      retq
>>       12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
>>
>> The new:
>>
>>   0000000000001290 <PageMovable>:
>>       1290:       48 8b 47 08             mov    0x8(%rdi),%rax
>>       1294:       55                      push   %rbp
>>       1295:       48 89 e5                mov    %rsp,%rbp
>>       1298:       53                      push   %rbx
>>       1299:       31 db                   xor    %ebx,%ebx
>>       129b:       83 e0 03                and    $0x3,%eax
>>       129e:       48 83 f8 02             cmp    $0x2,%rax
>>       12a2:       74 05                   je     12a9 <__SetPageMovable+0x12a9>
>>       12a4:       89 d8                   mov    %ebx,%eax
>>       12a6:       5b                      pop    %rbx
>>       12a7:       5d                      pop    %rbp
>>       12a8:       c3                      retq
>>       12a9:       e8 00 00 00 00          callq  12ae <__SetPageMovable+0x12ae>
>>       12ae:       48 85 c0                test   %rax,%rax
>>       12b1:       74 f1                   je     12a4 <__SetPageMovable+0x12a4>
>>       12b3:       48 8b 40 68             mov    0x68(%rax),%rax
>>       12b7:       48 85 c0                test   %rax,%rax
>>       12ba:       74 e8                   je     12a4 <__SetPageMovable+0x12a4>
>>       12bc:       48 83 78 68 00          cmpq   $0x0,0x68(%rax)
>>       12c1:       0f 95 c3                setne  %bl
>>       12c4:       89 d8                   mov    %ebx,%eax
>>       12c6:       5b                      pop    %rbx
>>       12c7:       5d                      pop    %rbp
>>       12c8:       c3                      retq
>>       12c9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
>>
>> Thanks.
>>
> 
> 

-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
