Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 865436B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:53:25 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so20430078plf.1
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:53:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l185si6000667pgd.108.2018.04.05.12.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:53:24 -0700 (PDT)
Date: Thu, 5 Apr 2018 12:53:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] include: mm: Adding new inline function vmf_error
Message-Id: <20180405125322.2ef3abfc6159a72725095bd0@linux-foundation.org>
In-Reply-To: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
References: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: willy@infradead.org, linux-mm@kvack.org

On Thu, 5 Apr 2018 21:52:25 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> Many places in drivers/ file systems error was handled
> like below -
> ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
> 
> This new inline function vmf_error() will replace this
> and return vm_fault_t type err.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2453,6 +2453,18 @@ static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
>  	return VM_FAULT_NOPAGE;
>  }
>  
> +static inline vm_fault_t vmf_error(int err)
> +{
> +	vm_fault_t ret;
> +
> +	if (err == -ENOMEM)
> +		ret = VM_FAULT_OOM;
> +	else
> +		ret = VM_FAULT_SIGBUS;
> +
> +	return ret;
> +}
> +

That's a bit verbose.  Why not simply

	return (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;

Also, if would be nice to see some sites converted so we can see the
benefit of the patch and to actually test it.
