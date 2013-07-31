Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 32B456B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:20:31 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:20:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: reduce function dereference
Message-ID: <20130731082029.GH30514@dhcp22.suse.cz>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
 <1375255885-10648-5-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375255885-10648-5-git-send-email-h.huangqiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, handai.szj@taobao.com, lizefan@huawei.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, jeff.liu@oracle.com

On Wed 31-07-13 15:31:25, Qiang Huang wrote:
> This function dereferences res far too often, so optimize it.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  kernel/res_counter.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 085d3ae..4aa8a30 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -178,27 +178,30 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
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
> -	if (PAGE_ALIGN(*res) >= *res)
> -		*res = PAGE_ALIGN(*res);
> +	if (PAGE_ALIGN(res) >= res)
> +		res = PAGE_ALIGN(res);
>  	else
> -		*res = RES_COUNTER_MAX;
> +		res = RES_COUNTER_MAX;
> +
> +	*resp = res;
>  
>  	return 0;
>  }
> -- 
> 1.8.3
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
