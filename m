Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD2C44088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:34:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so2046451oih.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 22:34:29 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTP id u68si4997726oiu.57.2017.08.24.22.34.26
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 22:34:28 -0700 (PDT)
Message-ID: <599FB3C4.6000009@huawei.com>
Date: Fri, 25 Aug 2017 13:21:08 +0800
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
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhen Lei <thunder.leizhen@huawei.com>

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
>
> Anything using a shift value < 0 or > 31 will get crap as a
> result. Rightfully so because it's just undefined.
>
> Yes I know that the insanity of user space is unlimited, but anything
> attempting this is so broken that we cannot break it further by making that
> shift arg unsigned and actually limit it to 0-31
>
> Thanks,
>
> 	tglx
>
>
>
> .
>
 >From df9e2a5a3f1f401943aeb2718d5876b854dea3a3 Mon Sep 17 00:00:00 2001
From: zhong jiang <zhongjiang@huawei.com>
Date: Fri, 25 Aug 2017 12:05:56 +0800
Subject: [PATCH v2] futex: avoid undefined behaviour when shift exponent is
 negative

when futex syscall is called from userspace, we find the following
warning by ubsan detection.

[   63.237803] UBSAN: Undefined behaviour in /root/rpmbuild/BUILDROOT/kernel-3.10.0-327.49.58.52.x86_64/usr/src/linux-3.10.0-327.49.58.52.x86_64/arch/x86/include/asm/futex.h:53:13
[   63.237803] shift exponent -16 is negative
[   63.237803] CPU: 0 PID: 67 Comm: driver Not tainted 3.10.0 #1
[   63.237803] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.1-0-g4adadbd-20150316_085822-nilsson.home.kraxel.org 04/01/2014
[   63.237803]  fffffffffffffff0 000000009ad70fde ffff88000002fa08 ffffffff81ef0d6f
[   63.237803]  ffff88000002fa20 ffffffff81ef0e2c ffffffff828f2540 ffff88000002fb90
[   63.237803]  ffffffff81ef1ad0 ffffffff8141cc88 1ffff10000005f48 0000000041b58ab3
[   63.237803] Call Trace:
[   63.237803]  [<ffffffff81ef0d6f>] dump_stack+0x1e/0x20
[   63.237803]  [<ffffffff81ef0e2c>] ubsan_epilogue+0x12/0x55
[   63.237803]  [<ffffffff81ef1ad0>] __ubsan_handle_shift_out_of_bounds+0x237/0x29c
[   63.237803]  [<ffffffff8141cc88>] ? kasan_alloc_pages+0x38/0x40
[   63.237803]  [<ffffffff81ef1899>] ? __ubsan_handle_load_invalid_value+0x162/0x162
[   63.237803]  [<ffffffff812092c1>] ? get_futex_key+0x361/0x6c0
[   63.237803]  [<ffffffff81208f60>] ? get_futex_key_refs+0xb0/0xb0
[   63.237803]  [<ffffffff8120b938>] futex_wake_op+0xb48/0xc70
[   63.237803]  [<ffffffff8120b938>] ? futex_wake_op+0xb48/0xc70
[   63.237803]  [<ffffffff8120adf0>] ? futex_wake+0x380/0x380
[   63.237803]  [<ffffffff8121006c>] do_futex+0x2cc/0xb60
[   63.237803]  [<ffffffff8120fda0>] ? exit_robust_list+0x350/0x350
[   63.237803]  [<ffffffff814fa140>] ? __fsnotify_inode_delete+0x20/0x20
[   63.237803]  [<ffffffff818cabc0>] ? n_tty_flush_buffer+0x80/0x80
[   63.237803]  [<ffffffff814faed3>] ? __fsnotify_parent+0x53/0x210
[   63.237803]  [<ffffffff81210a47>] SyS_futex+0x147/0x300
[   63.237803]  [<ffffffff81210900>] ? do_futex+0xb60/0xb60
[   63.237803]  [<ffffffff81f0a134>] ? do_page_fault+0x44/0xa0
[   63.237803]  [<ffffffff81f16809>] system_call_fastpath+0x16/0x1b

using a shift value < 0 or > 31 will get crap as a result. because
it's just undefined. The issue still disturb me, so I try to fix
it again by excluding the especially condition.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/x86/include/asm/futex.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
index b4c1f54..c414d76 100644
--- a/arch/x86/include/asm/futex.h
+++ b/arch/x86/include/asm/futex.h
@@ -49,9 +49,11 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
        int cmparg = (encoded_op << 20) >> 20;
        int oldval = 0, ret, tem;

-       if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
+       if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
+               if (oparg < 0 || oparg > 31)
+                       return -EINVAL;
                oparg = 1 << oparg;
-
+       }
        if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
                return -EFAULT;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
