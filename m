Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B5E3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C43CA2173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C43CA2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72D676B0007; Thu, 28 Mar 2019 22:17:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DC1F6B0008; Thu, 28 Mar 2019 22:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3B86B000C; Thu, 28 Mar 2019 22:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 365616B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:17:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i124so536242qkf.14
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hB+2voDSZQygDbqT+h65nNkGk3dewMMqXA8mUkVsWII=;
        b=nRDOQ1lHDLDSCCg3n4oLAkyKfTnIvKpWz5S5zzRbbEf/srs046rYi6OWpA9Q/nMyUl
         RMl9WTpIKxvnELZJBPkn0bWfvAR9gGQfIieeGYG0OvrNsQDMZSH+zUpUq72oOfXx9FlE
         Eli4fZ21qUtWZCndJRhSkCn4HfX1fOswCsA0Wcjjp8VFu8X1ZAviLZHdtvCc02+JR1u/
         O1cLyittx5Jr8MyM6x2QE6ALnmdLn3m87Gfwm8hErUKgk/60O4Gxpkp3mu3bsW9CCW1l
         VhLDKGxYxi15ALyp9ef5Uego1jU0sHGXuMWqDukquWBwvPqvv1IxY8YPhUdo6XJFAZdB
         Z0Ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVfQKlLhDNEgQ0y4QtZdUN5Z3RgxHr/yEQp/gFKxUtscWo9jVOI
	JAxN/vIXLD/QNUrLf2lCvCn5wnH55MZWo6aNyYGbqs+fvs+IRanzUXmq71gr27NBDqIFpf2/qhZ
	WELmhUxvuha0QGkFrWgn5cXYXCCOCDvfmozVPEUCAszXHFBJkE126ycobZ7E/JJcaRw==
X-Received: by 2002:ac8:18dd:: with SMTP id o29mr37823632qtk.104.1553825873933;
        Thu, 28 Mar 2019 19:17:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweCNl6sIsaNpJZFS3f9Hf/Mw1aP1Y8h0hrxxJU9uSAx4jeMI4fYRlXNfODNduX875yv7nX
X-Received: by 2002:ac8:18dd:: with SMTP id o29mr37823609qtk.104.1553825873340;
        Thu, 28 Mar 2019 19:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553825873; cv=none;
        d=google.com; s=arc-20160816;
        b=l2YSNzfCb4fTdIOic6KHt+TgSCTlo8B3uF/N9IcAf9H3CieKVWrb1x+D1pox79M1Xh
         x2xVvu543gEwz9I1lW1fVWGD9dmXzIaZMcHcU80P1xcAquoFaojwNmXwf7cM5bmhbVyc
         uk5IHeDKpW+AAdBv7lun4cntkPUKH66uvzXPfaOl/uDtf349KILZJwJSuMKHJADVA0es
         pyjtVopY5lRHCEULesehfQNWJ4VSiCZUq4oCcUsa3WyNhZFDdymGJEN6u1kq5q/+W47E
         mIWVN6csgEa20PZy32nuci6/AET6/m7wY/8ZQ/RYKEyomBA8QjzaCgDutu2Iqn6iM+p0
         Tvuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hB+2voDSZQygDbqT+h65nNkGk3dewMMqXA8mUkVsWII=;
        b=dFOVPaaXn9JShAeBlZacJ0PCmIYQW1kRWvhsFa1VNH7LqII3wMMEuU6sVa/CPBr5r6
         GK9MHjb3jXQtSLE/E2ywW6FKafKm+kmm795r6GOdzbTX+xRu8OSyDvlaynHgFS5OEKva
         3wzzM/HwTnLQky2Ylr3/Y29M7Eye0opjl1x0D0bwVX9KsZY/nxOyUWhKJaq/x0ZVjAyv
         pKew9B36XSAAbm//SLREqrzgsVWeQ96hanU0j+9m8td+xTID8uMOFU1q7QArSSVDfGi8
         UMgmbktMWZ2FoBvvNXwvd9fzZGqYdG5hxY2aIMEhOFEmGIS13YkMmwsahDDKtkGfNilb
         vBWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u24si274399qte.394.2019.03.28.19.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 642703092649;
	Fri, 29 Mar 2019 02:17:52 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3BD9C83B17;
	Fri, 29 Mar 2019 02:17:51 +0000 (UTC)
