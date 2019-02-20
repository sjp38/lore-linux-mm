Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8876AC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40C9E2147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:59:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mvd53L3S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40C9E2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB70B8E0031; Wed, 20 Feb 2019 15:59:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8BC28E0002; Wed, 20 Feb 2019 15:59:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D6A8E0031; Wed, 20 Feb 2019 15:59:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7846B8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:59:38 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id j132so17678282pgc.15
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:59:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=505CT9UNmxyARcL8WDsjWWFZGxSMsAWXHGodR+SfaFU=;
        b=PkebmFDvNRGyYjTl8Gv/6wP7fmfn7b8gaPaG87rm/2w3KFr3dEViAIgOnaEBOR4hPl
         hLzqj0kFFqp7bysifpl8E/s8OYmpvp6hx3YFVhjT7hdnh/RkE8/rTnYy+T04KlYcL9AC
         cZGcIYrZqTFrJ1POW7ceKwYnSgAtHRgjYu8mSzhwSWXLU6sD4DqouraQXjhbMsjf+2QT
         0IdsdslTKVkUxNxxDAX+GqOfz02sxqSXNe20QZFq1ANy0+6RaxTi8GxBXdzJALDGTpO/
         gKbsCCtBwaiVDBpQtQDHxYDuZyuHhTcMxFrhBwvl0M9b/IjZYhBRuvXq/g2N6+0E5pTe
         wTCQ==
X-Gm-Message-State: AHQUAuaDCNoUHr932KHMyObPfYdxI0EXvaZrSRRZ2qQLks4aFt+ICSFj
	iv1o01ZWsz551pzhM+0v8j8PdwVt2AuPa/MRbG2QCJROjECemGDHw7HF+Ee+3Ha50mIop26rb57
	QcbtyiTca5NdALwVWNubmKzoFpAXUHNCWNhSeGEhfS5pb9USJJrIUAgeH4ikzT6iVqw==
X-Received: by 2002:a63:545:: with SMTP id 66mr30567575pgf.102.1550696378075;
        Wed, 20 Feb 2019 12:59:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0NWntQMxko3hFAKsE3WwC+d+j1R38wFbiEM+Ht1PVMFsqw9mhSas2ly6sqjqMLlJ9taz8
X-Received: by 2002:a63:545:: with SMTP id 66mr30567537pgf.102.1550696377188;
        Wed, 20 Feb 2019 12:59:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550696377; cv=none;
        d=google.com; s=arc-20160816;
        b=B5MUNAtFfuCpKkWt8gY2htyTIwo84G+Tv5rZwOLjSGQHnQHTrCsIdd3/I+E4VtK+yr
         BdavVtLmIjXv69E1iMhotqSgt/QrAArBsADpyjFEAxV1r1txtB4yBkgca75qT/LvaMpH
         yrvNsl+7EUgZN/Fb0k8YqsnC15L/Ow14B5pqUvK27csG29qZh0doE62kxFewvO4R2Nq/
         pG5ZadNu9OAKTqc2sHurhWofiCNpl71QJ72nsuYkzmevrvR/RMVi1ZRw/80145vwGDbL
         LQYJv+oHNCytz1YZteBuTXydu2Pf070dJ4qcM8pHmjviM+mSKidbgjVRYj1nXTC5DLwh
         JtGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=505CT9UNmxyARcL8WDsjWWFZGxSMsAWXHGodR+SfaFU=;
        b=OSPt4jjY43/2ROANztdUq/md64mUWhp/EivuG7hhBR/Ic0PpzrQGagNu09LSITaglr
         fFpCAyVsbYhXc8Pk4i9kFUYmfRyH9j+tE8UXDRu7EJCIF4aVe1se8NHJnsY0yejtzW4Y
         BF1tLFjnVXIIN3dkHaM3gqDq4XoFQQ4/jkYsjuYdx0X8LYCa6KNPnUCxcKBiP/QttvJa
         +uldXya6PCsHN/GVD/G6ymbMFenbqD1o10YoRYugHWNsNXmGhf6CvBWIdN1jbtHm09G9
         0aFpTnVZtVzGbpr4oU6EhbHHmnQ0MGBcznSCfInzLOfLpDoNzDx8qskFJbwuSiS3ccWH
         B7cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mvd53L3S;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1si18359977pfm.264.2019.02.20.12.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 12:59:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mvd53L3S;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=505CT9UNmxyARcL8WDsjWWFZGxSMsAWXHGodR+SfaFU=; b=mvd53L3SwTot4baVjZ7KafeGd
	MLeivB6+Fcx1ohUT8HV5k7jKY2wRrPFdkNN8xC6iiVH4XtlhUC4VYee0diAXvOoLEy1IUQCiBrR5C
	nHaTdwPVPJ3ifyZ/f7pWmI7J51bRK+wcRLEFVNRjmqo+ZRmw4i6uL9oF7kGFxLJa5zUITjEvV2lUq
	OwjZz+QUNpLIVhH7AyHrXkPn7yzkLTJp7/ct5699s5Lmb+7dlnIdSL4f7BVwVMk4oQ28Kcr4oYaFs
	zMt3jZFZXhvamkPIrKpOUvT8EI2h1hPbfPphdtdsLhUxyF1lXp0Na2UfN0kzOhvdO/E1+RwSiuTVv
	mtyh1dtNA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwYxm-00036R-7C; Wed, 20 Feb 2019 20:59:30 +0000
Date: Wed, 20 Feb 2019 12:59:30 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190220205930.GL12668@bombadil.infradead.org>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
 <20190219222828.GA68281@google.com>
 <f7e4db43-b836-4ac2-1aea-922be585d8b1@arm.com>
 <20190220202244.GA80497@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220202244.GA80497@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 01:22:44PM -0700, Yu Zhao wrote:
> On Wed, Feb 20, 2019 at 03:57:59PM +0530, Anshuman Khandual wrote:
> > Using pgtable_pmd_page_ctor() during PMD level pgtable page allocation
> > as suggested in the patch breaks pmd_alloc_one() changes as per the
> > previous proposal. Hence we all would need some agreement here.
> > 
> > https://www.spinics.net/lists/arm-kernel/msg701960.html
> 
> A proposal that requires all page tables to go through a same set of
> ctors on all archs is not only inefficient (for kernel page tables)
> but also infeasible (for arches use kmem for page tables). I've
> explained this clearly.
> 
> The generalized page table functions must recognize the differences
> on different levels and between user and kernel page tables, and
> provide unified api that is capable of handling the differences.

The two architectures I'm aware of (s390 and power) which use sub-page
allocations for page tables do so by allocating entire pages and then
implementing their own allocators.  It shouldn't be a huge problem to
use a ctor for the pages.  We can probably even implement a dtor for them.

Oh, another corner-case I've just remembered is x86-32's PAE with four
8-byte entries in the PGD.  That should also go away and be replaced
with a shared implementation of sub-page allocations which can also be
marked as PageTable.

Ideally PTEs, PMDs, etc, etc would all be accounted to the individual
processes causing them to be allocated.  This isn't really feasible
with the x86 PGD; by definition there's only one per process.  I'm OK
with failing to account this 32-byte allocation to the task though.
So maybe the pgd_cache can remain separate from the hypothetical unified
ppc/s390 code.

