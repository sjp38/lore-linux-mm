Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8D74C6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 04:22:04 -0400 (EDT)
Date: Fri, 12 Apr 2013 17:11:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: Check more strictly to avoid ULLONG overflow by
 PAGE_ALIGN
Message-Id: <20130412171108.d3ef3e2d66e9c1bfcf69467c@mxp.nes.nec.co.jp>
In-Reply-To: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
References: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

Hi,

On Fri, 12 Apr 2013 14:39:23 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> While writing memory.limit_in_bytes, a confusing result may happen:
> 
> $ mkdir /memcg/test
> $ cat /memcg/test/memory.limit_in_bytes
> 9223372036854775807
> $ cat /memcg/test/memory.memsw.limit_in_bytes
> 9223372036854775807
> $ echo 18446744073709551614 > /memcg/test/memory.limit_in_bytes
> $ cat /memcg/test/memory.limit_in_bytes
> 0
> 
> Strangely, the write successed and reset the limit to 0.
> The patch corrects RESOURCE_MAX and fixes this kind of overflow.
> 
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Reported-by: Li Wenpeng < xingke.lwp@taobao.com>
> Cc: Jie Liu <jeff.liu@oracle.com>
> ---
>  include/linux/res_counter.h |    2 +-
>  kernel/res_counter.c        |    8 +++++++-
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index c230994..c2f01fc 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -54,7 +54,7 @@ struct res_counter {
>  	struct res_counter *parent;
>  };
>  
> -#define RESOURCE_MAX (unsigned long long)LLONG_MAX
> +#define RESOURCE_MAX (unsigned long long)ULLONG_MAX
>  

I don't think it's a good idea to change a user-visible value.

>  /**
>   * Helpers to interact with userspace
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index ff55247..6c35310 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -195,6 +195,12 @@ int res_counter_memparse_write_strategy(const char *buf,
>  	if (*end != '\0')
>  		return -EINVAL;
>  
> -	*res = PAGE_ALIGN(*res);
> +	/* Since PAGE_ALIGN is aligning up(the next page boundary),
> +	 * check the left space to avoid overflow to 0. */
> +	if (RESOURCE_MAX - *res < PAGE_SIZE - 1)
> +		*res = RESOURCE_MAX;
> +	else
> +		*res = PAGE_ALIGN(*res);
> +

Current interface seems strange because we can set a bigger value than
the value which means "unlimited".
So, how about some thing like:

	if (*res > RESOURCE_MAX)
		return -EINVAL;
	if (*res > PAGE_ALIGN(RESOURCE_MAX) - PAGE_SIZE)
		*res = RESOURCE_MAX;
	else
		*res = PAGE_ALIGN(*res);

?

>  	return 0;
>  }
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
