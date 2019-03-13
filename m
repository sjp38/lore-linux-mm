Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0A20C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 09:58:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B2D12087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 09:58:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B2D12087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E81848E0003; Wed, 13 Mar 2019 05:58:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E32138E0001; Wed, 13 Mar 2019 05:58:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D21178E0003; Wed, 13 Mar 2019 05:58:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 788BB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 05:58:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k6so686359edq.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 02:58:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yqKaVHBwD3P5KNO+JV43iFleGVoTdaDnvO1Yqf4vQmA=;
        b=EdzCO8EEXMvNHkFdIVKqRsjlyzzUJyrX7tsDdhJO/pPXZ9TaGct8d8o70XZzachMTN
         9q8D2CzWYP6JNEyRqGdpHg4BVNtVPI+ozWfb+9EFHFZmrZr3G+n+ARB/br7sGJyzkivG
         cjUbmJWk8Vifz9yHhlz1/3CqCP0IJ0NUtRn56ka1qOVelgJVZEl5Us1yg5IXg3uq2d28
         RtGWoOoivdcdbvnmEq9qBE783l2EPfEskj2mYp78vEyLMEBHyYlxXMcywIM+C/YUT3em
         jBTzqE97XgfvNfQf+l0xrzguMOXO6vGkjQHSKFsd/becxaaWCm28HOG4p2vxBs775c5N
         Lg/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWQJ4ETPtHHj1hZp6TkmcltoR7hxpL6/IOLtvhHrpiwLYspNQ/2
	m8t8KzA+vrGBvonG1G56ymqFlYdcABwu4dcr0x4WeimOaN/l2qqGWwrf+qEGo4Z7Qo0/DJ5w6am
	WSe9e/17MYtbaUAGK5N2VZE9hhzHCwrIK/8dOqb7caYO2hfT1LbEDDLNzYRxHz/eJ0w==
X-Received: by 2002:a50:c9c7:: with SMTP id c7mr7278252edi.72.1552471117052;
        Wed, 13 Mar 2019 02:58:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9yaoNediiqOVPIFv12uCUJUWZqiW6UyayZSEdTA8y7kcQVG+b3CTxso+U/m3E278/qPz/
X-Received: by 2002:a50:c9c7:: with SMTP id c7mr7278195edi.72.1552471115991;
        Wed, 13 Mar 2019 02:58:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552471115; cv=none;
        d=google.com; s=arc-20160816;
        b=k1d65L6oX5BB7T5Edx+vMFfsA6TRSRQYs2P7UFa+rllTWk19dOWroP6LzF0/jtA6i2
         Sc0b1KAp2t9QUPCOr5RMiQIPKq2AUaWRy8IwNKlMqNJflBJu7VYI1XzaaIEaua8xXzqv
         bmZ8zcbxYvsF9q4LLJdBi9EuGFGvJbSpF9FkUQHYixFrfLtK+m4vml67/EOM2jNjtU20
         YaDvCV4+QjfNScWPWwshc8A19xCnvVU9upQPRlp5UmofZ1PaxQPKW6ww01+jIyqpCfux
         qSYZwNLU5mmmvy/q9OPPNWujaLdGGfw/RpnhEmZOKBGUn/lEBB6q0n5Hde8Xc62t6zE5
         5K1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yqKaVHBwD3P5KNO+JV43iFleGVoTdaDnvO1Yqf4vQmA=;
        b=i5jTlP3jEz1PSUkHIgtOe5Tqce0SCg3ouYyAmZDg4XSgdJkOf2sj90n1Bv59iHVi4z
         sPKaLvaBH+wrROdS96Z7oAdaLTLh4+CHQJ3WngBzerDLtm6sHfL9S0kxSaqNt9Ict3s+
         NEqqG9szG8lJZwthG6EjfsvgDTT7VyCbX+D+yFqysGCjVkOYJVui0ZyLo8tDunON3693
         ldZSBPYpAc378NcbfDUsjKTACkXy39Q/ZYd9dK0Q7Cln3T5MVN3p+d5rD8BrVNXGnRQf
         RL4lZAsTMgXik7QnO4hYtDoaunr3T3w0pEmyRg0Hk1z50fhOxubPvrek+9dw4Yj4s0LW
         /LYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si543754edi.296.2019.03.13.02.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 02:58:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 148B8AF42;
	Wed, 13 Mar 2019 09:58:35 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 5C8701E3FE8; Wed, 13 Mar 2019 10:58:34 +0100 (CET)
