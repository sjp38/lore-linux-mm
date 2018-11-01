Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2B4D6B026A
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:45:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s23-v6so3794561plq.7
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:45:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4-v6sor27048937plk.55.2018.11.01.03.45.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 03:45:57 -0700 (PDT)
Date: Thu, 1 Nov 2018 21:45:52 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC PATCH v1 2/4] kvmppc: Add support for shared pages in HMM
 driver
Message-ID: <20181101104552.GE16399@350D>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-3-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022051837.1165-3-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Mon, Oct 22, 2018 at 10:48:35AM +0530, Bharata B Rao wrote:
> A secure guest will share some of its pages with hypervisor (Eg. virtio
> bounce buffers etc). Support shared pages in HMM driver.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> ---
>  arch/powerpc/kvm/book3s_hv_hmm.c | 69 ++++++++++++++++++++++++++++++--
>  1 file changed, 65 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
> index a2ee3163a312..09b8e19b7605 100644
> --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> @@ -50,6 +50,7 @@ struct kvmppc_hmm_page_pvt {
>  	struct hlist_head *hmm_hash;
>  	unsigned int lpid;
>  	unsigned long gpa;
> +	bool skip_page_out;
>  };
>  
>  struct kvmppc_hmm_migrate_args {
> @@ -278,6 +279,65 @@ static unsigned long kvmppc_gpa_to_hva(struct kvm *kvm, unsigned long gpa,
>  	return hva;
>  }
>  
> +/*
> + * Shares the page with HV, thus making it a normal page.
> + *
> + * - If the page is already secure, then provision a new page and share
> + * - If the page is a normal page, share the existing page
> + *
> + * In the former case, uses the HMM fault handler to release the HMM page.
> + */
> +static unsigned long
> +kvmppc_share_page(struct kvm *kvm, unsigned long gpa,
> +		  unsigned long addr, unsigned long page_shift)
> +{
> +

So this is a special flag passed via the hypercall to say
this page can be skipped from page_out from secure memory?
Who has the master copy of the page at this point?

In which case the question is

Why did we get a fault on the page which resulted in the
fault migration ops being called?
What category of pages are considered shared?

Balbir
