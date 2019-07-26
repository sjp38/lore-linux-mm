Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92652C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:24:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61C9C218DA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:24:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61C9C218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10CCF6B0007; Fri, 26 Jul 2019 02:24:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097156B0008; Fri, 26 Jul 2019 02:24:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA17A8E0002; Fri, 26 Jul 2019 02:24:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFE396B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:24:18 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id d65so12047951wmd.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:24:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
        b=YmJffiRX3ZFYv7vqwgicQfWmIKbgOzyPw4BSugUSGiw/gj6Xa7wVc8ZK0Sn8+YCTe3
         4iadmyepYfzyesBkISF40sqdu9LsKtFtGLqgOo2/mzzquU/9gPy3PKVLR7Dw7sazVmAq
         LolQnhOu1+NP1ULaUC3TxeRVHTbglg9mxCNiOuWOUFaLu9T+2s9qUa4BuHjGlRB7Y0hV
         T4l+/n9QYTGuu7kI/ycC1DmNjz8T0oijLU2DswSITbV2FU3okZM1IOpeBMOQw2BowYvh
         Rf03H/IFFY1V4Carik2YohOSCHSpLfeEMsZX+Fo7NZyq3ocG42Tp03NrBbxZF5BDYirJ
         1OkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUdJ51860NalKOw5j3i4BR9jmmVZd/AyClcIKR0/vOFelSE84E3
	/Hn7QFCGmqCLHx/cePeDAb+H1tFyeB1rCe991KweqImzyrZwght0k8iJdg+JcuOJXIHb9yctDUN
	8dFouJ0KTWF9SLrk5RSGf54ZpmvdQLDq59qHpYtBN8W47JX4WrwmkVKZ2EQoD0hE+Cw==
X-Received: by 2002:a1c:ca06:: with SMTP id a6mr5166525wmg.48.1564122258322;
        Thu, 25 Jul 2019 23:24:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyW07Fr9WtfW1UoJdeAdJwDQwPvDK+rqukF8Vac/O1J8o/tmY9m+3RfCYvyGk94pzGUHEFV
X-Received: by 2002:a1c:ca06:: with SMTP id a6mr5166479wmg.48.1564122257607;
        Thu, 25 Jul 2019 23:24:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564122257; cv=none;
        d=google.com; s=arc-20160816;
        b=EzKjjG8TGRAMPvK/1oRzcD7vhDLleVv2kSQK/IRYh5kNYu5sFtUbfY5aIihckN1JiB
         FeJCMFpjyIVkatEuj1QJruRnntHHzZKcx2hCX5/kZAB1XB2Wb+W54sNRdJ4CyNnqtr/k
         GTHCxlK9OaAirym0pA7EZrC9Ric/q+3m6980nzLT7xOgX/VJuU9pVGAeIn2fan3W3yJo
         u2/m1zg3Om+21dNIxHMyRg+JA+xrRUC4BbWtk6V3qD7zt9N9jABllEzdXekGjxTxA35b
         zLVUDTCfHgGrLQhJzTGFAQWzSFPRRLGiK3rioCZwTs3kDywIyjtwPiSvt4USfOETXBx9
         dKbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
        b=CDM2/dNAKY/qajLcnOs8UxjQyi/q4x3/SVQ+8+7nEzLr+83zONLdczMHE/FJLImYAN
         d5ieCsXYmUksmaql5AQ1U65Tlhqhq6I8imTwpL/gRXkMMKVXx9AW+LLobSqFJ0eYlXed
         rmbKvtSknKZaoYFPle5aJHSL+oGGTsQGrQdYk1Be2GSb2wLxwNViItBD7CUpvK27t8ml
         SOCfUL8RjgWfSy5UKxsSIfNuTClVfZQGox51XaGZgFTI6aFt9OKiuvIr7lqURltsR4rf
         kySA1bXT5QESQuvk/Tc68h+WVDdabdK02qa2TChA5uoRtf5b42jKD8Q1Aw6UOX6PPVvM
         xKzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x20si41196501wrd.352.2019.07.25.23.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 23:24:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A6F1568B02; Fri, 26 Jul 2019 08:24:15 +0200 (CEST)
Date: Fri, 26 Jul 2019 08:24:15 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 5/7] mm/hmm: make full use of walk_page_range()
Message-ID: <20190726062415.GB22881@lst.de>
References: <20190726005650.2566-1-rcampbell@nvidia.com> <20190726005650.2566-6-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726005650.2566-6-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

