Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3888BC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E326921954
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ciyWTDMr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E326921954
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E3F48E0003; Mon, 17 Jun 2019 03:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66DFE8E0001; Mon, 17 Jun 2019 03:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E84A8E0003; Mon, 17 Jun 2019 03:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13EB88E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:15:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d3so7177172pgc.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:15:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gpRMsfGNXtpOHyXo1HHqlE0dlVAyPKBRJRDhBOKV9jk=;
        b=i5mOQyQbIKWnpAQSvyjq3UIY+dKM3MPE+xv0DIKVz6CoNm89L1U0K5jdM7Bhvyy/Pa
         dxfsN+xToehDfoCAshGHIbROKQEdt4aP3VnXCxEAgllfhkeE0FDITnM0/JXfAAXYA3iu
         LA8NwGNW7KA2ugv0ZAFAgoBTQde6JkS+EoHLv5xi/Av5+sKQkqy6ssEaAycvGnUUyga9
         B9eWT7jrGMdVq4tKGEFkatdXc/YON7HqSvUwtJtwEXGWs0J/rn0J+hsBLYs1pNLhdyYm
         khEmSutchqWQVAJfoz12O7KXxpSP/HHvPegi0RwVA9JHbHsmiJGk6yL89jciC1IoYhg5
         0hHA==
X-Gm-Message-State: APjAAAUSj5jhUCwzD4b6pKYd93qUNSdTH3mJnLU4y3y2Mh05MyVcc5Z8
	lM0UzO7KSARp2i8E81zVD0FFnCgfl9ygES6CIQdgWxQUjdDEYDfkfWpq+DlzC4a0EN9K8MbQC3G
	IzUGWuWIPt4bHjxpmpDH0Rf5AhsRjaS7ZoiDTeeWf3ZiQpo8jmPHgTNbIi3Sjs9sOOQ==
X-Received: by 2002:a17:902:9f93:: with SMTP id g19mr90849356plq.223.1560755751698;
        Mon, 17 Jun 2019 00:15:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyN4F8uufqCTeFVQgyp94eCjUloWTmjTuIxR4/yZCXUwRmIysAnbgV6tN1c6PSjgNy4ft+
X-Received: by 2002:a17:902:9f93:: with SMTP id g19mr90849311plq.223.1560755751103;
        Mon, 17 Jun 2019 00:15:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560755751; cv=none;
        d=google.com; s=arc-20160816;
        b=Ut53Isg1i8KHqzjgqiLYDLbv2ZViSPYrO8GatkE4bL4pDZOxBGgR+zbvH2lnmcjqTX
         QwCX0e+Lv4TIcaaG7ZzvST+G1pL1PXUIncjqKNZBfGl8cTQQvYJKCwT7SZzYZvpbS93x
         J5iBRzCV3vulkTpwio1j+E123baMFIf4Ujuh+mHxHDK6w2BwJ2HZMNA/KKdDHuKW+ntQ
         qBPayk68tB0xQbCc//C2E2ktCp6/v+3Shc+rXcWaNXfoy2kQjXNW47PZpWFIWta1omDz
         oSwKwBgA2kK1ekVv66/pkwSU9Utnx6rzIWMiunh7n5VuIiniqAkTrZCBQbulCbJ6//te
         1Ycg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gpRMsfGNXtpOHyXo1HHqlE0dlVAyPKBRJRDhBOKV9jk=;
        b=PlYbHEbGLV5IQfQjfoSDfIm/el+BG7HJfcmE/mLzdmuAMcQuEpGwcufFxBhYarPNOz
         qx1hRGarBK3dGSKXO66mQMN7DHLgg4UvDBlKshj8ZPN/Oge0sC8+qc63mAJsre/RSukb
         ABTSSPpBlrNaVO4eWx5B8f/kBDuZxpfEPcHZNXUKk/xlR4uO15HOKI4OpbLQbVxwV2PN
         xbHrItiMFUWLgAONiZsB7m1pO7hfY7JClTYmfpOpgOT4SkuxTnt4Z4On7jayJOCItHA/
         A7xxp0usggxAb5367YeVoG5qWCLmyQhIRKV7Ed+E/xvBl2V2GKE6sGXNA9YupPrpnrt2
         jMww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ciyWTDMr;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p23si9993302pgj.356.2019.06.17.00.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 00:15:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ciyWTDMr;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gpRMsfGNXtpOHyXo1HHqlE0dlVAyPKBRJRDhBOKV9jk=; b=ciyWTDMrwSY3eNjL+rF5wFxvY
	Hk0lkKZBcBzvIMyNlZFE0NW6MIWRBlxlwnMDVqs7KohK9iSwbzBy5AnCQbGRDRPTaWJDWsBEHbf6S
	x2vJX1VhVXZiH6spDpYQwXl6RqXuKAeRagnraCMYavKvp+Sc/fsLkO/AHgrZtGSgDWkuGS781Vuej
	UCWQr0KsCKYjfN/XoK5gwW2s3OqBX2wib/0PrlfQSff+SB3cwgBxTivqhBuUUuo0TcpdenkP5mOgs
	nBHx8IXK+RndchBTpjqETN8U02sGo2U3SxhTEnnzA9GKAfbuiopJf2aHzCHL+/P6NlBB+1co33y6L
	VDNnrnyjA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hclrT-0005ke-Jx; Mon, 17 Jun 2019 07:15:27 +0000
Date: Mon, 17 Jun 2019 00:15:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, Jiri Kosina <jkosina@suse.cz>,
	Mukesh Ojha <mojha@codeaurora.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: Re: [PATCH 5/5] mm/hotplug: export try_online_node
Message-ID: <20190617071527.GA14003@infradead.org>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-6-alastair@au1.ibm.com>
 <20190617065921.GV3436@hirez.programming.kicks-ass.net>
 <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:05:30PM +1000, Alastair D'Silva wrote:
> On Mon, 2019-06-17 at 08:59 +0200, Peter Zijlstra wrote:
> > On Mon, Jun 17, 2019 at 02:36:31PM +1000, Alastair D'Silva wrote:
> > > From: Alastair D'Silva <alastair@d-silva.org>
> > > 
> > > If an external driver module supplies physical memory and needs to
> > > expose
> > 
> > Why would you ever want to allow a module to do such a thing?
> > 
> 
> I'm working on a driver for Storage Class Memory, connected via an
> OpenCAPI link.
> 
> The memory is only usable once the card says it's OK to access it.

And all that should go through our pmem APIs, not not directly
poke into mm internals.  And if you still need core patches send them
along with the actual driver.

