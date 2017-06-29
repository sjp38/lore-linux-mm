Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7616B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 22:14:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 86so72708413pfq.11
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 19:14:55 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id v10si2881839plg.332.2017.06.28.19.14.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 19:14:54 -0700 (PDT)
Message-ID: <595461F4.3020300@huawei.com>
Date: Thu, 29 Jun 2017 10:12:04 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent
 is negative
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <568AC6DF-7E6D-4F10-BD41-D43195629C13@zytor.com>
In-Reply-To: <568AC6DF-7E6D-4F10-BD41-D43195629C13@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/6/29 5:43, hpa@zytor.com wrote:
> On June 27, 2017 9:35:10 PM PDT, zhong jiang <zhongjiang@huawei.com> wrote:
>> Hi,  Ingo
>>
>> Thank you for the comment.
>> On 2017/6/22 0:40, Ingo Molnar wrote:
>>> * zhong jiang <zhongjiang@huawei.com> wrote:
>>>
>>>> when shift expoment is negative, left shift alway zero. therefore,
>> we
>>>> modify the logic to avoid the warining.
>>>>
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>> ---
>>>>  arch/x86/include/asm/futex.h | 8 ++++++--
>>>>  1 file changed, 6 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/arch/x86/include/asm/futex.h
>> b/arch/x86/include/asm/futex.h
>>>> index b4c1f54..2425fca 100644
>>>> --- a/arch/x86/include/asm/futex.h
>>>> +++ b/arch/x86/include/asm/futex.h
>>>> @@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int
>> encoded_op, u32 __user *uaddr)
>>>>  	int cmparg = (encoded_op << 20) >> 20;
>>>>  	int oldval = 0, ret, tem;
>>>>  
>>>> -	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
>>>> -		oparg = 1 << oparg;
>>>> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
>>>> +		if (oparg >= 0)
>>>> +			oparg = 1 << oparg;
>>>> +		else
>>>> +			oparg = 0;
>>>> +	}
>>> Could we avoid all these complications by using an unsigned type?
>> I think it is not feasible.  a negative shift exponent is likely
>> existence and reasonable.
>>  as the above case,  oparg is a negative is common. 
>>
>> I think it can be avoided by following change. 
>>
>> diff --git a/arch/x86/include/asm/futex.h
>> b/arch/x86/include/asm/futex.h
>> index b4c1f54..3205e86 100644
>> --- a/arch/x86/include/asm/futex.h
>> +++ b/arch/x86/include/asm/futex.h
>> @@ -50,7 +50,7 @@ static inline int futex_atomic_op_inuser(int
>> encoded_op, u32 __user *uaddr)
>>        int oldval = 0, ret, tem;
>>
>>        if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
>> -               oparg = 1 << oparg;
>> +               oparg = safe_shift(1, oparg);
>>
>>        if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
>>                return -EFAULT;
>> diff --git a/drivers/video/fbdev/core/fbmem.c
>> b/drivers/video/fbdev/core/fbmem.c
>> index 069fe79..b4edda3 100644
>> --- a/drivers/video/fbdev/core/fbmem.c
>> +++ b/drivers/video/fbdev/core/fbmem.c
>> @@ -190,11 +190,6 @@ char* fb_get_buffer_offset(struct fb_info *info,
>> struct fb_pixmap *buf, u32 size
>>
>> #ifdef CONFIG_LOGO
>>
>> -static inline unsigned safe_shift(unsigned d, int n)
>> -{
>> -       return n < 0 ? d >> -n : d << n;
>> -}
>> -
>> static void fb_set_logocmap(struct fb_info *info,
>>                                   const struct linux_logo *logo)
>> {
>> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
>> index d043ada..f3b8856 100644
>> --- a/include/linux/kernel.h
>> +++ b/include/linux/kernel.h
>> @@ -841,6 +841,10 @@ static inline void ftrace_dump(enum
>> ftrace_dump_mode oops_dump_mode) { }
>>  */
>> #define clamp_val(val, lo, hi) clamp_t(typeof(val), val, lo, hi)
>>
>> +static inline unsigned safe_shift(unsigned d, int n)
>> +{
>> +       return n < 0 ? d >> -n : d << n;
>> +}
>>
>> Thansk
>> zhongjiang
>>
>>> Thanks,
>>>
>>> 	Ingo
>>>
>>> .
>>>
> What makes it reasonable?  It is totally ill-defined and doesn't do anything useful now?
 Thanks you for comments.
 
 Maybe I mismake the meaning. I test the negative cases in x86 , all case is zero. so I come to a conclusion.
 
zj.c:15:8: warning: left shift count is negative [-Wshift-count-negative]
  j = 1 << -2048;
        ^
[root@localhost zhongjiang]# ./zj
j = 0
j.c:15:8: warning: left shift count is negative [-Wshift-count-negative]
  j = 1 << -2047;
        ^
[root@localhost zhongjiang]# ./zj
j = 0

I insmod a module into kernel to test the testcasts, all of the result is zero.

I wonder whether I miss some point or not. Do you point out to me? please

Thanks
zhongjiang
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
