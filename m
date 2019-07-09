Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAC5AC606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99F9C20844
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:04:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99F9C20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DA828E0043; Tue,  9 Jul 2019 06:04:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28BB98E0032; Tue,  9 Jul 2019 06:04:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17B248E0043; Tue,  9 Jul 2019 06:04:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA6EA8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:04:07 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i63so12981942ywc.1
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:04:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=68MZs/ensRliDKGfPLeLs4LeJliFIBCANgyE2j5fXlw=;
        b=h9im4CdoSFfilT493eJr7zJ5od+UYF1sFBN7OEj/74Qb1aNFmXwqOHKSVrl67TfXeF
         vE6Ydc/08LFp8a0WFYPqaib4pdv5B4rp+MNvRpwxUSS28+l/egpFOXaMnyJ9dkKnDmA8
         FzfMxt0Z/fLvNP8QvDMrLkKjWBJA3hb8nkUmLLsXRlPirvX2n0F8McHT6Bg5rUSO1lM+
         1beTMc6uQ/YCZK/nlnB3u1CyCXUFqgKWmWbzaOJU2YPwZTtIgMrOIVePQFUCp9nk4cAQ
         tZNVkDrnLv32mmztBxx85J6V6rqLvH7DCjFDvFRkw45Qx3Z+jx/yZEthpBbbqsfiYyeY
         Ca/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXz3uD2CRwE6zs5zOqpumuAhPLboBSM1gS/7UfAIYSY+zCbEEKD
	lI2A+5D/KnDL7+4p0NI2jyNcnh96Emg+vHRuxQ6WptdxYf1mY/nfQoZZxeSTjRFJgD8qemuowwC
	+/7tvtMse5Tp1kSGf9A+n2lb8gtj7eRv273kNQ/GTZJ6wQw1jS/h6OARJpUg7IbLSYw==
X-Received: by 2002:a25:bf84:: with SMTP id l4mr12239357ybk.516.1562666647614;
        Tue, 09 Jul 2019 03:04:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRfvRI3yvIR9HY2EXHWNhalaJSyKj+lCrT+ajntkoEY5V4qUJwF4ZuGiXwdnlgnXlwvy6S
X-Received: by 2002:a25:bf84:: with SMTP id l4mr12239315ybk.516.1562666646644;
        Tue, 09 Jul 2019 03:04:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562666646; cv=none;
        d=google.com; s=arc-20160816;
        b=gEIVgXQDD84fz5cr/CldUVZ9Eyvy3Xrp7G8S7jk41gZqBkkiO0OoXcTFKyIY6K0sW+
         8ZQzPz0bNOQGIsWLF8LM0JvGLHuMe9Bgdily2MNxh05eUseSD9t50oCJcbrks/sQtRKn
         1JlY5+tcjqmp8MPBO1uaH6bgTMOP3wW3PayTAyAsnnOdUzNqhn/1EyTPdw/BtLmnJM2g
         CUwajjeU/cHelbeEsRY5frfdsQSXN6MaM8Gp1z+GDytKpejom1FYYyqSFJW8Sk8RHjP3
         QaawYSBv8ce3SvR/fjB+gsuXaoboBq97fbnncF8Btp9fBZ/fZ4csELzbwkZz5LWHJx2r
         /Ytw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=68MZs/ensRliDKGfPLeLs4LeJliFIBCANgyE2j5fXlw=;
        b=DP2553M+z/NwQ8Gu0vNxmDnB0GWMQ+tyNiuITl+WyARoaJjnjBSo89LrY060+hdnUi
         puUU2zBQ1R7sFviTcXUoiQruLoa4Z7k7QYB/u966Q3dheMpHWbW1/uEA1Wsqfqk0cdMu
         TeO+a+PAvxNEUKEllk4MwNb/0NbtoxtKZh3NQOSsJpZbU5OWH10AvRDzx2RF5+MkosRN
         79qsirQQSNtQGx6oTjw9G90Ny39fpRh/XVHruTB0sJR15/cCr+tQ4iIWgfFnoazrvYQe
         PG6jYkqdsefGk6PFjjH4humUlhlJnNbyM0KcVToDKH7qPebLK9vDkV3TTVqHtPP3mtd+
         FcAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r6si2880402ywf.224.2019.07.09.03.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:04:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69A2RoB087664
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:04:06 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tmpfmnr1r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:04:05 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:04:04 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:04:01 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69A3xV946923860
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:03:59 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 87EE8AE045;
	Tue,  9 Jul 2019 10:03:59 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B6954AE056;
	Tue,  9 Jul 2019 10:03:57 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  9 Jul 2019 10:03:57 +0000 (GMT)
Date: Tue, 9 Jul 2019 15:33:53 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 1/6] kvmppc: HMM backend driver to manage pages of
 secure guest
Reply-To: bharata@linux.ibm.com
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-2-bharata@linux.ibm.com>
 <20190617053106.lqwzibpsz4d2464z@oak.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617053106.lqwzibpsz4d2464z@oak.ozlabs.ibm.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19070910-0008-0000-0000-000002FB39DF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0009-0000-0000-0000226899A5
