Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C4FFC6B00DA
	for <linux-mm@kvack.org>; Tue,  7 May 2013 10:12:13 -0400 (EDT)
Date: Tue, 7 May 2013 16:12:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: replace memparse to avoid input overflow
Message-ID: <20130507141208.GD9497@dhcp22.suse.cz>
References: <1367768681-4451-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367768681-4451-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

On Sun 05-05-13 23:44:41, Sha Zhengju wrote:
> memparse() doesn't check if overflow has happens, and it even has no
> args to inform user that the unexpected situation has occurred. Besides,
> some of its callers make a little artful use of the current implementation
> and it also seems to involve too much if changing memparse() interface.
> 
> This patch rewrites memcg's internal res_counter_memparse_write_strategy().
> It doesn't use memparse() any more and replaces simple_strtoull() with
> kstrtoull() to avoid input overflow.

I do not like this to be honest. I do not think we should be really
worried about overflows here. Or where this turned out to be a real
issue? The new implementation is inherently slower without a good
reason.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  kernel/res_counter.c |   41 ++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 36 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index be8ddda..a990e8e0 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -182,19 +182,50 @@ int res_counter_memparse_write_strategy(const char *buf,
>  {
>  	char *end;
>  	unsigned long long res;
> +	int ret, len, suffix = 0;
> +	char *ptr;
>  
>  	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
>  	if (*buf == '-') {
> -		res = simple_strtoull(buf + 1, &end, 10);
> -		if (res != 1 || *end != '\0')
> +		ret = kstrtoull(buf + 1, 10, &res);
> +		if (res != 1 || ret)
>  			return -EINVAL;
>  		*resp = RES_COUNTER_MAX;
>  		return 0;
>  	}
>  
> -	res = memparse(buf, &end);
> -	if (*end != '\0')
> -		return -EINVAL;
> +	len = strlen(buf);
> +	end = buf + len - 1;
> +	switch (*end) {
> +	case 'G':
> +	case 'g':
> +		suffix ++;
> +	case 'M':
> +	case 'm':
> +		suffix ++;
> +	case 'K':
> +	case 'k':
> +		suffix ++;
> +		len --;
> +	default:
> +		break;
> +	}
> +
> +	ptr = kmalloc(len + 1, GFP_KERNEL);
> +	if (!ptr) return -ENOMEM;
> +
> +	strlcpy(ptr, buf, len + 1);
> +	ret = kstrtoull(ptr, 0, &res);
> +	kfree(ptr);
> +	if (ret) return -EINVAL;
> +
> +	while (suffix) {
> +		/* check for overflow while multiplying suffix number */
> +		if (unlikely(res & (~0ull << 54)))
> +			return -EINVAL;
> +		res <<= 10;
> +		suffix --;
> +	}
>  
>  	if (PAGE_ALIGN(res) >= res)
>  		res = PAGE_ALIGN(res);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
