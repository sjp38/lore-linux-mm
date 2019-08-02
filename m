Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D0CC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5744020679
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:12:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J4P9XXFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5744020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F031A6B0005; Fri,  2 Aug 2019 04:12:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDA1E6B0008; Fri,  2 Aug 2019 04:12:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC8F56B000A; Fri,  2 Aug 2019 04:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A53CA6B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:12:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s21so41159164plr.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:12:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KjfLNU0SyqIyVrAxHzlRCdRO4H2dKobiLNT7ypOiSiU=;
        b=EHn5U6950+EpQpXDvMn+nnqXEeZpJNFWkpjtb6mIUCpTNjZmgr9JIDzOb1PMaT9IxS
         8YDwzPLsYIE5xw+NqwFIHUI1ED78qGjnbSMqwX43bwIpfn5KPznIzGTamGVLZRX4vQH9
         hBy2ZDb759ImTg4Mxz7/hBFscw2YW0qEMiGqAXSiU73d77rLERMUgcwnOtk/4njKQ5hG
         aRH6OPuMa69Ozk8p311Eb3AZJSYCnQMxIOoS4sRUIPzDPK34dCzLkgslPbXTpP3pTX+n
         rJvXg4bNft6mVTlxO1022Pgngm4Fj1HXU/W1Ova2xEIMwI1U0cNMWygsXNUF7ZPSXux4
         4AWg==
X-Gm-Message-State: APjAAAV6VrGh3jNDKajjMcibhfMhmq/xja15VjLAIwePpy2R7hg9q0hZ
	b9ovpTO5Sb/xB7fS12KxMHjpxVCPoVR1N1qfLtq2/j/XwmcO3vo4xm9IYJ3c+FrPaj5Xmkt/rn8
	1NtlNeWFstkG6v32dwwN4lZW8M9tR49BGA2n9+OsY0RBUROSoauUJrrYwhrO5PXGCQg==
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr125865640plk.225.1564733545308;
        Fri, 02 Aug 2019 01:12:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmUrWwKOaG6mh5dqrPkD5Tg3JbJc13G1WTebPZEDwzpVORUjnuWPPpGRVrwOc2kbN4IB/Q
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr125865592plk.225.1564733544605;
        Fri, 02 Aug 2019 01:12:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564733544; cv=none;
        d=google.com; s=arc-20160816;
        b=lE8G4zfR7JbCdeOIqC3a9Sw9SD8RLLerPDFv4Iil+fnCMeDphpX6r/tGyQbkqmPOAi
         q884I9esyPtvZyzpkr67dx4KNfANWaYqQxD1Q4436cPVn7hNHRp5jgfR/XWH6LQ3Wtv+
         R53hBtJ38Feu1KlC6SRhOYXFg1gp4cJEvYboMZgDyiMHF+6975ObQcExLnGyPO9RIPG/
         h4kIHnBYq+XnsnFPSb4VlEXcUqBou3N9XEYe6VOzD5LGn8EZpqgDSALfPQ2G42hlxAHv
         8yUKkzyLPpIbOTUbbmxUe5/RuUfL5Wh6iCp6+Gf1SnrfZZIBzl9Dm3iLVSXe7Cyi1m8n
         TGLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KjfLNU0SyqIyVrAxHzlRCdRO4H2dKobiLNT7ypOiSiU=;
        b=vrjvBb/1fVqu2KNg90gHaY0HoYaGP3Y36+tzwsbP+/TCsU0A3lGGaXcS2CgrdJAeA0
         +Kn27DpODo8VKsvNpVSHKrtE++M2jrHaD0onykOZkgJi8m5AZPpp6V+8QT9A5LGpUDv1
         mASVoueQwCRwBLPpENcDgxvK1b7MuoAlOYbAEZYiOj/R73bD7uN8HjRnqr/e0g7/xqUN
         fjkpmQfJe5cDewTWibeedbx6E+xER7YQF4uI/Fk8IG5Cuhs/p7y+Oc9vNzNCSlwv1Sqo
         inql1HXiDVbyhm0JOuvm+dgqsBnqGw/NuYLnVC3JYVD3s7MtxemC//GCuw8VcD/7pAqA
         1A1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J4P9XXFF;
       spf=pass (google.com: best guess record for domain of batv+e51aaead15bb68118d94+5822+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+e51aaead15bb68118d94+5822+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 7si36540581pga.439.2019.08.02.01.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 01:12:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+e51aaead15bb68118d94+5822+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J4P9XXFF;
       spf=pass (google.com: best guess record for domain of batv+e51aaead15bb68118d94+5822+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+e51aaead15bb68118d94+5822+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KjfLNU0SyqIyVrAxHzlRCdRO4H2dKobiLNT7ypOiSiU=; b=J4P9XXFF6r79xI9pt/gvdN9oA
	X2BwcCJGTOUfq1Js4lh22cDe6AkfCTnwQVmhlxluksQvNyI5oF9lpPy5MckRL2x9WShvEg2EGleyc
	pilujzQ40oIUsYl7Cd0HiAVfsD2LNRfimYy7A2AWWnE5cNuUYlfJoUISYSIQ7WGGauYbZ4KKLUOsw
	ZShxaJJyNljB1jTZLdCyTON4yE+V7sW94y0xtokoq4FUgM56q+Q4z5tYxT/ID2b1bjIQqDGRYUTtY
	rPEW3iODyLo8ESy8fFTBdNddfZI4K6k8qCDYVZSYYKnH3NAVbnCkynp0MrsiOL0OBLFFbBEf9Awve
	V3qlCc83g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htSfl-0004Xd-Uu; Fri, 02 Aug 2019 08:12:22 +0000
Date: Fri, 2 Aug 2019 01:12:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Chris Mason <clm@fb.com>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Message-ID: <20190802081221.GA15849@infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
 <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
 <20190801235849.GO7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801235849.GO7777@dread.disaster.area>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 09:58:49AM +1000, Dave Chinner wrote:
> Which simply reinforces the fact that that request type based
> throttling is a fundamentally broken architecture.
> 
> > It feels awkward to have one set of prio inversion workarounds for io.* 
> > and another for wbt.  Jens, should we make an explicit one that doesn't 
> > rely on magic side effects, or just decide that metadata is meta enough 
> > to break all the rules?
> 
> The problem isn't REQ_META blows throw the throttling, the problem
> is that different REQ_META IOs have different priority.
> 
> IOWs, the problem here is that we are trying to infer priority from
> the request type rather than an actual priority assigned by the
> submitter. There is no way direct IO has higher priority in a
> filesystem than log IO tagged with REQ_META as direct IO can require
> log IO to make progress. Priority is a policy determined by the
> submitter, not the mechanism doing the throttling.
> 
> Can we please move this all over to priorites based on
> bio->b_ioprio? And then document how the range of priorities are
> managed, such as:

Yes, we need to fix the magic deducted throttling behavior, especiall
the odd REQ_IDLE that in its various incarnations has been a massive
source of toruble and confusion.  Not sure tons of priorities are
really helping, given that even hardware with priority level support
usually just supports about two priorit levels.

