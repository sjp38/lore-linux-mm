Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6F226B041E
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:40:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l34so32275722wrc.12
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:40:40 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id r195si17175253wmd.24.2017.06.21.09.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 09:40:39 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id z45so27910286wrb.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:40:39 -0700 (PDT)
Date: Wed, 21 Jun 2017 18:40:36 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent is
 negative
Message-ID: <20170621164036.4findvvz7jj4cvqo@gmail.com>
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* zhong jiang <zhongjiang@huawei.com> wrote:

> when shift expoment is negative, left shift alway zero. therefore, we
> modify the logic to avoid the warining.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  arch/x86/include/asm/futex.h | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
> index b4c1f54..2425fca 100644
> --- a/arch/x86/include/asm/futex.h
> +++ b/arch/x86/include/asm/futex.h
> @@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
>  	int cmparg = (encoded_op << 20) >> 20;
>  	int oldval = 0, ret, tem;
>  
> -	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
> -		oparg = 1 << oparg;
> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
> +		if (oparg >= 0)
> +			oparg = 1 << oparg;
> +		else
> +			oparg = 0;
> +	}

Could we avoid all these complications by using an unsigned type?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
