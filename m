Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF4156B0011
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 16:17:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z6so4132244pgu.20
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 13:17:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t3si7122025pgf.356.2018.04.21.13.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 13:17:14 -0700 (PDT)
Date: Sat, 21 Apr 2018 13:17:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180421201711.GE14610@bombadil.infradead.org>
References: <20180421171442.GA17919@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180421171442.GA17919@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: mawilcox@microsoft.com, ross.zwisler@linux.intel.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Apr 21, 2018 at 10:44:42PM +0530, Souptick Joarder wrote:
> @@ -1112,7 +1112,7 @@ int __dax_zero_page_range(struct block_device *bdev,
>  }
>  EXPORT_SYMBOL_GPL(dax_iomap_rw);
>  
> -static int dax_fault_return(int error)
> +static vm_fault_t dax_fault_return(int error)
>  {
>  	if (error == 0)
>  		return VM_FAULT_NOPAGE;

At some point, we'll want to get rid of dax_fault_return, but that can be
a follow-on patch after vmf_error is in.

>  		if (write)
> -			error = vm_insert_mixed_mkwrite(vma, vaddr, pfn);
> +			ret = vmf_insert_mixed_mkwrite(vma, vaddr, pfn);
>  		else
> -			error = vm_insert_mixed(vma, vaddr, pfn);
> +			ret = vmf_insert_mixed(vma, vaddr, pfn);
>  
> -		/* -EBUSY is fine, somebody else faulted on the same PTE */
> -		if (error == -EBUSY)
> -			error = 0;
> -		break;
> +		goto finish_iomap;

> @@ -1284,12 +1281,12 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
>  	}
>  
>   error_finish_iomap:
> -	vmf_ret = dax_fault_return(error) | major;
> +	ret = dax_fault_return(error) | major;
>   finish_iomap:

I think we lose VM_FAULT_MAJOR with this change.

I would suggest fixing this with ...

  error_finish_iomap:
-	vmf_ret = dax_fault_return(error) | major;
+	ret = dax_fault_return(error);
  finish_iomap:

[...]

  out:
-	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
-	return vmf_ret;
+	trace_dax_pte_fault_done(inode, vmf, ret);
+	return ret | major;