Date: Thu, 28 Mar 2019 22:17:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 09/11] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem v2
Message-ID: <20190329021748.GH16680@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-10-jglisse@redhat.com>
 <20190328180425.GI31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328180425.GI31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 29 Mar 2019 02:17:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 11:04:26AM -0700, Ira Weiny wrote:
> On Mon, Mar 25, 2019 at 10:40:09AM -0400, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > HMM mirror is a device driver helpers to mirror range of virtual address.
> > It means that the process jobs running on the device can access the same
> > virtual address as the CPU threads of that process. This patch adds support
> > for mirroring mapping of file that are on a DAX block device (ie range of
> > virtual address that is an mmap of a file in a filesystem on a DAX block
> > device). There is no reason to not support such case when mirroring virtual
> > address on a device.
> > 
> > Note that unlike GUP code we do not take page reference hence when we
> > back-off we have nothing to undo.
> > 
> > Changes since v1:
> >     - improved commit message
> >     - squashed: Arnd Bergmann: fix unused variable warning in hmm_vma_walk_pud
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  mm/hmm.c | 132 ++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 file changed, 111 insertions(+), 21 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 64a33770813b..ce33151c6832 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -325,6 +325,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
> >  
> >  struct hmm_vma_walk {
> >  	struct hmm_range	*range;
> > +	struct dev_pagemap	*pgmap;
> >  	unsigned long		last;
> >  	bool			fault;
> >  	bool			block;
> > @@ -499,6 +500,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
> >  				range->flags[HMM_PFN_VALID];
> >  }
> >  
> > +static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
> > +{
> > +	if (!pud_present(pud))
> > +		return 0;
> > +	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
> > +				range->flags[HMM_PFN_WRITE] :
> > +				range->flags[HMM_PFN_VALID];
> > +}
> > +
> >  static int hmm_vma_handle_pmd(struct mm_walk *walk,
> >  			      unsigned long addr,
> >  			      unsigned long end,
> > @@ -520,8 +530,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
> >  		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> >  
> >  	pfn = pmd_pfn(pmd) + pte_index(addr);
> > -	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
> > +	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
> > +		if (pmd_devmap(pmd)) {
> > +			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
> > +					      hmm_vma_walk->pgmap);
> > +			if (unlikely(!hmm_vma_walk->pgmap))
> > +				return -EBUSY;
> > +		}
> >  		pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> > +	}
> > +	if (hmm_vma_walk->pgmap) {
> > +		put_dev_pagemap(hmm_vma_walk->pgmap);
> > +		hmm_vma_walk->pgmap = NULL;
> > +	}
> >  	hmm_vma_walk->last = end;
> >  	return 0;
> >  }
> > @@ -608,10 +629,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> >  	if (fault || write_fault)
> >  		goto fault;
> >  
> > +	if (pte_devmap(pte)) {
> > +		hmm_vma_walk->pgmap = get_dev_pagemap(pte_pfn(pte),
> > +					      hmm_vma_walk->pgmap);
> > +		if (unlikely(!hmm_vma_walk->pgmap))
> > +			return -EBUSY;
> > +	} else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte)) {
> > +		*pfn = range->values[HMM_PFN_SPECIAL];
> > +		return -EFAULT;
> > +	}
> > +
> >  	*pfn = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
> 
> 	<tag>
> 
> >  	return 0;
> >  
> >  fault:
> > +	if (hmm_vma_walk->pgmap) {
> > +		put_dev_pagemap(hmm_vma_walk->pgmap);
> > +		hmm_vma_walk->pgmap = NULL;
> > +	}
> >  	pte_unmap(ptep);
> >  	/* Fault any virtual address we were asked to fault */
> >  	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> > @@ -699,12 +734,83 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  			return r;
> >  		}
> >  	}
> > +	if (hmm_vma_walk->pgmap) {
> > +		put_dev_pagemap(hmm_vma_walk->pgmap);
> > +		hmm_vma_walk->pgmap = NULL;
> > +	}
> 
> 
> Why is this here and not in hmm_vma_handle_pte()?  Unless I'm just getting
> tired this is the corresponding put when hmm_vma_handle_pte() returns 0 above
> at <tag> above.

This is because get_dev_pagemap() optimize away the reference getting
if we already hold a reference on the correct dev_pagemap. So if we
were releasing the reference within hmm_vma_handle_pte() then we would
loose the get_dev_pagemap() optimization.

Cheers,
Jérôme

