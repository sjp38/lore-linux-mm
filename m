Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97E6DC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:03:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F75D206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:03:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A3pdiP1Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F75D206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC8106B0003; Wed, 19 Jun 2019 08:03:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51C78E0002; Wed, 19 Jun 2019 08:03:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCABD8E0001; Wed, 19 Jun 2019 08:03:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6CF6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:03:55 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so11559475pfk.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:03:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rpMV7cbut4s+IQIkL5i+Lot01IcGhFHyq5nHVaZpyng=;
        b=IK9giDZQVRYlTl+4A5gWp2xqBqRDAGxXF+ZnZtbn72GWd5/SDfLfDO9LwxzJpQQnaB
         vPgAZQbFSStFzy6dYKXkwweBtv/mKlN59lIwAi3mXE8i0MHWnsM79f/3cn4/JW5BylBd
         rq/VlLuFm2LGmSaLAYdGcY+Klj+fw7/uxIILWuYK1R2gSDES6aHk6ZwwbSG5CSVfm0Kx
         O7eCEmowBP4kId7cbm6/M8ggQEkXSyM1A294cMRZXUaDBtpX6Jf6dQAdbUEA+psOg6If
         To1J56wuJ8tetwQ2vouDo8eZSlp7LylzNbqZOKdby5gbKgBybpS+yWNi9eRtA4JmsVIx
         XpkA==
X-Gm-Message-State: APjAAAUbHkYOchHO89rgnncK6BLrgOXmXQwWTrOaWB1o6bMXtpver2pK
	AMpYQODZa8Ae/LchypLnvzTB60l96uYYTBW8tX84n5ckX6R7tH0bIrw46F2oIx2J+Yd3FHil5LV
	depjiAMa9J+QwcIeTWybrwxgMECWGWDRAB9RlSc57IxZgokg6dRBrXGFIWmonwxinyg==
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr94871926plr.74.1560945835136;
        Wed, 19 Jun 2019 05:03:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySkC7tlrmNyGqgLkAL4EH6FUUTbVyv8LYGxsNyETcHQZlAZmw6SubaBlH1RdiJ5HVnwiKl
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr94871889plr.74.1560945834475;
        Wed, 19 Jun 2019 05:03:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560945834; cv=none;
        d=google.com; s=arc-20160816;
        b=Vkce3PMBKT/azDoSi+uOCMlgAjnk8c0nJbUbZU7dodhau1ujdfFb7gA7sJPWxpF4Pe
         WDkfGK4pZZcAqO74Y4MLAhC+qSkCZwzmzLC+sgZJ4Ji7bWqUSsOKjjlGh2l8nX+IYR5x
         Fdrz1TD7X06qAFs9Y594OrNjr3JF/oAmEvkDxZDxImmc7Sk+RIhmfYXlCTVTR/xj/l8H
         AKGtLkn+V8IsYR+ORhgoNhYdS+j+xZYiobX1KeeVpx9Z6wcnVmNKQdQO78i4VN77rVsh
         ObIoXL57KO6xj4hpulCLjgDQRsCe9Po0Yt9IDltUpJxNaCtuEigFl8EE8JxeC4oBtfdb
         yHRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rpMV7cbut4s+IQIkL5i+Lot01IcGhFHyq5nHVaZpyng=;
        b=dr70pj1FZBrCgIYAJIxw3WE9rqM+q0NqZh4Ln9DoGX9lU6XlqqLmMxE1vYYjsfoBR0
         gtaN3JFoiP5fqzOrzLz7pkuf3CtvuzkwQgyEigIbJ44qtCgMi8zKDJ2+SBNmJUTflzIL
         bmsHJOyozgTqhRAlmpGtIlSKHSP3uG2tqQJbJwI0VytDa4kkA9HykrHWc6xpw83bOG39
         l8qGyvd06dOcsT+HxFG9d+s7jZeVl1Mdr4kg5kGMnlB8/yiIBC8JMSfkQ4uW8QcU/aP9
         OPPOHDKaBQT7tp+Vsd+KlVkGLjWBH8G+BsHbOVas0dtUa+InUb5rMjwI+nF1C9fhu4WF
         XNGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A3pdiP1Q;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1si15524900pld.6.2019.06.19.05.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 05:03:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A3pdiP1Q;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rpMV7cbut4s+IQIkL5i+Lot01IcGhFHyq5nHVaZpyng=; b=A3pdiP1QbGW7j1ii05qxyfW2d
	z2qWT3JMlbvwTaaGM6TU/h2nYOMIvaXje6Q6y4HsvNBZc0iGHnfDo+NQ+G0p6dmIxFeBGpgH6qk94
	Qz8DrSDN+V1whr/dlswoX96DK23SXFL9fT7XsSjbiwXmAy95IK66enm+Ch1PvM7tn+mByWUHILn5t
	7+3TE7IgkaNMpg25l4tHj+JHg5MHS3C+ZGVeA1WZoGfjO+BBNSq5pFAl385pU0bkwQkM0g0LWFXoq
	opbr1HMuE4YnTZ1cNQkIBJSa1mkUsWPaDzcEFkaIEBG6o4aSkJJ93fstPOWzbSe/gISzlgPwN0WGz
	qh7SYpIgA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdZJg-0000AR-8n; Wed, 19 Jun 2019 12:03:52 +0000
Date: Wed, 19 Jun 2019 05:03:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	Ben Skeggs <bskeggs@redhat.com>,
	"Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190619120352.GA31563@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
 <20190615142106.GK17724@infradead.org>
 <20190618004509.GE30762@ziepe.ca>
 <20190618053733.GA25048@infradead.org>
 <be4f8573-6284-04a6-7862-23bb357bfe3c@amd.com>
 <20190619080705.GA5164@infradead.org>
 <20190619115632.GC9360@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619115632.GC9360@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 08:56:32AM -0300, Jason Gunthorpe wrote:
> This looks a lot like the ODP code (amdgpu_mn_node == ib_umem_odp)
> 
> The interval tree is to quickly find the driver object(s) that have
> the virtual pages during invalidation:
> 
> static int amdgpu_mn_sync_pagetables_gfx(struct hmm_mirror *mirror,
>                         const struct hmm_update *update)
> {
>         it = interval_tree_iter_first(&amn->objects, start, end);
>         while (it) {
>                 [..]
>                 amdgpu_mn_invalidate_node(node, start, end);
> 
> And following the ODP model there should be a single hmm_mirror per-mm
> (user can fork and stuff, this is something I want to have core code
> help with). 

That makes the hmm_mirror object pretty silly, though as the scope
is then exactly the same as the mmu_notifier itself.

> The hmm_mirror can either exist so long as objects exist, or it can
> exist until the chardev is closed - but never longer than the
> chardev's lifetime.
> 
> Maybe we should be considering providing a mmu notifier & interval
> tree & lock abstraction since ODP & AMD are very similar here..

It defintively sounds like a good idea to move this kind of object
management into common code.  Nouvea actually seems like the odd one
out here by not having a list of objects below the mirror, but then
again and interval tree with a single entry wouldn't really hurt it
either.

