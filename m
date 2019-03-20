Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2BC2C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D3142146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:05:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D3142146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C566B0003; Wed, 20 Mar 2019 03:05:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CB856B0006; Wed, 20 Mar 2019 03:05:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F23E36B0007; Wed, 20 Mar 2019 03:05:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A56DF6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:05:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so518137edr.12
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:05:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ffK3ohpiiZohy4LxAgUF4JsRoA6CiLqy2vnNh9jOtgg=;
        b=Dlv1D7A6NwcyNiKA8y133s+Od7TPYCRe+KOBf7CexEAW7nvvG+j719ekewvNEvol/D
         y6pF4DawCR5I8JyYmDs5i/gWcXvtxp5EG+TxdsHjzc3VuS8BwpAHNMT4iv1EcDmcg8uk
         c48OWnSD+N32aQanSDTac3vV1XexIHtz38By5axsCDoKJuhtFnJx333VKJq1/OAgodHW
         3YqqfNLMST/Vl769S4Y9YcYtaH3omiTcYhgW9lJwde/T6tF4rTC8BZ1gos/SyVM6YkTz
         TFvseXkHwCtrffxVQbK2ZdrR3iKyCfbLY1rQPD//T8L+kNt4BqJYWEPlzqmSyuI5g6UG
         Y9Cw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU4NM32R/OnkrfRUCTJ9wYTIEQymvURz1lm6loiXiU9JQW63uYz
	kaQHMVvv9q6xgJkQW4oPZn79OdI20kTcGSfOl+eibzsJPQMupuf2RsOdp+Dh8Vu8xE7tJ9OuPUw
	y70JnkvNDfRTcJePpWJ1t+obnsPjcTeGFKhMeyGu5yv43rR0OQDgl5LifObKXcJY=
X-Received: by 2002:a17:906:d71:: with SMTP id s17mr15288408ejh.233.1553065520202;
        Wed, 20 Mar 2019 00:05:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwo6Kqdj12yX9NXnCHqHCg7fWjnlwlN/nDWEYp9hpyOhfm9fPKNc5Adx865DM8cfyMc6eE9
X-Received: by 2002:a17:906:d71:: with SMTP id s17mr15288367ejh.233.1553065519354;
        Wed, 20 Mar 2019 00:05:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553065519; cv=none;
        d=google.com; s=arc-20160816;
        b=VdkH1Bt8Atrpz478lgGYOvk5CosUCwpGrGajxT2s+kl2WjFrex1u/e8nmbGGeDvSXs
         sWlYRRrfyG/TZPANj1dRBde3+x81kNrLVznQavQFt21emOKHmQsblCVWCvnAh9RcuGhB
         GktXnR5mKjLsWiYQq229dLikLLGbSBVmBpTbMDsiM1vAGnoNiovDbTwTdQ5e/7CJbOt0
         ZUtkzHiISMudV1/Sz5979X+2eXGH5NZPuUcWLb+i8ZNMfQrt0nsLMglbhqy+7K9F+NL/
         BE8CVBd7KfhDO9XGj+axhfkNO6MCf9S1HuQue9ysKUqM/NZhuDE7KWX+f/OQQlxzEYqz
         5nhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ffK3ohpiiZohy4LxAgUF4JsRoA6CiLqy2vnNh9jOtgg=;
        b=OLDRZdyRjswpuu6P4vo7HUutEKcg403HnWiv6hxgyRiPC8zOQDTL+3K6VaKr5bwJvF
         rR+9qkXKLOI9UfmYZAbeRW2MreW4twc76+ygYoZnBUHeL0svodonnKw7ZxDsJBoe1rkr
         82PyzPK7ZlnSjNejS6oxXGESn69KzzIIk2OscxQtxT+Gzzz4ZJli5drY6dRWX1Yj9tAl
         0ZANmvnHB5INzxVxVgADJ10yVanXZiZtZWktFPbvT3PMqOJAj2MJ1kozTUHQqqn/cJzn
         hSFRQ52Mjlahpxl2pMCmOlESIFKrKfmc6XKGMOySsOxbChqv6I8oWOBN+b3gWt1+B2aX
         9TqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r25si509171edb.15.2019.03.20.00.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:05:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B739AE16;
	Wed, 20 Mar 2019 07:05:18 +0000 (UTC)
Date: Wed, 20 Mar 2019 08:05:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	yong.wu@mediatek.com, yingjoe.chen@mediatek.com, yehs1@lenovo.com,
	willy@infradead.org, will.deacon@arm.com, vbabka@suse.cz,
	tfiga@google.com, stable@vger.kernel.org, rppt@linux.vnet.ibm.com,
	robin.murphy@arm.com, rientjes@google.com, penberg@kernel.org,
	mgorman@techsingularity.net, matthias.bgg@gmail.com,
	joro@8bytes.org, iamjoonsoo.kim@lge.com, hsinyi@chromium.org,
	hch@infradead.org, Alexander.Levin@microsoft.com,
	drinkcat@chromium.org, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
Message-ID: <20190320070516.GD30433@dhcp22.suse.cz>
References: <20190319183751.rWqkf%akpm@linux-foundation.org>
 <20190319191721.GC30433@dhcp22.suse.cz>
 <01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-03-19 00:37:33, Cristopher Lameter wrote:
> On Tue, 19 Mar 2019, Michal Hocko wrote:
> 
> >
> > I believe I have asked and didn't get a satisfactory answer before IIRC. Who
> > is going to consume this information?
> 
> The slabinfo tool consumes this information.

Slabinfo just prints that information without any additional logic
AFAICS. So this doesn't look like a usecase to add an API to maintain
for ever.

Or is anybody using slabinfo to use this information for anything
useful?

-- 
Michal Hocko
SUSE Labs