Date: Wed, 13 Mar 2019 10:58:34 +0100
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, Ross Zwisler <zwisler@kernel.org>,
	Jan Kara <jack@suse.cz>, akpm@linux-foundation.org,
	linux-nvdimm@lists.01.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2] fs/dax: deposit pagetable even when installing zero
 page
Message-ID: <20190313095834.GF32521@quack2.suse.cz>
References: <20190309120721.21416-1-aneesh.kumar@linux.ibm.com>
 <8736nrnzxm.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8736nrnzxm.fsf@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 10:17:17, Aneesh Kumar K.V wrote:
> 
> Hi Dan/Andrew/Jan,
> 
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> 
> > Architectures like ppc64 use the deposited page table to store hardware
> > page table slot information. Make sure we deposit a page table when
> > using zero page at the pmd level for hash.
> >
> > Without this we hit
> >
> > Unable to handle kernel paging request for data at address 0x00000000
> > Faulting instruction address: 0xc000000000082a74
> > Oops: Kernel access of bad area, sig: 11 [#1]
> > ....
> >
> > NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
> > LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
> > Call Trace:
> >  hash_page_mm+0x43c/0x740
> >  do_hash_page+0x2c/0x3c
> >  copy_from_iter_flushcache+0xa4/0x4a0
> >  pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
> >  dax_copy_from_iter+0x40/0x70
> >  dax_iomap_actor+0x134/0x360
> >  iomap_apply+0xfc/0x1b0
> >  dax_iomap_rw+0xac/0x130
> >  ext4_file_write_iter+0x254/0x460 [ext4]
> >  __vfs_write+0x120/0x1e0
> >  vfs_write+0xd8/0x220
> >  SyS_write+0x6c/0x110
> >  system_call+0x3c/0x130
> >
> > Fixes: b5beae5e224f ("powerpc/pseries: Add driver for PAPR SCM regions")
> > Reviewed-by: Jan Kara <jack@suse.cz>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> 
> Any suggestion on which tree this patch should got to? Also since this
> fix a kernel crash, we may want to get this to 5.1?

I think this should go through Dan's tree...

								Honza

> > ---
> > Changes from v1:
> > * Add reviewed-by:
> > * Add Fixes:
> >
> >  fs/dax.c | 15 +++++++++++++++
> >  1 file changed, 15 insertions(+)
> >
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 6959837cc465..01bfb2ac34f9 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/sizes.h>
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/iomap.h>
> > +#include <asm/pgalloc.h>
> >  #include "internal.h"
> >  
> >  #define CREATE_TRACE_POINTS
> > @@ -1410,7 +1411,9 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
> >  {
> >  	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
> >  	unsigned long pmd_addr = vmf->address & PMD_MASK;
> > +	struct vm_area_struct *vma = vmf->vma;
> >  	struct inode *inode = mapping->host;
> > +	pgtable_t pgtable = NULL;
> >  	struct page *zero_page;
> >  	spinlock_t *ptl;
> >  	pmd_t pmd_entry;
> > @@ -1425,12 +1428,22 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
> >  	*entry = dax_insert_entry(xas, mapping, vmf, *entry, pfn,
> >  			DAX_PMD | DAX_ZERO_PAGE, false);
> >  
> > +	if (arch_needs_pgtable_deposit()) {
> > +		pgtable = pte_alloc_one(vma->vm_mm);
> > +		if (!pgtable)
> > +			return VM_FAULT_OOM;
> > +	}
> > +
> >  	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
> >  	if (!pmd_none(*(vmf->pmd))) {
> >  		spin_unlock(ptl);
> >  		goto fallback;
> >  	}
> >  
> > +	if (pgtable) {
> > +		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
> > +		mm_inc_nr_ptes(vma->vm_mm);
> > +	}
> >  	pmd_entry = mk_pmd(zero_page, vmf->vma->vm_page_prot);
> >  	pmd_entry = pmd_mkhuge(pmd_entry);
> >  	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
> > @@ -1439,6 +1452,8 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
> >  	return VM_FAULT_NOPAGE;
> >  
> >  fallback:
> > +	if (pgtable)
> > +		pte_free(vma->vm_mm, pgtable);
> >  	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, *entry);
> >  	return VM_FAULT_FALLBACK;
> >  }
> > -- 
> > 2.20.1
> 
> -aneesh
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

