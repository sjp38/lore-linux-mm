Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64990C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED772086A
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:31:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED772086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD3666B0003; Fri,  2 Aug 2019 06:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B84EB6B0005; Fri,  2 Aug 2019 06:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A71F76B0006; Fri,  2 Aug 2019 06:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 862806B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:31:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x17so64153327qkf.14
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C0jTOdf0QLG91vRfjt/3kL9HwySWh5510tuu5CRfXFw=;
        b=MUfn4PpT3HpXCZfw1dqejKVJz9W6O5BCF2mBVDgvWTkucpnmMQXfioDmyZrS2YzKnI
         Y9fPl2e9/wqI56InG0HbYzLLP9BTzgSZ44J8QwApfFpN3QW0z4A9y7rzc6hVSAzoufrI
         X7MGRsECcuQoo/qbCe5Hk3YqD23qn1U4w/Pj3jOVivePOSTN4admNhTkDXPEL3yQih9Q
         7gkrMgXG/V8wyQYNp9p1D+GUq0Fyn1Ct1ygMLRdKW4+lJlJ0lOi0Ew7Lzq3d9yNCaChN
         lZwx3+5Qss0zAp4g/7ktKMb3+3hjL6yr7kDDqA6rBPrpO40PXqlaWJE8YFUiPVvZA0xQ
         hbpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWxltLc0jxc/ue5qBVZoHuwi0Whw3l2729MVUh475sdzLz6LD2X
	sXajnpMr3JHdzxTISBL3fSmnBlCRS3cP8f/TiyGc1YJAglRQ4/DjfeZXTPGs7jk11Ip2I5S/GWA
	CfukTm/Q/4ViUI+B2H0GbU8JHSbtmCHRIxrUSj+2UKIqyvN4N9efyiNGuTjqs3gV6FQ==
X-Received: by 2002:a37:a692:: with SMTP id p140mr87537127qke.432.1564741877324;
        Fri, 02 Aug 2019 03:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaGRm4GTXQBacT2EAlui1tkrArfL4d7L4VTADI2o8v68Okemh1QitSTOIMhFe3SowlSg+0
X-Received: by 2002:a37:a692:: with SMTP id p140mr87537085qke.432.1564741876678;
        Fri, 02 Aug 2019 03:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564741876; cv=none;
        d=google.com; s=arc-20160816;
        b=a7AHa/d37XJ9M9Dc3p4xaKVpVv9LCgXFpBrthEMO3OoYBQG+A6BoKOByqXkRtOBWVu
         swRyfCDNFHQbvZj6bwf+p53uvQwLFAuW3sA9JWYEQeaTtvZxF3olgJNS7Pdr3qkgB16o
         dXZMoaygOOF6cE2rE6oZEqjtxo+oJDc1hF1rp+9HolMrQ19ipVje5Qidmg9pPdtzHz15
         SPq8x1Shh8qqQssNa9/kXWbcJxOdJ6QmGuW2ZHAhtuag26LyI+1eJ0KmKfrGPHOVn9zH
         4q5ipKB95tXiCDNWCQEumWo6cf9tWAyo3ENYqXFtTqSLkH66acLO/1ba29ESVGxWSHmT
         nBkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C0jTOdf0QLG91vRfjt/3kL9HwySWh5510tuu5CRfXFw=;
        b=lbYAsgipSDUC+ugBmWbzZJZG5ZR/H8Mp+RBBsIlm5Fd+xNMntqrOAG66z1CorYXygZ
         wb7Y8YUxcrOFIzMz34/Idh9UQiZ/ZUS3KvLf9fQL220wD9OMFXQ+S4PBu+zeL665YS6E
         dUbZr3FGpsnA9QCvBeT15wayROZ2N4pvai0m/g8wvqoveoIAL6bj2lpW6sLHhDWhwl6X
         LzW+GtqzXBb9TTF77MNGxMQSfKxQ6PajIIxVzk57tlR1NoFfEu/IuARCRn+s5CHXveHf
         HR5iHkHQ+d6DOGa4A6bS1RZmZWuMfJ2pr/n57rhS046en6u4sw07t717VjI/+stC5Sxd
         tXHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o131si44509692qke.127.2019.08.02.03.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 03:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D090981F07;
	Fri,  2 Aug 2019 10:31:15 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 043E860925;
	Fri,  2 Aug 2019 10:31:13 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri,  2 Aug 2019 12:31:15 +0200 (CEST)
Date: Fri, 2 Aug 2019 12:31:13 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190802103112.GA20111@redhat.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
 <20190801145032.GB31538@redhat.com>
 <36D3C0F0-17CE-42B9-9661-B376D608FA7D@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36D3C0F0-17CE-42B9-9661-B376D608FA7D@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 02 Aug 2019 10:31:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/01, Song Liu wrote:
>
>
> > On Aug 1, 2019, at 7:50 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > On 07/31, Song Liu wrote:
> >>
> >> +static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
> >> +					 unsigned long addr)
> >> +{
> >> +	struct mm_slot *mm_slot;
> >> +	int ret = 0;
> >> +
> >> +	/* hold mmap_sem for khugepaged_test_exit() */
> >> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> >> +	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
> >> +
> >> +	if (unlikely(khugepaged_test_exit(mm)))
> >> +		return 0;
> >> +
> >> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
> >> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
> >> +		ret = __khugepaged_enter(mm);
> >> +		if (ret)
> >> +			return ret;
> >> +	}
> >
> > could you explain why do we need mm->mmap_sem, khugepaged_test_exit() check
> > and __khugepaged_enter() ?
>
> If the mm doesn't have a mm_slot, we would like to create one here (by
> calling __khugepaged_enter()).

I can be easily wrong, I never read this code before, but this doesn't
look correct.

Firstly, mm->mmap_sem cam ONLY help if a) the task already has mm_slot
and b) this mm_slot is khugepaged_scan.mm_slot. Otherwise khugepaged_exit()
won't take mmap_sem for writing and thus we can't rely on test_exit().

and this means that down_read(mmap_sem) before khugepaged_add_pte_mapped_thp()
is pointless and can't help; this mm was found by vma_interval_tree_foreach().

so __khugepaged_enter() can race with khugepaged_exit() and this is wrong
in any case.

> This happens when the THP is created by another mm, or by tmpfs with
> "huge=always"; and then page table of this mm got split by split_huge_pmd().
> With current kernel, this happens when we attach/detach uprobe to a file
> in tmpfs with huge=always.

Well. In this particular case khugepaged_enter() was likely already called
by shmem_mmap() or khugepaged_enter_vma_merge(), or madvise.

(in fact I think do_set_pmd() or shmem_fault() should call _enter() too,
 like do_huge_pmd_anonymous_page() does, but this is another story).


And I forgot to mention... I don't understand why
khugepaged_collapse_pte_mapped_thps() has to be called with khugepaged_mm_lock.

Oleg.

