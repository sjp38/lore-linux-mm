Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3C19C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993AF2147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C+BUwJtT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993AF2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E5878E0002; Wed, 13 Feb 2019 08:06:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 294238E0001; Wed, 13 Feb 2019 08:06:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AB2E8E0002; Wed, 13 Feb 2019 08:06:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDE988E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:06:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t6so1639242pgp.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:06:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v/SUZ32bLKbB19QVGv5xAUSeQGwbhzkwhCTSONn+E+M=;
        b=FiG1w8UnhkXiupZIAGtQoO3W1obeaWfQbaUbYeh8kclT4QXwS+1R4vJbWgbFvo+FPn
         6NLAbAVoOp7EvEya0vfjhAYR9kOrClSemkGsDyB19aCZ6VWqXnjywoe13AY++69HRNUA
         2n7k5RFR7D7tjhsq53uWNfaLg0Vv/ZlfiPM8uegbZnBGQdY3EJb0c8wH5xnZsT+mrLdG
         AqSFhuvpCj3ZEBs7VM0bV8yDrAS/IZImjcCb1oGgIXV44FepaCmbbTxkVWBW61rp+RBP
         cwbGTpUTBstDMbxOgms8VZS3yt1FgvqAiRaq8nlmi431WWJ+ytQ6LCbQzEODrBShXa7/
         pqVA==
X-Gm-Message-State: AHQUAuYZtSYA4qSNawrxVlc9V6edns++dHM2DOa70x1/bvWFSBLvtabS
	Wy/iwSlTGUPwbxrbSCZ2S8MuWD0jLR6eZBas9InQU43Y/zguBOQbKLBsf1bp+p5acplK4KtSo94
	vubRW/DI57lMZmMaRqK3RmXpm2zSynMaDxycRK1xo0VjmasQ3DwqDHeEvOw0kyXlg+A==
X-Received: by 2002:a62:1981:: with SMTP id 123mr408793pfz.69.1550063211474;
        Wed, 13 Feb 2019 05:06:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZ6h8cWPSRU0vEaGBsR7xpn4Y3K4lHEnAnavcvK91FDIbqL0S4dUUTda8mVbYH/3cQtqrB
X-Received: by 2002:a62:1981:: with SMTP id 123mr408717pfz.69.1550063210550;
        Wed, 13 Feb 2019 05:06:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550063210; cv=none;
        d=google.com; s=arc-20160816;
        b=NDSWpzwabYWi62DmBSEqghBQjRv35mH/meItBXPu1lCTXCQ13qO3vyQyh6kH98D4tD
         9z4dAhpmCeCDtWZXAyBXjdcLuKd7dyZ1QTT8YfW1E5mc+To9VfWb83nbl2JVlU2gLnuB
         WKkcKmoPjHIhH177ntY2ArriyJVcuxi6nFOykcMBh07Rsw0ylviXmPsB0yLmW9UIs6eF
         68lHM12yIBG1KVVTRiXcmA+85RFKLugaK2FASVnBWu3ZyuNVTAMpqTcMpuhl/u0YKgF/
         gDNVv02ZEgOyV8Z8BIDIWJgS19tNokNTsyQ1cDRpXQwYBso/4WPsMLS6yixtmERQYaHg
         BWQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v/SUZ32bLKbB19QVGv5xAUSeQGwbhzkwhCTSONn+E+M=;
        b=T5RA711rXdVKSRjCMb3f8oJ4B0QMJ11zX4/9aBdtycyhsIfVPoM/+7raBwW4abQeQn
         AAooq/N9Rd3oSFt5eDrRtXjcKqrLqEPm3MqqPBbfNtdVGC8E7yFKk9AmEwI9beZ95Jfu
         UNnHnNuAhv2PyYJ0pMQj1KgxiPgHgx7LUt12TDp9OSVx5HuPsjuDORFBvQcR+vUDN1lm
         pjKH0Dn7AkXnJUpqZXbe+N2xFgNvzPDWFUDJqJyJQvaEVDYRL/RGM5I4EJrnAkRvdPs2
         CY7z4gKMOjuG9/Fg9l/ymd1hmXC9ImycsffrJq/mo/6c9N0ueYeSdjEydudg/ATaAlTT
         kIog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C+BUwJtT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q13si15128082pgj.86.2019.02.13.05.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 05:06:50 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C+BUwJtT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=v/SUZ32bLKbB19QVGv5xAUSeQGwbhzkwhCTSONn+E+M=; b=C+BUwJtTvwgYa5sRRkKMYNVqZ
	ak/NcpoOoVcJZ4tdr+3q/lIQOpBkN4DGqFIwj/mLp3NZc7Kz2JHDl2ou46v77pWFfvw9vCVWN/8Iz
	nMRJOWeUpm06CpdcFAf7YrzdjMK5aMOtiqArK7ZxB4YNDQ+PlhjDMuSH7GGwweP3gAM9w3fgQW1G7
	GZHs5cheOfonHKGxrN7FPkAbpA9bZssfg0flQaXgqvEnqAex1nFQvVMeXGDYE8L/TdG4nuiCVK7GK
	xYLPO+p8P+v8IvdyFzBtyRShxLmqU9kHvBC34xX7yPb7nxxt2NSj+7teE0Yd6I/qy7yvJyvPuXW2I
	HgvS/hHfQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtuFT-0001z6-Av; Wed, 13 Feb 2019 13:06:47 +0000
Date: Wed, 13 Feb 2019 05:06:47 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190213130647.GQ12668@bombadil.infradead.org>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:33:31AM +0300, Kirill A. Shutemov wrote:
> To consider it seriously we need to understand what it means for
> split_huge_p?d()/split_huge_page()? How khugepaged will deal with this?
> 
> In particular, I'm worry to expose (to user or CPU) page table state in
> the middle of conversion (huge->small or small->huge). Handling this on
> page table level provides a level atomicity that you will not have.

We could do an RCU-style trick where (eg) for merging 16 consecutive
entries together, we allocate a new PTE leaf, take the mmap_sem for write,
copy the page table over, update the new entries, then put the new leaf
into the PMD level.  Then iterate over the old PTE leaf again, and set
any dirty bits in the new leaf which were set during the race window.

Does that cover all the problems?

> Honestly, I'm very skeptical about the idea. It took a lot of time to
> stabilize THP for singe page size, equal to PMD page table, but this looks
> like a new can of worms. :P

It's definitely a lot of work, and it has a lot of prerequisites.

