Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B005E8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:03:47 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q3so10969122qtq.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:03:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q45si3998217qte.344.2019.01.10.07.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 07:03:46 -0800 (PST)
Date: Thu, 10 Jan 2019 10:03:43 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: Convert to use vm_fault_t
Message-ID: <20190110150343.GA4394@redhat.com>
References: <20190110145900.GA1317@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110145900.GA1317@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 10, 2019 at 08:29:00PM +0530, Souptick Joarder wrote:
> convert to use vm_fault_t type as return type for
> fault handler.
> 
> kbuild reported warning during testing of
> *mm-create-the-new-vm_fault_t-type.patch* available in below link -
> https://patchwork.kernel.org/patch/10752741/
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v5.0-rc1 next-20190109]
> [if your patch is applied to the wrong git tree, please drop us a note
> to help improve the system]
> 
> kernel/memremap.c:46:34: warning: incorrect type in return expression
>                          (different base types)
> kernel/memremap.c:46:34: expected restricted vm_fault_t
> kernel/memremap.c:46:34: got int
> 
> This patch has fixed the warnings and also hmm_devmem_fault() is
> converted to return vm_fault_t to avoid further warnings.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: J�r�me Glisse <jglisse@redhat.com>

> ---
>  include/linux/hmm.h | 4 ++--
>  mm/hmm.c            | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 66f9ebb..ad50b7b 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -468,7 +468,7 @@ struct hmm_devmem_ops {
>  	 * Note that mmap semaphore is held in read mode at least when this
>  	 * callback occurs, hence the vma is valid upon callback entry.
>  	 */
> -	int (*fault)(struct hmm_devmem *devmem,
> +	vm_fault_t (*fault)(struct hmm_devmem *devmem,
>  		     struct vm_area_struct *vma,
>  		     unsigned long addr,
>  		     const struct page *page,
> @@ -511,7 +511,7 @@ struct hmm_devmem_ops {
>   * chunk, as an optimization. It must, however, prioritize the faulting address
>   * over all the others.
>   */
> -typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +typedef vm_fault_t (*dev_page_fault_t)(struct vm_area_struct *vma,
>  				unsigned long addr,
>  				const struct page *page,
>  				unsigned int flags,
> diff --git a/mm/hmm.c b/mm/hmm.c
> index a04e4b8..fe1cd87 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -990,7 +990,7 @@ static void hmm_devmem_ref_kill(struct percpu_ref *ref)
>  	percpu_ref_kill(ref);
>  }
>  
> -static int hmm_devmem_fault(struct vm_area_struct *vma,
> +static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
>  			    unsigned long addr,
>  			    const struct page *page,
>  			    unsigned int flags,
> -- 
> 1.9.1
> 
