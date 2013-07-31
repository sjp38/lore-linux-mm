Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id DA1C16B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:14:43 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:14:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: avoid overflow caused by PAGE_ALIGN
Message-ID: <20130731081441.GG30514@dhcp22.suse.cz>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
 <1375255885-10648-4-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375255885-10648-4-git-send-email-h.huangqiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, handai.szj@taobao.com, lizefan@huawei.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, jeff.liu@oracle.com

On Wed 31-07-13 15:31:24, Qiang Huang wrote:
> Since PAGE_ALIGN is aligning up(the next page boundary), so after PAGE_ALIGN,
> the value might be overflow, such as write the MAX value to *.limit_in_bytes.
> 
> $ cat /cgroup/memory/memory.limit_in_bytes
> 18446744073709551615
> 
> # echo 18446744073709551615 > /cgroup/memory/memory.limit_in_bytes
> bash: echo: write error: Invalid argument
> 
> Some user programs might depend on such behaviours(like libcg, we read the
> value in snapshot, then use the value to reset cgroup later), and that
> will cause confusion. So we need to fix it.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  kernel/res_counter.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 3f0417f..085d3ae 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -195,6 +195,10 @@ int res_counter_memparse_write_strategy(const char *buf,
>  	if (*end != '\0')
>  		return -EINVAL;
>  
> -	*res = PAGE_ALIGN(*res);
> +	if (PAGE_ALIGN(*res) >= *res)
> +		*res = PAGE_ALIGN(*res);
> +	else
> +		*res = RES_COUNTER_MAX;
> +
>  	return 0;
>  }
> -- 
> 1.8.3
> 
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
