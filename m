Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B571C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:09:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27A4C206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:09:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27A4C206A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B94526B0003; Tue, 10 Sep 2019 05:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B45D66B0006; Tue, 10 Sep 2019 05:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0CB96B0007; Tue, 10 Sep 2019 05:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 839B06B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:08:59 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 328A040D3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:08:59 +0000 (UTC)
X-FDA: 75918436398.11.van57_4e4f67ad62955
X-HE-Tag: van57_4e4f67ad62955
X-Filterd-Recvd-Size: 2313
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:08:58 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E559228;
	Tue, 10 Sep 2019 02:08:56 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B684C3F67D;
	Tue, 10 Sep 2019 02:08:53 -0700 (PDT)
Date: Tue, 10 Sep 2019 10:08:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia He <justin.he@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Airlie <airlied@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Message-ID: <20190910090845.GD14442@C02TF0J2HF1T.local>
References: <20190906135747.211836-1-justin.he@arm.com>
 <20190909212712.GE29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909212712.GE29434@bombadil.infradead.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 02:27:12PM -0700, Matthew Wilcox wrote:
> On Fri, Sep 06, 2019 at 09:57:47PM +0800, Jia He wrote:
> > +		if (!pte_young(vmf->orig_pte)) {
> > +			entry = pte_mkyoung(vmf->orig_pte);
> > +			if (ptep_set_access_flags(vmf->vma, vmf->address,
> > +				vmf->pte, entry, 0))
> > +				update_mmu_cache(vmf->vma, vmf->address,
> > +						vmf->pte);
> > +		}
> > +
> 
> Oh, btw, why call update_mmu_cache() here?  All you've done is changed
> the 'accessed' bit.  What is any architecture supposed to do in response
> to this?

For arm64 and x86 that's a no-op but an architecture with software TLBs
may preload them to avoid a subsequent fault on access after the pte was
made young.

-- 
Catalin

