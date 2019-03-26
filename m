Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA2BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 22:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B92672087E
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 22:52:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="n5Ofe8zL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B92672087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DAEA6B0005; Tue, 26 Mar 2019 18:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18AA56B0006; Tue, 26 Mar 2019 18:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A1D26B0007; Tue, 26 Mar 2019 18:52:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD23A6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 18:52:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f15so15099035qtk.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 15:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k2K7y5i3c/bIxXtCts/FFPzx4K3yumcOwK4/9lIY7Rk=;
        b=dz9EID+ZA1+no+G5Oq4K8mVDsJYCJAzzD0j4+uUBCVXKWe+0diLQbeu0wSGD/1dpyH
         kufJ2CZHhZiuZ548XZhf+UsLMIx6kZ5rD8eIIN9Nme2i+TpSuugoNqLdAsxf5OAWDhgG
         yROKoDF/4BzMyjzQ/YMmKr5RQfMqZtz8zhwEpxqEs5uXMpCVWFwHC8J5DX8dMgNjJrNs
         bE8PMQlROB4geStZg2b8yYc17LGZAKsgGRrp1LDzSUxXLbpa1YxZB+EY53uAOtILbcj/
         evSY3SK8QcT7F6Qkh6J867Je2wK55EFgaRj+Y+qkGjXCMDg2LGE+IpKKDFnfThJPNEDr
         GiSA==
X-Gm-Message-State: APjAAAVg4qNkwWzd88Vb+7biFQulljTwR3zfluwPd+l25d3o3810OJDW
	gfMWW2cQ5LklyGsAeMmWJnnnRHWNuYIht2k82HPhY/EeJe9dltIZ4Xf7xg6Q3dKfkvMiIumNUX6
	wy+dhms1tX2dxhFc7/K5WyhLD9hpoIVfl2dN5TmqB7hM4KlIucOthMlvnO5cehlmf8w==
X-Received: by 2002:a37:5401:: with SMTP id i1mr27949122qkb.124.1553640727517;
        Tue, 26 Mar 2019 15:52:07 -0700 (PDT)
X-Received: by 2002:a37:5401:: with SMTP id i1mr27949076qkb.124.1553640726753;
        Tue, 26 Mar 2019 15:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553640726; cv=none;
        d=google.com; s=arc-20160816;
        b=R/MSKv0YTlcGZaloGIs69XABgQLQ02FSfJD1Rb5diATqzzRrT93Fd1NLiQ2leseyeT
         MQWI1dlWiDhYl7GlfaXHHYVLGOhzXoKWh3dDNGpHOgzjmdpb+8Q44durGSfGXKX8m+WM
         WBDavKb2hWLTyEdqoF7akIZBg1ypyp3r/HOkBjXY7nIwr0H2XTof4GiLOrXjY1VHRW3l
         eb+GuFTAQZNy8CEF6bnCSMHZmMc7EL5ZmqH9vBClgtTW9fMBCaGMuKA8amEBm72upjhX
         V6nJ89hfm4Zb72u0GMpgfxDIEja/ysH6F1NJJn48MwDEf2l9Jx7WTuAh/ZGHveFqYqay
         6ndA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=k2K7y5i3c/bIxXtCts/FFPzx4K3yumcOwK4/9lIY7Rk=;
        b=NCWR7Ns/Wxi1IGmKlQiINYRoTt5r1eMDQCyJfDgNPytF5VTzs+kHKjjZZ8aVHRHTFM
         OBIBTMFaNt6W7wWSirPt4BALn/DBuGeZATVrT4zvyt6BDxYBRj/YW5smnLASx5rh0IFG
         PsRSMAlE9Nn1lvm3l2RJ2ucxs41jOhAkM371+DQlgsDBRdAO6rI3l6jLJO9ruEwngCWV
         223ZFMsIxLLybpqoOBNAOeUbVper/AS/7pi3NjdhNLPEKHvYo1p1P5Wl/9UpFAvrc8TJ
         lMl0OBmzgQa0C74cGgKDKpIxF2NO72uFkCsAgW4sneiNVCGU5F+c7KpwnY095/EMH7aR
         8sqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=n5Ofe8zL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h32sor32198557qtc.3.2019.03.26.15.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 15:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=n5Ofe8zL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=k2K7y5i3c/bIxXtCts/FFPzx4K3yumcOwK4/9lIY7Rk=;
        b=n5Ofe8zLAm9EvPjLhVdPsZ3yG+NXRr4zT84bTkHrv5sbGyhMdamxp8kmuZCee4HzOn
         vJkAbTon7PDVvYe3EFK7GVlOoVTOnjLB1CViUgGTK5uuYPXOw4ZLWKTOTm0NPo7Zx3Sf
         iyFHDIRg7FTnJ32MLxyOMtoh7uSbxAG16X3FZ3kd/muS5nMET3h4yolATvnTiHym2shp
         y8j4LbsQp7pv7TmRMcGCPehHXc2+FTM7JwFAubRsShJIAyU1frlyf/6DG3+h1adfDJ+y
         sr61X8iIfSJWKhqqF4WxmKwMvQD6uJSXvByvuPeB7NLgjwqjc3xGfKuBUVZMsO7kWFFT
         ywLQ==
X-Google-Smtp-Source: APXvYqyACKSYRBpxrbdIiKwu+la2okmi8IV5CX3I+DKq1kFHmH4WfTErGqK9QvxozjxIFy+SFYyQww==
X-Received: by 2002:ac8:17ee:: with SMTP id r43mr27012056qtk.169.1553640726411;
        Tue, 26 Mar 2019 15:52:06 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id p64sm12128427qkc.62.2019.03.26.15.52.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 15:52:05 -0700 (PDT)
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cl@linux.com,
 penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190326154338.20594-1-cai@lca.pw>
 <20190326160617.GG33308@arrakis.emea.arm.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <2193546d-e525-b8d0-a643-53fea7391c86@lca.pw>
Date: Tue, 26 Mar 2019 18:52:04 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190326160617.GG33308@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/26/19 12:06 PM, Catalin Marinas wrote:
> I wonder whether we'd be better off to replace the metadata allocator
> with gen_pool. This way we'd also get rid of early logging/replaying of
> the memory allocations since we can populate the gen_pool early with a
> static buffer.

I suppose this is not going to work well, as DMA_API_DEBUG use a similar
approach [1] but I still saw it is struggling in a low-memory situation and
disable itself occasionally.

[1] https://lkml.org/lkml/2018/12/10/383

