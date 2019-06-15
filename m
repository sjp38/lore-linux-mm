Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5246C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A240B2184B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:17:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZGV0NCi9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A240B2184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F75D6B0006; Sat, 15 Jun 2019 10:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A85E8E0002; Sat, 15 Jun 2019 10:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB41E8E0001; Sat, 15 Jun 2019 10:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5AFD6B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:17:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so3304934pla.18
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RsiIOe9hz9lv0grh/5TETFa2K+PcFkUA7+fv86fOR5Y=;
        b=k43vJFaQnPv/8h+outizwwvFzsJQVf3qtCeikXkUaYSHmFMkCAkDbH5GLFuyTQejc1
         4VeTT/8rAkPFaHIW3oeul2M53VqJHea0hlwyeLIOSZxiNtAIX7Nk4uzLhMhexZEuLjsM
         3rHscSQ6x8L1ktHQReTJ5sz/pS16UeTbqIKD662EyTJF4g7xvpIbK3ZQPAw2OJ4jENxK
         XQCRBBsfagC0kScgQK7D2F9WFnN+2AJhVo2nq5kcPqj4cZnBC+U8jO08S3MJduI3hi2r
         ejVtrDQQsc7q/kXFRBZh+YTgf7ChQB5KFq/wgCkW8W7K9pgTLDa0PR7EqSFCI3yHH7C/
         qVPA==
X-Gm-Message-State: APjAAAXZTMVLGk+7lL29JoX3dgyaVxlZubZl6UqXYxA6dpZBsgoaZdTo
	9UDe2f8smrg+fLIi+DFjqrLkxkcLEtPN5rae7gZtDCciKa4OAezrdTjKy6C2PHpE5gRDFZ9tFSi
	kqYtyjS/7o4iBlQPgInChKjp3er4oEwMxgOmhqkKyf2ualB61WXW0VsODR3ELXnx4gw==
X-Received: by 2002:a65:56c2:: with SMTP id w2mr41726475pgs.49.1560608253329;
        Sat, 15 Jun 2019 07:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnvPaw3W5IAHyilsU/6Bnv3oeWctf+UDhzbVFZocLZHRS1j4EefCbiFHr5lWxLspCTJGBd
X-Received: by 2002:a65:56c2:: with SMTP id w2mr41726449pgs.49.1560608252708;
        Sat, 15 Jun 2019 07:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608252; cv=none;
        d=google.com; s=arc-20160816;
        b=uTX7MRE0Ic/CveqHFiWx5JOOE3L5DeiYZYKk+wzH23PURFuMgYslCozXwJb9zKi3HM
         UcDi/JMtgfYs7LKJs2mu3AxHIxBcdpKwS0Zbs5UEO5U6CGsTp1X5Z5E6BdLM5hoKwQAy
         fPGz40Nyz+FwMkQ8LgSpzNsWg+TGG+6q56Mjf8wC5FqWBy4+CDw079uk929qJuIifkSJ
         6fxdZ9T+rdS+Jnx3nj7Ky7BPMAclLwbalr2clZW2EtywV7M7fnBwRzby/cHwbGeqib/V
         enMcMc3JHtIt4vgAUZz7DvPAW1FIBwOYRJgkNd/WheJdTtnLXaKLFBqL6CWWtPje2CCB
         +s6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RsiIOe9hz9lv0grh/5TETFa2K+PcFkUA7+fv86fOR5Y=;
        b=IjBJAQ8PRiqjO1fdVeNYbWPAMdDSE0Mmp7WXfZXzSwJrpVTB7Nnilyk1LL16cfTQtC
         NGw7iFkucguYn716PiheLdtn240Pg07nZlqt5y3BJ5tfjY+w9c/CfoMVhEvX4m5zjMWj
         2fqDqk0ISdsNXxAAUkpvnXau+IyWCU4rJ6kK8qbso4js4f050/hErpAdn/ozLHtgKYFS
         sf75W/XrZmV76TRPlVyshGRoV9LttJDv/iQHGYn37ydbNN1tPlIB9tv/RWyCVbAG6VGW
         4L/NS1eCiR1/wFbEXxMlXJkSs++++zNjCJaRm8B4+YeH1UyFJv4KbJmx4UZl8p64dsag
         xELQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZGV0NCi9;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o6si5289163plh.197.2019.06.15.07.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:17:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZGV0NCi9;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RsiIOe9hz9lv0grh/5TETFa2K+PcFkUA7+fv86fOR5Y=; b=ZGV0NCi9ysO0XtRDFkLleOXhx
	Pytm+wwoUaqIyplTuPpzPx/Um5MRpO7oD21ESdm15ZuobrU5ByqxevsIgAb+esf98ncN5O3TO/gi5
	ngxJcin5B8yz8EStFibw7qlVy26TuST04itrGnYArJ0P8gvRWor6jkiZgOlB+tIDErzLL5J8u9E5G
	3B+q8ub4IIQvi1S4JxhxHCfMFg14viWDC3mbn+ho1Uuql4o+caakGrzhtD/njve0bkvHan7V4u1hb
	VHQQPTjV8xX35xtkkXqXRC6KHzFfG6KaCEfn4GZ5MW//F208juEbvZsLmv9LYpKHc8f3ys425dOWH
	Ta35tRB7Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Ul-0004Sq-0D; Sat, 15 Jun 2019 14:17:27 +0000
Date: Sat, 15 Jun 2019 07:17:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 09/12] mm/hmm: Poison hmm_range during unregister
Message-ID: <20190615141726.GI17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-10-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-10-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -	/* Sanity check this really should not happen. */
> -	if (hmm == NULL || range->end <= range->start)
> -		return;
> -
>  	mutex_lock(&hmm->lock);
>  	list_del_rcu(&range->list);
>  	mutex_unlock(&hmm->lock);
>  
>  	/* Drop reference taken by hmm_range_register() */
> -	range->valid = false;
>  	mmput(hmm->mm);
>  	hmm_put(hmm);
> -	range->hmm = NULL;
> +
> +	/*
> +	 * The range is now invalid and the ref on the hmm is dropped, so
> +         * poison the pointer.  Leave other fields in place, for the caller's
> +         * use.
> +         */
> +	range->valid = false;
> +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));

Formatting seems to be messed up.  But again I don't see the value
in the poisoning, just let normal linked list debugging do its work.
The other cleanups looks fine to me.

