Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE1E6C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 02:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E4622171F
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 02:06:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HRw4C/Dx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E4622171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B94B96B0003; Sat, 23 Mar 2019 22:06:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B437A6B0006; Sat, 23 Mar 2019 22:06:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A58F66B0007; Sat, 23 Mar 2019 22:06:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 638556B0003
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 22:06:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t5so6158113pfh.18
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 19:06:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4kf7mevqAtByrMjmFQKxYOg7X2YM39ANcKP/M6abyes=;
        b=Ma20e3rsyBest6jvKH9K06fUaugM37G7WIVyC4EG6Nli/qaueiKZVHw91stdws4pbU
         TzCCsEiUiJqDhsikVZMJkktHPBf8KnBSXJHuusx40nYKEbigVvr7tBv/nGno4GL3K5jz
         6SnnCjXJ99lrZxbp0GvDx0QT2s1BhGXuIbv6Qx1udMeokmKP1/xAC0eQpd4D7iBoegp8
         fUGn7eilleo/s5SAFxzXbmhRI9B4FxybJap8WP1V6PvwdfPvFq21tNP9vgNpsrbwzjDh
         Z1FUV/d/o3qQmr3mqMlhZ3QGpQD3rUZ+eX9lyER5u1SZHbJP6ltduhgx4yarsP+Dv0KC
         pW0g==
X-Gm-Message-State: APjAAAVEwAxzab1/9FfK6CPdgr1eqT3gB8uTJjbEo0AhHvfRes5A+RjO
	dHkzORcpnPpKHkbU6DuMIpEBNFBpSHCadsnRCDFZXa0SNd+IMzxfx5k9Xqh66D39B3QpOhgVaGI
	74SHcUucpwR/DQl1QooI51Adi9tkN8QXIDWEOQHdwIK2CexFSv6A6KJ7tOcrV0kJm4Q==
X-Received: by 2002:a63:784e:: with SMTP id t75mr7497794pgc.326.1553393179809;
        Sat, 23 Mar 2019 19:06:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvqbomCW/gLB8YjyjldYA7zkDxot1uTPo4Wd/qPL5dfzJz8l+m1aVk3XFiJ0OnOEnPmlZ1
X-Received: by 2002:a63:784e:: with SMTP id t75mr7497758pgc.326.1553393178971;
        Sat, 23 Mar 2019 19:06:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553393178; cv=none;
        d=google.com; s=arc-20160816;
        b=YM6RfqP9tnBYkLQlKl9COWzzbbGCByNYrfEV1z3YbBGqbO3+XreDh8ULK7ghDSTCdp
         NNiPtQZuBoMz3218mDVd1+20JUAtcbVV7QrmS1t5sti/livPB5sxDFs1Sn1fmSbEH7xe
         UaRfHYZAy+IkpRDy3uPL1BESDdEEut09WH/sbyiNNeDeiNz9S7z/YwMRu2mptt/ZAkab
         sBSIySsj/rNBNTtVlCATb0ZoG5Rl5rG19Qk1jHVS1OB3h+bdAoL3YouZhmF1cWmBFfdY
         p9qslIX8KqxorkpKWW+L4iiOsEKpKLs2uXon8a9bJ/fIQtNH3fSJoIcBQrNDOeywoq4f
         E2AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4kf7mevqAtByrMjmFQKxYOg7X2YM39ANcKP/M6abyes=;
        b=Dd5fKisbYMTdQ+mtdYYBsoRODWAiJ7X7uCkK8kmf1UX4o9nG7ZIz1y5vl+IqW0Yajl
         xh2GrdDuQiStlbbkVxzY41pi79Vd2WR3Mvgc6dT/McBXI5GBDD88ncpdPXfXeOEOYdI5
         +MR+lMrRFbuAlJt84QOUwzbixre3hFh9AmdQSlYKh0ntxesadyAtj4xXSaoC36kLDJcY
         NrajSo21gm3sZTg6ydkp3YcT7N7OcX1DF/vq5KuyxgDvCZGWFIFC8abqaOkWLohEfxF0
         jcODgIHAukZlPAHqRfFbTtGALybB1eSY/sQYuRJCLvQYC5JQ8OcxDXt9l8E9h6IRdrZf
         /T5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="HRw4C/Dx";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v5si7741502pgb.83.2019.03.23.19.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 19:06:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="HRw4C/Dx";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4kf7mevqAtByrMjmFQKxYOg7X2YM39ANcKP/M6abyes=; b=HRw4C/DxBOK3bA/l5suL/42vI
	I5xVf9LY+fSQOh1cA+5Rpv0CwEd+a3bEMD7OjhSwoE3l4WGRSLZ9rXssCmyGA+3shhI6/YH1H+4Ox
	Vb8w7cxy7LWlmpT+terxhujY5rAd+B0T8qWS/G/ad/DU6ZW78kLxjl8cZGz5vk3L1OTJ3axyB9cRW
	bFIcI2vt5w6HRZ7C9fED5twfLuDkBJt2Z/gZ2qyDIBt3YWYI6l1tPRTgxlYSnnC+A5iWNZCVyH+Ma
	8lCbzXV6KLp2NRiilOJeG6EnjuTeYOE1B4thgnW5h0zVsxL8jNvOfmj8NV6+DJ6DI3Ifeln2O6hg1
	D2ELQXSeg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7sWd-00047X-01; Sun, 24 Mar 2019 02:06:15 +0000
Date: Sat, 23 Mar 2019 19:06:14 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190324020614.GD10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 23, 2019 at 07:50:15PM -0400, Qian Cai wrote:
> On 3/22/19 11:38 PM, Matthew Wilcox wrote:
> > On Fri, Mar 22, 2019 at 04:12:48PM -0400, Qian Cai wrote:
> >> FYI, every thing involve swapping seems triggered a panic now since this patch.
> 
> Yes, it works.

Thanks for testing.  Kirill suggests this would be a better fix:

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 41858a3744b4..9718393ae45b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -334,10 +334,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 static inline struct page *find_subpage(struct page *page, pgoff_t offset)
 {
+	unsigned long index = page_index(page);
+
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(page->index > offset, page);
-	VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);
-	return page - page->index + offset;
+	VM_BUG_ON_PAGE(index > offset, page);
+	VM_BUG_ON_PAGE(index + compound_nr(page) <= offset, page);
+	return page - index + offset;
 }
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);

