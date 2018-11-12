Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE23E6B026C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:07:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so2343433eda.10
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:07:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w25-v6si848536eju.19.2018.11.12.02.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 02:07:13 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wACA4oeR114285
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:07:12 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nq42289yc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:07:11 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 12 Nov 2018 10:07:10 -0000
Date: Mon, 12 Nov 2018 15:37:02 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: Re: [RFC PATCH v1 2/4] kvmppc: Add support for shared pages in HMM
 driver
Reply-To: bharata@linux.ibm.com
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-3-bharata@linux.ibm.com>
 <20181101104552.GE16399@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101104552.GE16399@350D>
Message-Id: <20181112100702.GF17399@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Thu, Nov 01, 2018 at 09:45:52PM +1100, Balbir Singh wrote:
> On Mon, Oct 22, 2018 at 10:48:35AM +0530, Bharata B Rao wrote:
> > A secure guest will share some of its pages with hypervisor (Eg. virtio
> > bounce buffers etc). Support shared pages in HMM driver.
> > 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
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
> 
> So this is a special flag passed via the hypercall to say
> this page can be skipped from page_out from secure memory?
> Who has the master copy of the page at this point?
> 
> In which case the question is
> 
> Why did we get a fault on the page which resulted in the
> fault migration ops being called?
> What category of pages are considered shared?

When UV/guest asks for sharing a page, there can be two cases:

- If the page is already secure, then provision a new page and share
- If the page is a normal page, share the existing page

In the former case, we touch the page via get_user_pages() and re-use the
HMM fault handler to release the HMM page. We use skip_page_out to mark
that this page is meant to be released w/o doing a page-out which otherwise
would be done if HV touches a secure page.

When a page is shared, both HV and UV have mappings to the same physical
page that resides in the non-secure memory.

Regards,
Bharata.
