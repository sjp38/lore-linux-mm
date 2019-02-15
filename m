Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95782C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:49:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 593032070D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:49:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 593032070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3A38E0002; Fri, 15 Feb 2019 04:49:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6C5C8E0001; Fri, 15 Feb 2019 04:49:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B35EF8E0002; Fri, 15 Feb 2019 04:49:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 571F68E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:49:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so3669373edp.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:49:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1y8dUmdcVzwv02OzP8lD00dl4iNtThamn79X5Lndggk=;
        b=hWiP5zQ5la5D5QoGKPJTDy2ZNm1/vzp3vyw8C2nJL+itd6OS1reSTDKwtoZmi95Izw
         Culm8yUbEKbRwRCBQCU5aSghoMccsq+p1zEnGZXWLfnFAVobvtLhHjMFHkjWgxci5Wlb
         gR8zH+IJbtrUBLTsaWT80zsZulHoQnzvgjwWsQTYyiuvuvOhChSaWIz9/re0noH5qB7w
         NtZPru/4Lwskk6TxZkqAVXasxyfJP6f6146GLuSFPUbLqImcO3yWPh1+L0FQSEHp+ZTU
         DAWezTLg2rPpXQMLjD9LDJQrByRkEAROwcBuouJioj95XAPbu8dRAVrMtQCl95elVHe2
         51UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuYDS2cBIprQE6qP9DlK07xqwb6/oZzd7MXCUBl7NqUkmoKROtkk
	LtQN9QjrU0+vas2oXf8MhjZxEKnIiRZq9OaSBYsEtQy2Fyih1TFgZmLxr9rUrjZbRzb8MiqgFaG
	6cqRCNTSAUsBqzJ/ctfWo3M01QuJZzEiq0SxqPkOrxXWhkj0TIzfHyMPHtTolnPxq3Q==
X-Received: by 2002:a50:c344:: with SMTP id q4mr6950102edb.250.1550224193900;
        Fri, 15 Feb 2019 01:49:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaetfTy2Aw/bu98/7f+jvq2NtzwAANVwFTK8wNxvp98mrAEboI71/2+K+NVgZdcvq7KydS1
X-Received: by 2002:a50:c344:: with SMTP id q4mr6950052edb.250.1550224193108;
        Fri, 15 Feb 2019 01:49:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550224193; cv=none;
        d=google.com; s=arc-20160816;
        b=qBRE7ZSuzhh+QivoAp5CwK4Uhy4vV3hnzRaVyNYIf4DhATDlD9/+mKCwi+lnbWHpRy
         wJ7otvCI64HpuMSOYQe+3Dhpso4VnGs1RDEI/0w78GHpyRdth8YPIsfH2epnzT9msQGB
         F7gIskUD/ILmNbCbAMhxK7jmQ3tZOdW0FTG8a74QpDCvpZOPyujQsDSzzAOL4TOoSs2x
         proD9uk7Vm5y0Tv1RgFzx23uLxJr4Jo8kDzfEu8NXFu/9vQSCuL9NnD/W1qLNSWPH9VA
         cmh3DiFffOgXOejg1G31KboEY1rKia/6ByaW/e3BKWws7wyW/RTJ36WPIQy+AaMpN9Pt
         66DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1y8dUmdcVzwv02OzP8lD00dl4iNtThamn79X5Lndggk=;
        b=bh/irsbjRmfPeWoNY/Xw/4j2Y2QMXe+mK+XQu+NFGaOVvnjf66r1bm49vZxawu62vG
         upzpG3h99O+6xnfI6tRHVhN2TMcWYTVnK4ujBb3dMWxjB+WDBVzO6tKXicLGcOclLDBZ
         1nGcZqMGB+bU7SkDsxQLdkAZvhaNU22I5A8onpMvRtl5x4mainsYJ8GP5c+S7XJ3gaEP
         CKwRw+av/MRuuO4wFjLDfL55hzRCZOHWUOEFTG/vWo9Mdm/H74r+577ahts1S3tFqQJF
         VC33hdG/I0guWyZRbQhHDEGNrtvWd0oXvQ0tMfRWXYGCSWErUwOBlpWHIFXheLxsnR8j
         0jJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i29si2341550ede.245.2019.02.15.01.49.52
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 01:49:53 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A3413A78;
	Fri, 15 Feb 2019 01:49:51 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A58523F557;
	Fri, 15 Feb 2019 01:49:49 -0800 (PST)
Date: Fri, 15 Feb 2019 09:49:47 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190215094945.GA100037@arrakis.emea.arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
 <20190213131710.GR12668@bombadil.infradead.org>
 <19b85484-e76b-3ef0-b013-49efa87917ae@arm.com>
 <20190214090628.GB9063@rapoport-lnx>
 <8dfa8273-b21d-5f6c-eb3e-7992c6863a07@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8dfa8273-b21d-5f6c-eb3e-7992c6863a07@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:41:16PM +0530, Anshuman Khandual wrote:
> On 02/14/2019 02:36 PM, Mike Rapoport wrote:
> > On Wed, Feb 13, 2019 at 07:23:18PM +0530, Anshuman Khandual wrote:
> >> On 02/13/2019 06:47 PM, Matthew Wilcox wrote:
> >>> On Wed, Feb 13, 2019 at 01:36:28PM +0530, Anshuman Khandual wrote:
> >>>> +#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
> >>>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> >>>> +{
> >>>> +	if (unlikely(vma->vm_flags & VM_EXEC))
> >>>> +		return pte_mkexec(entry);
> >>>> +	return entry;
> >>>> +}
> >>>> +#else
> >>>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> >>>> +{
> >>>> +	return entry;
> >>>> +}
> >>>> +#endif
> >>>
> >>>> +++ b/mm/memory.c
> >>>> @@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
> >>>>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> >>>>  	entry = pte_mkyoung(vmf->orig_pte);
> >>>>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> >>>> +	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
> >>>> +		entry = maybe_mkexec(entry, vma);
> >>>
> >>> I don't understand this bit.  We have a fault based on an instruction
> >>> fetch.  But we're only going to _maybe_ set the exec bit?  Why not call
> >>> pte_mkexec() unconditionally?
> >>
> >> Because the arch might not have subscribed to this in which case the fall
> >> back function does nothing and return the same entry. But in case this is
> >> enabled it also checks for VMA exec flag (VM_EXEC) before calling into
> >> pte_mkexec() something similar to existing maybe_mkwrite().
> > 
> > Than why not pass vmf->flags to maybe_mkexec() so that only arches
> > subscribed to this will have the check for 'flags & FAULT_FLAG_INSTRUCTION' ?
> 
> Right it can help remove couple of instructions from un-subscribing archs. 

If the arch does not enable CONFIG_ARCH_SUPPORTS_LAZY_EXEC, wouldn't the
compiler eliminate the FAULT_FLAG_INSTRUCTION check anyway? The current
maybe_mkexec() proposal here looks slightly nicer as it matches the
maybe_mkwrite() prototype.

-- 
Catalin

