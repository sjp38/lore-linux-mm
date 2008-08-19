Message-ID: <48AADBDC.2000608@linux-foundation.org>
Date: Tue, 19 Aug 2008 09:42:36 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: rewrite vmap layer
References: <20080818133224.GA5258@wotan.suse.de>
In-Reply-To: <20080818133224.GA5258@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> +static void free_unmap_vmap_area(struct vmap_area *va)
> +{
> +	va->flags |= VM_LAZY_FREE;
> +	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> +	if (unlikely(atomic_read(&vmap_lazy_nr) > LAZY_MAX))
> +		purge_vmap_area_lazy();
> +}

Could you check here if we are in an atomic context and then simply not purge
the vmap area? That may we may get to a vfree that can be run in an atomic
context.

Or run purge_vma_area_lazy from keventd?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
