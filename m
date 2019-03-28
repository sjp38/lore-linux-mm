Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D577FC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:03:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BFEA21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:03:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BFEA21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC65F6B0006; Thu, 28 Mar 2019 18:03:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4C9E6B0007; Thu, 28 Mar 2019 18:03:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CED126B0008; Thu, 28 Mar 2019 18:03:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A860F6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:03:37 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s70so98957qka.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:03:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rdPWbej7EqVcN3T+YM5Cayk/G3ydkRrxFs1zc0ToGrc=;
        b=nxSWKasIx/eROV6/thRnv3uYQXPWHYijq0s6GMtVBtVHUGvSk2tXTR+IEd6SX6h67D
         9oUFsyaIYK39/0hnNxSEBMiTOJfN43lgrAxVamDRUjSf4vMEo3XG5hyRglxRKNLJzmEZ
         yOAIhZK/pwmCoUdmTBEcbkrX3lhhAXNyMBoPCsOtDQiVeqRxiXcBKFvyKTeJSTUJLyEz
         A9hRkpIz9QxaXZZURKwcmfFQTRNrc8u3Yn/nZyTNYPuwPuRlEW2JL7sV2FZCmkbrERss
         vxQzrT+7Yh5s6sxTqzW19vW9Svvu8ujYBGkR+K7ZHttCjQOpImT7RPp00Fshlp5/bzIp
         q+9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXqNYI4cErd2z96ALVg4vo9dudnasX6Xrg82XczZpiKjiKmzeCm
	8ysCdBGyK4V24eUb5Wz40ZnO6HlpFysVRjmELss3AZzAQEh08hU9ohyoUYC3EP/OHbTCwwd3wlV
	PZSqDN69m839ROvQcDJuIychvPlGbY8sq9Xw12kpqjO6Wiwbgi7Erptu4sJ2OwRU9nw==
X-Received: by 2002:a37:9fc6:: with SMTP id i189mr36515037qke.246.1553810617389;
        Thu, 28 Mar 2019 15:03:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYqGXIXGbqXAta5FTDJWDAKVZc+3aas0rxzZaECZNVww2U05b8UEK16EC6vxRs/ihQ76m5
X-Received: by 2002:a37:9fc6:: with SMTP id i189mr36514995qke.246.1553810616756;
        Thu, 28 Mar 2019 15:03:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810616; cv=none;
        d=google.com; s=arc-20160816;
        b=eFgmNBSpsLiprbuyO0uaylgGVbuQjrDDo8lD12oMioNCNHjiwPe25ol8j7XtFpzQMM
         8HLYfVeCxmyFp1UOxF4qoe+KiAmGbN7k4Lh9X3zmeugwfrTU4MhCQksTsE2D1Tuo9OQS
         QnRhaPTMUQaD4+ZHS5O3zzPfK+XtEz0pYAj3NlY7dVg2FCxurJX8e9qzvDYn+WRaLPBo
         hiLCjVEsliI9VqvyHN660efhkP08smh+g3kcUmWTkWT1JoOm7Pro3QvS8E1CKJEYsEVc
         HiPT8qJIN3KpyOWFm8QM43q27dOSm58cmvNO3SFA2xrNMjoiXC2LoaHHJEMaUAkh8kDn
         /EMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rdPWbej7EqVcN3T+YM5Cayk/G3ydkRrxFs1zc0ToGrc=;
        b=V9LHugZEhU/UO1teIlYwPeWyD3ouRxCUgj+UMDw4beXWhyg54CvFHCO2KN++nmLvnO
         R2loJq92mfd/HlUuuwO7LQosCPPCzppMlwgj1rtnDehcYFnpZCjDJo2zRyRtEH1gBKFw
         jfxqyuYw8xIERixu/BQ2/JY8YF1KpR/971Bf20zSy/xgWVGJVHsCkKqhpb870+G1B1v3
         wk6szyVkGIehbPdkT0HE13mO7jnxJSkHqj3L94h+KootfDQ1IwbtDbEzoN0wUkTiErGI
         FMGhq6ok/2BWOp1roco3jvX4TXosbV99ez2P+mpa8juPwjhoJwJprczjLaSGknfPOKZQ
         3iNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z4si54029qvz.104.2019.03.28.15.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:03:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F3EEB20268;
	Thu, 28 Mar 2019 22:03:35 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E009F379C;
	Thu, 28 Mar 2019 22:03:34 +0000 (UTC)
Date: Thu, 28 Mar 2019 18:03:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 05/11] mm/hmm: improve and rename hmm_vma_fault() to
 hmm_range_fault() v2
Message-ID: <20190328220332.GD13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-6-jglisse@redhat.com>
 <20190328134351.GD31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328134351.GD31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 28 Mar 2019 22:03:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 06:43:51AM -0700, Ira Weiny wrote:
