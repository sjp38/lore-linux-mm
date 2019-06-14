Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AB11C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:42:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2208720866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:42:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C/ulpoOj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2208720866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F46B6B0003; Fri, 14 Jun 2019 09:42:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4B86B000A; Fri, 14 Jun 2019 09:42:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 792716B000D; Fri, 14 Jun 2019 09:42:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDFA6B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:42:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b127so1806044pfb.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:42:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p3fdSrD6/f8+J2jfdFQoF6CbHZtdUBeGJFTtmYRKwYs=;
        b=b/W28UJpFxo2qOOv6wxvSg7Me+sMKk8qXgRDAq8OcjL8kDoIfRJXyp6Kzm7TKivCd8
         i1Cx6GyHou7kxSmXPvoqdGbNe/duQBHn6gFt3HX1cCcToKBXJZ4BL/9QqHjP4p9RXdFC
         TAKEAopYXodIKUEBCi2MDYTX5dMg164nijx4zhIG4M2JtJW9sKKxliksdE+I3nofnudQ
         YlO+HnmxS0S0fW6OfHKyntI0QXqisOFRVNYDcZZlxY9iuLS0lwTcNRuZpamZ7gSiK1X5
         DCS06mKVFSx+V8ZUJ3PLOvQfMC7ji4Z/tNEnu3F+tB9l+0q1sIJV88/HbCnDiApoZuPp
         FR5A==
X-Gm-Message-State: APjAAAXV4hFnEKrgZUISJaqBJXPMmSKIPfP8ESpAM0ABO7bPoLYGK1Em
	pZzcvGuDTsP8N5CXZClUNFexbbhioy0jKEMmNmNMPYy1mhrOQVy0k8/oCsoFWFnXB/tftva2Xda
	yDxNuuYDQWmBfODqZAHtbHenJSkm7oKU2mwayRBVHGthMuJkNRIxW0MvQFH0fcaRfpQ==
X-Received: by 2002:a17:90a:ab0c:: with SMTP id m12mr11427403pjq.87.1560519744744;
        Fri, 14 Jun 2019 06:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuK4E6Bxg7FihwMfnl5z4eRmpfkIre4KkC50EN5nKD9o+VaTKrdQgrJGVnZ9qklRS4nc8t
X-Received: by 2002:a17:90a:ab0c:: with SMTP id m12mr11427323pjq.87.1560519743952;
        Fri, 14 Jun 2019 06:42:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560519743; cv=none;
        d=google.com; s=arc-20160816;
        b=vorLE7DTndGbTlCZRik4HCJGQoTg8UXXS1aGLBUC4u7BYrncPf4EDQg9Q20gsiZudX
         QJpn7SrGRrM0cYTx0lWEpSA0INOeh/8vbHd+QnrMLMZo18I3epQGuRveNFTG/5NRouZ3
         jH+hai1TTEF592xQEiNcLfDgikP118fcTVZWxLY4Xt7YmqgqQSv+ZRTexxLAopN4xxzi
         59LJw0SX8khdlP7GUDY69HaE8LQu1XEvTqfPuQ6N4CLsR7z+GwH/nklHUTlgWxUbLKd7
         1XFtgnm6d4MSp071pDl8N/VM2P9yBkfn3lE/q6BK7c/U9/D6CLYDmVh3USMXhRwpaqQF
         tWNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=p3fdSrD6/f8+J2jfdFQoF6CbHZtdUBeGJFTtmYRKwYs=;
        b=F97cbqDKl7CQCasu365twA209EFypNmCP7u4gpUCojJQvF3zOpJJFWmBMWTbZlK6Ik
         xsxvXW1b9vS0i044e7J9oMD8HlkCwf731xXUXBTF4FLpR7Glk4SyngABKl0BDHcShRgQ
         zdi5CrrsUBK7qDIfc8whkkQlSZ3zT5g1+/Hg1ULJ++dKPwOhZP5KyDbPReFNhsLA3Mwa
         TFfhXbrEb+sbkqgoX92jkyPmoamDQipg6yxoYz73yoTjek8hGZuZtd1hbo0b/wHW0uvj
         tzFm3NepAAeT2fbSmXdBgO0ONlCKtdENOwzC04iTGXeXm4NcEL/7FgoEOWKFXTg9+fh7
         2LuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="C/ulpoOj";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b139si2539427pfb.38.2019.06.14.06.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:42:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="C/ulpoOj";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=p3fdSrD6/f8+J2jfdFQoF6CbHZtdUBeGJFTtmYRKwYs=; b=C/ulpoOj8tF0DMXgykNNOW20X
	4Mzm4QmvDAn+j9P8nuhJeRygIqeHOjSWDJY+0+OzKZ1QOxCd16AZBN9sn99xoafwCYsf0SxCAHd1A
	5kjiC6LnXF8NWX9MRaaHLXEQtSc9mwQ2izH24oV42RKxLUWNbRkwBv0evHaMj4mAHfsOJWq/plo5j
	c0YcPHAbAKviEhOul5kKUn8wvhSx2e1cRWynTF38u8QKSf61Y8QRiK3tgX92QtBeOrAr6sXrG97P6
	l+62k64V9qA6RAM5SGJaJWO6SQnHIs6xo4GyoGp4XiUwjTllRucUNGOQaV5yoLXL9aV1vtwrDFKFh
	1iC6nF3Lw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmTE-0000Vp-AX; Fri, 14 Jun 2019 13:42:20 +0000
Date: Fri, 14 Jun 2019 06:42:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Roman Penyaev <rpenyaev@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: Check absolute error return from
 vmap_[p4d|pud|pmd|pte]_range()
Message-ID: <20190614134220.GL32656@bombadil.infradead.org>
References: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
 <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
 <406afc57-5a77-a77c-7f71-df1e6837dae1@arm.com>
 <20190613153141.GJ32656@bombadil.infradead.org>
 <4b5c0b18-c670-3631-f47f-3f80bae8fe4b@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b5c0b18-c670-3631-f47f-3f80bae8fe4b@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 10:57:42AM +0530, Anshuman Khandual wrote:
> 
> 
> On 06/13/2019 09:01 PM, Matthew Wilcox wrote:
> > On Thu, Jun 13, 2019 at 08:51:17PM +0530, Anshuman Khandual wrote:
> >> acceptable ? What we have currently is wrong where vmap_pmd_range() could
> >> just wrap EBUSY as ENOMEM and send up the call chain.
> > 
> > It's not wrong.  We do it in lots of places.  Unless there's a caller
> > which really needs to know the difference, it's often better than
> > returning the "real error".
> 
> I can understand the fact that because there are no active users of this
> return code, the current situation has been alright. But then I fail to
> understand how can EBUSY be made ENOMEM and let the caller to think that
> vmap_page_rage() failed because of lack of memory when it is clearly not
> the case. It is really surprising how it can be acceptable inside kernel
> (init_mm) page table functions which need to be thorough enough.

It's a corollary of Steinbach's Guideline for Systems Programming.
There is no possible way to handle this error because this error is
never supposed to happen.  So we may as well return a different error
that will still lead to the caller doing the right thing.

