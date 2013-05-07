Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 207E66B00DC
	for <linux-mm@kvack.org>; Tue,  7 May 2013 10:04:08 -0400 (EDT)
Date: Tue, 7 May 2013 16:04:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] memcg: check more strictly to avoid PAGE_ALIGN
 wrapped to 0
Message-ID: <20130507140402.GC9497@dhcp22.suse.cz>
References: <1367768590-4403-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367768590-4403-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

On Sun 05-05-13 23:43:10, Sha Zhengju wrote:
> Since PAGE_ALIGN is aligning up(the next page boundary), this can
> prevent input values wrapped to 0 and cause strange result to user.

I guess you wanted to say that it can cause an overflow, right?
"
Since PAGE_ALIGN is aligning up (to the next page boundary), this can
cause an overflow to 0 if >= ULLONG_MAX-4094 value is given in the
buffer.
"
> 
> This patch also rename the second arg of
> res_counter_memparse_write_strategy() to 'resp' and add a local
> variable 'res' to save the too often dereferences. Thanks Andrew
> for pointing it out!

Again, it would be nicer to have this cleanup in a separate patch.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Reported-by: Li Wenpeng <xingke.lwp@taobao.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

We have this bug since ever and nobody has noticed so nobody seems to
use 

> ---
>  kernel/res_counter.c |   18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 3f0417f..be8ddda 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -178,23 +178,29 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
>  #endif
>  
>  int res_counter_memparse_write_strategy(const char *buf,
> -					unsigned long long *res)
> +					unsigned long long *resp)
>  {
>  	char *end;
> +	unsigned long long res;
>  
>  	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
>  	if (*buf == '-') {
> -		*res = simple_strtoull(buf + 1, &end, 10);
> -		if (*res != 1 || *end != '\0')
> +		res = simple_strtoull(buf + 1, &end, 10);
> +		if (res != 1 || *end != '\0')
>  			return -EINVAL;
> -		*res = RES_COUNTER_MAX;
> +		*resp = RES_COUNTER_MAX;
>  		return 0;
>  	}
>  
> -	*res = memparse(buf, &end);
> +	res = memparse(buf, &end);
>  	if (*end != '\0')
>  		return -EINVAL;
>  
> -	*res = PAGE_ALIGN(*res);
> +	if (PAGE_ALIGN(res) >= res)
> +		res = PAGE_ALIGN(res);
> +	else
> +		res = RES_COUNTER_MAX; /* avoid PAGE_ALIGN wrapping to zero */
> +
> +	*resp = res;
>  	return 0;
>  }
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
