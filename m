Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BECA5C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79B1021848
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A7X2mxpn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79B1021848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 141496B0003; Sat, 15 Jun 2019 10:25:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1388E0002; Sat, 15 Jun 2019 10:25:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008208E0001; Sat, 15 Jun 2019 10:25:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD126B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:25:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so3763767pfk.14
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:25:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SdWUCWylJzhzeM8QVNQHKHRjscfikWmZIAkgaxj+0Bw=;
        b=kvdc1QAfRPxSXF/mmFvFRiFgXlxWTqajOXSl/8nE6F2w301Zz6YL07xrnnU4/Mnrt6
         0w2OwqPtmaqrh/3Giw+93SFfiokb7JMAGzRHPZKnDgvVCRP0BmKri1X9vhY1tGvzppKe
         ispOLhL+eBvm214IXtdChn9bEcSVeu5Dlc8Ln4IE2a1KOad7VzRchY+fC7Vt7OvW2B2W
         MSdqWOzAHTxXIopTkkbQop7uv32IdmjaQ3mKHqfX3zbyc9frOsB5sKUAgnQdoH4djAUM
         ZPwIWGNnvhVJLprIfyBSCgbzsrP7BrC+rewRiuq+wgNFJd+j+fqJlfsTR6EwuB4OJgMQ
         BcMw==
X-Gm-Message-State: APjAAAUGd6MD1c5BEjAt5mE9y+U9jS4z6InCKAN4n+9YkgFaGIXwWPSI
	tkUpG3iPPstkbXQ6i9ZybXm3MMwAWdxH38j9qpE4nUaws8I+UbL2yAbdcc1JT7JuuTU9mEETqBw
	h8BbFYJucT2yMr5+b59LHcxnRi90A8vpGMwFnDXDWR2IA2IuJEbgBGxGTtSO3cL91SQ==
X-Received: by 2002:a17:902:61:: with SMTP id 88mr20668280pla.50.1560608722443;
        Sat, 15 Jun 2019 07:25:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWIO+nOQ3ATNLmgg0Ea55g8fsFDN2mtLvkVmzzSA82ZFO+QQQQxg+jSMFMw25RNUYAUUuj
X-Received: by 2002:a17:902:61:: with SMTP id 88mr20668232pla.50.1560608721713;
        Sat, 15 Jun 2019 07:25:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608721; cv=none;
        d=google.com; s=arc-20160816;
        b=LLcBngrw4raAAP4GW8Et2znGY9l9XAKR4g35TT7F88zFfw+Ha+RKG+sk9PQ/6HLgXt
         E+RXdOBOgmVaCm8VtX6hmyTD08G4Ey7zUapV4QUY/dusLfVobY6vkKW2dsXu4pgOB88j
         r2MKe4QEiRFVhqlXKz1wEb9rujC+73Ii6fMle4btrO3apqDoMgUpXWMMSPFdFZl0ls06
         9/6JDGNoY1U3U0sRm+Nm8QR2sp7i85k9UBsFdvdYsQvyk7TEqg5rwNpG4Ag8CVLlH8b6
         L3MWSxoETnAARzpS3dy56uWPJ6vF823dKBNbkea9b6jx7wogDHkE42TYOgXnoZVOiibA
         YGGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SdWUCWylJzhzeM8QVNQHKHRjscfikWmZIAkgaxj+0Bw=;
        b=bFG0q2fe7cpfhJouPf8t46jAiVlafTeUjhIZrU7b598+PZrI4lZhk7CeQ8cgSQpPQa
         26MJwlbx3nwgVXqpW+V517jRo7DZVFmuR38CvmG6yKqG4bGdlSchBCTT8GKh7jI8DEAr
         bbyvnKqvjuM1VAvr7c5Iu6MAfViIgsb4uS7HDHwGXs/H8n0fFrF73kYzTX8LC5Nqgt0V
         5xmqoMP1E0O1KKiA6Wmrejkmqu9ozcdeVYTzA1gQtK4UFgUprKQiTbU3E1T4oePy7Vck
         379hQEd87wcQEzAI2xfc+sJpHjY3vhNJ/wY57NYjRrnJWNgZIbHp6dSXH3KpGPgf4NNN
         J8rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A7X2mxpn;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q14si4995374pgi.16.2019.06.15.07.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:25:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A7X2mxpn;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SdWUCWylJzhzeM8QVNQHKHRjscfikWmZIAkgaxj+0Bw=; b=A7X2mxpnfBOFX0A60aP25q3n/
	szKd4gAVZwsTrlyaIQc5xR24lEmlvmqS83JEsqzjL+AHehjxvbX9tH+sGx5b+/T/POdhFT1Xy7EQd
	z9W2915h22nOnp+4mPxdGJjQST174K6/01OPoe8ioZOArCSmBX24iHJLukWtBCN5yrp7lgnCtL/If
	1mfw9bWonbn4DfHzMmLdRA3xr91p9DvtZSE0qrB2lAlkJ5w/EDdE8D0zcUjdAQSONzDYM6FcFPb/k
	YM/tCltM51daIP24UNpmoh0cZpWskqznE35632yXKH+R+QmO89o+nzwUgq0GJ1pb7OrMAPqMpErU/
	dFBGPBDoQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9cG-0008Br-TX; Sat, 15 Jun 2019 14:25:12 +0000
