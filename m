Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A8C0C10F0B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AED62190C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:21:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WIGucUyB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AED62190C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31FD8E0020; Wed, 20 Feb 2019 10:21:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB1B8E0002; Wed, 20 Feb 2019 10:21:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85DE38E0020; Wed, 20 Feb 2019 10:21:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E77B8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:21:00 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so17012628pgq.9
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:21:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EFeifr+GfaKqX300Um+mjNzD3Rm1S0esXSt0B9w2YGY=;
        b=p7h+iXI0BHvVkMNOkXH8b0orgwCWfuL3FMrYcDoVy2O1lJo1wizZjkZHRbZwz/ROTr
         3COIaO68UoE8Cn+2kZwGWnCDht8wvJp25fzOETrrgBPUPIaymSaMTBVB7AiFgch8Jtt5
         t9Y+yD8HqllpLjOLSndbNY5hFmFaMEGhk6TB5XJ9PGhzmOYE7053QS6fo8qW1Gewy3AB
         WObMa8JALQfIuco59EMy+jMb0d6nU22mWwOnoxQthw4BAd/CEAcu3zoq6tNCmA0hXdLM
         65AqlGcSpzIgYJ0390AcFaxahm5qzWajcXi9z2oEWomf2rIR8s4Suu4+SqkwbGEaPScw
         AhcA==
X-Gm-Message-State: AHQUAuZD3WskkiqBb1RGBkz0YF4HvU05hsksdoDa1/k0nWiF5cdMCjBo
	nKZSwtaHd7WEHn0y/gmMBmyhKiYEiU4yjbpxb2LM7dhDr4YKvxhu1shhwQoOZe+isK0UAI0wX4m
	f3rwR7g9ItpFK6dWrc+6B5DiKiiAUmdj0Otqou8xsek7l0jCaT/YMT+RrvROZmuDXBw==
X-Received: by 2002:a17:902:8697:: with SMTP id g23mr28373595plo.30.1550676058757;
        Wed, 20 Feb 2019 07:20:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYShjBOhbBpf1VZeOtwJ5v5HTJXrGVwkEcCnElhelL35X1DQViOhBuuJQR9qAt4b1bRuiHq
X-Received: by 2002:a17:902:8697:: with SMTP id g23mr28373541plo.30.1550676058090;
        Wed, 20 Feb 2019 07:20:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550676058; cv=none;
        d=google.com; s=arc-20160816;
        b=NTTmVk9AKInmXus1O8U0RFa9APPZl7w9qML8jc54R3lUNRSJ6m9viBaGuj293oU1an
         Dd+/9O41xDP2g1x9FtYXyolEdMMDkXpyODQfutbsv4IQ0Y55+UUdi2EcW/Jrh2U32AGV
         JHdkEdEEMBrqpLYbC2oK6A9u6ccSHWGgQ5IJ8e0CMBZMYjssh5/fb8DOT8VJurDawTtK
         KZSFmw4p3YRKdJgKmraj504Nq7tjY2HTvrXZgs7WHw/uHYhtMoAhufikcEx1hBltzE+W
         cyOI7bPIRz05xaWz/2p11JtzIAWKpf4Q+BYTKYg2qRbR57aqZ5fu0rX9dq1YSZaF2gdK
         7b8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EFeifr+GfaKqX300Um+mjNzD3Rm1S0esXSt0B9w2YGY=;
        b=nfoKVEYYsyUPqyIgAIZkDavZxtgLK4YAwWYBBQBJcMbofU9viTMMZuuut/r+/X/Ea+
         HHfEgzQf5Nduucb8rQgWo9FGpNBK5YP8RZulQ2Ukkg935Ev2WH5mPQFMk39XQ5TWu/h6
         +1LQsrrwLoeGl2l9ZWSEy3sCwgysN98F9OOqzg0dIGx9trhvXPTnN6RRDWiwKqBLequq
         avGZNGtdN6qONYyUxQ77cy6Je4OrlzWUk7ZIYuR0RA2COwFmAd3ZFpVepUOQZK7v1WfH
         cZkwwRVkoIQqEe6AoUXxaQwoNsXbSK6Y8w52SqUGJphF5gEDHnOVRjE7/FdSSS4GcFA0
         8gng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WIGucUyB;
       spf=pass (google.com: best guess record for domain of batv+a6035ce01c0cd448ed71+5659+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a6035ce01c0cd448ed71+5659+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d37si20381340plb.140.2019.02.20.07.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 07:20:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+a6035ce01c0cd448ed71+5659+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WIGucUyB;
       spf=pass (google.com: best guess record for domain of batv+a6035ce01c0cd448ed71+5659+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a6035ce01c0cd448ed71+5659+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=EFeifr+GfaKqX300Um+mjNzD3Rm1S0esXSt0B9w2YGY=; b=WIGucUyBjsGVWuL2jvGEP36J7
	wAIM66Nws+XW3bCRdl88lmFalND8Uqloj60hjuL97/UwAqCvwAh/q71HAghQoAiJxUBKDV4NeFs+P
	HVl2PIkFym1snOkp7H0Bh7Iwy3HNth61esVAhkupONHYlLPFOyNBcP6ioDPUrT9m8HmSlz0Cy7brW
	T3CThrxzbkECUC+LLP/75uJ0vWxiD0QDLR28VwL+hwhNu5iUxu99KR6fznvbiQWa2uKqaDKSSWHwd
	5uLNPR4nLxuoKU8lEnZ+ly+ElHLeYkLQbpv5lMqHn24WHv224i/dDaYfT4EtkA5c0+hIF01oAUZ5T
	N7tedkzRQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwTek-00048O-OH; Wed, 20 Feb 2019 15:19:30 +0000
Date: Wed, 20 Feb 2019 07:19:30 -0800
From: Christoph Hellwig <hch@infradead.org>
To: ira.weiny@intel.com
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm-ppc@vger.kernel.org,
	kvm@vger.kernel.org, linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: Re: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190220151930.GB11695@infradead.org>
References: <20190220053040.10831-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220053040.10831-1-ira.weiny@intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 09:30:33PM -0800, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Resending these as I had only 1 minor comment which I believe we have covered
> in this series.  I was anticipating these going through the mm tree as they
> depend on a cleanup patch there and the IB changes are very minor.  But they
> could just as well go through the IB tree.
> 
> NOTE: This series depends on my clean up patch to remove the write parameter
> from gup_fast_permitted()[1]
> 
> HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> advantages.  These pages can be held for a significant time.  But
> get_user_pages_fast() does not protect against mapping of FS DAX pages.

This I don't get - if you do lock down long term mappings performance
of the actual get_user_pages call shouldn't matter to start with.

What do I miss?

