Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2DB5C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E26320873
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:46:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YPaurXaT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E26320873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BF206B0005; Fri, 19 Jul 2019 02:46:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2967F6B0006; Fri, 19 Jul 2019 02:46:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1849C8E0001; Fri, 19 Jul 2019 02:46:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D24FE6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:46:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so18150307pfa.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:46:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dFnx5TzMMcoSpuOVSBkt3bk6kgdNjnFBeNAo17jg5Wk=;
        b=tSHEvptrIZca5WApdTo7DNo93i8gkK7FbVTN474ZxMx5IYQnCE+jJQn/k1vBpj4GaQ
         9qqFfUoULaC5NNM3wfOYqGnDpqumwexbBIeaDz7WYps6cvWTXFY3RxICk22UW95YCV51
         6BMYlDS8FQxiWpwO2bHJ++cZJz+YTTjb2j3DlQd4jhxYGOgXTGgojqHnBm/69KGWKpH9
         v3m+ZohQFqJkmloNrPuYPsshVzoavsNd0PDm7OdEtxdRhtHYFZwaJLni3UGJ3iXJG7Xs
         NK5ZpBghwSxp4GRuv/PUIDaUYh6C4PNWJ0fvyimvlyGbAk264EeimwraIWwS4Tv2fFwX
         eldQ==
X-Gm-Message-State: APjAAAU3lyJPcBgKIUKW7BzUSIOb4WNOWELFA2oM3EIYRoNdzUc9xt2U
	20bRNCnSMazQWfmzMic1Kbt8A5RHMFaecR72PwWyvUssRnUJnGE7z3jf34vGNzoNaJzVMymudEa
	yBRurQcXHsSEItX5C1yv3KtSNBN+bJePfR8giGs4Y4YcH1f2XUsQWf4HQtIs7DmrV4g==
X-Received: by 2002:a17:90a:c68c:: with SMTP id n12mr56120704pjt.33.1563518804475;
        Thu, 18 Jul 2019 23:46:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNLzzYJ9zizLTt7irttq/Jnp+ehzrP3d3ikS5nnGSh1o1NOqUGj6AKBDAWgeZmr3oJpmQg
X-Received: by 2002:a17:90a:c68c:: with SMTP id n12mr56120658pjt.33.1563518803861;
        Thu, 18 Jul 2019 23:46:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563518803; cv=none;
        d=google.com; s=arc-20160816;
        b=0dtzkaHM4Swn3mQTPS5Yw3/zWwhmd/BM049B3cPlNvqfQwjZGLLUt3nmRYxCEDocNL
         E1Zs1E95SdzSprjLr+I4+9CoBZHFVdOkqe5w7xnc17/MOTKAc/qk2+wkyrr9HmFXFEle
         QvPqSUEEhNmLC0ZZEyqhGwOmwo2TH9gpjt/QU/sGF67qy5KAr65TnwHmW1BrcstpsA7D
         b3syEEp8rtiMW/e8IigvPzHA8sPLz2jmMOVGTxt92sS+GUzlPX9zufvnRmLbL1xxh6G7
         ar4BP3aI8KFvlq9ertJuS2g8vaoYvu0Gti1xQ/GL9ubDl4mOW84ETE7U6liKgsLUS4C/
         iyDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dFnx5TzMMcoSpuOVSBkt3bk6kgdNjnFBeNAo17jg5Wk=;
        b=OZtJ9Ij9ondd3mC33BwQPFqUopVdEz4S88LbcqoWj/d+U1Yq5hsi/2B4bwf4fcg9/N
         Jw4TB+eYrHRORv8roVWh0Sv89Pd66A+Md7qI1mtGco/vVXZ6DHHEvyrsL3CXkJGDP1o9
         xD15+Nqo2SgvcZEa5qi/4ATmU+0j/cUZI/ymae+taLr+XKkdLM3zgEMJPY7Cj7A+KUt6
         Zxd2Lh5WD89+qNTn0dsgEsiWcphJuwCItLutvmOvmZhuxVfka1f/DDlFNPfih2xMawhF
         5ezP5SBJmoX2VQUuyipB+geehk8CJUlKf4Eg8Y2Of2UiDCJnMJu/cppLVJkFcEUWhJyp
         HkCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YPaurXaT;
       spf=pass (google.com: best guess record for domain of batv+0127b854950d050a2cef+5808+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+0127b854950d050a2cef+5808+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1si4529182pgi.41.2019.07.18.23.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 18 Jul 2019 23:46:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+0127b854950d050a2cef+5808+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YPaurXaT;
       spf=pass (google.com: best guess record for domain of batv+0127b854950d050a2cef+5808+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+0127b854950d050a2cef+5808+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dFnx5TzMMcoSpuOVSBkt3bk6kgdNjnFBeNAo17jg5Wk=; b=YPaurXaTajlIneAubMagzsXcC
	s7lRHW6bMmRz5vJoILwjx09X/rG2EhotoYUCEBkPgAPRvep7T9EL8rE9YqZx+lJqfB8dIDW6sgb/f
	5ekxC+GX1RAI38SYBVesXcaEU28iwSanRRpEj/Mj05pSBUI/SgcGybCGhG5k0jsC+sqHbDva5YziK
	mxIe/MvYIGBGZ1jnh1UCzMiQK0WxQFTvo5gFiJu5VkmN0vpIF61rDTSu940GxT4YvZ0Ag8KdzjBt9
	fHnRvSoZHZKlymeW/sRI+JzKkOFfxcda4Fh/aTFGeFCY27ywJsi/kGHel8I3FcBNjtHaD6m2WGCGJ
	+rqfCRqZQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hoMfB-0007eC-Mp; Fri, 19 Jul 2019 06:46:41 +0000
Date: Thu, 18 Jul 2019 23:46:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linuxram@us.ibm.com,
	cclaudio@linux.ibm.com, kvm-ppc@vger.kernel.org,
	Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>,
	linux-mm@kvack.org, jglisse@redhat.com,
	janani <janani@linux.ibm.com>, aneesh.kumar@linux.vnet.ibm.com,
	paulus@au1.ibm.com, sukadev@linux.vnet.ibm.com,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v5 1/7] kvmppc: HMM backend driver to manage pages of
 secure guest
Message-ID: <20190719064641.GA29238@infradead.org>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-2-bharata@linux.ibm.com>
 <29e536f225036d2a93e653c56a961fcb@linux.vnet.ibm.com>
 <20190710134734.GB2873@ziepe.ca>
 <20190711050848.GB12321@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711050848.GB12321@in.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 10:38:48AM +0530, Bharata B Rao wrote:
> Hmmm... I still find it in upstream, guess it will be removed soon?
> 
> I find the below commit in mmotm.

Please take a look at the latest hmm code in mainline, there have
also been other significant changes as well.

