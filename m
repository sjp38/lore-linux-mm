Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBD26B03A0
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:05:21 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n141so61349980qke.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:05:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 19si2283225qkk.44.2017.03.07.23.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:05:17 -0800 (PST)
Date: Wed, 8 Mar 2017 15:04:59 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [RFC PATCH v4 24/28] x86: Access the setup data through debugfs
 decrypted
Message-ID: <20170308070459.GB11045@dhcp-128-65.nay.redhat.com>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154724.19244.71396.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216154724.19244.71396.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 02/16/17 at 09:47am, Tom Lendacky wrote:
> Use memremap() to map the setup data.  This simplifies the code and will
> make the appropriate decision as to whether a RAM remapping can be done
> or if a fallback to ioremap_cache() is needed (which includes checking
> PageHighMem).
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/kdebugfs.c |   30 +++++++++++-------------------
>  1 file changed, 11 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/x86/kernel/kdebugfs.c b/arch/x86/kernel/kdebugfs.c
> index bdb83e4..c3d354d 100644
> --- a/arch/x86/kernel/kdebugfs.c
> +++ b/arch/x86/kernel/kdebugfs.c
> @@ -48,17 +48,13 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
>  
>  	pa = node->paddr + sizeof(struct setup_data) + pos;
>  	pg = pfn_to_page((pa + count - 1) >> PAGE_SHIFT);
> -	if (PageHighMem(pg)) {
> -		p = ioremap_cache(pa, count);
> -		if (!p)
> -			return -ENXIO;
> -	} else
> -		p = __va(pa);
> +	p = memremap(pa, count, MEMREMAP_WB);
> +	if (!p)
> +		return -ENXIO;

-ENOMEM looks better for memremap, ditto for other places..

>  
>  	remain = copy_to_user(user_buf, p, count);
>  
> -	if (PageHighMem(pg))
> -		iounmap(p);
> +	memunmap(p);
>  
>  	if (remain)
>  		return -EFAULT;
> @@ -127,15 +123,12 @@ static int __init create_setup_data_nodes(struct dentry *parent)
>  		}
>  
>  		pg = pfn_to_page((pa_data+sizeof(*data)-1) >> PAGE_SHIFT);
> -		if (PageHighMem(pg)) {
> -			data = ioremap_cache(pa_data, sizeof(*data));
> -			if (!data) {
> -				kfree(node);
> -				error = -ENXIO;
> -				goto err_dir;
> -			}
> -		} else
> -			data = __va(pa_data);
> +		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
> +		if (!data) {
> +			kfree(node);
> +			error = -ENXIO;
> +			goto err_dir;
> +		}
>  
>  		node->paddr = pa_data;
>  		node->type = data->type;
> @@ -143,8 +136,7 @@ static int __init create_setup_data_nodes(struct dentry *parent)
>  		error = create_setup_data_node(d, no, node);
>  		pa_data = data->next;
>  
> -		if (PageHighMem(pg))
> -			iounmap(data);
> +		memunmap(data);
>  		if (error)
>  			goto err_dir;
>  		no++;
> 

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
