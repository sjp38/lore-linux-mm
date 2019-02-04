Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C52E9C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 804D82082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:19:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uSWLen75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 804D82082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CAB48E0053; Mon,  4 Feb 2019 13:19:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17C988E001C; Mon,  4 Feb 2019 13:19:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 046678E0053; Mon,  4 Feb 2019 13:19:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8BBA8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:19:47 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x12so431306pgq.8
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:19:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NG9nYwCAVqEpP+paq6QtboUvwEo6x8RZXfTYGpZRrLw=;
        b=NMCAYJw3XYdwuTr5idvEbpuzT9kdGYsk7LanW0s/HSVfoV5hmX46Er5Vj57cOkyus4
         flNBSfMDGLPnSCxSylTuxGriNHhAOV2S/F+AV9z2vb3zkXAwXk7hE4uAN3JgzAXo1hXg
         h7SeweD1d/Eqx45+L/klMiaY6IHxtI3+zC+Z94C0dtG0fxrW1qHmGxiAG+g9+FcLNmVV
         Rj2jcJKdy3z+zTqJvNRS9sJSecRgbpuxzVSH1BFuiI7HDIbNCgcOPde9SJmC2IivcKWU
         Z9mS81FJrlOpCbnD4xDDfo/hYyJ+tVPwvfnDLsKjoLB7Y1ei8YTqavqX4VGIYdixcbzc
         IXpg==
X-Gm-Message-State: AHQUAubWq38yG0zEPJy9RJ/ku6Nip1JxqQsepILJiVyx3OUMAR3Jsrip
	UVxBSzp0cZck9vJJ68qeIf+nFsP3uf02mp08cBXib36goPwskLWdhJPN51hpuakHTYfmxk9LnAU
	XBSGNWIkaiQzcSSsaBr/xcsZ6o9fNNdU2PTLyvCwroLqvhrqjnJGILcwG/oGsiSilcA==
X-Received: by 2002:a63:e715:: with SMTP id b21mr593908pgi.305.1549304387308;
        Mon, 04 Feb 2019 10:19:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOngkHlIkY5cV2gYpSiSfSI4yrjRfy+lO1TIuHEmdxhaOrqXf+wDSbMquRvfwwAs+OI3Li
X-Received: by 2002:a63:e715:: with SMTP id b21mr593851pgi.305.1549304386494;
        Mon, 04 Feb 2019 10:19:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304386; cv=none;
        d=google.com; s=arc-20160816;
        b=ZbDQawnXVLbsOMFs1L1n1g9VK1ia12lgKPf5o69O2pWOCgPq+j+y2J7pAiX664psgK
         MDf1RZXPm8Oa9viL3w5Q4V3tB6Y7HILbjkPFCvxqUUYK3TKU0nQx49O51y5jdVOxd51H
         lNSNRJlPWQ3yvnt3ca7HomNDV3IZ+nj9uVuatuCBy3G9N++CQphvb6uxMBag9APul3mh
         9lXdy9B1T9cNzyLJSmwBHGKxFpAafa95GXD+JZPYM1jUq6IDFYF0S4Ny1tS8Wd+OKnQ3
         t4EqI3rsLYy9XZK+o8wyE/epNyMIo7aurgySv6pCUeom7wsDhBar+U12jSsCRd2RwlRS
         d2JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NG9nYwCAVqEpP+paq6QtboUvwEo6x8RZXfTYGpZRrLw=;
        b=l98GQlBbqx7bPYq2AwyGU04KHNOl9UsaF+UZSioWHJtO5j42wMlUaafAUMeEQ0Q+Kh
         2mrNMJ9M/bHTGMR74wOUGPtILwBu6dEqk+U0yOUIb7mvj6IzMxuJILsfj5G+S3Z43gKy
         u2oKfwWMfbYslrSoCjdqQ1qCFHOj7Qo6wddgfZgHfXxGCrcZSDnyvDyBOa4O2PMyWPLL
         KDEGXcSsQfUog2JPxDdi0v01+8FkbYRudYXSGBcIoNQp70GZcaYHpr+swrUVpUPd3EX9
         NMt8lDw13NprVS1BMax6Fiv4lLvwuVK/ySUOsSV1Swi1R8UEwMwfez10MnuQo7c6aCcn
         PVbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uSWLen75;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w7si619265ply.421.2019.02.04.10.19.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 10:19:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uSWLen75;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NG9nYwCAVqEpP+paq6QtboUvwEo6x8RZXfTYGpZRrLw=; b=uSWLen75JY5fHulYjRaAYf7ZF
	orEmz+rVxtEBYySX3aXWEHZNE8GGDpaOyjliOuetbgrq6TE1rZFD84nW1a0hMIZn2lY1AG/MaJKQE
	zjHxU9V24NeXnWehVH6ERlDMA+3KPiVoVnqP9CN5PktQZO1tJ1pnXcPpTd+Fu2gkE4zUoBmbqDjxS
	pymF1/FC3OB9FI0huuIN/4BvggTAQwoX/AZtZWyH+JM51h9B4jn9SKk5gbieg7enClnK4lulAZvs5
	Q9Ww4bnNOYB8c0p92SUB2QlERAMduCa8FI5FYdZJYvapWjhOi86zepu3UfI9KAF05ZVXfOgYwVcQp
	+pEFALSSg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqiqO-0004T7-La; Mon, 04 Feb 2019 18:19:44 +0000
Date: Mon, 4 Feb 2019 10:19:44 -0800
From: Matthew Wilcox <willy@infradead.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 4/6] mm/gup: track gup-pinned pages
Message-ID: <20190204181944.GD21860@bombadil.infradead.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <20190204052135.25784-5-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204052135.25784-5-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 03, 2019 at 09:21:33PM -0800, john.hubbard@gmail.com wrote:
> +/*
> + * GUP_PIN_COUNTING_BIAS, and the associated functions that use it, overload
> + * the page's refcount so that two separate items are tracked: the original page
> + * reference count, and also a new count of how many get_user_pages() calls were
> + * made against the page. ("gup-pinned" is another term for the latter).
> + *
> + * With this scheme, get_user_pages() becomes special: such pages are marked
> + * as distinct from normal pages. As such, the new put_user_page() call (and
> + * its variants) must be used in order to release gup-pinned pages.
> + *
> + * Choice of value:
> + *
> + * By making GUP_PIN_COUNTING_BIAS a power of two, debugging of page reference
> + * counts with respect to get_user_pages() and put_user_page() becomes simpler,
> + * due to the fact that adding an even power of two to the page refcount has
> + * the effect of using only the upper N bits, for the code that counts up using
> + * the bias value. This means that the lower bits are left for the exclusive
> + * use of the original code that increments and decrements by one (or at least,
> + * by much smaller values than the bias value).
> + *
> + * Of course, once the lower bits overflow into the upper bits (and this is
> + * OK, because subtraction recovers the original values), then visual inspection
> + * no longer suffices to directly view the separate counts. However, for normal
> + * applications that don't have huge page reference counts, this won't be an
> + * issue.
> + *
> + * This has to work on 32-bit as well as 64-bit systems. In the more constrained
> + * 32-bit systems, the 10 bit value of the bias value leaves 22 bits for the
> + * upper bits. Therefore, only about 4M calls to get_user_page() may occur for
> + * a page.

The refcount is 32-bit on both 64 and 32 bit systems.  This limit
exists on both sizes of system.

