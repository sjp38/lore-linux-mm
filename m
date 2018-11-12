Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 704F86B000C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:39:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so3946291edd.16
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:39:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n6-v6si942068ejy.72.2018.11.12.01.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 01:39:11 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAC9d9ch116169
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:39:09 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nq4gaemer-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:39:08 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 12 Nov 2018 09:39:03 -0000
Date: Mon, 12 Nov 2018 15:08:55 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: Re: [RFC PATCH v1 2/4] kvmppc: Add support for shared pages in HMM
 driver
Reply-To: bharata@linux.ibm.com
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-3-bharata@linux.ibm.com>
 <20181030052646.GB11072@blackberry>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030052646.GB11072@blackberry>
Message-Id: <20181112093855.GC17399@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Tue, Oct 30, 2018 at 04:26:46PM +1100, Paul Mackerras wrote:
> On Mon, Oct 22, 2018 at 10:48:35AM +0530, Bharata B Rao wrote:
> > A secure guest will share some of its pages with hypervisor (Eg. virtio
> > bounce buffers etc). Support shared pages in HMM driver.
> > 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> 
> Comments below...
> 
> > ---
> >  arch/powerpc/kvm/book3s_hv_hmm.c | 69 ++++++++++++++++++++++++++++++--
> >  1 file changed, 65 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
> > index a2ee3163a312..09b8e19b7605 100644
> > --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> > +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> > @@ -50,6 +50,7 @@ struct kvmppc_hmm_page_pvt {
> >  	struct hlist_head *hmm_hash;
> >  	unsigned int lpid;
> >  	unsigned long gpa;
> > +	bool skip_page_out;
> >  };
> >  
> >  struct kvmppc_hmm_migrate_args {
> > @@ -278,6 +279,65 @@ static unsigned long kvmppc_gpa_to_hva(struct kvm *kvm, unsigned long gpa,
> >  	return hva;
> >  }
> >  
> > +/*
> > + * Shares the page with HV, thus making it a normal page.
> > + *
> > + * - If the page is already secure, then provision a new page and share
> > + * - If the page is a normal page, share the existing page
> > + *
> > + * In the former case, uses the HMM fault handler to release the HMM page.
> > + */
> > +static unsigned long
> > +kvmppc_share_page(struct kvm *kvm, unsigned long gpa,
> > +		  unsigned long addr, unsigned long page_shift)
> > +{
> > +
> > +	int ret;
> > +	struct hlist_head *list, *hmm_hash;
> > +	unsigned int lpid = kvm->arch.lpid;
> > +	unsigned long flags;
> > +	struct kvmppc_hmm_pfn_entry *p;
> > +	struct page *hmm_page, *page;
> > +	struct kvmppc_hmm_page_pvt *pvt;
> > +	unsigned long pfn;
> > +
> > +	/*
> > +	 * First check if the requested page has already been given to
> > +	 * UV as a secure page. If so, ensure that we don't issue a
> > +	 * UV_PAGE_OUT but instead directly send the page
> > +	 */
> > +	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
> > +	hmm_hash = kvm->arch.hmm_hash;
> > +	list = &hmm_hash[kvmppc_hmm_pfn_hash_fn(gpa)];
> > +	hlist_for_each_entry(p, list, hlist) {
> > +		if (p->addr == gpa) {
> > +			hmm_page = pfn_to_page(p->hmm_pfn);
> > +			get_page(hmm_page); /* TODO: Necessary ? */
> > +			pvt = (struct kvmppc_hmm_page_pvt *)
> > +				hmm_devmem_page_get_drvdata(hmm_page);
> > +			pvt->skip_page_out = true;
> > +			put_page(hmm_page);
> > +			break;
> > +		}
> > +	}
> > +	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
> > +
> > +	ret = get_user_pages_fast(addr, 1, 0, &page);
> 
> Why are we calling this with write==0?  Surely in general the secure
> guest will expect to be able to write to the shared page?
> 
> Also, in general get_user_pages_fast isn't sufficient to translate a
> host virtual address (derived from a guest real address) into a pfn.
> See for example hva_to_pfn() in virt/kvm/kvm_main.c and the things it
> does to cope with the various cases that one can hit.  I can imagine
> in future that the secure guest might want to establish a shared
> mapping to a PCI device, for instance.

I switched to using gfn_to_pfn() which should cover all the cases.

> 
> > +	if (ret != 1)
> > +		return H_PARAMETER;
> > +
> > +	pfn = page_to_pfn(page);
> > +	if (is_zero_pfn(pfn)) {
> > +		put_page(page);
> > +		return H_SUCCESS;
> > +	}
> 
> The ultravisor still needs a page to map into the guest in this case,
> doesn't it?  What's the point of returning without giving the
> ultravisor a page to use?

Yes, missed it.

Regards,
Bharata.
