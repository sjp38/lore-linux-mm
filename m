Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92DC5C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 14:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 389952087C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 14:12:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="l/Cyl8vy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 389952087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 995838E0003; Fri,  8 Mar 2019 09:12:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943D18E0002; Fri,  8 Mar 2019 09:12:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 833EC8E0003; Fri,  8 Mar 2019 09:12:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43C528E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 09:12:25 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so22117373pfd.11
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 06:12:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aQc0SyowOdTmxrkU2xp2xFOofpRQZkuv8UFO0ktx/Gw=;
        b=q/oQU5hOe7Dw5LzjPeV25GVxNDZwMZkUBGmarns6zyHtSFlb0KR8gJiCrAuVzSIHPF
         jJLubMiZIoVFZQAPN9XGD9cjY2AMsBfmiX1AM53+hswIRRSwY7ihI4AFa0Qj5KSvoy1b
         Y3muceSwMv5EmTPWIRnCGeRcMGcBRFFf0L1WLqdqAiXVPmcrPkvH1T+QCrWNE8Nxa4Nt
         F+CQZLF3lcrE2DCyPxged3Mn5RIhKuU4mhmskm+O27Pq/UR/cCwUJxQCLLWNIxz7Ph9f
         oiy/A00j7UYr/syboqb5ASlJ0uZ2UxivOj/lhUh9sKCPbff4tQPhCX/YSdhCdCh5qRzT
         5y0w==
X-Gm-Message-State: APjAAAWEYmTaxeGTe9DBM1NkNsBH4Z+ZXBi+EJKIHHrq3LjiDO7/BY3u
	KYHylpkxrLFBUNSvySkYhTdekrBX8w023HkRYgueuOmpwEwdM527c2gCHZwUlC4RypVyYBQQGaF
	LqgwDSZabkfS21vzc/MwZjMqxZdziYoqaxq6kX7gd9eG2M0D4SBr+dslgso9JJDncXQ==
X-Received: by 2002:a65:52c3:: with SMTP id z3mr16991197pgp.395.1552054344814;
        Fri, 08 Mar 2019 06:12:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqwZOh6clostSMbuka46R6Qna4rmHadgeIW8xaSozAEbUf+q+DT/CTMnnoLJWKZhFCut+Oau
X-Received: by 2002:a65:52c3:: with SMTP id z3mr16991095pgp.395.1552054343600;
        Fri, 08 Mar 2019 06:12:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552054343; cv=none;
        d=google.com; s=arc-20160816;
        b=NnRmHEHm0Lr9VwYGVUw1MG9SffCWVtJ/A1+njRuepwCzZH9rpN6n03WIPVTX7L9b1B
         Tw13KNgPKnDAI5p8SR6AhI6Bh83i1H8y/b4eh7CyN1npojcTzeHh24pQLY2i8yYQQ6qs
         XVupvzvpjmsBSs1HB2QUj4aQlRKbBHdAjMy5BSqJD5BUrT6PuozlftTs2n7q2A2V0Snw
         FS/v8yBxSlJVrNROgJ1PpBPvFuFbh89s0CBH6RdZ1NhrrMHnZVlkMMhqFjWF8FTawbOC
         tjYL+3uZQWycgWouJ6d2Or4mm1r0Ao7AOYjRmV94LhUCvEvuWuGcfnyPOgLI6rltriJY
         mfEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aQc0SyowOdTmxrkU2xp2xFOofpRQZkuv8UFO0ktx/Gw=;
        b=Agbid8RVr8R8jsZSXvkaZSxO30dkTiUkXXcZaxvThyegwixRDSvfIw4jz5vSR5Kih7
         HL3AlC76T+3TwSh+EkiyZhF+zLV1oDjahqlxtJk66BFygTSzqP9K6dlD0QZ3JG6Yc5zA
         BA74wK+yyHRZ1vMQWWtVIvu+qT32ZnoNJuYa8sPv4UwJksV79OuJ2qt9JIGIvoN7ALqJ
         7mj6ndlf3GIHEJ9O92P2DxsUCHPUnvkBZ7fqG2kzo/Pj0KX7WFhMEW+yba/HMuh3VNv2
         4U/s9CKeejCUv5KiTxU0GPNZ2RbNcw2xepPdXd2x+lfmnf9E/M4a8AyS5Gag5kgzr+72
         b9ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="l/Cyl8vy";
       spf=pass (google.com: best guess record for domain of batv+8598a4c90796d7699c08+5675+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8598a4c90796d7699c08+5675+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 32si7108127plc.427.2019.03.08.06.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 06:12:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+8598a4c90796d7699c08+5675+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="l/Cyl8vy";
       spf=pass (google.com: best guess record for domain of batv+8598a4c90796d7699c08+5675+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8598a4c90796d7699c08+5675+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aQc0SyowOdTmxrkU2xp2xFOofpRQZkuv8UFO0ktx/Gw=; b=l/Cyl8vyTvDwqSnNGu+5hMY12
	7QQ4o+sc3edmPS09IezABK15wlZW6k9rwF3gFP+7/jqA5V7RHy5tzk1qtzM8Sndq08YlArFd9CD1Q
	spSIjJhhR6pcrx90oxnbZBy355+sSdWeMoXu9ObKhzB+bVN0CQaQJhw1I5E8NsutG72MPa5twt1Su
	cGXv9XQE9XF/lpzlYXjNCJDb3/2462UGi5AyXHq+iSCs+WlNmZowjcaL8sllXycDVE06H2QknUzS2
	NSARjQDBHU0ii6zLqLbBouH1vpo+82oU3YYOjM3BaiaW3nITV6H8+e3bdTaIVQx7uP8t2oCVMKvdA
	BZun3Zvuw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h2GEW-0006nZ-PD; Fri, 08 Mar 2019 14:12:20 +0000
Date: Fri, 8 Mar 2019 06:12:20 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190308141220.GA21082@infradead.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
> This series tries to access virtqueue metadata through kernel virtual
> address instead of copy_user() friends since they had too much
> overheads like checks, spec barriers or even hardware feature
> toggling. This is done through setup kernel address through vmap() and
> resigter MMU notifier for invalidation.
> 
> Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
> obvious improvement.

How is this going to work for CPUs with virtually tagged caches?

