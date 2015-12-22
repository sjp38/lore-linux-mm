Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ACDBD82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:56:57 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so6267683pfb.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 13:56:57 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id ti16si6944531pac.192.2015.12.22.13.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 13:56:56 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id o64so112168204pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 13:56:56 -0800 (PST)
Date: Tue, 22 Dec 2015 13:56:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory-hotplug: don't BUG() in
 register_memory_resource()
In-Reply-To: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
Message-ID: <alpine.DEB.2.10.1512221353001.5172@chino.kir.corp.google.com>
References: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

On Fri, 18 Dec 2015, Vitaly Kuznetsov wrote:

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 67d488a..9392f01 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -127,11 +127,13 @@ void mem_hotplug_done(void)
>  }
>  
>  /* add this memory to iomem resource */
> -static struct resource *register_memory_resource(u64 start, u64 size)
> +static int register_memory_resource(u64 start, u64 size,
> +				    struct resource **resource)
>  {
>  	struct resource *res;
>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> -	BUG_ON(!res);
> +	if (!res)
> +		return -ENOMEM;
>  
>  	res->name = "System RAM";
>  	res->start = start;
> @@ -140,9 +142,10 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>  	if (request_resource(&iomem_resource, res) < 0) {
>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>  		kfree(res);
> -		res = NULL;
> +		return -EEXIST;
>  	}
> -	return res;
> +	*resource = res;
> +	return 0;
>  }
>  
>  static void release_memory_resource(struct resource *res)
> @@ -1311,9 +1314,9 @@ int __ref add_memory(int nid, u64 start, u64 size)
>  	struct resource *res;
>  	int ret;
>  
> -	res = register_memory_resource(start, size);
> -	if (!res)
> -		return -EEXIST;
> +	ret = register_memory_resource(start, size, &res);
> +	if (ret)
> +		return ret;
>  
>  	ret = add_memory_resource(nid, res);
>  	if (ret < 0)

Wouldn't it be simpler and cleaner to keep the return type of 
register_memory_resource() the same and return ERR_PTR(-ENOMEM) or 
ERR_PTR(-EEXIST) on error?  add_memory() can check IS_ERR(res) and return 
PTR_ERR(res).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
