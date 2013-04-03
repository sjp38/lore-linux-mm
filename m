Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 452796B0074
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 21:12:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5B9763EE0BC
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:12:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42A0545DE4E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:12:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A08545DE4D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:12:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 19AB81DB8038
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:12:01 +0900 (JST)
Received: from g01jpexchyt31.g01.fujitsu.local (g01jpexchyt31.g01.fujitsu.local [10.128.193.114])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B93CA1DB802C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:12:00 +0900 (JST)
Message-ID: <515B81B8.9020307@jp.fujitsu.com>
Date: Wed, 3 Apr 2013 10:11:20 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] resource: Add __adjust_resource() for internal use
References: <1364919450-8741-1-git-send-email-toshi.kani@hp.com> <1364919450-8741-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1364919450-8741-2-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, tmac@hp.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

Hi Toshi,

2013/04/03 1:17, Toshi Kani wrote:
> Added __adjust_resource(), which is called by adjust_resource()
> internally after the resource_lock is held.  There is no interface
> change to adjust_resource().  This change allows other functions
> to call __adjust_resource() internally while the resource_lock is
> held.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

The patch looks good.
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> ---
>   kernel/resource.c |   35 ++++++++++++++++++++++-------------
>   1 file changed, 22 insertions(+), 13 deletions(-)
> 
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 73f35d4..ae246f9 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -706,24 +706,13 @@ void insert_resource_expand_to_fit(struct resource *root, struct resource *new)
>   	write_unlock(&resource_lock);
>   }
>   
> -/**
> - * adjust_resource - modify a resource's start and size
> - * @res: resource to modify
> - * @start: new start value
> - * @size: new size
> - *
> - * Given an existing resource, change its start and size to match the
> - * arguments.  Returns 0 on success, -EBUSY if it can't fit.
> - * Existing children of the resource are assumed to be immutable.
> - */
> -int adjust_resource(struct resource *res, resource_size_t start, resource_size_t size)
> +static int __adjust_resource(struct resource *res, resource_size_t start,
> +				resource_size_t size)
>   {
>   	struct resource *tmp, *parent = res->parent;
>   	resource_size_t end = start + size - 1;
>   	int result = -EBUSY;
>   
> -	write_lock(&resource_lock);
> -
>   	if (!parent)
>   		goto skip;
>   
> @@ -751,6 +740,26 @@ skip:
>   	result = 0;
>   
>    out:
> +	return result;
> +}
> +
> +/**
> + * adjust_resource - modify a resource's start and size
> + * @res: resource to modify
> + * @start: new start value
> + * @size: new size
> + *
> + * Given an existing resource, change its start and size to match the
> + * arguments.  Returns 0 on success, -EBUSY if it can't fit.
> + * Existing children of the resource are assumed to be immutable.
> + */
> +int adjust_resource(struct resource *res, resource_size_t start,
> +			resource_size_t size)
> +{
> +	int result;
> +
> +	write_lock(&resource_lock);
> +	result = __adjust_resource(res, start, size);
>   	write_unlock(&resource_lock);
>   	return result;
>   }
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
