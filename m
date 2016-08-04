Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAA796B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 00:09:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so13984323pab.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 21:09:51 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id c83si12329634pfd.268.2016.08.03.21.09.49
        for <linux-mm@kvack.org>;
        Wed, 03 Aug 2016 21:09:51 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001e01d1ee04$c7f77be0$57e673a0$@alibaba-inc.com>
In-Reply-To: <001e01d1ee04$c7f77be0$57e673a0$@alibaba-inc.com>
Subject: Re: [PATCH 04/10] fault injection: prevent recursive fault injection
Date: Thu, 04 Aug 2016 12:09:31 +0800
Message-ID: <001f01d1ee06$00b484e0$021d8ea0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org

> 
> If something we call in the fail_dump() code path tries to acquire a
> resource that might fail (due to fault injection), then we should not
> try to recurse back into the fault injection code.
> 
> I've seen this happen with the console semaphore in the upcoming
> semaphore trylock fault injection code.
> 
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>  lib/fault-inject.c | 34 ++++++++++++++++++++++++++++------
>  1 file changed, 28 insertions(+), 6 deletions(-)
> 
> diff --git a/lib/fault-inject.c b/lib/fault-inject.c
> index 6a823a5..adba7c9 100644
> --- a/lib/fault-inject.c
> +++ b/lib/fault-inject.c
> @@ -100,6 +100,33 @@ static inline bool fail_stacktrace(struct fault_attr *attr)
> 
>  #endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
> 
> +static DEFINE_PER_CPU(int, fault_active);
> +
> +static bool __fail(struct fault_attr *attr)
> +{
> +	bool ret = false;
> +
> +	/*
> +	 * Prevent recursive fault injection (this could happen if for
> +	 * example printing the fault would itself run some code that
> +	 * could fail)
> +	 */
> +	preempt_disable();
> +	if (unlikely(__this_cpu_inc_return(fault_active) != 1))
> +		goto out;
> +
> +	ret = true;
> +	fail_dump(attr);
> +
> +	if (atomic_read(&attr->times) != -1)
> +		atomic_dec_not_zero(&attr->times);
> +
> +out:
> +	__this_cpu_dec(fault_active);
> +	preempt_enable();

Well schedule entry point is add in paths like
	rt_mutex_trylock
	__alloc_pages_nodemask
and please add one or two sentences in log
message for it.

thanks
Hillf
> +	return ret;
> +}
> +
>  /*
>   * This code is stolen from failmalloc-1.0
>   * http://www.nongnu.org/failmalloc/
> @@ -134,12 +161,7 @@ bool should_fail(struct fault_attr *attr, ssize_t size)
>  	if (!fail_stacktrace(attr))
>  		return false;
> 
> -	fail_dump(attr);
> -
> -	if (atomic_read(&attr->times) != -1)
> -		atomic_dec_not_zero(&attr->times);
> -
> -	return true;
> +	return __fail(attr);
>  }
>  EXPORT_SYMBOL_GPL(should_fail);
> 
> --
> 1.9.1
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
