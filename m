Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	TVD_SPACE_RATIO,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9D59C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:07:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 764F82086C
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:07:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="hvRX8RJi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 764F82086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA66F8E0002; Thu, 31 Jan 2019 14:07:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54DD8E0001; Thu, 31 Jan 2019 14:07:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C458C8E0002; Thu, 31 Jan 2019 14:07:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4038E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:07:56 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id e10so2322638ybr.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:07:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dd11Ii3Cwcf72oIoTmhO01bly9ahZY85W2Izjt3U5d8=;
        b=UgmvSv8uzeBrcrQ8susHSHItWg3ckvZsVxOT0qG6ZVgqEdpQ+J4iFV+BaVD+aHHC/4
         QpTBKgSArraLarBWwrcadyMJLq0QmlFb36hDXTJIXnIdYB7OJaYHtusKckmaIpfl8o+g
         fjQwl3o+lPuKs5CwL5SMdeI9GidWBB/iHvY1OtVUlcr0dZTWnf6yWamRy0I9s7tnaWVt
         VjPgbpLLsSJGcHsVCHDGi1vhpekKv/RVBCFxRZ/eRQ66F4y3ntCPqx5hgYukp5iyPQfb
         ldUIoA7ZCN5mTvDu43R0Z9FkFxk322dtSuR8W6aepigG7tViglUM6yTOwptRtblLO3lF
         V8Zg==
X-Gm-Message-State: AJcUukd2Lqz569BVeOQnzyzQW14gW+HDMFlVHW1AYyu/HFtAugSQ+jyd
	ZtuEkTfiQv0bV5mmf7SAVLicCSvebnwGzaKqFlSVivQJRLog3fdprlIQek4Uz4GmZ/GxE55Vsj4
	OdH0SjcfmNOE3Ht2LcaL1cBAQmaHJEQqi4DcgPLGde3pDwhed0GPr9DYXPlmk7DUuA75tMxvrAy
	4fOdk3ss2TCbBPWbQ2ALOFZdez3VaCnUp0PNtgsD59wK7uP/7fgjM9aEip5g3ZWjetX95eqL5HE
	T3p/JvCKqhLzybC65WMUXtNh9WYOlyhAco8gHWZFTU/ClZSZ9WekPfjrjwvV9Npbu0/fT2L++NX
	eVUwt9Vt8ViDHn171dTmMSqfVXmZAfUoVDc06uiwDld2mZBt70ndqtuRoOQYhiDJdwZFij40it7
	X
X-Received: by 2002:a81:254:: with SMTP id 81mr34705929ywc.68.1548961676427;
        Thu, 31 Jan 2019 11:07:56 -0800 (PST)
X-Received: by 2002:a81:254:: with SMTP id 81mr34705895ywc.68.1548961675950;
        Thu, 31 Jan 2019 11:07:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548961675; cv=none;
        d=google.com; s=arc-20160816;
        b=Aw2jfttX32wlVtKkMxBGixWa7uobJaSylv67349+rekDeR1wmfNvAoPki2EvNBAUxy
         QmPGCTMdi78y/21QAvIxwSjGkgQeGpt2tU8bffDKgVKsFIW8CaCs/65zI4mz4OAKzG8E
         /cilaZ8Rs9aG6I/vEafyZPVMvETByTQ2ZYoeIZiw+vpEkWnXzz5zmycoiWzZJUxjWy5q
         e3qAEOT8TFeyd+zZRahQ/BXboVqHIHvgFFWT+YrEaWWV25imC4KwyVrXUsN6YFskuy1j
         FlKjfsNHqfzV1+vi3nF9zAf2lezQzzLF/qmfPEbkhm1BZ/iernuGodb/Y+qiOxeS+Rv4
         RHCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dd11Ii3Cwcf72oIoTmhO01bly9ahZY85W2Izjt3U5d8=;
        b=d4teWOqCj0Ixrhum1+0nQY9E4koQzaCsN7Qyc2Rs+Qo3bYL4Gdp/7NNsiXecpkSm98
         D2k1eDW2i8Vt5UyMKuGtDCbtz78loBpVcrtUTfSztHxC6XGUZIyFeenTcgBu4Z9Nu77C
         mdq46PJ5ArXKwMP47niC99eyB+XG7IzwSKI+X+GFUFcHbWqUs0BdB/k3WFUM36KX6HNS
         x1xhOZcxe4qQl3ghdtaa0NIQ5sNjduT6nUztMixSrJ4aLIcEE3dndXOc2/KJ/NrwpBtR
         oqeWl4VkUifqtVUffaEwz3dK+zDQVFE5NBLXM7O/44EsT841WudovQ3STmpMGeZ01Uw1
         AinQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=hvRX8RJi;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w125sor993389ywc.30.2019.01.31.11.07.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 11:07:55 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=hvRX8RJi;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dd11Ii3Cwcf72oIoTmhO01bly9ahZY85W2Izjt3U5d8=;
        b=hvRX8RJiFav8ycoAvncqkoNTMwfyyfv1/U88oebthLcFCEbkOUldlpbnenDBdWB9Rh
         RfrC2gfuMa9dyAYdJM+DCVuvs2j8IOpByX3nq7g9nZpeEnirhQ8FoJvbK31AATryKkRB
         QoDtjb498sj6yyYOFpeo4NJMESuCWnszZ2Jc4=
X-Google-Smtp-Source: ALg8bN7FL6RHa7Uni7yiHHCDwueIeiIbxA7m88UA7ZdQnUBCNZgunNseiR3rf64JQzBRNeLpJwWkEQ==
X-Received: by 2002:a81:8284:: with SMTP id s126mr34383456ywf.23.1548961675233;
        Thu, 31 Jan 2019 11:07:55 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:7e97])
        by smtp.gmail.com with ESMTPSA id d3sm2123298ywh.58.2019.01.31.11.07.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 31 Jan 2019 11:07:54 -0800 (PST)
Date: Thu, 31 Jan 2019 14:07:54 -0500
From: Chris Down <chris@chrisdown.name>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 203/305] mm/memcontrol.c:5629:52: error:
 'THP_FAULT_ALLOC' undeclared; did you mean 'THP_FILE_ALLOC'?
Message-ID: <20190131190754.GA6743@chrisdown.name>
References: <201902010206.hcZ8gj0z%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201902010206.hcZ8gj0z%fengguang.wu@intel.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001373, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Patch already available: https://lore.kernel.org/patchwork/patch/1037502/

