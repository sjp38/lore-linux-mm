Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 95C1690008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:29:32 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id z12so4262692lbi.11
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:29:31 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id xv1si11753488lbb.119.2014.10.30.05.29.30
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 05:29:31 -0700 (PDT)
Date: Thu, 30 Oct 2014 14:28:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/5] mm: gup: use get_user_pages_unlocked
Message-ID: <20141030122853.GD31134@node.dhcp.inet.fi>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:19PM +0100, Andrea Arcangeli wrote:
> This allows those get_user_pages calls to pass FAULT_FLAG_ALLOW_RETRY
> to the page fault in order to release the mmap_sem during the I/O.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  drivers/iommu/amd_iommu_v2.c       | 6 ++----
>  drivers/media/pci/ivtv/ivtv-udma.c | 6 ++----
>  drivers/scsi/st.c                  | 7 ++-----
>  drivers/video/fbdev/pvr2fb.c       | 6 ++----
>  mm/process_vm_access.c             | 7 ++-----
>  net/ceph/pagevec.c                 | 6 ++----
>  6 files changed, 12 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
> index 90d734b..4cd8a87 100644
> --- a/drivers/iommu/amd_iommu_v2.c
> +++ b/drivers/iommu/amd_iommu_v2.c
> @@ -521,10 +521,8 @@ static void do_fault(struct work_struct *work)
>  
>  	write = !!(fault->flags & PPR_FAULT_WRITE);
>  
> -	down_read(&fault->state->mm->mmap_sem);
> -	npages = get_user_pages(NULL, fault->state->mm,
> -				fault->address, 1, write, 0, &page, NULL);
> -	up_read(&fault->state->mm->mmap_sem);
> +	npages = get_user_pages_unlocked(NULL, fault->state->mm,
> +					 fault->address, 1, write, 0, &page);
>  
>  	if (npages == 1) {
>  		put_page(page);
> diff --git a/drivers/media/pci/ivtv/ivtv-udma.c b/drivers/media/pci/ivtv/ivtv-udma.c
> index 7338cb2..96d866b 100644
> --- a/drivers/media/pci/ivtv/ivtv-udma.c
> +++ b/drivers/media/pci/ivtv/ivtv-udma.c
> @@ -124,10 +124,8 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
>  	}
>  
>  	/* Get user pages for DMA Xfer */
> -	down_read(&current->mm->mmap_sem);
> -	err = get_user_pages(current, current->mm,
> -			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map, NULL);
> -	up_read(&current->mm->mmap_sem);
> +	err = get_user_pages_unlocked(current, current->mm,
> +			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map);
>  
>  	if (user_dma.page_count != err) {
>  		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
> diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
> index 4daa372..a98e00b 100644
> --- a/drivers/scsi/st.c
> +++ b/drivers/scsi/st.c
> @@ -4538,18 +4538,15 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
>  		return -ENOMEM;
>  
>          /* Try to fault in all of the necessary pages */
> -	down_read(&current->mm->mmap_sem);
>          /* rw==READ means read from drive, write into memory area */

Consolidate two one-line configs into a one?


Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
