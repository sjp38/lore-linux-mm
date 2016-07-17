Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBF3C6B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 20:45:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so298766642pfx.3
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 17:45:06 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 77si983818pft.11.2016.07.16.17.45.04
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 17:45:05 -0700 (PDT)
Message-ID: <578AD67F.9030905@emindsoft.com.cn>
Date: Sun, 17 Jul 2016 08:51:11 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return value
 of PageMovable
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn> <20160711002605.GD31817@bbox> <5783F7DE.9020203@emindsoft.com.cn> <20160712074841.GE14586@dhcp22.suse.cz> <57851FC4.4000000@emindsoft.com.cn> <20160713075346.GC28723@dhcp22.suse.cz>
In-Reply-To: <20160713075346.GC28723@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 7/13/16 15:53, Michal Hocko wrote:
> On Wed 13-07-16 00:50:12, Chen Gang wrote:
>>
>>
>> On 7/12/16 15:48, Michal Hocko wrote:
>>> On Tue 12-07-16 03:47:42, Chen Gang wrote:
>>> [...]
>>>> In our case, the 2 output size are same, but under x86_64, the insns are
>>>> different. After uses bool, it uses push/pop instead of branch, for me,
>>>> it should be a little better for catching.
>>>
>>> The code generated for bool version looks much worse. Look at the fast
>>> path. Gcc tries to reuse the retq from the fast path in the bool case
>>> and so it has to push rbp and rbx on the stack.
>>>
>>> That being said, gcc doesn't seem to generate a better code for bool so
>>> I do not think this is really worth it.
>>>
>>
>> The code below also merge 3 statements into 1 return statement, although
>> for me, it is a little more readable, it will generate a little bad code.
>> That is the reason why the output looks a little bad.
>>
>> In our case, for gcc 6.0, using bool instead of int for bool function
>> will get the same output under x86_64.
> 
> If the output is same then there is no reason to change it.
>

For the new version gcc, the output is same. But bool is a little more
readable than int for the pure bool function.

But for the current widely used gcc version (I guess, gcc-4.8 is still
widely used), bool will get a little better output than int for the pure
bool function.
 
>> In our case, for gcc 4.8, using bool instead of int for bool function
>> will get a little better output under x86_64.
> 
> I had a different impression and the fast path code had more
> instructions. But anyway, is there really a strong reason to change
> those return values in the first place? Isn't that just a pointless code
> churn?
> 

Excuse me, maybe, I do not quite understand your meanings, but I shall
try to explain as far as I can understand (welcome additional detail
explanation, e.g. "return values" means c code or assembly output code).

In the previous reply, I did not mention 3 things directly and clearly
(about my 2 mistakes, and the comparation between gcc 6.0 and 4.8):

 - Mistake 1: "Use one return statement instead of several statements"
   is not good, the modification may be a little more readable, but it
   may get a little bad output code by compiler.

 - Mistake 2: I only notice there is more branches, but did not notice
   the real execution path (I guess, your "fast path" is about it).

 - The optimization of upstream gcc 6.0 is better than redhat gcc 4.8:
   in this case, gcc 6.0 will:

     generate the same better code for both bool and int for the pure
     bool function.

     optimize the first checking branch (no prologue) -- gcc 4.8 need
     mark 'likely' for it.

     skip the 'likely' optimization when "use 1 return statement instead
     of several statements" -- generation a little bad code too.

All together, for me:

 - Only use bool instead of int for pure bool functions' return value
   will get a little better code

 - I shall send patch v2, only change bool to int for all Page_XXX, and
   keep all the other things no touch.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
