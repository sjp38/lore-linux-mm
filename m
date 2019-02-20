Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B27E7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 17:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4929D2083E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 17:19:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QY4bhRsY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4929D2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93EE48E0028; Wed, 20 Feb 2019 12:19:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914CE8E0002; Wed, 20 Feb 2019 12:19:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82AD08E0028; Wed, 20 Feb 2019 12:19:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43A658E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:19:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id k10so19294770pfi.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:19:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bC6pS3j8UW8GudgjKyKfkdkz6KXDOgyObG2XTOWM/OQ=;
        b=Geaov56OpzdrJsNLnvWvq3exJwOxnwH4vcfPCCTs+fN14dyNuVu664t/woGIJJRNeu
         HgzWKJXNUHmuk2ndeKy0rf66FXOjUzvV844Nj6vpgxXzCe208JjGYAuEcjlW3gRIkBXU
         lRAuq9oae1iF5O7rrobwSCPyDVtO5lMYcf+hY2/tyiZbSuEHm4bupyPDxbWKvpIS61DM
         nVMpoNHMmA6UiknjOVUYr+sPTer4g1BAEYUPTVnunTHl7tka3DEfNtJr6gKoWfcYYKez
         FZlTavRF3ZKVAcwAQyzfOYs/D8XjXaGIspj17neku+GKnUFFsMkYzALV7r1q5o5LQ2Mf
         Cxcw==
X-Gm-Message-State: AHQUAuaEtQ/OIK9RnD6URfrCvquZ3L1jFASCPIohpnSeX+q2rV/meOhP
	hAmgKEiTJ90aIxv5qLkTFlssTny9S64aI0KZKs/Gswj2PGUIbrEL6nh9wH6KppAXdHunJ1wJ1/6
	aGSRaqgcChwPa2ugDD2vqN/9bAe3AEEdV2lSwNoc2S3nL/imY6p0BDGA3mrzU89aZBg==
X-Received: by 2002:a63:8341:: with SMTP id h62mr34432933pge.254.1550683148869;
        Wed, 20 Feb 2019 09:19:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZgju2VYLbX4vgx9A2be0+oK3RlpoRm9Thml6fGsk61KZzlQO48wcX6RetU9etwImLlYMPl
X-Received: by 2002:a63:8341:: with SMTP id h62mr34432875pge.254.1550683147988;
        Wed, 20 Feb 2019 09:19:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550683147; cv=none;
        d=google.com; s=arc-20160816;
        b=Seq0NpZdsQ9bAFTo5SYNVsGnPCGdHHZ8417df4UItSrdVEsIRu1akL4bBMM93Gz6Zg
         f5Gf2o6YT0iq55eSPa1mquxYQskEv75VGR7zag8kWUgSo4ck/EvMsGU+VcOFlXySq2FS
         9vD+AJv+jZR4vu40N6l4LR60FOtPDLED6Qg7HuRohd/bY6L0xrkcraNbHiI0zgAOxXLD
         A6WuGhh4M3HZrVcz+CT6hppwamWu8i/lhFNY3paDmK/m1FR2oBIpSDP035AHRy5mSwl+
         dHr9DZZx7h/K2uztQT3gqLQCkgLp5jbR1epp4XLNNkkM3Brrqrf4BVSmYLb5ASza7+Ke
         awqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bC6pS3j8UW8GudgjKyKfkdkz6KXDOgyObG2XTOWM/OQ=;
        b=E25IdVImirnhJ0hcaiYRz4uq9/AVh5D4QEkMRc6jeA/X038+IfryY+8Kd2Hm+BISOj
         33MUSwTsfNVUAcGzH9fVTbB6FEphwflgRYzonps0HuFlcZ+F+F86+EV81M3iMQoXoGm3
         uxxv4BQAMXroO0KFsXf7LCl8MN9+zYJGK3bbB3yhHtl2sZUzO2eKtDfSSyOCeESVgNZd
         8jaqRKGnfufI/veWZHWLIgk54Q9nXkKXAx+IW/2wdhNffiPbADttROdLlKRboxRUiR7E
         g43B+/dA69pKjpAayBAPS2Zn4hGa3KM39yoWzkWz7I6v9yeMzVSXmKcf8giGHJZy5Blp
         rAmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QY4bhRsY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x14si15992551pgh.98.2019.02.20.09.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 09:19:07 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QY4bhRsY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bC6pS3j8UW8GudgjKyKfkdkz6KXDOgyObG2XTOWM/OQ=; b=QY4bhRsYDzRNTOM1qq9a4tMnb
	z+0X098AK3YnufVjQMCwey7R6j1W+CTt3824QpW6LaHOEpwzZJ8Ob973TkZqMoi7yqTFk1HE/OseQ
	XWIYmYs587b+iiDGR0AdgED+b0YkGoZ+lbjStxohN233IpOAna2ILerpnjrpf9T8gHPhfjM2DCIHG
	b+2iZACa3SWhmjX45MlhaBpYThg+WsbaQ3q96O97PqXzxaDJOGxdOtxeMSDybxRhPjqOO1oovGqhZ
	yke4Cxr9odjig2+9nqu3ZdXfOc5cTsgOfsNhXWsFtSx5vvOa3tEVEc5GV9jlVvUnnumBWC1eeni2f
	rDHaAHkBQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwVWT-0007Wd-95; Wed, 20 Feb 2019 17:19:05 +0000
Date: Wed, 20 Feb 2019 09:19:05 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Keith Busch <keith.busch@intel.com>
Cc: William Kucharski <william.kucharski@oracle.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-block@vger.kernel.org
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
Message-ID: <20190220171905.GJ12668@bombadil.infradead.org>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
 <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
 <20190220144345.GG12668@bombadil.infradead.org>
 <20190220163921.GA4451@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220163921.GA4451@localhost.localdomain>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 09:39:22AM -0700, Keith Busch wrote:
> On Wed, Feb 20, 2019 at 06:43:46AM -0800, Matthew Wilcox wrote:
> > What NVMe doesn't have is a way for the host to tell the controller
> > "Here's a 2MB sized I/O; bytes 40960 to 45056 are most important to
> > me; please give me a completion event once those bytes are valid and
> > then another completion event once the entire I/O is finished".
> > 
> > I have no idea if hardware designers would be interested in adding that
> > kind of complexity, but this is why we also have I/O people at the same
> > meeting, so we can get these kinds of whole-stack discussions going.
> 
> We have two unused PRP bits, so I guess there's room to define something
> like a "me first" flag. I am skeptical we'd get committee approval for
> that or partial completion events, though.
> 
> I think the host should just split the more important part of the transfer
> into a separate command. The only hardware support we have to prioritize
> that command ahead of others is with weighted priority queues, but we're
> missing driver support for that at the moment.

Yes, on reflection, NVMe is probably an example where we'd want to send
three commands (one for the critical page, one for the part before and one
for the part after); it has low per-command overhead so it should be fine.

Thinking about William's example of a 1GB page, with a x4 link running
at 8Gbps, a 1GB transfer would take approximately a quarter of a second.
If we do end up wanting to support 1GB pages, I think we'll want that
low-priority queue support ... and to qualify drives which actually have
the ability to handle multiple commands in parallel.

