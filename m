Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0036CC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE18221479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:37:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CIVdNiHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE18221479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484726B0005; Thu, 18 Apr 2019 10:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435A26B0006; Thu, 18 Apr 2019 10:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34BED6B0007; Thu, 18 Apr 2019 10:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDDD66B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:37:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n5so1471729pgk.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=noo9RZuSmQzMt67aa+GzHzuTRBl4Y+P9KScgu1KB88Q=;
        b=aUKWNhX0xH9Pe2ySh5oPxGXIVwt7QTaKgXDwP9/wkpEGGS3xMhrDprfq00HqzajqTP
         zpqlctiU0QTLnfgt9BqCxnh68jQoo4977FgrkXIgYh90DSiO6n1ZAHNUrlZAPZRecRwX
         yIoCd4/e20JhFb3+t+tSO4HexXu9jkMRsG9lmlx6xx+EoMVnn1KpfZg6L5HzJ7sHmqNh
         4tbQc2Cr5UvRHzytMgI6flSIrpLu8xqTZvxZMTw9ngEo4Xzz0Cd5epMYqszCtSHsV/wz
         IArb5F1svimt051ygQEU3zZWAwYVOUrNsXWRG5ebwE+4uIh/suNK+SvnzOuIgIKLc9FR
         Au8g==
X-Gm-Message-State: APjAAAWhkx6lChqwDwLEQjZUzD15NWyYXWrKGKMdn0Uk8cfcTEewu7DM
	G0fpgXgZfiC/JStn82LlKtDKtedoJODhQwmA85OwS6XwYwjBLoiwTf4NgGVdJEGP0RbwqTkZoec
	CGsHAO5uLK2BUVcYCa2Oz2kUtVUev/uzB9CtxYqx+baUudALLc5jbOuigwWYBZr+fjg==
X-Received: by 2002:a63:e045:: with SMTP id n5mr89564675pgj.230.1555598236640;
        Thu, 18 Apr 2019 07:37:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5KB15KzfP/CwRMVSRyX/dyFOFnDEQtDHy07KtZq7q/BBSQtGRFzmKpJXODHvoDaXV9/Qv
X-Received: by 2002:a63:e045:: with SMTP id n5mr89564607pgj.230.1555598235827;
        Thu, 18 Apr 2019 07:37:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555598235; cv=none;
        d=google.com; s=arc-20160816;
        b=QOXdrV8rHzLas01VGTX9Oita+0zTxgyY2TaXTTn6FvCvYpGSoCI8kh7AtUunQhXo1G
         bSB2UpkFnpeYdS4pNzYs2XgXk9ETyZp36yNCge74X/xByqyBAU9zMr1SXi8GReeuYcIr
         cHMXUPUkwIlQpurMpwnGujRUrTv4sycuZmKm1eqj3209JlX61+2UZe4SI1l8RGQMmEwN
         dCfIZE6WTL0os+kbFfjJl1a6zlkXG0h4+HOgosxpfnzAmDfh9b6xbaeMPFsGDLgqHXLu
         afbuETNqG1kNELfqGb7rGL1n/GR+7P58PDDn/WB6IRGDJ9IT0D4q/uVxZAtXgtg6G+82
         iSdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=noo9RZuSmQzMt67aa+GzHzuTRBl4Y+P9KScgu1KB88Q=;
        b=XwgP5rwIOO8i6DArI3jI9wieDb93+R5Qg7irF220B55NxOuTXhgau2YkPUerXPxKu0
         gbtxUg+E+M0jt+dAIWANsZCeIUX+1vAwOqx7QewXt5710FqblkuW/zuAM6n9yDNXyWNu
         4lqWlJc6P0M56SMYOzj8ingj5bpSskbZOUoLs0fR9YCNYhIf2jmL9J470vrOQlFpx6Ap
         9M2rSEROObFIsfjv2PQ0ZwWRZQT+xdnuFzu6N7E5mBUJFM330CFKlu+iVsPFzsMNNBZJ
         AwGR5xW3Nhi5k2c8yI/T0YqKYZG3T3oloVlVXxNFHj0JygVf1mF/bgw/oS+lNsvWJH4u
         CFsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CIVdNiHn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16si2358708pfh.244.2019.04.18.07.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 07:37:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CIVdNiHn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=noo9RZuSmQzMt67aa+GzHzuTRBl4Y+P9KScgu1KB88Q=; b=CIVdNiHnksaNJux5nRHHoIWZD
	wLYwAOSC5nitkHKSXWezArXQcdT5vCBuak47ikvMm9ZLrCLtYgWLQg825DrjKNiJ3gNQ6+Lh5oj/M
	xx8SAiuPTveLUSFWKTpUkyI6a7si0Mj0n+kGcWfuJCnb/QgpRnHQLQZlHMQbewE7faSsSffOA5cM/
	yEcYUqyluVR2BT1IJLhW6vXu+1w+c6nwDzyZ6Ry4LW8dIpO4BB5p2rCFFTFf1v9gbVwNg9ZKyZzQR
	Tq2ga6cMnNvP4QFIkzyHRYMR88VpbBisOkm7HMX9iag6qxN26Yzva8btPNYEfEGpleOtgP4k/FMQY
	GaKkGXwvw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hH8A4-0001py-8I; Thu, 18 Apr 2019 14:37:12 +0000
Date: Thu, 18 Apr 2019 07:37:12 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Li Wang <liwang@redhat.com>,
	Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: v5.1-rc5 s390x WARNING
Message-ID: <20190418143711.GF7751@bombadil.infradead.org>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
 <20190418135452.GF18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418135452.GF18914@techsingularity.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 02:54:52PM +0100, Mel Gorman wrote:
> > > [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190

We lost a character here?  "_irect_" should surely be "_direct_"

> ---8<---
> mm, page_alloc: Always use a captured page regardless of compaction result
> 
> During the development of commit 5e1f0f098b46 ("mm, compaction: capture
> a page under direct compaction"), a paranoid check was added to ensure
> that if a captured page was available after compaction that it was
> consistent with the final state of compaction. The intent was to catch
> serious programming bugs such as using a stale page pointer and causing
> corruption problems.
> 
> However, it is possible to get a captured page even if compaction was
> unsuccessful if an interrupt triggered and happened to free pages in
> interrupt context that got merged into a suitable high-order page. It's
> highly unlikely but Li Wang did report the following warning on s390
> 
> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190

... so it probably needs to be corrected here.

