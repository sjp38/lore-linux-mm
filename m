Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B336A6B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 00:47:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s89so19362607pfk.11
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 21:47:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y67si11206214pfj.22.2017.04.29.21.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Apr 2017 21:47:06 -0700 (PDT)
Date: Sat, 29 Apr 2017 21:47:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v3 03/17] mm: Introduce pte_spinlock
Message-ID: <20170430044700.GF27790@bombadil.infradead.org>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493308376-23851-4-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493308376-23851-4-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On Thu, Apr 27, 2017 at 05:52:42PM +0200, Laurent Dufour wrote:
> +++ b/mm/memory.c
> @@ -2100,6 +2100,13 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
>  }
>  
> +static bool pte_spinlock(struct vm_fault *vmf)
> +{
> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	spin_lock(vmf->ptl);
> +	return true;
> +}

To me 'pte_spinlock' is a noun, but this is really pte_spin_lock() (a verb).

Actually, it's really vmf_lock_pte().  We're locking the pte
referred to by this vmf.  And so we should probably have a matching
vmf_unlock_pte(vmf) to preserve the abstraction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
