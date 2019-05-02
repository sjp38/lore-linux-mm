Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01E40C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 01:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA6C8206DF
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 01:52:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e1Cdnr7M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA6C8206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44DAA6B0005; Wed,  1 May 2019 21:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D7F36B0006; Wed,  1 May 2019 21:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251126B0007; Wed,  1 May 2019 21:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD5106B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 21:52:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e12so461587pgh.2
        for <linux-mm@kvack.org>; Wed, 01 May 2019 18:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xNjOP9gg2QMy4x3ICBZoOoeoO4NbjsoS8XWQ33F0y5I=;
        b=uhwEEIs8pNE9T35AuH2gPcphp3othwbc/EIB7LD2J6RfV+m/39384s8c34Z5gceE7N
         ws0X49KEd+xbRHHgmA3jUZlyFnQmySdsKyInS7YrCalS3duE/MZfruibDYUSbtTNHn71
         SFLgpJrwVAVQklAgfamkUQSo1V19LW8/VBSdXPEtPyLjj3nfed7EAyqSn53w5YflntYK
         gNrtxR95zPqEv7Vf6UIP43dMnwbr6Pk1GkyCBgLEjVRsKbbbigRem0lcp8GynbB0v3+1
         egYaV5eMjqyWIpW0zyYO/1Ycahj6qc4r1NShk9Sqi8ORoMwZLgRtYPF06+T40LRDyHTh
         zIrw==
X-Gm-Message-State: APjAAAWApXmE40O/A4MEKYyt9+pe6a8no6BLt04nr5tw1gPBJrYcf4eM
	SIajMKOBTTogwzlg9yjiq3+WUgbPLtWdlbDpIhXm2WJp8iZ+DQaTkJWXKicwDsKX7YjV/34Ffgd
	5Hr4TE998HaRJDUti8MBMZOEkbp4yf/CeWLI3KFBu7WA8wNxgEHR4S0GN9rnW2VI8Sg==
X-Received: by 2002:a17:902:324:: with SMTP id 33mr845781pld.246.1556761937566;
        Wed, 01 May 2019 18:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZdjF2JrVG3PU5DEBSCTboOFnL+eJvo7ZoRnPuSHWrBu+kHsB9bet+8tWnHMxsk7lT6xWQ
X-Received: by 2002:a17:902:324:: with SMTP id 33mr845734pld.246.1556761936763;
        Wed, 01 May 2019 18:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556761936; cv=none;
        d=google.com; s=arc-20160816;
        b=tTXbU0c0a2u9jtkUSchBLjVXDGA6zbh9v2tnpkakkSCmNbU5A4/mLZEm30IHZn12C5
         guWDavP7aV2pcaXLzaaHqzA5ojQoYYpwYmdMrU3DXEe6VqH7pc7JnvLZnKMygFpYTa2S
         +UYvw1vg2yM4ouzntdSwsAAUcjzdbLMCiHIJZdpjw9EuDPWCcg3hLjvDOvaKofXows1z
         afyPzZeeEyMsYoasTPtMvBO0IgAps7qvxwBOXOajmBsmHQBfqw6vQ1k+jRXGaS85YPcC
         BAvzpBOBYaPY7JEAdtwOvyH3nXbXZHaElxJVHpjOcK2360vEqklM4z/uz+koufiE683E
         aIYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xNjOP9gg2QMy4x3ICBZoOoeoO4NbjsoS8XWQ33F0y5I=;
        b=HLGQMWgrlTRV1wNLk3pIv9INK14T+l8HT5w/iaAltJaNxt/rduEEFusDjnPsr1XIz1
         m0rglsH2zqQ8KPAHu9S3niTJ6A1KKKAdYCitKo6VX+UJBMG7EEFClUtAyankC5K+8WUK
         nHn/p6BfMOpP5qpkAB7sp5Fpo5qUktdhRsmOcl9FrHrUvcvws48iszwH3zqd4epvde3B
         Kzm92Rf6UMpEKyR9jxDzbs62HTOTqgZ8POYqqz4KX/5VjWHpGLWqAd5EhgegPpL024nf
         r6EoiVuzL+fk8FGlhYsWaOUj0HLLizeweJk316+UvhwCwCEwygPjHcT0wig0O/3wyL3B
         MRoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e1Cdnr7M;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 35si35559944ple.382.2019.05.01.18.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 18:52:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e1Cdnr7M;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=xNjOP9gg2QMy4x3ICBZoOoeoO4NbjsoS8XWQ33F0y5I=; b=e1Cdnr7Mt+nZArvTOHcIt/dcH
	Ie+TXMWhFAYA5HNxT+y63lHRcgthMLNLL/PSs84r2uhvCLp73HMv7fZ+6i58oeYNTdQzpVsYqdBF3
	nSsIM/r501mqjtAIkshkaSAWXLi3+lfbyh811CpB3RgxxHaVYJa6loRHloXhQ1iJ/dbbmb3AJHj1t
	pj+KBXXwUGZS7zTl5dGTlNJJTY1q4Id6eY+DUeLIZg2fShSdrsNHDR9dS/jmOXHnDsJZoKQLz3Qn1
	j4DV7gXZmiWBaXasQ1mnVROZhkNd7/lbqMTeCiyj5EpOonGLtzfwRwoMya+eznp6sO5aOwOgMiYnW
	PWVOs2XIQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hM0tT-0005DI-4W; Thu, 02 May 2019 01:52:15 +0000
Date: Wed, 1 May 2019 18:52:14 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190502015214.GB8099@bombadil.infradead.org>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426152044.GB13360@redhat.com>
 <20190427012516.GH1454@dread.disaster.area>
 <20190429132643.GB3036@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429132643.GB3036@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 09:26:45AM -0400, Jerome Glisse wrote:
> This is a filesystem opt-in feature if a given filesystem do not want
> to implement it then just do not implement it and it will use page
> cache. It is not mandatory i am not forcing anyone. The first reasons
> for those are not filesystem but mmap of device file. But as LSF/MM
> is up i thought it would be a good time to maybe propose that for file-
> system too. If you do not want that for your filesystem then just NAK
> any patch that add that to filesystem you care about.

No.  This is stupid, broken, and wrong.  I know we already have
application-visible differences between filesystems, and every single one
of those is a bug.  They may be hard bugs to fix, they may be bugs that we
feel like we can't fix, they may never be fixed.  But they are all bugs.

Applications should be able to work on any Linux filesystem without
having to care what it is.  Code has a tendency to far outlive its
authors expectations (and indeed sometimes its authors).  If 'tar' had
an #ifdef XFS / #elsif EXT4 / #elsif BTRFS / ... #endif, that would be
awful.

We need the same semantics across all major filesystems.  Anything else
is us making application developers lives harder than necessary, and
that's unacceptable.