Date: Sat, 15 Jun 2019 07:25:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 12/12] mm/hmm: Fix error flows in
 hmm_invalidate_range_start
Message-ID: <20190615142512.GL17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-13-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-13-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:44:50PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> If the trylock on the hmm->mirrors_sem fails the function will return
> without decrementing the notifiers that were previously incremented. Since
> the caller will not call invalidate_range_end() on EAGAIN this will result
> in notifiers becoming permanently incremented and deadlock.
> 
> If the sync_cpu_device_pagetables() required blocking the function will
> not return EAGAIN even though the device continues to touch the
> pages. This is a violation of the mmu notifier contract.
> 
> Switch, and rename, the ranges_lock to a spin lock so we can reliably
> obtain it without blocking during error unwind.
> 
> The error unwind is necessary since the notifiers count must be held
> incremented across the call to sync_cpu_device_pagetables() as we cannot
> allow the range to become marked valid by a parallel
> invalidate_start/end() pair while doing sync_cpu_device_pagetables().
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Tested-by: Philip Yang <Philip.Yang@amd.com>
> ---
>  include/linux/hmm.h |  2 +-
>  mm/hmm.c            | 77 +++++++++++++++++++++++++++------------------
>  2 files changed, 48 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index bf013e96525771..0fa8ea34ccef6d 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -86,7 +86,7 @@
>  struct hmm {
>  	struct mm_struct	*mm;
>  	struct kref		kref;
> -	struct mutex		lock;
> +	spinlock_t		ranges_lock;
>  	struct list_head	ranges;
>  	struct list_head	mirrors;
>  	struct mmu_notifier	mmu_notifier;
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c0d43302fd6b2f..1172a4f0206963 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -67,7 +67,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	init_rwsem(&hmm->mirrors_sem);
>  	hmm->mmu_notifier.ops = NULL;
>  	INIT_LIST_HEAD(&hmm->ranges);
> -	mutex_init(&hmm->lock);
> +	spin_lock_init(&hmm->ranges_lock);
>  	kref_init(&hmm->kref);
>  	hmm->notifiers = 0;
>  	hmm->mm = mm;
> @@ -124,18 +124,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
> +	unsigned long flags;
>  
>  	/* Bail out if hmm is in the process of being freed */
>  	if (!kref_get_unless_zero(&hmm->kref))
>  		return;
>  
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>  	/*
>  	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
>  	 * prevented as long as a range exists.
>  	 */
>  	WARN_ON(!list_empty(&hmm->ranges));
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>  
>  	down_read(&hmm->mirrors_sem);
>  	list_for_each_entry(mirror, &hmm->mirrors, list) {
> @@ -151,6 +152,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  	hmm_put(hmm);
>  }
>  
> +static void notifiers_decrement(struct hmm *hmm)
> +{
> +	lockdep_assert_held(&hmm->ranges_lock);
> +
> +	hmm->notifiers--;
> +	if (!hmm->notifiers) {

Nitpick, when doing dec and test or inc and test ops I find it much
easier to read if they are merged into one line, i.e.

	if (!--hmm->notifiers) {

Otherwise this looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>

