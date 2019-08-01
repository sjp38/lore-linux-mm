Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E5AC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA014206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:46:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kam.mff.cuni.cz header.i=@kam.mff.cuni.cz header.b="Dg4Q8hMA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA014206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kam.mff.cuni.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B7C58E0007; Thu,  1 Aug 2019 13:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4658D8E0001; Thu,  1 Aug 2019 13:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32E798E0007; Thu,  1 Aug 2019 13:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBC198E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 13:46:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x2so35731669wru.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 10:46:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UZJPmwQ0kVcDvUUwN38aLK9+F/uu4BDRy3q5bFVWb0Q=;
        b=pUdFhXT81bOx2ff2cJoqhwKFIjp1XgUayLauglscVL2XSDuDe0pFl0ASQKKKE/Gmcg
         H/Tt6UuxOp79GDnGWQ8RFAm4bYYJ/mEXLwZbZwDVLCNA6x/RtyTqP0P3MuvkF+abUJkc
         RIYgLRb52AMMopvdy2+TV9f+Sbj/DkQ4KCq1G9SG/Rz98h/CGuVgqtcVMQDRcHDSM3Yq
         NAFveppCTzEAGOyfYAaaaLwmTZYMikQ4m+K6RPP3ffkUWlm8UWaNxOyTtE3TmLRGMnnl
         WWn1vwqMVyjAdi/WySq3cicr7Grsovewh4z7eE+iKsujfSdeRdnl02Q+FDs7jsu1+wt+
         wljg==
X-Gm-Message-State: APjAAAVMRYNeb+DpsoDML5KGuPNwWVnAT4VBIkrjXz+DubVXUPjSmo+U
	1LiyscbdcWNT8D5/9yfaYv9foe4YvkTnrbFqwmcyKvPsNgwZhvorh7DQTFymn2Jv/OGa6UC8YZc
	iow2rZHIwdLjIWTVXGRI8iLMp42rlVVTLpPdeWEitsMlbfWBPv8X3c3ikayCgmHpfQw==
X-Received: by 2002:a1c:a019:: with SMTP id j25mr117910816wme.95.1564681592483;
        Thu, 01 Aug 2019 10:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKIIn0uBNYqKwOgVBnikGxDH2saH9O4l01KCYXZx+ABZ0pRSQdABUP46EDBePaAgOplTNQ
X-Received: by 2002:a1c:a019:: with SMTP id j25mr117910787wme.95.1564681591803;
        Thu, 01 Aug 2019 10:46:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564681591; cv=none;
        d=google.com; s=arc-20160816;
        b=OyGxREyLSsNwJz+pNW3vtlOR+q1UjOmyHZJl55xgRCkldSGUYAwzI2SA+rL0EDkzBl
         b4VyGl3SzRZVT4I4iKaoKqfIoZ4wn8vJasJW5qACQl73HYDL/c26hg+SoWerMEW9bO5U
         +gMyjVNcifxCXpCxHln/6feRhGsZ7kHHrh2zrMAJOwcZlhXfUwLHd/okHaqPxZjlZ+XM
         GbRhfoCSlfDRQe8CmMWXvHe4MGmt+m5L3vJSlhyNvTFq0Vwrg+yRCOUsGKNCPZ/fXQDe
         Qb5JAZ5QUzyFYoB3gN8FkVAZVYKVPaPXM7mc6/eYoFHeJ9FfxFPEGjSbkF1Q5If9En4V
         jidw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UZJPmwQ0kVcDvUUwN38aLK9+F/uu4BDRy3q5bFVWb0Q=;
        b=VccSmikXTM7q7ApUdHFkQxluVujPTKFAsDBx0Mn+rH7nTkjUZlRF2CTQ+1xu6cTKI0
         Q4evQeByaGTSlzTwp7kQCeO7+4fNFQ764n3MTLsppZ4AAV54qOHTjy2w8xXVUlpqii2U
         1DH0wm2UPuGiC8WKP9guVYvj1Fja/Ja+RttsbxuUpZQ0leY22oOQpyl3XMCOUZcrJLjq
         7jmApisieZNV3QU3FX8XT/4kHXSlu9HIR9mH9/LhsxBl5IMGEO0plD9XJWi0Zo6U2+Pi
         P77Bfml9cJPLz8p0FwJRaKPogXDKUpH9u4CiQWvDN5YrmnXGolkCVTdDDOowGWj92Bm6
         I5Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=Dg4Q8hMA;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: from nikam.ms.mff.cuni.cz (nikam.ms.mff.cuni.cz. [195.113.20.16])
        by mx.google.com with ESMTPS id y16si61303231wrd.418.2019.08.01.10.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Aug 2019 10:46:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) client-ip=195.113.20.16;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=Dg4Q8hMA;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: by nikam.ms.mff.cuni.cz (Postfix, from userid 3081)
	id 4DE21281AC4; Thu,  1 Aug 2019 19:46:31 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kam.mff.cuni.cz;
	s=gen1; t=1564681591;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=UZJPmwQ0kVcDvUUwN38aLK9+F/uu4BDRy3q5bFVWb0Q=;
	b=Dg4Q8hMAw5K3/Ea8D8F3UCo7CH5oAotdl2OX/QOwlgZT4ZhBM7+HWBIpNLlFm3evgRuSvL
	e2EBYCqJflxcZc/bd0nHDmwkJRTdN/6w6QSSuqPu9YjM33OAw5tu37y4QqflwiQrvZ0aiY
	mrUrcJ5uknz5pE/pg5z0AqLTDxiFiEc=
Date: Thu, 1 Aug 2019 19:46:31 +0200
From: Jan Hadrava <had@kam.mff.cuni.cz>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wizards@kam.mff.cuni.cz, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with
 memcg disabled via commandline
Message-ID: <20190801174631.ulnlx3pi2g2rznzk@kam.mff.cuni.cz>
References: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
 <20190801140610.GM11627@dhcp22.suse.cz>
 <20190801155434.2dftso2wuggfuv7a@kam.mff.cuni.cz>
 <20190801163213.GO11627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190801163213.GO11627@dhcp22.suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 06:32:13PM +0200, Michal Hocko wrote:
> On Thu 01-08-19 17:54:34, Jan Hadrava wrote:
> > Just to be sure, i run my tests and patch proposed in the original thread
> > solves my issue in all four affected stable releases:
> 
> Cc Andrew.

Are you sure? I can't see any change in e-mail headers.

> I assume we can assume your Tested-by tag?

Well, these test only checked, that bug is present without the patch
and disappears after applying it. Anyway: I am ok with it.


-- 
Jan Hadrava

