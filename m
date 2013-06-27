Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 9D8EB6B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 05:12:39 -0400 (EDT)
Date: Thu, 27 Jun 2013 11:12:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RESEND PATCH] zcache: initialize module properly when
 zcache=FOO is given
Message-ID: <20130627091235.GA17647@dhcp22.suse.cz>
References: <1372296740-25259-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1372296740-25259-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: Bob Liu <lliubbo@gmail.com>, konrad.wilk@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, crrodriguez@opensuse.org, Bob Liu <bob.liu@oracle.com>

Please make sure that this will get into 3.10 or it would have to get to
it via stable tree.

On Thu 27-06-13 09:32:20, Bob Liu wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> 835f2f51 (staging: zcache: enable zcache to be built/loaded as a module)
> introduced in 3.10-rc1 has introduced a bug for zcache=FOO module
> parameter processing.
> 
> zcache_comp_init return code doesn't agree with crypto_has_comp which
> uses 1 for the success unlike zcache_comp_init which uses 0. This
> causes module loading failure even if the given algorithm is supported:
> [    0.815330] zcache: compressor initialization failed
> 
> Reported-by: Cristian Rodriguez <crrodriguez@opensuse.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index dcceed2..0fe530b 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1811,10 +1811,12 @@ static int zcache_comp_init(void)
>  #else
>  	if (*zcache_comp_name != '\0') {
>  		ret = crypto_has_comp(zcache_comp_name, 0, 0);
> -		if (!ret)
> +		if (!ret) {
>  			pr_info("zcache: %s not supported\n",
>  					zcache_comp_name);
> -		goto out;
> +			goto out;
> +		}
> +		goto out_alloc;
>  	}
>  	if (!ret)
>  		strcpy(zcache_comp_name, "lzo");
> @@ -1827,6 +1829,7 @@ static int zcache_comp_init(void)
>  	pr_info("zcache: using %s compressor\n", zcache_comp_name);
>  
>  	/* alloc percpu transforms */
> +out_alloc:
>  	ret = 0;
>  	zcache_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
>  	if (!zcache_comp_pcpu_tfms)
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
