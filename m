Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 696A1C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:29:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13DE5217F4
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:29:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sJnQ4Ar2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13DE5217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93B6B6B0003; Thu,  9 May 2019 14:29:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EBEF6B0006; Thu,  9 May 2019 14:29:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DA476B0007; Thu,  9 May 2019 14:29:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4433F6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:29:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q73so2136272pfi.17
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:29:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=71Qbv1zVs7uzCNDDdAMdwTNNjRic0Q+rhbAYpm3/nu4=;
        b=Wa+p8KY6ccwS1L5ZcK/nhJGsg4s+wmxyAqb4bykJo9i59F7NnYw3vDC1BG5j7g387+
         YSGVHsd1+6+BZqwufypnlHT3XBp5l9UWyUxUHierUXncBkj47Yhmvzcuxv/zhuiwu/uK
         U2/Oo1lDY+sKXqBDcVAQV3/FbTkrwzMwpeqMByrfmRfQqQwnw94oqkTHqjqSk2LjtxSk
         1BBvGYJvVvk22kDkQfDOC8aDpt+QrQyp6J4o5P+8v8AbBUAiGGGJAd7Z5hKlL+bo7HDn
         fnU1KIwEWCwu+WUMDg64TqrUdxKou0/saXTYiB93Fg8BU3oKMJsRkyU3YbaNcKHeTJrZ
         088g==
X-Gm-Message-State: APjAAAWFu7GqVuS4LHrqF+K2MGJPdDdlC6TbdepsapsOs2Y96fcXQ/YO
	R+vkX4uCYpUxSZ5AG76F8ZQBXd+iroexvW/SuIkPU5v4kDxwRRmkCNo5/emUuzeAZdTTQ8/6PzD
	gydDD0Y+Qt/DthtonCsBWpkmdrayHabeoD8ee4TITo5PR2BTqLqDpXl9XR0/bNKk4/Q==
X-Received: by 2002:a62:14d6:: with SMTP id 205mr7466080pfu.4.1557426544947;
        Thu, 09 May 2019 11:29:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKdyI/ODEfmdvfsrp9gFFjxD4WHN+A5gVjskdvn5rhANjqnfO9gySKYhf6HJPkE7WfceNT
X-Received: by 2002:a62:14d6:: with SMTP id 205mr7465994pfu.4.1557426544081;
        Thu, 09 May 2019 11:29:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557426544; cv=none;
        d=google.com; s=arc-20160816;
        b=zDdnOmk5ySaIwOEuf/HjcTIk/DVRAZiE++KQUwLKA9a8ZkVi0VXI3q2OZgzA5NDWdc
         /MHqorlE4Xg7tmVAXGiZQz8iErWxSjXVRR4wQZ4RvRsGp6QeQvR+jljFUNFxYnJUamHX
         cU1Chbnlqpi6WflY9YD1TzGCdCDs0bUtWR0u2pg8oXC0u9R8Z7JBiNgtbTuOXry7RbKz
         gzsOtBV9an9taKB1+e8dvfM/NfX8TpacHXAx8NnRqe4I6aDJqJmw4mNLjz6Jh+MWPWGz
         wt30Gqq1T+teT6Vy/2ub9dfp2D74UK9UcpmG+7/1uN4azLHi+fjlragZgoWZwlNtgXJg
         jOHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=71Qbv1zVs7uzCNDDdAMdwTNNjRic0Q+rhbAYpm3/nu4=;
        b=Y6BxkqPd78nbuiLwTWDWZPnZ/IITCV5by4XUZf8RsAgV0DrQ4QzoPmBjtbJtFpiJb7
         nKnn7IDx7Epjwid1ES1K5ieDGEVD0mHIFVecV1PJE1Zx9dHphe1Nj/67WgNiIcjuYyD1
         ZssQ+JEDwRPDh45m9Ekz64uwuvJjYqqpkkwAqQl5H/uFJAEYLo6bNvwpOyiAfG+l92nr
         fsLh741l9NvJYh6fpINwYolGbliegRhCOCRLZ1cL1uFXakNSV/AwJUM2APoOSNSCzUoc
         GHwKa+CAtEbof6RMrgC70SfW375PZ7FN8+ZOJ0Wk/KEbvcVH4x0DMW7iiHm//r9ITTB/
         DbWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sJnQ4Ar2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a7si3892936pgw.133.2019.05.09.11.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 11:29:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sJnQ4Ar2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=71Qbv1zVs7uzCNDDdAMdwTNNjRic0Q+rhbAYpm3/nu4=; b=sJnQ4Ar2j9VBEKP2/r1+NukeZ
	VTgE2fa07/IBn44q+nYgua8tQph/KICQY9eB/5HeXsY7FPpi8Gmf8umbjtPFCZSxnR6zFvWGTrHj8
	ylCLpOu+eIULK/8mRBrcY4ucOf3fKF+5DPo0pYO9New00DYZ5mMCnvnJTdxRhCUxTPOkAtHo+kSLp
	EXjFxZ8RCgqr2Dp5u9+H70DPCLI9oA0B1a3hyvurg7OjN8U/78iymSenidehqKWXYqm+S8QIkuRJV
	VgXGO1x6AbuzTQEPuvS7ziSEAR1ywDZZNk6X/YaACVZWl8ztPRP2fOT5qK/JNjljn4iqFy9E+Hc8J
	L4o9/9QAw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOnmw-0004PS-PJ; Thu, 09 May 2019 18:29:02 +0000
Date: Thu, 9 May 2019 11:29:02 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190509182902.GA11738@bombadil.infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
 <20190509140713.GB23561@bombadil.infradead.org>
 <2807E5FD2F6FDA4886F6618EAC48510E79D0CFDA@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79D0CFDA@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 04:48:39PM +0000, Weiny, Ira wrote:
> > On Wed, May 08, 2019 at 06:58:09PM -0700, Ira Weiny wrote:
> > > On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> > > > It's possible to save a few hundred bytes from the kernel text by
> > > > moving the 'order' argument into the GFP flags.  I had the idea
> > > > while I was playing with THP pagecache (notably, I didn't want to add an
> > 'order'
> > > > parameter to pagecache_get_page())
> > ...
> > > > Anyway, this is just a quick POC due to me being on an aeroplane for
> > > > most of today.  Maybe we don't want to spend five GFP bits on this.
> > > > Some bits of this could be pulled out and applied even if we don't
> > > > want to go for the main objective.  eg rmqueue_pcplist() doesn't use
> > > > its gfp_flags argument.
> > >
> > > Over all I may just be a simpleton WRT this but I'm not sure that the
> > > added complexity justifies the gain.
> > 
> > I'm disappointed that you see it as added complexity.  I see it as reducing
> > complexity.  With this patch, we can simply pass GFP_PMD as a flag to
> > pagecache_get_page(); without it, we have to add a fifth parameter to
> > pagecache_get_page() and change all the callers to pass '0'.
> 
> I don't disagree for pagecache_get_page().
> 
> I'm not saying we should not do this.  But this seems odd to me.
> 
> Again I'm probably just being a simpleton...

This concerns me, though.  I see it as being a simplification, but if
other people see it as a complication, then it's not.  Perhaps I didn't
take the patches far enough for you to see benefit?  We have quite the
thicket of .*alloc_page.* functions, and I can't keep them all straight.
Between taking, or not taking, the nodeid, the gfp mask, the order, a VMA
and random other crap; not to mention the NUMA vs !NUMA implementations,
this is crying out for simplification.

It doesn't help that I screwed up the __get_free_pages patch.  I should
have grepped and realised that we had over 200 callers and it's not
worth changing them all as part of this patchset.