> On Mon, Mar 25, 2019 at 10:40:05AM -0400, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > Rename for consistency between code, comments and documentation. Also
> > improves the comments on all the possible returns values. Improve the
> > function by returning the number of populated entries in pfns array.
> > 
> > Changes since v1:
> >     - updated documentation
> >     - reformated some comments
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  Documentation/vm/hmm.rst |  8 +---
> >  include/linux/hmm.h      | 13 +++++-
> >  mm/hmm.c                 | 91 +++++++++++++++++-----------------------
> >  3 files changed, 52 insertions(+), 60 deletions(-)
> > 
> > diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> > index d9b27bdadd1b..61f073215a8d 100644
> > --- a/Documentation/vm/hmm.rst
> > +++ b/Documentation/vm/hmm.rst
> > @@ -190,13 +190,7 @@ When the device driver wants to populate a range of virtual addresses, it can
> >  use either::
> >  
> >    long hmm_range_snapshot(struct hmm_range *range);
> > -  int hmm_vma_fault(struct vm_area_struct *vma,
> > -                    struct hmm_range *range,
> > -                    unsigned long start,
> > -                    unsigned long end,
> > -                    hmm_pfn_t *pfns,
> > -                    bool write,
> > -                    bool block);
> > +  long hmm_range_fault(struct hmm_range *range, bool block);
> >  
> >  The first one (hmm_range_snapshot()) will only fetch present CPU page table
> >  entries and will not trigger a page fault on missing or non-present entries.
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 32206b0b1bfd..e9afd23c2eac 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -391,7 +391,18 @@ bool hmm_vma_range_done(struct hmm_range *range);
> >   *
> >   * See the function description in mm/hmm.c for further documentation.
> >   */
> > -int hmm_vma_fault(struct hmm_range *range, bool block);
> > +long hmm_range_fault(struct hmm_range *range, bool block);
> > +
> > +/* This is a temporary helper to avoid merge conflict between trees. */
> > +static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > +{
> > +	long ret = hmm_range_fault(range, block);
> > +	if (ret == -EBUSY)
> > +		ret = -EAGAIN;
> > +	else if (ret == -EAGAIN)
> > +		ret = -EBUSY;
> > +	return ret < 0 ? ret : 0;
> > +}
> >  
> >  /* Below are for HMM internal use only! Not to be used by device driver! */
> >  void hmm_mm_destroy(struct mm_struct *mm);
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 91361aa74b8b..7860e63c3ba7 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -336,13 +336,13 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
> >  	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
> >  	ret = handle_mm_fault(vma, addr, flags);
> >  	if (ret & VM_FAULT_RETRY)
> > -		return -EBUSY;
> > +		return -EAGAIN;
> >  	if (ret & VM_FAULT_ERROR) {
> >  		*pfn = range->values[HMM_PFN_ERROR];
> >  		return -EFAULT;
> >  	}
> >  
> > -	return -EAGAIN;
> > +	return -EBUSY;
> >  }
> >  
> >  static int hmm_pfns_bad(unsigned long addr,
> > @@ -368,7 +368,7 @@ static int hmm_pfns_bad(unsigned long addr,
> >   * @fault: should we fault or not ?
> >   * @write_fault: write fault ?
> >   * @walk: mm_walk structure
> > - * Returns: 0 on success, -EAGAIN after page fault, or page fault error
> > + * Returns: 0 on success, -EBUSY after page fault, or page fault error
> >   *
> >   * This function will be called whenever pmd_none() or pte_none() returns true,
> >   * or whenever there is no page directory covering the virtual address range.
> > @@ -391,12 +391,12 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
> >  
> >  			ret = hmm_vma_do_fault(walk, addr, write_fault,
> >  					       &pfns[i]);
> > -			if (ret != -EAGAIN)
> > +			if (ret != -EBUSY)
> >  				return ret;
> >  		}
> >  	}
> >  
> > -	return (fault || write_fault) ? -EAGAIN : 0;
> > +	return (fault || write_fault) ? -EBUSY : 0;
> >  }
> >  
> >  static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
> > @@ -527,11 +527,11 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> >  	uint64_t orig_pfn = *pfn;
> >  
> >  	*pfn = range->values[HMM_PFN_NONE];
> > -	cpu_flags = pte_to_hmm_pfn_flags(range, pte);
> > -	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> > -			   &fault, &write_fault);
> > +	fault = write_fault = false;
> >  
> >  	if (pte_none(pte)) {
> > +		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, 0,
> > +				   &fault, &write_fault);
> 
> This really threw me until I applied the patches to a tree.  It looks like this
> is just optimizing away a pte_none() check.  The only functional change which
> was mentioned was returning the number of populated pfns.  So I spent a bit of
> time trying to figure out why hmm_pte_need_fault() needed to move _here_ to do
> that...  :-(
> 
> It would have been nice to have said something about optimizing in the commit
> message.

Yes i should have added that to the commit message i forgot.

> 
> >  		if (fault || write_fault)
> >  			goto fault;
> >  		return 0;
> > @@ -570,7 +570,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> >  				hmm_vma_walk->last = addr;
> >  				migration_entry_wait(vma->vm_mm,
> >  						     pmdp, addr);
> > -				return -EAGAIN;
> > +				return -EBUSY;
> >  			}
> >  			return 0;
> >  		}
> > @@ -578,6 +578,10 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> >  		/* Report error for everything else */
> >  		*pfn = range->values[HMM_PFN_ERROR];
> >  		return -EFAULT;
> > +	} else {
> > +		cpu_flags = pte_to_hmm_pfn_flags(range, pte);
> > +		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> > +				   &fault, &write_fault);
> 
> Looks like the same situation as above.
> 
> >  	}
> >  
> >  	if (fault || write_fault)
> > @@ -628,7 +632,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  		if (fault || write_fault) {
> >  			hmm_vma_walk->last = addr;
> >  			pmd_migration_entry_wait(vma->vm_mm, pmdp);
> > -			return -EAGAIN;
> > +			return -EBUSY;
> 
> While I am at it.  Why are we swapping EAGAIN and EBUSY everywhere?

It is a part of the API change when going from hmm_vma_fault() to
hmm_range_fault() and unifying the return values with the old
hmm_vma_get_pfns() so that all API have the same meaning behind
the same return value.

Cheers,
Jérôme

