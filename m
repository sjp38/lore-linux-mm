Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39385C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:07:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEBFF20823
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:07:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WdRlzSpz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEBFF20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D8886B0006; Wed, 19 Jun 2019 04:07:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6629C8E0002; Wed, 19 Jun 2019 04:07:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC458E0001; Wed, 19 Jun 2019 04:07:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 101FF6B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:07:10 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so6368228plf.16
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:07:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=joSQX+c79LrXwDofUn4UcqKpzHato3fL9zTkPCCp5Mk=;
        b=ObQpzV4HuMx0w+0oePErYjesq7QHkHd7bdHTUcqLfZGPyeuEq9hftzFEcJUwANgI3d
         yhoRZi/XKXvXEvH+Du9vhahLpV19dYw94ktZI8s/MCYxAAfZL99nfQQaeyBPmtK3/qGN
         yxadWKuQzyso477V2994eIojoeT3WXcSgwSA65ss6CZym6M9AqgD/Pe/h+25rvN1nzxO
         SVxhUHQwkzf+Ylr1Q5hbzFhv4b+Vw9Rj+7FviHye4Txyuo9CAM91JmEvSd/0rbMNNPIR
         /82htC7HGUecLi985TBvUb4rzp/pFQL/kQd+gQ3z33kvc88NEB0mFM1E+NrvOdKws7GL
         UEDg==
X-Gm-Message-State: APjAAAVFo6Sm7GXQxxIii3rOCUD2bvoNB/piPgkPAZI3e94uw6xOXVxn
	H/uYQXqsEnhTuSxdhmLagSPzXWR3YKuOSbeFnDVQAHw+uKDJ2LWLBGRHolQAOBSAkjJ3c3WVMv4
	l7jMkrEuOBv0QKzCkFW+hF81iZcrvGj8bj0BPNH4jhsMFvfmesUKAczmClsqMQFWAXA==
X-Received: by 2002:a65:514a:: with SMTP id g10mr6561587pgq.328.1560931629534;
        Wed, 19 Jun 2019 01:07:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztOI9ziIuvNvAEzltnUuM9yZMe6Qq+SAUIZYrw1kaKcwMquCH3w3/Oo0eQQ/bG2j8IWcx3
X-Received: by 2002:a65:514a:: with SMTP id g10mr6561531pgq.328.1560931628774;
        Wed, 19 Jun 2019 01:07:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560931628; cv=none;
        d=google.com; s=arc-20160816;
        b=MZ54b+MrT2lYajb4IaBnm5zPbJ17KK6iOafTLF8SJVsjAaA4lyxMeMoakOsmmY5kTD
         QCwWgOLsx0y3SbxZ34JWRhex5a4NKbZXdQ9VicpUlBLeY2eFLQgLKBX/6kNfmn0DQ9ar
         jxBTMSIs2dtG8nFGuU6X3DYfSwontHacK/4ip3pDauoN7casri2nq6WRdIXC+3zPqdXz
         NT6ksm4DsqY5ZE8k+islhYlYh/SgYTD/3kGkJ2DOunB7DMLceHPk7reqs2/wVqxZXoGG
         5cN47fVJqPzy7H7hzy45fXLGz/7TaIJITpKuRcjindeDe3zV8DhsE3Uklb3KNfhjDnzB
         fJWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=joSQX+c79LrXwDofUn4UcqKpzHato3fL9zTkPCCp5Mk=;
        b=0DDRjJFTyfNlskH9uzW2Ed/ukc1c310Z5CpzkpvZWIoTQOhtUG8VQf9DeeHamMhBdS
         xEDmp1ucq5kaB8DJC4DEDlwNeOxuoFFkscMI/W7XhhLCEj6eOaGPgYG8GeaaVKm8XuXF
         jTRiD1vxFEnlHFrlLGLxDqaRG/xVn2Vp0z93ehTW/48S7ngfgD3KxMcwz4UFzbO9Gukv
         AXXVB0LNwma2vURMbil66q2Z0r4IW6rhSCg3EoskAmz6FV9pQ+eXHChEiRClkq0aKDJi
         EQHyfDLRUS5OFVqXV4ESN49NIIP1osOmqtxGiahIa7SDwZy/EOt6FBCkmfvpwWEOyCgf
         QUCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WdRlzSpz;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o71si797514pjb.8.2019.06.19.01.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:07:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WdRlzSpz;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=joSQX+c79LrXwDofUn4UcqKpzHato3fL9zTkPCCp5Mk=; b=WdRlzSpz2usjiHEXhhtXkURap
	JR/ywCqFnns9c9y2t4j4VowNJXeRydRRNboQlVSHN8bq2ehggKbdZH1HlMzQMHyezwSB+PRDQklSm
	QGdvWLYUFZn9VrVTSA3XepaQVYpa+5bgROMB9yzWCXXaKy+/WJuY+VzMSw9v59/fKxlT2CobF5aT/
	iKwPEhqNC+F/eV+jAM/BxqQZIwJr5YGZ/rjVwaXAmRH+b9vNvmm3V2rDsAcKr5ORPlRjhxXjkKPPx
	3nWz74yeA+o4L5ZKbl6tDC67LBLtYr13ByiHJ3KK4La27WSvZ17+VriT5N6Bx7Ur9bTQVNY8zxBGU
	CLLHoGCOg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdVcX-00045B-4O; Wed, 19 Jun 2019 08:07:05 +0000
Date: Wed, 19 Jun 2019 01:07:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>,
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
Message-ID: <20190619080705.GA5164@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
 <20190615142106.GK17724@infradead.org>
 <20190618004509.GE30762@ziepe.ca>
 <20190618053733.GA25048@infradead.org>
 <be4f8573-6284-04a6-7862-23bb357bfe3c@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be4f8573-6284-04a6-7862-23bb357bfe3c@amd.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 12:53:55AM +0000, Kuehling, Felix wrote:
> This code is derived from our old MMU notifier code. Before HMM we used 
> to register a single MMU notifier per mm_struct and look up virtual 
> address ranges that had been registered for mirroring via driver API 
> calls. The idea was to reuse a single MMU notifier for the life time of 
> the process. It would remain registered until we got a notifier_release.
> 
> hmm_mirror took the place of that when we converted the code to HMM.
> 
> I suppose we could destroy the mirror earlier, when we have no more 
> registered virtual address ranges, and create a new one if needed later.

I didn't write the code, but if you look at hmm_mirror it already is
a multiplexer over the mmu notifier, and the intent clearly seems that
you register one per range that you want to mirror, and not multiplex
it once again.  In other words - I think each amdgpu_mn_node should
probably have its own hmm_mirror.  And while the amdgpu_mn_node objects
are currently stored in an interval tree it seems like they are only
linearly iterated anyway, so a list actually seems pretty suitable.  If
not we need to improve the core data structures instead of working
around them.

