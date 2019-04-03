Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D74F2C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 775B0206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:24:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jLEUlmhS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 775B0206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09356B0007; Wed,  3 Apr 2019 11:24:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB8BE6B026A; Wed,  3 Apr 2019 11:24:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA9596B027A; Wed,  3 Apr 2019 11:24:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 778256B0007
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:24:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 42so12527116pld.8
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:24:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hFeBLOZeBtjEsKXGsqRA4gQsMvEg/4klMc4N3IGv0Tk=;
        b=H7aUKtPObSH2ypCSQdt1rDDR9gLxqEBooFTBhP3rKEcfSrDiZzn07olt96JWfrF4Iy
         ezeFwfp1lbO7gJDQ/SSnszbNFNdeZYsdRdzS4gsLnzy4aGEnGxTclNayTHh8/5uEu6Co
         tDn4bQKG+6mjPAPG4ZWem7OzbUJoxDBQdbQQmC1e3Sey61GxEuZimr3oLv46aCQvO4vu
         gl/frlil7qqgHOV9kAtiUw3F3hKRTgE1kztiUOt2cEDLKCyX3O5vfsYOqwMdUqIDICym
         uVfJNJgVYkSQAEseKcjCMr4T0Wyph+2risrVj3tRbmPtq72yM9jxbMj5AjQRfWHOrdIk
         /s6Q==
X-Gm-Message-State: APjAAAU/Cv5KGXAl5Iw1ck/sA/Tsz6krFxinhvFtIii00h3WbQYUMeaj
	6YkQaPZZzknH6qx8sHLv+ropVMJwjWS9gpLo7Vh76fIKJAInHqHrJhukVVDLwsQO0klkV/pZomx
	l6G3trKhKVXycQU44y8H1XWHn6585/daxje7Mrmk89lQBkcSETljazTTyXz8d5Devhg==
X-Received: by 2002:aa7:8453:: with SMTP id r19mr29447pfn.44.1554305052925;
        Wed, 03 Apr 2019 08:24:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZpdDoYV4qaX7QRi4VTJNcZsl2jTrVrEYvHGUmXg5MINXo9uF8c6UO67yU572Jy/T+l37L
X-Received: by 2002:aa7:8453:: with SMTP id r19mr29293pfn.44.1554305051175;
        Wed, 03 Apr 2019 08:24:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554305051; cv=none;
        d=google.com; s=arc-20160816;
        b=QcySJ30jYr/nDH0THoVb6c2LxzPjcBgi+DDOuKPzC5Sgjzrh6ysg34C+6x2L5FFCf0
         C2qcfgn/9PbIkJF1w9Gg1j7GXUJ4NyE/kq4l54ZJMtiHveQmcV4/yZVmGhRzPqkFBmna
         oST+iYwTSAirALmo6LIckBQ2j4xOxCrO5W4m9AQJJjuo/pkgXz5I+1a+jGnYINsTGqKB
         UA43wIvTdxYp1B24pUrIuJatDzzVoLkOtZRa2rec4QG9hmRMv481r4MMuIr21hUtdpdc
         uI+O8qpRCE8UFCdpaNqJORx5Su4NaO8CF1pKJ9lLuMy5OE8DZZaHOXiNRsRXLW8aeKUu
         ltzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hFeBLOZeBtjEsKXGsqRA4gQsMvEg/4klMc4N3IGv0Tk=;
        b=ZdVDgbgLfHogYuL1TZzrIcfCUzAJDRTrPEysAVurBe2q4r+DNiBx1CmNk6Ogwe/MoE
         lC3RjlH5ogBgs4DB0/jYTL0Qmg+qkebnGWf0t9gbf+EVBT4GoCyA20P/hzdj4g2i4iL7
         pmliADGtSr15O1qygIEtJwASyMh7OsEJSfADQppH74xBssiMKtFfqxiIy+YGuQTre1zx
         XdePrPOrtLdSS38/Mo/7WkRkYxZ9oq4UMBG8CWCJAImAk/laE7cm7rhms9hwkU5EcZMR
         /lqNb46+/WT7zU+tGggXeC5OzJrmSQZqPiNEQDXNkYcBRj9iO4B/9ETiWQq/kzffN9eg
         aGZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jLEUlmhS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 91si14329685ple.299.2019.04.03.08.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 08:24:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jLEUlmhS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hFeBLOZeBtjEsKXGsqRA4gQsMvEg/4klMc4N3IGv0Tk=; b=jLEUlmhSfFViL2DU0i7klJ1oJ
	NTnazxywHhBSCrYsetjdi77DhswL2Z1O8vFwXNRCWx0o1VKE9v10fxMnEVEEl59FYaTWLA2T15mvM
	pf6tbVKihYUJ2fROl0nWwZdQNXi/BLII3drZVJOhs/ihz9kR2Nlrck80f2cMC28sK/cliapce1/vm
	f4nIFyKImWw1HfwgGtynTAoYhJwOyrFAWL5fD2F9LsxxhI14J4h4J/rVUoUoBKisKQU54ciIC8UGJ
	phkuvMWS4zalMTta+QXXpfCoVlsMbYI/RZ7KCJObpXIb14RxHEWojKS/EW2VszqPxzswYCN8h2p5l
	dKUTT2pPQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBhkF-0000g2-Fm; Wed, 03 Apr 2019 15:24:07 +0000
Date: Wed, 3 Apr 2019 08:24:07 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Tri Vo <trong@android.com>, Randy Dunlap <rdunlap@infradead.org>,
	Peter Oberparleiter <oberpar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Hackmann <ghackmann@android.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kbuild-all@01.org, kbuild test robot <lkp@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] gcov: fix when CONFIG_MODULES is not set
Message-ID: <20190403152407.GG22763@bombadil.infradead.org>
References: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
 <20190329181839.139301-1-ndesaulniers@google.com>
 <83226cfb-afa7-0174-896c-d9f7a6193cf4@infradead.org>
 <CANA+-vAcW0VfAZmZWi84s1pQQ+tFx8VyzYsWi5_gj7vHT3Ao6Q@mail.gmail.com>
 <CAKwvOd=PstHEm_Vxtx_SGanKhAJSjoQiCb3kgCVeK4peUF2k-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKwvOd=PstHEm_Vxtx_SGanKhAJSjoQiCb3kgCVeK4peUF2k-g@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 09:54:50AM +0700, Nick Desaulniers wrote:
> Looks like the format is:
> Fixes: <first 12 characters of commit sha> ("<first line of commit>")
> so:
> Fixes: 8c3d220cb6b5 ("gcov: clang support")
> 
> We should update:
> https://www.kernel.org/doc/html/v5.0/process/stable-kernel-rules.html
> to include this information.

It's in Documentation/process/submitting-patches.rst already.

