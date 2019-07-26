Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74D42C41514
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 19:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39585218B8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 19:55:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qLaE1wkK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39585218B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B060B8E0005; Fri, 26 Jul 2019 15:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8FD8E0002; Fri, 26 Jul 2019 15:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A6378E0005; Fri, 26 Jul 2019 15:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66CB18E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:55:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so26761955pgv.0
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Jbv0LbZynJFOQcTJN5oGebnbSqk/idAThN/ynHRXZp8=;
        b=EpTN2XAMJIVrMDtGL3lY8V5i/QOlCDAd2d2I3FiGGRNWVy5xSiSwhrsl6WFrdC8ZSh
         enMTCSuinrkpMRCsTmGn7BJNcc4+7FYzaFFjqBZ23WDr3SJfH+hG7cWQMz9XoLgT73/h
         7HbwtSGXKiqk40yyjS3fJiSDqwqIKmMGcspAtaJbmiWSqTAdVWFpbbd74q5d22MSaN54
         MrPSC8hlg2q26GAIVFACmWDIMdsGCLVOjB7UBFTIZ2v/8yhltsGsy30fyAZfvwxqHvwy
         CphtgIFf+feRCgKdkncxDjH4dj5NDqRvq4LBMr3yD6Mlr3epL9iBj2k/uu4lEyHdIgsT
         icjg==
X-Gm-Message-State: APjAAAVeoQ8NKj+c7HyGagB6xv1Gw5DqbWImgIeR+cJU8svHeGM5EjNO
	NEh+w57vwHsrGm+2p46fFhCJlhyUdANZbhGS9AiQyqGIxljF0lLhll9pBwNbxK1cmIT1Q19RwGh
	TxXX1PSTQXUiGg8EyIeZo4quzrDYN4wAdRgU/9xXsQptQ+HNUpKqjkwRA/8uoBj0hOw==
X-Received: by 2002:a63:5945:: with SMTP id j5mr92488864pgm.452.1564170900995;
        Fri, 26 Jul 2019 12:55:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqlOY8Kx3QL0BrmRE6GVaJKPTW0DxvraZ4YsmDP5p7NncnrnsMeHLL+Hzwv6NUjiU92/eA
X-Received: by 2002:a63:5945:: with SMTP id j5mr92488822pgm.452.1564170900187;
        Fri, 26 Jul 2019 12:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564170900; cv=none;
        d=google.com; s=arc-20160816;
        b=DH7Cui616Ro3dwardwZr7nwHYkV72As3V5stBsnDmWD1RlZnVOFphtyGeOIYkkV/2e
         Yh65/5NQM9HifrJBC4fFGUCE3L9bjzDmvg67ABf50LDLiuLjG27qIQl3gV0vrylYC9P+
         W/3HB4d5A/ORe30nqwY3oC+X9lVTUUDvpTRkEABJD+u8Tt0YcFvGdAnDLgL6a0p5Rp5t
         Z05/8/vdoJFNf9KbVza3WeI7zlxY4E1uRD60fPL4CLgRwRhzek+H9qRdlMoReGPnzdyN
         96FwnEpdHcMlYdJTuPQQIw8TPr5whA8RkBjzYjqTwj+2W/oRVl7wjx8MCSya00H9/Qc8
         ANwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Jbv0LbZynJFOQcTJN5oGebnbSqk/idAThN/ynHRXZp8=;
        b=YPmKyZ+Spjmxt6sFiT45PbisNtJKskZFs6mfIY/MbOVFCQLg/36cECm+RfBrzIl7T2
         N5Ov0p8uzwzapjGV5p0wzFnhy1QryAnfno4vRAFthPoTxRAnXQDHAA+yUFLrVuXigbrD
         ISArN5q3aIOhfzdWa5aFgFmbkb1Zr0jj04Vc+PbwTixlM9Px3rqTdGXb+DP+B2JT3jNu
         SZ3GM2E7u8UXZVG1fUUn93dSUBw9x34kaIJjFWa+pPK9nXgUJs4vgSyDMXxGQh9sEZuD
         hkV9z+SzBpIo6E6HWHttc/gkIoJ/ebmE5n5oKisAs1ohsRAWIbAE7CXnBdWEM3pcaYWG
         PR+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qLaE1wkK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1si23391583plp.264.2019.07.26.12.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 12:55:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qLaE1wkK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Jbv0LbZynJFOQcTJN5oGebnbSqk/idAThN/ynHRXZp8=; b=qLaE1wkKgoy7MM+GpS8n4h0G5
	ore0CpfVTIbcdEbcRmCa3upn43Xm+UHEcbYtITzvkm+EW5hIfq1Vkb4nLIvE1cbnvqtSp3poIxCwo
	Z2e7Qsak865u/eh3Yug9ba7yjlnjT7jbooxL03UhvtaENYgbBDfeBxNn7xs++60Pbll5RIqAzZAtH
	9PHtgtW9psv9Sqlz05XEV7HAfHOqSzG2R0ZGzfs4G1mjtBgBB29R+rwCVdhfIkLeKQNMAjYpdTWry
	11Nicdi23ixiLKeLhOIAXCwfF6d2yqDdDSUDgD1LRimA9qyYq9uzv9aukemW6TAcgADgf6BU/zBrR
	miBBXLelQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hr6Ir-00045T-GC; Fri, 26 Jul 2019 19:54:57 +0000
Date: Fri, 26 Jul 2019 12:54:57 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190726195457.GI30641@bombadil.infradead.org>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <c3bb0420-584c-de3b-2439-8702bc09595e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3bb0420-584c-de3b-2439-8702bc09595e@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 10:17:11AM +0530, Anshuman Khandual wrote:
> > But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> > architectures doing the right thing if asked to make a PMD for a randomly
> > aligned page.
> > 
> > How about finding the physical address of something like kernel_init(),
> 
> Physical address corresponding to the symbol in the kernel text segment ?

Yes.  We need the address of something that's definitely memory.
The stack might be in vmalloc space.  We can't allocate memory from the
allocator that's PUD-aligned.  This seems like a reasonable approximation
to something that might work.

> > and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
> 
> So I guess this will help us use pte/pmd/pud/p4d/pgd entries from a real and
> present mapping rather then making them up for test purpose. Although we are
> not creating real page tables here just wondering if this could some how
> affect these real mapping in anyway from some accessors. The current proposal
> stays clear from anything real - allocates, evaluates and releases.

I think that's a mistake.  As Russell said, the ARM p*d manipulation
functions expect to operate on tables, not on individual entries
constructed on the stack.

So I think the right thing to do here is allocate an mm, then do the
pgd_alloc / p4d_alloc / pud_alloc / pmd_alloc / pte_alloc() steps giving
you real page tables that you can manipulate.

Then destroy them, of course.  And don't access through them.

> >> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> >> +static void pud_basic_tests(void)
> > 
> > Is this the right ifdef?
> 
> IIUC THP at PUD is where the pud_t entries are directly operated upon and the
> corresponding accessors are present only when HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> is enabled. Am I missing something here ?

Maybe I am.  I thought we could end up operating on PUDs for kernel mappings,
even without transparent hugepages turned on.

