Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C301C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1F8620879
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NfRr1sg+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1F8620879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9A76B026E; Thu, 23 May 2019 12:35:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 769FC6B0270; Thu, 23 May 2019 12:35:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67FCA6B028C; Thu, 23 May 2019 12:35:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 316D96B026E
	for <linux-mm@kvack.org>; Thu, 23 May 2019 12:35:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r75so4534704pfc.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 09:35:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pTqw8vVT02TTedKtNx5d/snM21V25zXZwTaJRpzHF2s=;
        b=JJmyWrUrxr483XEmEc5waheFdus+mOGygTPguwBTmATPvL4C3Axsqh8VTYmCXZTDnS
         vCfwvavPzQGGWUKpTYG0+JBu1fjX+FSI5WsmHjdVHk/XasDuLi0UplEr/z1BdqGYfKOp
         3uSlleuEWTguahcgB6CJiuTMjqhZOZErnOgFkcTjyL1L4St8+UMdK7HA4D9IkO2nxYhZ
         7mBVdDsnYVM+wH4uxB7P12MtX9Z76kHnb54QpFN3hTpJzasCTi3zFOz37m8OILCQNpQh
         dSJcJoponTcM4QpI1Q2GFw8neu9ofQVEI199JdATqhFXa9zNf5/MeWgj7WfAa5qvSdL7
         ly0Q==
X-Gm-Message-State: APjAAAWOwyAXyKpWi6y5Xg6JRv/jSm3X1GqvjroJxQCJO+GlpdWUBjOO
	4ZBsvuxMtloGBjooAoaFmYMcbj5HS5CEGX7EIptWnLXUrTDilb1c/PxNYUyzR4UxnDHr/R4GrBk
	HAJ1iqqufN+TTWIBPjCvDg7fsvLlYs+X7zJVAxSdhuSpIGSWLAHgUzIOc28/Kp2TERw==
X-Received: by 2002:a63:c5b:: with SMTP id 27mr48058685pgm.70.1558629353708;
        Thu, 23 May 2019 09:35:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyG6BxwPvrKqBKQL5+s4wxO/HVxeHExdzKJm2RR6xWd/boeBI2QIZ2unJDJVSZBFu2v3Cj
X-Received: by 2002:a63:c5b:: with SMTP id 27mr48058572pgm.70.1558629352982;
        Thu, 23 May 2019 09:35:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558629352; cv=none;
        d=google.com; s=arc-20160816;
        b=pu1OQjErcrwvAFfchWS7LlscnyHQ5FVHwI6xQjD50jdkBzp87MpWa5oQE5pzV+AE90
         vyg0r4Awq+99UpFRyaXftE9n4XSL/yrjdkbCLOJlPS1zyIfJlQVSEdjl6Oqlh8NQIvd7
         B86YhG7fcTuvs0H0il6FYl+vF36iu6IWq3JupWmpP8P4Gnmzx5w1XUsWPp+/OZ7EJf+z
         GpQqKSVHePa7knmqGYw/BdPysWJ5Xj68170Ximc4OGqW7+YnvtHxf0w8kJ25MmByiEZ4
         jHVkgXGnqzQz5TbyZBg8K8ibW5PzVOXXwtW+x11CBgqhHf5Uf/5iRr6OYEIOBZlUc2JK
         5qqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pTqw8vVT02TTedKtNx5d/snM21V25zXZwTaJRpzHF2s=;
        b=sJz2AeXKfcxlGFjYElKvj+iCtV/10vVE694gSRfipf63KqUnnbeXqxasT45dCOwf6S
         8FTTTyTj6FblopmxluJ8UsW/64LFVFYH69BFzPAy7QZft51aPnRQS2vmOLPQ3j19NQpi
         kB2lxR15hacEYP2qFROlwPa1dxAys0ByQRLf8934iIgd2a5ldce7w4oGQRx8kWA/xAYn
         6BHwev7XvGdDS6iWplIWqFdgK5KzGNK0VK6zTJYE6ukzX4M2axf3s3578cjUW5GPLF5R
         snw/V0u+qv9o6CYiocyedqrNowMdiXPlxc1v7IJz0baAft2fgUOJSOHJv+18xxoPNF5F
         lRqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NfRr1sg+;
       spf=pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o66si31786905pfa.23.2019.05.23.09.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 09:35:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NfRr1sg+;
       spf=pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=pTqw8vVT02TTedKtNx5d/snM21V25zXZwTaJRpzHF2s=; b=NfRr1sg+JCx7yTC0Y1pf6Ia/1
	Jj1Q2JKIqRmnEF8uOXpqDpnr9jnvpqyQBNSvVaYyiHaVfePwCfQ0tbLKI4O2cMdcBLvDzvrte+2cX
	1Ly+5JK/e9hbhNJbBJND96QDqY8TGO8OwTWGUrJF1N3V3YCU6jDgEx7HfhN+62O+StZI9eZfbaiEK
	mOxv1UxoWRRwqCOo3fLHC/klxOsWZN6BIyCzN2XJsws5lMcg06NHOBzxQvEFf9idGdYnR3B3EO+AW
	M523UGnpBClzSFsxc9+IrD/MOXokNRCGk9ezwriiL9ixjGlj/s3dDot/vgK2nXpf5NgXjUxy43LCg
	HgQHp8E6Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTqh3-0004Ox-JP; Thu, 23 May 2019 16:35:49 +0000
Date: Thu, 23 May 2019 09:35:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Oliver Neukum <oneukum@suse.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org,
	gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	m.szyprowski@samsung.com, ytk.lee@samsung.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190523163549.GA8692@infradead.org>
References: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
 <20190520055657.GA31866@infradead.org>
 <1558614729.3994.5.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558614729.3994.5.camel@suse.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 02:32:09PM +0200, Oliver Neukum wrote:
> > Please switch to use memalloc_noio_save() instead.
> 
> Thinking about this again, we have a problem. We introduced
> memalloc_noio_save() in 3.10 . Hence the code should have been
> correct in v4.14. Which means that either
> 6518202970c1 "(mm/cma: remove unsupported gfp_mask
> parameter from cma_alloc()"
> is buggy, or the original issue with a delay of 2 seconds
> still exist.
> 
> Do we need to do something?

cma_alloc calls into alloc_contig_range to do the actual allocation,
which then calls current_gfp_context() to pick up the adjustments
from memalloc_noio_save and friends.  So at least in current mainline
we should be fine.

