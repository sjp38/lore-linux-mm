Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFE96B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 21:57:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b13so75957976pgn.4
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 18:57:16 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id q67si2678012pfl.134.2017.06.28.18.57.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 18:57:15 -0700 (PDT)
Message-ID: <59545DD6.3030508@huawei.com>
Date: Thu, 29 Jun 2017 09:54:30 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent
 is negative
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <alpine.DEB.2.20.1706282353190.1890@nanos>
In-Reply-To: <alpine.DEB.2.20.1706282353190.1890@nanos>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, Thomas

Thank you for clarification.
On 2017/6/29 6:13, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, zhong jiang wrote:
>> On 2017/6/22 0:40, Ingo Molnar wrote:
>>> * zhong jiang <zhongjiang@huawei.com> wrote:
>>>
>>>> when shift expoment is negative, left shift alway zero. therefore, we
>>>> modify the logic to avoid the warining.
>>>>
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>> ---
>>>>  arch/x86/include/asm/futex.h | 8 ++++++--
>>>>  1 file changed, 6 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
>>>> index b4c1f54..2425fca 100644
>>>> --- a/arch/x86/include/asm/futex.h
>>>> +++ b/arch/x86/include/asm/futex.h
>>>> @@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
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
>>   I think it is not feasible.  a negative shift exponent is likely
>>   existence and reasonable.
> What is reasonable about a negative shift value?
>
>> as the above case, oparg is a negative is common.
> That's simply wrong. If oparg is negative and the SHIFT bit is set then the
> result is undefined today and there is no way that this can be used at
> all.
>
> On x86:
>
>    1 << -1	= 0x80000000
>    1 << -2048	= 0x00000001
>    1 << -2047	= 0x00000002
  but I test the cases in x86_64 all is zero.   I wonder whether it is related to gcc or not

  zj.c:15:8: warning: left shift count is negative [-Wshift-count-negative]
  j = 1 << -2048;
        ^
[root@localhost zhongjiang]# ./zj
j = 0

 Thanks
 zhongjiang
> Anything using a shift value < 0 or > 31 will get crap as a
> result. Rightfully so because it's just undefined.
>
> Yes I know that the insanity of user space is unlimited, but anything
> attempting this is so broken that we cannot break it further by making that
> shift arg unsigned and actually limit it to 0-31
> Thanks,
>
> 	tglx
>
>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
