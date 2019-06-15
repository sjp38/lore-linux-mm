Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A3F6C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F2D32080A
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:12:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dNgRTy1V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F2D32080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AD826B0006; Sat, 15 Jun 2019 10:12:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95E8D8E0002; Sat, 15 Jun 2019 10:12:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D2F8E0001; Sat, 15 Jun 2019 10:12:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 507386B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:12:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z15so4018747pgk.10
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Xeia7Y2H20qxvC8T957Brc8A65sMgIu+4oNZeZROWY8=;
        b=nh6/LLRYjMjKCS32TKW5pMo9As6rjph/TJxAXG7ezuBF2kvS0tZ5+uaTnYRvsQaD48
         0ni2Wu3en08b1XYqwKZDEVqC/TrwbwWQlRLCoZ2PAcqv6DBZnB3w1QWoOohyb9T5MwH+
         jLfX6wNRPIeb1W99onlCYu3Se9jSPA6F8X5n6KfiQP068nA+42cXbgoYw96zyJ2sBtVE
         L1ypYynQlB0puxb0u5nEyMDwsJ8YEGZHfAQS/RX6GTafGhnlr21Em+begf8ZSRSAh8Xz
         bqn86WGpUovhnTNq2YjXwairaCb51wO0LALktKdssjQIvNVezPxneoZ9knqeK1SZFGS/
         7lZA==
X-Gm-Message-State: APjAAAW+dCnDMKWb3B5rjxhL5KEdU6tnH+p4e1GKix9S2s3l2H/2qhtr
	zXHNTF1lSDCHrTQB9/JV8272nyllCZE5GF4erA2JurLLscGkxswoTqePKvC26xUBf/oXpEyCEIm
	ycMXEZG6sUjYlUjo+a2KEEmjnviw1Fpz7P7fjRoSP3IOHh6uSJBdvwrernbaBfPMyhA==
X-Received: by 2002:a17:902:6b48:: with SMTP id g8mr14064162plt.151.1560607939018;
        Sat, 15 Jun 2019 07:12:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVZAUYKdR5gqEUrJ3euwqWNCTC0qgEVGLHMOJ6pijHAd8g95W7/xUDiBtBP53qmxdm5L6b
X-Received: by 2002:a17:902:6b48:: with SMTP id g8mr14064121plt.151.1560607938318;
        Sat, 15 Jun 2019 07:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560607938; cv=none;
        d=google.com; s=arc-20160816;
        b=mngsW7PqZNtvdX9a4Lmmdk4A0JaUMw66NuAWo3aESuzQNgOImLXVVVaqpeq/3xNWa/
         ScYivmJ7n1QfOqbihz7XYkFRgl+QrEqQIdAQ4ls55nnXtHF3iC5hnIqG7pQpT3+kZV7l
         +ufzjlsHaV4ZhD9sAM3u9wjF81Tqr79SPgFWwMY8qQmc8OQCwL6GIffVxFGfYHmJ8hiQ
         42d3WM/Ry2zI7ieJBG279ehl3E35ybW1hVSaxQEVhi+vtzZewizAc9eEC42w0DVb6aJ+
         yDhu3kaTWX/4lRNHSaIPa4zVzdqbWdeJHzzya+m+6Vit5yEJ0qLZ3+z4KEj9pjMmx9oB
         Z2XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Xeia7Y2H20qxvC8T957Brc8A65sMgIu+4oNZeZROWY8=;
        b=DFGhD84lebV2EAxV1LxF+6vaa6+7VyUWUyFzbh8GVcWVM5TdoC96M81/MxG4Uw4hzV
         rVcVWzzP2e1zDz8Cpky76BRFMho8Amx6D4T2/oYztNDd4P/WuasBq0MGTPStWY5Ysa1D
         bjsW+VA/myXfw5rvmCVk9nOr6ayCEmZ3df/8nkzKqhqhNVLBYgOBnI0Sw/Z/A3npSyl4
         LpEO4PW041u2tkIkpEV4Pfht9OlqxfPsnF22Wer+8AAZW6ITNWN7w7VcS0cQ8NUCZ8uN
         F6v9TFDC8VhMLqgiLQCP0bPhYj5Xk7pW8n1XbT/2A0DZRCxh+IbNyTCkgBFpZBtwfORl
         GSXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dNgRTy1V;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x32si5476572pld.190.2019.06.15.07.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:12:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dNgRTy1V;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Xeia7Y2H20qxvC8T957Brc8A65sMgIu+4oNZeZROWY8=; b=dNgRTy1VE+B9PBH6hwZ144/wJ
	hPJ6HGzKtH5KFgLTt3v3DzpcFqBEl0IyH4qot6+xc/fHoQLRWtTYKcvLodHmCCN46/wHpw9o1LC+d
	nsupPfh3zYNfmm6O8UQibHe4FMPlCLRsrs6+iyIHs0QZrxD56KndDvsC847sZcv6SIrm6GQgUprWL
	dLf+9pS7RKXZVIxFmz9AdlM5H70IdanFowU889RfB3jQkG9MqEaLpup3QiULxuk0eU94Wk5oziV5R
	nPOTz5pupFoa5pc3bHOanYkNsZ9BGWIx7d1wmp4/iHlZ+xYvhlfjsKxuQQnPCPdSq4GwKA3+eNie/
	GNiDvfjrg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Pf-000272-29; Sat, 15 Jun 2019 14:12:11 +0000
Date: Sat, 15 Jun 2019 07:12:11 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
Message-ID: <20190615141211.GD17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-5-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-5-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +	spin_lock(&mm->page_table_lock);
> +	if (mm->hmm) {
> +		if (kref_get_unless_zero(&mm->hmm->kref)) {
> +			spin_unlock(&mm->page_table_lock);
> +			return mm->hmm;
> +		}
> +	}
> +	spin_unlock(&mm->page_table_lock);

This could become:

	spin_lock(&mm->page_table_lock);
	hmm = mm->hmm
	if (hmm && kref_get_unless_zero(&hmm->kref))
		goto out_unlock;
	spin_unlock(&mm->page_table_lock);

as the last two lines of the function already drop the page_table_lock
and then return hmm.  Or drop the "hmm = mm->hmm" asignment above and
return mm->hmm as that should be always identical to hmm at the end
to save another line.

> +	/*
> +	 * The mm->hmm pointer is kept valid while notifier ops can be running
> +	 * so they don't have to deal with a NULL mm->hmm value
> +	 */

The comment confuses me.  How does the page_table_lock relate to
possibly running notifiers, as I can't find that we take
page_table_lock?  Or is it just about the fact that we only clear
mm->hmm in the free callback, and not in hmm_free?

