Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 454D06B4CDE
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:14:37 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d6-v6so16675711pfn.19
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:14:37 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id x9si7113437pge.76.2018.11.28.04.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 04:14:35 -0800 (PST)
Subject: Re: [PATCH 008/216] x86, pageattr: Prevent overflow in
 slow_virt_to_phys() for X86_PAE
References: <1543404768-89470-1-git-send-email-alex.shi@linux.alibaba.com>
 <1543404768-89470-8-git-send-email-alex.shi@linux.alibaba.com>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <1573cbad-29cd-f34e-a005-1a6906a4cd4e@linux.alibaba.com>
Date: Wed, 28 Nov 2018 20:14:21 +0800
MIME-Version: 1.0
In-Reply-To: <1543404768-89470-8-git-send-email-alex.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, Michael Wang <yun.wang@linux.alibaba.com>, Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Dexuan Cui <decui@microsoft.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

Hi, All,

Please ignore this stupid email thread. I thought I had suppressed cc in gitconfig. But I am wrong...

Very very sorry!


Thanks
Alex

On 2018/11/28 7:29 PM, Alex Shi wrote:
> From: Dexuan Cui <decui@microsoft.com>
>
> commit d1cd1210834649ce1ca6bafe5ac25d2f40331343 upstream.
>
> pte_pfn() returns a PFN of long (32 bits in 32-PAE), so "long <<
> PAGE_SHIFT" will overflow for PFNs above 4GB.
>
> Due to this issue, some Linux 32-PAE distros, running as guests on Hyper-V,
> with 5GB memory assigned, can't load the netvsc driver successfully and
> hence the synthetic network device can't work (we can use the kernel parameter
> mem=3000M to work around the issue).
>
> Cast pte_pfn() to phys_addr_t before shifting.
>
> Fixes: "commit d76565344512: x86, mm: Create slow_virt_to_phys()"
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: gregkh@linuxfoundation.org
> Cc: linux-mm@kvack.org
> Cc: olaf@aepfle.de
> Cc: apw@canonical.com
> Cc: jasowang@redhat.com
> Cc: dave.hansen@intel.com
> Cc: riel@redhat.com
> Cc: stable@vger.kernel.org
> Link: http://lkml.kernel.org/r/1414580017-27444-1-git-send-email-decui@microsoft.com
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
> ---
>  7u/arch/x86/mm/pageattr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/7u/arch/x86/mm/pageattr.c b/7u/arch/x86/mm/pageattr.c
> index 4ed2b2d..81b82f4 100644
> --- a/7u/arch/x86/mm/pageattr.c
> +++ b/7u/arch/x86/mm/pageattr.c
> @@ -405,7 +405,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
>  	psize = page_level_size(level);
>  	pmask = page_level_mask(level);
>  	offset = virt_addr & ~pmask;
> -	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
> +	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
>  	return (phys_addr | offset);
>  }
>  EXPORT_SYMBOL_GPL(slow_virt_to_phys);
