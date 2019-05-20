Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C332BC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 10:12:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 827F9206BA
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 10:12:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZU0ytO4Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 827F9206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04AD96B0005; Mon, 20 May 2019 06:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3E4B6B0006; Mon, 20 May 2019 06:12:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2D0B6B0007; Mon, 20 May 2019 06:12:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC31F6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 06:12:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f1so9670975pfb.0
        for <linux-mm@kvack.org>; Mon, 20 May 2019 03:12:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MqrvqRAJlxcONvOERepJ1ia9im/zVqpqGszIN9wgOpo=;
        b=hk6+GdiE795eialaL5f2FTSv5a+pldwCvKUbVZiCKmXpvvDmbBmmkiuJV9/mwFvMBD
         oYeNxd4jX0b1G2jjcokcDS6PKTLKwMkxyDW7mt3qdTUQK7hWcRFHrBRblWAzPcb2RCXG
         nXxbbilr6ax4PWK265Wz3Q/CJ+bbs58lAyi07AZTCnOfKz+St5HUSi3CYHXvqqvLpa2B
         ubXgqzLAZhy/yrcE2rXEgc+Wm+TCv3oFPlPXUvr9d5sASozEHP4h779ZCpsUivDX2eLx
         QNSlJLSk42YD3pXjeJScjKrCw942JTwxzKijSGxGP6pfJ1dz9x1TKCzYjjExeFgt/HR1
         wtMQ==
X-Gm-Message-State: APjAAAW7CTIQdxUEixaZcb+oVsYggxBZM+LBzdSKm5suQW0nAYPXEnTe
	7cGz8Y/apGD8xCdukeDkaktaZZP/frK2X9O4lFag2VGauPRQKi7OKzbi3ULB+zNIarv+wkQTcAw
	+i0nHKXR46YnOWwmNStWwKpcBBHQ7UUkK+EyKY6rDxVFfyhPTyu4X5S7+hmE/Z7uA2A==
X-Received: by 2002:a63:e43:: with SMTP id 3mr31912857pgo.253.1558347130216;
        Mon, 20 May 2019 03:12:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLMtEaKaAzq83XbOKjsTXxwhBmRXQVd8+HLVXJhQSAAxzDVRUqTjeVH4GhfyWvBtBc7vTW
X-Received: by 2002:a63:e43:: with SMTP id 3mr31912769pgo.253.1558347129171;
        Mon, 20 May 2019 03:12:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558347129; cv=none;
        d=google.com; s=arc-20160816;
        b=Ab9v20OHIAF45Bzw3SCKnHSt4QHVEj2IiVta1s7ev9M/5KTLVlLEj6VK9v44+BQU7l
         /nxDZrOEURoLXhf1w05c5MqB+lkIRvaSVRwAi28CMeYQoYHocmhO+wXr3hivY6jxF+Cs
         xLrN/ms0UfHaYweguw1y3dfDxCj/naIkCwSiM8SUgwGlSqhFnNOVK32ceYVFQyrr1e8B
         4UimTT9L7AljGTp5gYXZlUytmOZm63OJP/IJ8BUQVPg3h4mrteUMxJVPrtx0uZyg5YIp
         SGFCOeVyGzvHUmKojWlP+7S8DavMOrSnt000llkIWmnfgdz0NedYtUFm+FFnTkX+EqK8
         JyGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MqrvqRAJlxcONvOERepJ1ia9im/zVqpqGszIN9wgOpo=;
        b=ak8tKdIrRymIjFsr6JXHwZ25fc6PYmb/vONtTkUnB60AM4oBWTxtREJazh33QR7SWk
         FymDMA37GdezCQnP2mpS/YF4YuoqlAk3XPKdNa7ZbOYJBPQ+7kQraQXAH0VaLw43omr5
         MV5dJffJgEq8RWsrPjrhLF6WJRWyKMQtayxAVAxpeZHdJMItfXyFxhyEf29TBfna/i79
         UysRm2kdMARIh3Mj8bXD47/omNpeQaSbq6m6J6DTSFkFeqWrsH6qdT1/uHS3l1ErWKOg
         sBlGHA52w/EZJV3R99fkCdejXWPZr2SNUSc0oa4GJCfpQqk4Gu+yU6sHUtXI4hVj+xPh
         bhsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZU0ytO4Y;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s17si17920800pgj.186.2019.05.20.03.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 03:12:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZU0ytO4Y;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MqrvqRAJlxcONvOERepJ1ia9im/zVqpqGszIN9wgOpo=; b=ZU0ytO4YuOP96ibdGXamVHekr
	uBSM7cCD4CWqHQfee0lTS97z/EH61ONs+mc6CZYtOT3GX7GdQmDV3ZCOxswvcWlCdcD5tUMAKf3lO
	8cpp0xOP8zB04CG4MxT6SoS91K/bYf1pOv70rCpVbLb80GTGRylJADjqzF3cgmEgHUCkxQGxvFu3x
	aOyZDtSq0VnBtTuwVqlvi3AyMOPs0BZtj5FOG+3gvaPGFhfapQUsk0j9OXJifHtQQuG53bi2iid/Q
	FTK3ijbqOwmRyAmwSPJpu/fnRPXmJu6s/sGdB6ZSVuyzXo7qkti7ONQZV6wv8/86V2mFIRECvY9P/
	aujbpJYRQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSfH4-0003eI-EN; Mon, 20 May 2019 10:12:06 +0000
Date: Mon, 20 May 2019 03:12:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Oliver Neukum <oneukum@suse.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org,
	gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	m.szyprowski@samsung.com, ytk.lee@samsung.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190520101206.GA9291@infradead.org>
References: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
 <20190520055657.GA31866@infradead.org>
 <1558343365.12672.2.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558343365.12672.2.camel@suse.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:09:25AM +0200, Oliver Neukum wrote:
> we actually do. It is just higher up in the calling path:

Perfect!

> So, do we need to audit the mem_flags again?
> What are we supposed to use? GFP_KERNEL?

GFP_KERNEL if you can block, GFP_ATOMIC if you can't for a good reason,
that is the allocation is from irq context or under a spinlock.  If you
think you have a case where you think you don't want to block, but it
is not because of the above reasons we need to have a chat about the
details.

