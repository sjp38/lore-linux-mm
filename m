Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4EB4C606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:43:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7761A21537
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:43:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QrlvY5uq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7761A21537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E7658E0018; Mon,  8 Jul 2019 10:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0982C8E0002; Mon,  8 Jul 2019 10:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEFC88E0018; Mon,  8 Jul 2019 10:43:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA5818E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 10:43:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so10464807pfn.5
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 07:43:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zM0WKzhiKmDuxYb+ujTY+6g8jQuQY5ePwF4h6SqZlFY=;
        b=acLeJYvWaNzPX+CT6HId99EOu6DKYutAK+awy0V6Xyq1Urwz40kzJDr492w1gr4BPf
         NUadv1+McsvUEALsAEAXMupvygEI1QMGN0D4zttHwkrC+xbEoaLmH2KcYGJi9ES5DDQI
         KbcSyiEkNySOUr0mLAVSfQwd41eUlNSeyJj8RbVLorRd8HogOPgY5fTzYXC/SVu8j67O
         fNqiAaUUOOb5vkkdKPC7pLEZSyFrJJ4RKnO2mvL0jarKdIo2YmEkz9PRminkok/bhoJ4
         fXQUMZCwXk3duu2axUesRE2xWHru5I5LqRgWgTNsXY27CAwW9fFojndJK2HzkwV3HjD6
         scpA==
X-Gm-Message-State: APjAAAV5KihgPgYauZM0PFnJk7+MC2wFnvyM1GLzm0gJ1QTH0U9Emgo7
	HELFt6z1cJ1gliKpNu1+tDPKgBfAsc62WSWbsVi04nJfgwD1MW42x0ZuIaYpSOC479sT6GBuOZI
	ibIQClZ+gWOwuXafJCSkGwKJmtVhpHpmJjnVtLvXWS+N0Ptw+ahxOTN2rJhr8owUOcw==
X-Received: by 2002:a63:484d:: with SMTP id x13mr24224754pgk.122.1562597032246;
        Mon, 08 Jul 2019 07:43:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCNYVjeD/thDlAu/fc/EAaxgmVPjFZp6bFgLASwiS1P/jguRmU4hPW5k0nd8fU53XjXvum
X-Received: by 2002:a63:484d:: with SMTP id x13mr24224688pgk.122.1562597031546;
        Mon, 08 Jul 2019 07:43:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562597031; cv=none;
        d=google.com; s=arc-20160816;
        b=zgZaImHgfzYvybMxW/2KRXPIkRk2j4nqBdXRecq1zOHyKIq0vtYGP1Jjr5z8/ZqyE3
         2ZyPHRxs+QNNGhBDWI+KYdqZLG/7NaGcXAVrQ+4aL5EPZqhysg6lpNt76ufTtMSt9Km0
         /dXOposAyVgYuUUJ2DTM8kHhD4k+2gxNtTHhMfW4WN4XXWCwxLt21O7PBiBsvSUaa8fx
         8W2sRUgjgBXuy8q01RW0HakPKgnpHnVBRQR99UFp8pV+PLnddasS8S3eUOdFu/ngEn7V
         i4wIrv2goJHr/oYiY+RYr8urD9JutAwTt6l5W7rjcFunlX/etnuSf1yk2PUwpI4TzIyH
         8LMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zM0WKzhiKmDuxYb+ujTY+6g8jQuQY5ePwF4h6SqZlFY=;
        b=d1qj2n4wPRUXnkjL2AMvgyF4/c0cFIpSRIfs6IHmijsVJDWj9qXyd2QwiDg+ONFW36
         mXmR5lMOHEeEqSRMsvAV3WHtuFLciCycQqad1gLBMVcLZXmM5USQLL3KADCiLht3fmj9
         qXKCmrPPP3+TSXTBFCtQ7nNlHscTLr2K6Sn4H06VldBqRUnXa8RWE+LzNigYFonrNAyu
         rAFFif5HgsFL4LQfIQ6VZc4bkuVyy2pDLjKrWjwvLo2kCeHvrUMq0wUi3x4+/B50r46v
         LEWt/a1wW1NKhyW2psS+dhy/GZ7qMJr4h2Ppawa2tdOMX/a09NEJzZ4iac6muWIImWSf
         0HRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QrlvY5uq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v64si6299503pgv.476.2019.07.08.07.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Jul 2019 07:43:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QrlvY5uq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zM0WKzhiKmDuxYb+ujTY+6g8jQuQY5ePwF4h6SqZlFY=; b=QrlvY5uqLOY+0cTfKv/IMW8dV
	d7A3tAIAXD9d7ZnWMnUtDkLSsYNVjbfO16iYi5ioIL2AX24s/S3NhvJSms+DCRs36sjT3P1JWB1Y8
	TN+ptnqoY1NE5vdrak1eoI43/uxVqDNEL/c5K34tUyGHyl0jCoey4QkzZIdhdYcuvj3/+WcT1QI+u
	VhnXc66BoGA6+x3AjbE+oP41URXF0vWzh+0kMwFYU6fEf65JQIXI8kf2eUyqgLHepxpwgji7OheWn
	TD88k6PBtR46ftEGgDnImUXJqA63O0XWcb+NExqmm8+fFZpjChuPaKZTkTDHKmgV5O3piXPd9rJ2q
	D/YKIIK8A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hkUrP-0008LD-Lj; Mon, 08 Jul 2019 14:43:19 +0000
Date: Mon, 8 Jul 2019 07:43:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com, mhocko@suse.com,
	mst@redhat.com, linux-mm@kvack.org
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
Message-ID: <20190708144319.GE32320@bombadil.infradead.org>
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2019 at 04:05:41PM +0800, zhong jiang wrote:
> As the mman manual says, mmap should return fails when we assign
> the flags to MAP_SHARED | MAP_PRIVATE.
> 
> But In fact, We run the code successfully and unexpected.
> It is because MAP_SHARED_VALIDATE is introduced and equal to
> MAP_SHARED | MAP_PRIVATE.

No, you don't understand.  Look back at the introduction of
MAP_SHARED_VALIDATE.

