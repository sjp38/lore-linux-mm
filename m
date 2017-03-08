Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2716B03A4
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:09:54 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id o135so63117398qke.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:09:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s56si2261919qte.291.2017.03.07.23.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:09:53 -0800 (PST)
Date: Wed, 8 Mar 2017 15:09:34 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [RFC PATCH v4 25/28] x86: Access the setup data through sysfs
 decrypted
Message-ID: <20170308070934.GC11045@dhcp-128-65.nay.redhat.com>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154738.19244.37908.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216154738.19244.37908.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 02/16/17 at 09:47am, Tom Lendacky wrote:
> Use memremap() to map the setup data.  This will make the appropriate
> decision as to whether a RAM remapping can be done or if a fallback to
> ioremap_cache() is needed (similar to the setup data debugfs support).
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/ksysfs.c |   27 ++++++++++++++-------------
>  1 file changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/x86/kernel/ksysfs.c b/arch/x86/kernel/ksysfs.c
> index 4afc67f..d653b3e 100644
> --- a/arch/x86/kernel/ksysfs.c
> +++ b/arch/x86/kernel/ksysfs.c
> @@ -16,6 +16,7 @@
>  #include <linux/stat.h>
>  #include <linux/slab.h>
>  #include <linux/mm.h>
> +#include <linux/io.h>
>  
>  #include <asm/io.h>
>  #include <asm/setup.h>
> @@ -79,12 +80,12 @@ static int get_setup_data_paddr(int nr, u64 *paddr)
>  			*paddr = pa_data;
>  			return 0;
>  		}
> -		data = ioremap_cache(pa_data, sizeof(*data));
> +		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
>  		if (!data)
>  			return -ENOMEM;
>  
>  		pa_data = data->next;
> -		iounmap(data);
> +		memunmap(data);
>  		i++;
>  	}
>  	return -EINVAL;
> @@ -97,17 +98,17 @@ static int __init get_setup_data_size(int nr, size_t *size)
>  	u64 pa_data = boot_params.hdr.setup_data;
>  
>  	while (pa_data) {
> -		data = ioremap_cache(pa_data, sizeof(*data));
> +		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
>  		if (!data)
>  			return -ENOMEM;
>  		if (nr == i) {
>  			*size = data->len;
> -			iounmap(data);
> +			memunmap(data);
>  			return 0;
>  		}
>  
>  		pa_data = data->next;
> -		iounmap(data);
> +		memunmap(data);
>  		i++;
>  	}
>  	return -EINVAL;
> @@ -127,12 +128,12 @@ static ssize_t type_show(struct kobject *kobj,
>  	ret = get_setup_data_paddr(nr, &paddr);
>  	if (ret)
>  		return ret;
> -	data = ioremap_cache(paddr, sizeof(*data));
> +	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
>  	if (!data)
>  		return -ENOMEM;
>  
>  	ret = sprintf(buf, "0x%x\n", data->type);
> -	iounmap(data);
> +	memunmap(data);
>  	return ret;
>  }
>  
> @@ -154,7 +155,7 @@ static ssize_t setup_data_data_read(struct file *fp,
>  	ret = get_setup_data_paddr(nr, &paddr);
>  	if (ret)
>  		return ret;
> -	data = ioremap_cache(paddr, sizeof(*data));
> +	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
>  	if (!data)
>  		return -ENOMEM;
>  
> @@ -170,15 +171,15 @@ static ssize_t setup_data_data_read(struct file *fp,
>  		goto out;
>  
>  	ret = count;
> -	p = ioremap_cache(paddr + sizeof(*data), data->len);
> +	p = memremap(paddr + sizeof(*data), data->len, MEMREMAP_WB);
>  	if (!p) {
>  		ret = -ENOMEM;
>  		goto out;
>  	}
>  	memcpy(buf, p + off, count);
> -	iounmap(p);
> +	memunmap(p);
>  out:
> -	iounmap(data);
> +	memunmap(data);
>  	return ret;
>  }
>  
> @@ -250,13 +251,13 @@ static int __init get_setup_data_total_num(u64 pa_data, int *nr)
>  	*nr = 0;
>  	while (pa_data) {
>  		*nr += 1;
> -		data = ioremap_cache(pa_data, sizeof(*data));
> +		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
>  		if (!data) {
>  			ret = -ENOMEM;
>  			goto out;
>  		}
>  		pa_data = data->next;
> -		iounmap(data);
> +		memunmap(data);
>  	}
>  
>  out:
> 

It would be better that these cleanup patches are sent separately.

Acked-by: Dave Young <dyoung@redhat.com>

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