Message-Id: <20190709100353.GA27933@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=956 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:31:06PM +1000, Paul Mackerras wrote:
> On Tue, May 28, 2019 at 12:19:28PM +0530, Bharata B Rao wrote:
> > HMM driver for KVM PPC to manage page transitions of
> > secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> > 
> > H_SVM_PAGE_IN: Move the content of a normal page to secure page
> > H_SVM_PAGE_OUT: Move the content of a secure page to normal page
> 
> Comments below...
> 
> > @@ -4421,6 +4435,7 @@ static void kvmppc_core_free_memslot_hv(struct kvm_memory_slot *free,
> >  					struct kvm_memory_slot *dont)
> >  {
> >  	if (!dont || free->arch.rmap != dont->arch.rmap) {
> > +		kvmppc_hmm_release_pfns(free);
> 
> I don't think this is the right place to do this.  The memslot will
> have no pages mapped by this time, because higher levels of code will
> have called kvmppc_core_flush_memslot_hv() before calling this.
> Releasing the pfns should be done in that function.

In fact I can get rid of kvmppc_hmm_release_pfns() totally as we don't
have to do free the HMM pages like this explicitly. During guest shutdown
all these pages are dropped when unmap_vmas() is called.

> 
> > diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
> > new file mode 100644
> > index 000000000000..713806003da3
> 
> ...
> 
> > +#define KVMPPC_PFN_HMM		(0x1ULL << 61)
> > +
> > +static inline bool kvmppc_is_hmm_pfn(unsigned long pfn)
> > +{
> > +	return !!(pfn & KVMPPC_PFN_HMM);
> > +}
> 
> Since you are putting in these values in the rmap entries, you need to
> be careful about overlaps between these values and the other uses of
> rmap entries.  The value you have chosen would be in the middle of the
> LPID field for an rmap entry for a guest that has nested guests, and
> in fact kvmhv_remove_nest_rmap_range() effectively assumes that a
> non-zero rmap entry must be a list of L2 guest mappings.  (This is for
> radix guests; HPT guests use the rmap entry differently, but I am
> assuming that we will enforce that only radix guests can be secure
> guests.)

Worked out with Suraj on sharing the rmap and got a well defined
bit slot for HMM PFNs in rmap.

> 
> Maybe it is true that the rmap entry will be non-zero only for those
> guest pages which are not mapped on the host side, that is,
> kvmppc_radix_flush_memslot() will see !pte_present(*ptep) for any page
> of a secure guest where the rmap entry contains a HMM pfn.  If that is
> so and is a deliberate part of the design, then I would like to see it
> written down in comments and commit messages so it's clear to others
> working on the code in future.

Yes, rmap entry will be non-zero only for those guest pages which are
not mapped on the host side. However as soon as guest becomes secure
we free the HV side partition scoped page tables and hence
kvmppc_radix_flush_memslot() and other such routines which lookup
kvm->arch.pgtable will no longer touch it.

> 
> Suraj is working on support for nested HPT guests, which will involve
> changing the rmap format to indicate more explicitly what sort of
> entry each rmap entry is.  Please work with him to define a format for
> your rmap entries that is clearly distinguishable from the others.
> 
> I think it is reasonable to say that a secure guest can't have nested
> guests, at least for now, but then we should make sure to kill all
> nested guests when a guest goes secure.

Ok. Yet to figure this part out.

> 
> ...
> 
> > +/*
> > + * Move page from normal memory to secure memory.
> > + */
> > +unsigned long
> > +kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
> > +		     unsigned long flags, unsigned long page_shift)
> > +{
> > +	unsigned long addr, end;
> > +	unsigned long src_pfn, dst_pfn;
> > +	struct kvmppc_hmm_migrate_args args;
> > +	struct vm_area_struct *vma;
> > +	int srcu_idx;
> > +	unsigned long gfn = gpa >> page_shift;
> > +	struct kvm_memory_slot *slot;
> > +	unsigned long *rmap;
> > +	int ret = H_SUCCESS;
> > +
> > +	if (page_shift != PAGE_SHIFT)
> > +		return H_P3;
> > +
> > +	srcu_idx = srcu_read_lock(&kvm->srcu);
> > +	slot = gfn_to_memslot(kvm, gfn);
> > +	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
> > +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> > +	srcu_read_unlock(&kvm->srcu, srcu_idx);
> 
> Shouldn't we keep the srcu read lock until we have finished working on
> the page?

I wasn't sure, so keeping it locked till the end in the next version.

> 
> > +	if (kvm_is_error_hva(addr))
> > +		return H_PARAMETER;
> > +
> > +	end = addr + (1UL << page_shift);
> > +
> > +	if (flags)
> > +		return H_P2;
> > +
> > +	args.rmap = rmap;
> > +	args.lpid = kvm->arch.lpid;
> > +	args.gpa = gpa;
> > +	args.page_shift = page_shift;
> > +
> > +	down_read(&kvm->mm->mmap_sem);
> > +	vma = find_vma_intersection(kvm->mm, addr, end);
> > +	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
> > +		ret = H_PARAMETER;
> > +		goto out;
> > +	}
> > +	ret = migrate_vma(&kvmppc_hmm_migrate_ops, vma, addr, end,
> > +			  &src_pfn, &dst_pfn, &args);
> > +	if (ret < 0)
> > +		ret = H_PARAMETER;
> > +out:
> > +	up_read(&kvm->mm->mmap_sem);
> > +	return ret;
> > +}
> 
> ...
> 
> > +/*
> > + * Move page from secure memory to normal memory.
> > + */
> > +unsigned long
> > +kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
> > +		      unsigned long flags, unsigned long page_shift)
> > +{
> > +	unsigned long addr, end;
> > +	struct vm_area_struct *vma;
> > +	unsigned long src_pfn, dst_pfn = 0;
> > +	int srcu_idx;
> > +	int ret = H_SUCCESS;
> > +
> > +	if (page_shift != PAGE_SHIFT)
> > +		return H_P3;
> > +
> > +	if (flags)
> > +		return H_P2;
> > +
> > +	srcu_idx = srcu_read_lock(&kvm->srcu);
> > +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> > +	srcu_read_unlock(&kvm->srcu, srcu_idx);
> 
> and likewise here, shouldn't we unlock later, after the migrate_vma()
> call perhaps?

Sure.

Regards,
Bharata.

