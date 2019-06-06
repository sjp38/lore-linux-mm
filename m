Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800B3C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EDF320665
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:16:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Nd8WTWlw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EDF320665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C63626B0277; Thu,  6 Jun 2019 10:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEC706B0278; Thu,  6 Jun 2019 10:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66556B0279; Thu,  6 Jun 2019 10:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81A396B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:16:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g56so2184640qte.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=x2NtpsySZzA58TAtpw74/PYyujX/rnY3kx7DMxb/EUc=;
        b=gkbP/IPqKBw0+3W185ZD0P0/PR98uXYvCP4szy/xYKMaktoLP0wLue8GYi/rij3Mwd
         DA5uTTDTnPYlPGpV0ZOpp1dWl7TTPXFZF+ORCEWsKlq3phWKEkdPC3JgTktFQzZWmtxe
         HtEnR++XJ6qOYp9pmCXOZgmKr7uhUvaMloFGirkSOlQVBP5/yrW8wsrbH9PQSFtNRTYn
         JHieH9rxN0vsT0OC7upIp/RNxZR14RTy6Zcshu+AA/mnvE0pnwXv09YqciM4PRfyTZlX
         JnqSFOfVKtIMK8+cf26oUKQCJD+dYi4ferdLcWS+wsqD2DnF77uLfIs56CKdgolv4fnB
         2+SA==
X-Gm-Message-State: APjAAAWg7BBS7i4QreDQWP1e/5CgFyiWH+NlejKu+45wCeZ3l7HTMRrO
	IyfIiJPEEqKNjm1CxinEMlZ10/DlzOetrzvlfcHhWru5+n8pNrEHnWr4rQZEi6BDXoIXq0qPKyR
	35+jv4Mwh0zQ5ifhaUwu8tV3fbIEI1lVB4FTGPv275SJV+hgv/7a5BBRwNUuFVGnm8g==
X-Received: by 2002:a05:620a:142:: with SMTP id e2mr22226035qkn.191.1559830606225;
        Thu, 06 Jun 2019 07:16:46 -0700 (PDT)
X-Received: by 2002:a05:620a:142:: with SMTP id e2mr22225984qkn.191.1559830605610;
        Thu, 06 Jun 2019 07:16:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559830605; cv=none;
        d=google.com; s=arc-20160816;
        b=QTarFAiLmrul8vbT6XTrG+cU54su1W09KW8P28+a5YKXix+ESbHz5bQRvCGMt8ASI4
         kgoEVtqskvBpr/Wp3g1yzfBAb7mu+h78YJW1dz87hZ8HNjXKbM3MVkqWK4NnaDbBXFEb
         LFcCS/S7gWb6KqMB+hJAX2+21sux6+Q24Jim8IfiYCJldAfa5kc8AS17bXMLquTcgzFK
         yWQ3P05cpolkEnh33cnJQSIcUvM4MGvP27RDYLrAMpZGk4WkSXSmaoAYEFjlwWMTMfZC
         2QdtF8Jl+pimgg49u3tolZZfNhxTdxRKFq0pvA6uHMieVUCWxIDJyoY4XBoJ3meFNFSD
         cQdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=x2NtpsySZzA58TAtpw74/PYyujX/rnY3kx7DMxb/EUc=;
        b=BJmLoDGI74MFLais1lY4nt6EdHic3rRZ8308OJ+7g7UuTsiDYWPdMgp1We16suW8mm
         o0JmoSNDEAG5GwgAYSBbmT8Y9cZClEM4qZTdcc7o+7gBx4H9Xd92aQ5X7SAAjhTFxrQg
         IwmkwARvy2GhC1Qz4rKTW++6Q72CYEKJVA5S7fE//RYhiR4KUJ/DTyVH9CihGqo8bX/n
         4Zxx6GnH5EVnsN7SsiiT2UoCmWJRVgvgn8sZjpo3o/2RTZHRW/bcrt7wkKq/slwqn4FL
         HTfak01Jor8t8h5uLHFd0tjI3nqaN5e82aI4NlrlOQeq/Fntxe7toQTQQvwzr3eu82ix
         AywQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Nd8WTWlw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15sor2216115qti.52.2019.06.06.07.16.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:16:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Nd8WTWlw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=x2NtpsySZzA58TAtpw74/PYyujX/rnY3kx7DMxb/EUc=;
        b=Nd8WTWlw6G8cHAWZuKjxZwj5zy6tEAcuyngG0C5pWS3Q64zshz9FFMmsw/wVABqHjx
         /5XKwSWCvOkg9pIGKc0qS6JDn+H3ehfGrK3u0JCKeduZWtPM9OtjSjNzyXW2XKS2REji
         xGHU/vfM1Yo68cA6FIVjlFGE47N8bKH21YZ40A8Fo27l6IlkPldOL8T8rIt5U5afEc3K
         SgY1NGcQHj59crXbjdmKfZPslad6GKeDUHTwM3QpQfoAMbvF6Qk8LiiQJYzcABYNteXQ
         CNr/hKnecVB0PmXLGj7TsxQgnMPaFUV4B86MKvKELTpiyGarIWaKHzp9fTNpplATL0s5
         ggmg==
X-Google-Smtp-Source: APXvYqy4Bg3zzTDW43K2iOXSRQidq0DVY1LfO6HtCYvj44blfzhGJ5iIlkfyINA3yHm65CSJF4pPEA==
X-Received: by 2002:aed:22a9:: with SMTP id p38mr17862714qtc.188.1559830605359;
        Thu, 06 Jun 2019 07:16:45 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id k40sm1507614qta.50.2019.06.06.07.16.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 07:16:45 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYtC8-0000l9-Dz; Thu, 06 Jun 2019 11:16:44 -0300
Date: Thu, 6 Jun 2019 11:16:44 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Message-ID: <20190606141644.GA2876@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190506232942.12623-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> There are no functional changes, just some coding style clean ups and
> minor comment changes.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
>  include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
>  mm/hmm.c            | 51 ++++++++++++++++----------------
>  2 files changed, 62 insertions(+), 60 deletions(-)

Applied to hmm.git, thanks

Jason

