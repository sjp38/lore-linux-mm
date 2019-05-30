Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B262FC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A286259C2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cO8H1JSN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A286259C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8F9F6B026E; Thu, 30 May 2019 09:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E40486B026F; Thu, 30 May 2019 09:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2F796B0270; Thu, 30 May 2019 09:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A75A6B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:40:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r4so4607202pfh.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 06:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1z2R00tGmVK2jShz09WQ0aSl4fghOklhUmq3MkzmZGo=;
        b=EaRqsYbmiYehHo75cb9hygvQp8HULPOIi6S8ltflA00Rr9+GbiGkuxfevSpq/ThKQa
         hDD0jGvYaTDm8WQHqHPJCSD5vhRmWGceHvGZRMjhepvTVBWzDOcYDIlpXepdl8Hj/uxF
         Jxfj57HsxBol4ZbO69KIGyQ+bPK6N+bhmkAPMM/YxidGf1AFuLXAIaMWwGCSfz0hVrHO
         IOc3hB3vUxoqvsN/B7bvNQDxUOoZSrChydNg9uktuHzkgMcWbnrio0pX3YJ2car78hhK
         wcvfIsH1hCHyYGU/bnbF0Y2IOdrP4duBPNoCSADiYcVQj4wtqC4nPupTWXY++lcX4t2M
         pEtA==
X-Gm-Message-State: APjAAAXOz4gm4Fjn77CLSL/JeZUtwma7m0/dkXdRgaWeIxFQe1GgyaVN
	20/ntmOdN3qI0cf/d6FExAUz0b1O5UGaZVXMnx6VxLsQ1Fj22pBefghPO4SPyv+Ie9HQ72G+cfd
	7yI767kYehpJ6pcB3brRkQhuapamTYl/jpNWAsuBp3mIL4WtjmJ6TNQ9gVCNAha1dZA==
X-Received: by 2002:a17:902:778d:: with SMTP id o13mr3509602pll.275.1559223602269;
        Thu, 30 May 2019 06:40:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiU+w5Ur4fErtLjR0phSTaf1l+5q7vUbrJrd8XdKY4bnk1qDVuhZEUQyZFVY5bcu4n6iBc
X-Received: by 2002:a17:902:778d:: with SMTP id o13mr3509565pll.275.1559223601610;
        Thu, 30 May 2019 06:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559223601; cv=none;
        d=google.com; s=arc-20160816;
        b=avTJ8OrbMkdKsAg8zbDm64TixUdYZbGi621NVrLnKAn48b/DQMDp4vqBfc5WEviCIs
         oHPrOtyX3lASI5KtjDoe/5YWMgIEzQwUC2dxPQdFohIitVc0qK4mdpImJbI8/D0LkuZP
         EBTTeNlqi0O3Bz1Swih4M+sIZ0CRppZCJBxzEtJ8Mz3fYH3Sz8QOlxl+L6ntEy9V2COP
         rAFY2SE+doieNC00+FGiIuEaN7Puu+Td1L3bIQDbL+o8KkOS/Sz4cLJySxnyvymDGW/q
         v9Dx61VVFW3zxglCmVVqeFFi/Ouq25FeB8B1cKVLByxgQnbh+OjE4OHaBjrz8Xi44oxo
         S+2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1z2R00tGmVK2jShz09WQ0aSl4fghOklhUmq3MkzmZGo=;
        b=sZWgT5aIY4BWAINCy1GtpqYaao2gJgZPRUYnbppLG4VeF0E/Vy6haOZtaaXtbT2uXJ
         Yot0+mtVyf3no7/VGloZWBWTpC3wl8VXyuoj/omoy0U3F1DclqQq4FFO5yscbgZzoA75
         8alrvRXnKRKiaT0uMtu6ygWcQP6q5w8PQaZf+1arZW2b4vDUe0nwWHogyQMykGu3V5sR
         pdFqHga6gGmAlDb1+EHoDlO4ZJgMdLFwNbRUemXLRf3H+cyVqbP3Uumd9ztSl/Up3biJ
         +k1+VZ0KJsOsNw/o19MtZ16KETU4qLm7zv6PAWGjhk23sc4ngVfrfdqMFJVIaVi5zToL
         VCEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cO8H1JSN;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r185si3112165pgr.10.2019.05.30.06.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 06:39:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cO8H1JSN;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=1z2R00tGmVK2jShz09WQ0aSl4fghOklhUmq3MkzmZGo=; b=cO8H1JSNfCwyIOlnTHicp8Zhy
	tdZp1B1hNurTw3WgAzPBczTGKcSpIkF2nUeFXWFXbacSglBjt8yYhoxBpvJQd2bkSo8SPeHDMVlbk
	AmGm77WpHy+tChpRqlM72RL0yDXaK+gT4W1Kljnz/VQ/KVDugsJZ0Tc/HFFB2pHCUi7WQ8dCXvAcZ
	squPNwIZONWngjyh6R0Q/O1CiEId8WQLaglsMjfxroLiY82v0UZBHk7vWS3/3ejIRWejmUyHZlDM1
	gPiCoTWkidUnsD2jvuDxMSsXlKB3TaOPHa9W0ihPAK8uyAmomCO3ELcq+JfaA9MCjatOQ5PlCd63o
	jpySg/rQw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWLHe-0001vX-Pd; Thu, 30 May 2019 13:39:54 +0000
Date: Thu, 30 May 2019 06:39:54 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] mm: Generalize notify_page_fault()
Message-ID: <20190530133954.GA2024@bombadil.infradead.org>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
 <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 05:31:15PM +0530, Anshuman Khandual wrote:
> On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
> > The two handle preemption differently.  Why is x86 wrong and this one
> > correct?
> 
> Here it expects context to be already non-preemptible where as the proposed
> generic function makes it non-preemptible with a preempt_[disable|enable]()
> pair for the required code section, irrespective of it's present state. Is
> not this better ?

git log -p arch/x86/mm/fault.c

search for 'kprobes'.

tell me what you think.

