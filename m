Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 570B6C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19F912070B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IciHtC1A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19F912070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 990B56B0006; Fri, 21 Jun 2019 10:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 941E88E0003; Fri, 21 Jun 2019 10:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82FE38E0001; Fri, 21 Jun 2019 10:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 499616B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:58:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so3764581pla.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3dT8GgJ6+uQhH34e10+L7yEjvR1H493y6W8QxwGRYS0=;
        b=fkW+o6pzeFDkzCDG645pSDLx/nn38zbC+DBrHGmHiYz7ekL+pvygH80P3kKK8siRox
         lIPFMx5QTTeJLC9PwtAVI2BZxohfnUu7aiQi/i3f2Bxt2YLjLRr0Ylkt/g+0GeKC6geT
         ENY6i00Vm0g8cG4hvEmDdeW6MVTdB+QRnLw4wsEkwNdgFvg9Z5Y3M3wmSb2LUvTEIk5t
         FcrO4v+VmMui66llpm4AVzrk1ZYB4HOH1UOkxxjbCxBLvH3xmSHhFy1Ks6xRujciLSNU
         VZChA1DjFE3Rf+nYT+PMeMMsKRNEcyQehu8VmnReNTvv2odRsnZ9d5y5ThFlazTeqwet
         tsmw==
X-Gm-Message-State: APjAAAVMhHkIgCUY7dJU6SHGym70SSqlqArNfgrKt8r/5KDkIibhpwoz
	X1xsB5Q1zAopu/ncdQ4HiHjN3IUEFdaxG+YXxHN+t9mt5NZ29xYTizIxKyDUAuvRTzh/wrGN7dU
	AVEuYrnKqXQPMbFffASQ2R8yEpBLsrScxOTD7ladz173G+bjEsadS9r8Qzx5HQzYwyw==
X-Received: by 2002:a17:902:9896:: with SMTP id s22mr2776571plp.4.1561129091920;
        Fri, 21 Jun 2019 07:58:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1yqDP1iFG9VFl+V11RvOsU6X7FarikJBC2idkPy7ozuZOxDiChTLmrPKKVstNkGp5jmss
X-Received: by 2002:a17:902:9896:: with SMTP id s22mr2776537plp.4.1561129091385;
        Fri, 21 Jun 2019 07:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561129091; cv=none;
        d=google.com; s=arc-20160816;
        b=M0UFo8kyGTgYXH5fjT/3JYvX3dpsxcU/xwzfyAsUJNG8YytNjKs+LF64vc/zkOypfF
         rU1llFko4GRMVwtPEGqhw+LHdegiqNdYXm3z0x91XzgVfc1/9wUEr6BWemyMugvkOX/5
         /GWgTRrV/DTsPBOx8dQA06455RvUYSrynz9LCfwntiGQRwCq+iSx1bP8ZfEv7ZWo3H8r
         MFGTE+yvgyFpG1/9W+5dfbSTx/ICneWtYoygFKkBq+yBjtiLEZ7zqXqeqD8WDyBjwJla
         joz0aL+C1Ud6e011vbafc6SFqZ5/Zt4ba9m6ibdDgvFlrY7v+FUhBueR7N/pHQIMoGZf
         I1Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3dT8GgJ6+uQhH34e10+L7yEjvR1H493y6W8QxwGRYS0=;
        b=Gi3m8RottgKsGlLJnsEFauZwXkK+bKi7GMUtllKRKh/m0T2G+JYjAubp0zG6EjF/p5
         pY46T96bqvNTpxW0OJuXvlUY3j2Tj31uzHWoc80h4llRVsltfGyK2vVzoS3tjJurqpzq
         8+cs4irX1VzMhC2fpunyuyITMkzQtwN09gI1CypjeDcCnPNfo1e4n/1L04kcfv/qD8OP
         96sNb7zYs94im5M25IeTuVUOQf2Wvjuag7dF74VZlQD1xmvG20oiha0dp7HvBPT58Rjz
         APpkwdfiVy4TdmlY3W0aumpGHrgN5vk/gd8ykvapXImbiMFmjYzgoPvw0gzuzLJKJ1ME
         9hGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IciHtC1A;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m20si2611411pgv.314.2019.06.21.07.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 07:58:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IciHtC1A;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3dT8GgJ6+uQhH34e10+L7yEjvR1H493y6W8QxwGRYS0=; b=IciHtC1ApoWbUNoHP8hTutDrf
	o6gvUQ24Xt0J/bDrghCwt4cTzS188eaW79VxqY0BfbMmSloZAPNz+SSJ7lJwC1At/wwBlNnZMzGvE
	JI3kRdeSfQRJnLw93aYTxtNxEc88pjz1eFuKSrVFWWA9dYgBW3S2QHuF89ixFNoxdmCFa9evNZ71l
	bLbOKkFnBVE60MYg64lKrVu1HfeUjrlQHjDW2nCQQY0aK/NepvOgeU05EzOnC3ZAMsFFqVOTx03B9
	7rOmUhzubu7OkflA1YJR2Y2vXrp4aWmkmQskIwoNoAvTG4qZ/L9tz9pGkLltxg3c60n84ssoMa0Mi
	yBJMlDyDA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1heKzO-0002EK-KP; Fri, 21 Jun 2019 14:58:06 +0000
Date: Fri, 21 Jun 2019 07:58:06 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/sparsemem: Cleanup 'section number' data types
Message-ID: <20190621145805.GN32656@bombadil.infradead.org>
References: <156107543656.1329419.11505835211949439815.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156107543656.1329419.11505835211949439815.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000081, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 05:06:46PM -0700, Dan Williams wrote:
> David points out that there is a mixture of 'int' and 'unsigned long'
> usage for section number data types. Update the memory hotplug path to
> use 'unsigned long' consistently for section numbers.

... because we're seriously considering the possibility that we'll need
more than 4 billion sections?

