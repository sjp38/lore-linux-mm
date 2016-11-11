Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98C636B02E4
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:14:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so23453762wmd.6
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:14:42 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id i124si32236044wma.78.2016.11.11.02.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 02:14:41 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id a20so8366619wme.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:14:41 -0800 (PST)
Date: Fri, 11 Nov 2016 13:14:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: THP page cache support for ppc64
Message-ID: <20161111101439.GB19382@node.shutemov.name>
References: <20161107083441.21901-1-aneesh.kumar@linux.vnet.ibm.com>
 <20161107083441.21901-2-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107083441.21901-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 07, 2016 at 02:04:41PM +0530, Aneesh Kumar K.V wrote:
> @@ -2953,6 +2966,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
>  	ret = VM_FAULT_FALLBACK;
>  	page = compound_head(page);
>  
> +	/*
> +	 * Archs like ppc64 need additonal space to store information
> +	 * related to pte entry. Use the preallocated table for that.
> +	 */
> +	if (arch_needs_pgtable_deposit() && !fe->prealloc_pte)
> +		fe->prealloc_pte = pte_alloc_one(vma->vm_mm, fe->address);
> +

-ENOMEM handling?

I think we should do this way before this point. Maybe in do_fault() or
something.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
