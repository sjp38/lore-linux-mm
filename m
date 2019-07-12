Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BBF5C742BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:51:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 006EE20665
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:51:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="M2dP09VM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 006EE20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C7A28E0147; Fri, 12 Jul 2019 08:51:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 850C08E00DB; Fri, 12 Jul 2019 08:51:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F2298E0147; Fri, 12 Jul 2019 08:51:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 328F68E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:51:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k20so5652616pgg.15
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:51:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rwpolTjZGqbTjwkLH0mAAIVI9rPZBe7E59f4u4dvndk=;
        b=Hy4VlA3xtAdQlS28s0fsCED5x6NjCQRP1oughaDDClmnuVyPwHQep9EQVXMOueXVcy
         VTfQFQQmnWvbYFo4FCi7XgweDuY7jvgp0+lMQZfnicDqqfk2IevRjVynScEYME0kK753
         rj3Q9KoTFsv4OheYbELu8vEORhaKMNuIgk0hZsY6DAK5ySoR5pMx2RkSDCF+2FGovzln
         fZz1vAK/fDQ6PdY6yETNpoooAU5wGqCczYTjI9slNiGoX3mFxJwAc1vS//9N2qtusTWT
         xAx/wWxCiOI1wo+a173VEnNzxEAtCAVDChVcoH6mPsRCF0KDcNaTOs4dgGirsNZNI+rH
         iKFg==
X-Gm-Message-State: APjAAAUjR/cjOykD6Hxuw07OCWoQGWYXM2ifLn31P350HAbyRP3BJ7+3
	1PY8pvTDpYhkmlck10U15kiPM9L+1PysxYP70V23mPtfKxlCRCwpQytkXgLIAWBudPNVoYV1QHW
	m9iLlztHGciqrfPcPByT0vpw6bIsehB6TGFy/GOpa67Tz5dIO8uUkAYHKF6VUiCioYw==
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr11634965pjn.95.1562935866777;
        Fri, 12 Jul 2019 05:51:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjvsIen3TEmtwNUlecgZgSgUeMEG29ZdQrBJXvliur45lZAdNBtVFczeeDQc5E5Zt0ChYm
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr11634908pjn.95.1562935866120;
        Fri, 12 Jul 2019 05:51:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562935866; cv=none;
        d=google.com; s=arc-20160816;
        b=vaImsEU2B3zgCUUPRBQ+Gew74dvd/l8rBKPzvcu1v/4mMslzSciCMMrC1lyng2loLR
         9QRrjl/XHSK9mSnr1y009spFKinkP/J+1WcBWrrfGD7MdLlFEi0w6DpLqyS8C3CWmgGc
         Gd1nFk2OrPt+Jvw15ZXWHA4O6/7Um3vSItSO7dw/FubRLqI/VAuw8bUahOI8pA++wFLB
         oOdLghV9kpMcIjKwfg/ah5mcSmYnX63Djl1+HBYxSTrHFDiDWTfW5kdgSv1djM2yyedN
         UWyqYb+zrsIiTqcgwnqM+qMhld06mqcbq+LLREwJsmc+7p1bBwxFUSZxmWpmzSZosMpo
         znGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rwpolTjZGqbTjwkLH0mAAIVI9rPZBe7E59f4u4dvndk=;
        b=ZoAcfABj+rFYMAHJcDEvJDe9kj0JeImCxNRiSwX0v05fqVvTD0WYL3KybP5dH/2+IL
         MiQasufoLhu5j7V7yHIyKC9/247kndATJi4gz3GRr7X8LwNxqRMqT33scNFwAkchplgC
         KmRr/Vir4dKUCnjZaD3oPvfBGgFywS2zI+rdQ6R8FWfKx7WX7KCds6qHY0AhLyCzYCN8
         JNhxdEFyMhhbBCSGOEvVJ8tuGdzTeAfFHiL+OnEhv8cK/vfY0oNS0rgoDTW0Y7qc2Yqt
         Z9EjhMmPW5yNGwzu5hOg/Af2pnzuj/wRE6enjRjiltyG/K/y+wSWfQ1dO5TtS0eIK3gF
         H8Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M2dP09VM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j7si2132032pgh.158.2019.07.12.05.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 05:51:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M2dP09VM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rwpolTjZGqbTjwkLH0mAAIVI9rPZBe7E59f4u4dvndk=; b=M2dP09VMp056HkHzjt4KD8h0P
	pj6x6MKN2KDyASTibms8pAubzJ1mr3Q41T5d9AbtwAdaZ7h5k8x3fIJL+eT7wXHVf4JC6fk9HXPkd
	Dl+vY4CxPI7HGeG5FRxCOoZOf+vS0SugPI9EnN3u5EEH+KgIrWyeM9oITXrkmbUl2JrcbiL8X0hip
	zWBcCskL2lMgRkYMZhT0e0cE6dgndhjznxtrzxudGf5lkhjjHKJGRS2R9TnhQ7woa9LpARKBL13k+
	6O5AuHeVjb4+jADAERfPyUCDygpN1T1I9gL6OaxZnhW7VPjq1virgpae/SjTED2hovlyYB1GQPs3X
	GHeANTbMQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlv0v-0000Mt-GX; Fri, 12 Jul 2019 12:51:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BC3D4209772EE; Fri, 12 Jul 2019 14:50:59 +0200 (CEST)
Date: Fri, 12 Jul 2019 14:50:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
	rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712125059.GP3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:

> I think that's precisely what makes ASI and PTI different and independent.
> PTI is just about switching between userland and kernel page-tables, while
> ASI is about switching page-table inside the kernel. You can have ASI without
> having PTI. You can also use ASI for kernel threads so for code that won't
> be triggered from userland and so which won't involve PTI.

PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).

See how very similar they are?

Furthermore, to recover SMT for userspace (under MDS) we not only need
core-scheduling but core-scheduling per address space. And ASI was
specifically designed to help mitigate the trainwreck just described.

By explicitly exposing (hopefully harmless) part of the kernel to MDS,
we reduce the part that needs core-scheduling and thus reduce the rate
the SMT siblngs need to sync up/schedule.

But looking at it that way, it makes no sense to retain 3 address
spaces, namely:

  user / kernel exposed / kernel private.

Specifically, it makes no sense to expose part of the kernel through MDS
but not through Meltdow. Therefore we can merge the user and kernel
exposed address spaces.

And then we've fully replaced PTI.

So no, they're not orthogonal.

