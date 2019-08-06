Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F23CC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C122147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:57:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pw3U34ip"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C122147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8096B000C; Tue,  6 Aug 2019 01:57:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6977B6B000D; Tue,  6 Aug 2019 01:57:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586A36B000E; Tue,  6 Aug 2019 01:57:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F19F6B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 01:57:47 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d6so47610381pls.17
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 22:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j0OFKi5V39Sb3bwFscefMidUs4ndmFs7fX33s9yMejs=;
        b=YWAu21uL7w3eJpcEYhr+VoISo2BkjoWcdwrn+ANnGnqeWyKBjKka6qKMyhSkiK8hL+
         Fx2fp7DdY2pT1KClLDEk6L16bAe/z3eZCCIPxqDpUNYNFPa+I4+9Op5qU/TnNp8B8b08
         1AbLjLqs2t5Fu38Sh6Q5FczMy4SJ8k/L7g4qrGI3j74rab8CV0zA7CGZypZhbJVCDMyW
         4ariHLCSLzfLH+mQqQUMXkniCdmDMNYVyKJ5dloorevKVlpPCehSQht1PXTaU2dR5THQ
         MrS4mTaNydDRi3eMMIViQ3/lY2jDLShUHfWid0Um+lCpawiqiJ25zKL7A/EOLJgeCvnQ
         DGpw==
X-Gm-Message-State: APjAAAWMjRpvslpKLnWMQpNBNQrYOaBK8JHo/4Dw41d5xRTX2g7nkTMe
	CdLNWRcxqMg970cGJx7rCXRTrJWJf4ELS7SgnN67UVyPbeL1btZCj0dcwy3tpG4BbUZI7cYcLyt
	XCL1378940dROu2RFBrAbUHyJtPV878dhrrUtg2xxUI7ik53AxTRYgIVrPf1hwml9rw==
X-Received: by 2002:a17:90a:1d8:: with SMTP id 24mr1463229pjd.70.1565071066707;
        Mon, 05 Aug 2019 22:57:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIxsWEhDj79dRFDMIQ9TYSIp7biHas8FDnaBp/MQaZFg+bB7NRRDq/skr4Kj1rTUiQHVa5
X-Received: by 2002:a17:90a:1d8:: with SMTP id 24mr1463191pjd.70.1565071065999;
        Mon, 05 Aug 2019 22:57:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565071065; cv=none;
        d=google.com; s=arc-20160816;
        b=n+YXnXmGf6M4DZPMB/KtNNDLKTZOa/fMXjjTaZqqXiCuaSmIUAnv0HSVmAuOZmigV2
         2ndcPabmp53H37SXmQ34Do4w6+FkDdDO/S21yDGSwgIMwkJkUprJ4Q2fohCw30jcF/r6
         q/OFGHCLaCDfkmdX5lRcX4tLo5kD+sPPSEDJOaIxSrRVGKrWC9UMyG9GO4+tOWVN6hLr
         ZuVvnPg+iql0Zioy55LhaeXrGOm5RRTCIToQ9GsOFdD7JaAQE6uyqC7ivzGA7RpPUk3e
         dhnkujniu1DWAh0RPxvG+3dOLm/Ga6dKPYsRbdQk1LPIQlzcV5LtYA/xsdL816Effs1p
         rWxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j0OFKi5V39Sb3bwFscefMidUs4ndmFs7fX33s9yMejs=;
        b=RCboHoANRJwqjUTgDIuxpRBA9Lym8yuVFCx0UEaXuWY1u+xLeeCQzcrriGkxLvMQr/
         RprklUcoPw92WI28ksWd+zH6/ROZFnPwM5EmBENM6lMwuAXq6jrUpFRkEVl1nBpEad9T
         oObKbNQ4mGAFB/+0a/g0HT2CLDxKpUvmROaVpw+jfHFGV5uFT9U0Zg0VG/z9Afa9Nob9
         6Ihi1BYEpmcPoLaXsFMDUvo0HbtSa+qT4ffqcI3W6c86xkMbmduq/H8jC4YGzcm7moaq
         unfGRBT29saXx39Zcb8xV3sWLuDogskidFMKkOMshZumcZ2T6ORI41/hZk1iZMu0i85L
         +vyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pw3U34ip;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bh2si42914572plb.116.2019.08.05.22.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 22:57:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pw3U34ip;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=j0OFKi5V39Sb3bwFscefMidUs4ndmFs7fX33s9yMejs=; b=pw3U34ipSoi9mKxJ+NTSLNOpA
	3R9rRO1geSBe8FhsxEk3T35Kkym3drbjhCVyzim8ThIbjxbAc/78UWCaDTPQKd/Pd7Dck2onQudus
	1jQ/iOPsn3qyvjHwAWCz89EV/ZEXwZCcoaI7YvFaw4KrbRlTrkNjoTZkWQuYcCarnGqKBj5tLVw8o
	buRfPdQ8urHHzBWIp9ihvwZmINpmRjn9bKx7xMbPE2cbev2S9NIC7LHzm70w7PgSe5K2RrkYD4m/x
	Q29yhVu4rRX0hVv7gO794blvA9G9mArOjgRsTNkTH5gTfOzfeNlw5RGdyWpzgD6fsLJ5mck/jWPvb
	+K5HvAbYQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1husTg-0000yA-VN; Tue, 06 Aug 2019 05:57:44 +0000
Date: Mon, 5 Aug 2019 22:57:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [RFC] [PATCH 00/24] mm, xfs: non-blocking inode reclaim
Message-ID: <20190806055744.GC25736@infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

do you have a git tree available to look over the whole series?

