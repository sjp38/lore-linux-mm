Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 132796B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 17:50:24 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id u7so9029251pfb.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 14:50:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x73si22695839pfa.193.2015.12.18.14.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 14:50:23 -0800 (PST)
Date: Fri, 18 Dec 2015 14:50:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory-hotplug: don't BUG() in
 register_memory_resource()
Message-Id: <20151218145022.eae1e368c82f090900582fcc@linux-foundation.org>
In-Reply-To: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
References: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, David Rientjes <rientjes@google.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

On Fri, 18 Dec 2015 15:50:24 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> Out of memory condition is not a bug and while we can't add new memory in
> such case crashing the system seems wrong. Propagating the return value
> from register_memory_resource() requires interface change.
> 
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
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

Was there a reason for overwriting the request_resource() return value?
Ordinarily it should be propagated back to callers.

Please review.

--- a/mm/memory_hotplug.c~memory-hotplug-dont-bug-in-register_memory_resource-fix
+++ a/mm/memory_hotplug.c
@@ -131,7 +131,9 @@ static int register_memory_resource(u64
 				    struct resource **resource)
 {
 	struct resource *res;
+	int ret = 0;
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
+
 	if (!res)
 		return -ENOMEM;
 
@@ -139,13 +141,14 @@ static int register_memory_resource(u64
 	res->start = start;
 	res->end = start + size - 1;
 	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-	if (request_resource(&iomem_resource, res) < 0) {
+	ret = request_resource(&iomem_resource, res);
+	if (ret < 0) {
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
-		return -EEXIST;
+	} else {
+		*resource = res;
 	}
-	*resource = res;
-	return 0;
+	return ret;
 }
 
 static void release_memory_resource(struct resource *res)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
