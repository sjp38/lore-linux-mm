Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A7ACC46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9CA42082C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Xt2zW3Cs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9CA42082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44FB68E0003; Mon, 17 Jun 2019 09:15:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 401098E0001; Mon, 17 Jun 2019 09:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C7FF8E0003; Mon, 17 Jun 2019 09:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7B9C8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:15:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l184so7714792pgd.18
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g2RSyr1LswKR5yVaExwwUghHr8GGOtj1VRSVsfBu1GQ=;
        b=mainoWHNQYhj7tuIUIx0qol36I2ZBp8AIu4vh2JR4sDnv8CvUfZj4pCtZQgaOY76K1
         CT+lLqNVEGmwlAL8yJKdjpDewZLE3Ac7LNwiJTzNp3LqwSx6j8zviI3je6ujyBMlVOvB
         p2hTe6rpzF3xq4FGaeTrzNpHhyd0bpXc/sYno053k2cwrpshNd0O73dIm235gdlVURM8
         AZx7Elv9hjqa13Vco/fKDBTYjA77TqR6BUqUp1jTzws/HajgNAeqbIOcGUgbsYVm0K1X
         vOl1PF695IZUcJ7MCcOWQtjh8qxkt3vqCfSasTDA6DJfmvz2tCGxao3ifJxnenuZL5bX
         5utg==
X-Gm-Message-State: APjAAAUbgL7CNFbjOQR9mxIMUyL7IIT8zU6F09QPA++IQSIEGtPI3XX+
	GckLeN8LnB+JvtMPb48XL7MWDGF4wdzOQgliRbkt3CJLLSWzWpR6XrX7EJGDM/WQdNQmnqfbQt/
	HoitPXcy5p7ua3rWrzmK4wRnbHtHOLUqr6clwFshG/ftDVCDufcKnTb+JbOaIPK2lJA==
X-Received: by 2002:a62:82c2:: with SMTP id w185mr94198467pfd.202.1560777322573;
        Mon, 17 Jun 2019 06:15:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv939sPoxUS9mFDAMt0c5qTKDbp2UljlJKF/seclyEMh1LnVmarx22tcbfFLZxFnbZNF9N
X-Received: by 2002:a62:82c2:: with SMTP id w185mr94198417pfd.202.1560777321962;
        Mon, 17 Jun 2019 06:15:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560777321; cv=none;
        d=google.com; s=arc-20160816;
        b=xT0zEQ080kSXJbSWYaSQaqn9gOJUUIOs+wkzyqvD/K1VFVoLCAFWkUEknsnHnmK2YZ
         9YsLm0MzFZaVyEQkD9D59exp7RxFDjoUYzy4jQYUL6KC+Waz5K9352od5vfi4KH7eAQX
         hJEbzO1CVxe7k5LwmbKSsdMF2tjqau1Xop0YTN2s/C5poCuyHBwodnMvOm3nvUFxJdPt
         VPI4z1gdALqA+RXukq1HqgHSqiRqc9XfG9DiEtplJVWx00dWiZjkn021HVgA07vLh/K/
         tpmyyz2JZJx3bczunTCAmJsI/vCGaBZjfAWuaumSTKmchFvZZWSGrDxxeDLsa6zMarJY
         VPTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g2RSyr1LswKR5yVaExwwUghHr8GGOtj1VRSVsfBu1GQ=;
        b=aMS51rAhaA2owTE2L2WTDG1FiM6SbJJITexstgva2tydef8PrXRPgE7UfiZfItANqK
         9G07T3k7yVfe3KhlhrbCenIotXHIcwdMtPxbR/zIqIKy2ixjpI5YuMNSYuZHGkmznKHc
         j7C+GU5jCNyJ2+0shM2ONsLhIu4QZ8w1RB/UBtGtDleM//GV5oj1uIh8Je4WFt5IWeYp
         DjLFfdYBKX48H5K8Usu0jLW7t/BwH+sVwFADgO+ACbLnul1xSWitHgyZHbXkZXLv78J9
         W88hYs+P3aU507teD7dM5NlW1e9cpyj6JSZQrYKf0lOU9mcj8BtijnGra2z7xHLljDlw
         Ph5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Xt2zW3Cs;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t18si10432810pfh.29.2019.06.17.06.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 06:15:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Xt2zW3Cs;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=g2RSyr1LswKR5yVaExwwUghHr8GGOtj1VRSVsfBu1GQ=; b=Xt2zW3CsTdU+5dL1qgV7m+ZXj
	9YyYU2Wk6Tm8jGRvrjoLS1or4I9L8Nqw0mQ0LRGN+KocsYE/05sPoA1/cTAa3zfdt8zIsocYAYBlg
	FgUkxfwPxd0lS5E5WSJY35W31PExqnu6CzwadtRyYO9xC9msAFx2RSs+tbpZQ6XgdZAH0kfP2ulXj
	nOcKt7dpG5G3pI6AqfqWoqte8gIMa4B6F0bH8LWDBzSBZ4CjeVlm38WCclwKZBMGauNqijnSWoqIs
	Lpk4LxEgpQUm/LviWC5Z98ShD4yCngQetj2o1PDPpTuhHsae5J9s4IXxMJyukLQ+kdkej905zEcu5
	MC33MfY3g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hcrTP-00014F-MJ; Mon, 17 Jun 2019 13:14:59 +0000
Date: Mon, 17 Jun 2019 06:14:59 -0700
From: 'Christoph Hellwig' <hch@infradead.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: 'Christoph Hellwig' <hch@infradead.org>,
	'Peter Zijlstra' <peterz@infradead.org>,
	'Andrew Morton' <akpm@linux-foundation.org>,
	'David Hildenbrand' <david@redhat.com>,
	'Oscar Salvador' <osalvador@suse.com>,
	'Michal Hocko' <mhocko@suse.com>,
	'Pavel Tatashin' <pasha.tatashin@soleen.com>,
	'Wei Yang' <richard.weiyang@gmail.com>,
	'Arun KS' <arunks@codeaurora.org>, 'Qian Cai' <cai@lca.pw>,
	'Thomas Gleixner' <tglx@linutronix.de>,
	'Ingo Molnar' <mingo@kernel.org>,
	'Josh Poimboeuf' <jpoimboe@redhat.com>,
	'Jiri Kosina' <jkosina@suse.cz>,
	'Mukesh Ojha' <mojha@codeaurora.org>,
	'Mike Rapoport' <rppt@linux.vnet.ibm.com>,
	'Baoquan He' <bhe@redhat.com>,
	'Logan Gunthorpe' <logang@deltatee.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 5/5] mm/hotplug: export try_online_node
Message-ID: <20190617131459.GA639@infradead.org>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-6-alastair@au1.ibm.com>
 <20190617065921.GV3436@hirez.programming.kicks-ass.net>
 <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
 <20190617071527.GA14003@infradead.org>
 <068d01d524e2$aa6f3000$ff4d9000$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <068d01d524e2$aa6f3000$ff4d9000$@d-silva.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 06:00:00PM +1000, Alastair D'Silva wrote:
> > And all that should go through our pmem APIs, not not directly poke into
> mm
> > internals.  And if you still need core patches send them along with the
> actual
> > driver.
> 
> I tried that, but I was getting crashes as the NUMA data structures for that
> node were not initialised.
> 
> Calling this was required to prevent uninitialized accesses in the pmem
> library.

Please send your driver to the linux-nvdimm and linux-mm lists so that
it can be carefully reviewed.

