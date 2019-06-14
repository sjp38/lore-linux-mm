Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B752CC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:13:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61B0A2133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DnjUInTH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61B0A2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D9D86B000A; Fri, 14 Jun 2019 07:13:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062D26B000D; Fri, 14 Jun 2019 07:13:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E45666B000E; Fri, 14 Jun 2019 07:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC36B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:13:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k36so1675093pgl.7
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:13:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i1QliRSRssHtMj47mzR6P+jISSuYGuhNkArj40f45F8=;
        b=kANCho8ZTE7OygF++HUCx1sVgyGqfJtED0qN+IrWfTLxOeEE4jE7uxB2UZlmQGA89q
         TG+vpeuSg1ty2KMZ44rBbWivwQlWwKb3vJOiNF4+qF15LPfdxuR9inKOAfvV2n0MpzwB
         yyCrEldSOq7WTTH00xwz8CzPRF0AO6djELB+ilO6W3Geov64gCLYhDQ5McAEDhuGxXMg
         0ULEyUmUL9zowCJ3WTrAWwzkjhXP6Jny8aCY0GROkup2ei2NQWXrMxlzNhPfQtlg6rdm
         Hn2SkdaIBKhA7tdFT4XlNJu5q8aubwOmPKjmiefFtHXac51cE083UT0jl3ZfhZb57rDC
         f7TQ==
X-Gm-Message-State: APjAAAW+zKnvqn7C2TDDhuC6gF64HpJs15iYDsO2G1uq6SMHSiUT0rEJ
	+X5IhymeI0Y4L9+LXIJOgSPoLdcBv1s1lLO4euvoKb+kDZUEUDvRQsIz9pvt6bpE2dj1+liEDoY
	6kuWClFpITDcJ/Zrb6WAAGN1QSIpe2qtVpiHFhBDSFB22G/PIx63Zbqje7IK6MKdGug==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr2397368plb.32.1560510784232;
        Fri, 14 Jun 2019 04:13:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydaLl/shFhuFoJqLUCRf/z0hYm+N57TvH6I+aEqpEMm0I5NETjynvJW6N+RQH53e/8mPfc
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr2397325plb.32.1560510783608;
        Fri, 14 Jun 2019 04:13:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560510783; cv=none;
        d=google.com; s=arc-20160816;
        b=EFE/QDpQ1uRJyO/uOrxioXcO9YnSTxWnBFZk4UK70T4SRfECbidp6SOP9jtuQbbUKB
         seVXkVd00DZxrQoBddAk6IqU3BS3UmYBFmqQ9sSgNZXeRCoANqK5PCxyoGAltWXAUNx8
         bEN2NFTg9YxeGDVzSJybACoxVqouKJn3cVLjBl3bCblstPyQyMEs7z3FgQH9Hyr/W7tR
         l4WrXPs1qT4En41mKw4ShUG0LFLucCo1B3sEhDxznocuG0ep11Py+ji9Q/MYCb9R6UB1
         LQWB9U4sjmh5a3LHb2VLVNskrufLiUKQb/PU2wGwkvGPTbVaao4hfNx6KUVi2lYDmIo/
         Jj7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i1QliRSRssHtMj47mzR6P+jISSuYGuhNkArj40f45F8=;
        b=YJfHBuuzqOL1afr82M7yfLh7Xg7i/fSmaDzSyCuE5xdkSl59VpfBXNnJNb807oDteY
         9Qp6BS0F9W0vHBaUBYzYHKvUyFQYsWjDe4tcqZYQ5Gxq9oob4Wx7UbwDgSc3XxroE2fI
         fyMPrKjPtCs1D1FW4cNkmQSiYnF8CbTBW4aNQJOjdyRKWJtyd4ASwrKR3teaha/Bvrit
         0wa9zjPm54qy8Ma1sUVc8oKbqk+n8kGqFWgsB4WuQwN+MsJ6b1PC+phADc7hbHb0w2wp
         cD2cWX4+evV60aIa3fnUr8+EPivTFAZvrrbOlh4GbkmZKuJzzJSppXAgZXObbeDA4Zo9
         WbbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DnjUInTH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m22si2326267pgj.527.2019.06.14.04.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:13:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DnjUInTH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i1QliRSRssHtMj47mzR6P+jISSuYGuhNkArj40f45F8=; b=DnjUInTHYTgYwyh7pongXj5/T
	Ay8lbubOYGhAWlhVvM886c+bKs/VCukcuX65+3paFYKGGBEeGVcsJIe2KC7j00yZd6L2aKstuoSKu
	3fBIKkyP/CFoy+Q3If93I8UX68YZmXW6qMiO06TBw/NRzwl9/nqXH6s5ZLrD6t3JxDh61Anxa+EcA
	ZaR6RGKOmIUeg9XOimSWcemzSR1iRSOxKbLooKwqeiarY03HnJauyAnA4lOuxvby+wb18EZL0YA2j
	Z1uw0FsV4IKCM8P717wtGATtTFbXI3LzDPvs4QzF/9BWifaGUkYR1xyAV60XwsvT3L7IJNsQ+IFvn
	M5ejZNvJg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbk8j-00013Z-1D; Fri, 14 Jun 2019 11:13:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 58A1420A29B4F; Fri, 14 Jun 2019 13:12:59 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:12:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
Message-ID: <20190614111259.GA3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:40PM +0300, Kirill A. Shutemov wrote:
> page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
> going to use page_keyid() and since KVM can be built as a module
> lookup_page_ext() has to be exported.

I _really_ hate having to export world+dog for KVM. This one might not
be a real issue, but I itch every time I see an export for KVM these
days.

