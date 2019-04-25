Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39733C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00B83217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:47:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00B83217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA8F36B000A; Thu, 25 Apr 2019 03:47:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C58A66B000C; Thu, 25 Apr 2019 03:47:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B47226B000D; Thu, 25 Apr 2019 03:47:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7462A6B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:47:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e22so11219588edd.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:47:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GW5xBD4VSWju6Bks50aOZJIYMMRXdtn9b61Q+TSLpPM=;
        b=UMkpqXt7Zm5DCpAiQf4HiMnQzC+J70es/HfIbpEHplc/2DxgYSBls8tHbjPOGDjSX2
         Th7Xf9mvW/nWxWOGPW7sdyeXS3O0tG+SGYNyFWJqJmpltYy2NY4t0kz+bs4aTs0L+CMu
         6hw6ybb4pdI3rZsYB/Uk5HrMYappyTrjspoZck+sA82AYul6jjfajbvurjLKtpIBCOn5
         x6kRoyLV6QCIbwgUQOEfsVjGsPiD6+ZhI5iF5uWxnXaYxY9j3cNWtj93s0uX7HzKUz3k
         pbcYhjgMJmee0XQO7jkm3/gDcpCSY8Id76rnnTodYjKTqZHCmY6MVPdHIPDnz/rexHfp
         QFDw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVEbBPun6sPopiL1dGk618+O6BpOALeqoeOH1Kwr+9Oqu1HtykZ
	En7sj2BwXLCRD49PUrwOqBxefeEeX8jg7G+DPwXY0+p8DUxeOHmtVhGtZbETP/BZKkJzFnCmWJU
	2uJnf0HYiVP1xQfItfRTkLptRXh4Hj/Wuz1CvS74F5YC/joWDpJwgbItmUNjf3wc=
X-Received: by 2002:a17:906:2315:: with SMTP id l21mr2375904eja.85.1556174249649;
        Wed, 24 Apr 2019 23:37:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDvu4i6vPNEjkdbeqCmjd2FdOTS5UF8hz+oFOjK8a/TqKO9haD43Nvl8wjiroH1MG+q+Km
X-Received: by 2002:a17:906:2315:: with SMTP id l21mr2375868eja.85.1556174248935;
        Wed, 24 Apr 2019 23:37:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556174248; cv=none;
        d=google.com; s=arc-20160816;
        b=x3asVreyUu2xaIQTqWe2NqEwsGCQ1EqLbM2AlNleT+pBy1XqCNEz2ZmpO68kNN3VvA
         pExVKY7oEj1P0xpI5kceofvqGayIEqAKougjT0+LF3MsvWcYxGQ7WFhCMS1v8X0XnHia
         wfAPk6yb5lGDQi1p/TSdFFq2nNh7eqpjq2Lqai2b7IvC1HK7icoNB1provRsPkjwHG2j
         vxdC3DVNfObq7akPlSjrPLY7gwnSln+Eiq0s9VfeqdpVdU8hYXx5pOg928Lst8SW83aI
         IyrX+HqM44URBvPiPFlqK/kI/Wi5MT8Kyz7Zs5qhF6MDFDXHSI1edfPel4NP2Inbs8LI
         NiKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GW5xBD4VSWju6Bks50aOZJIYMMRXdtn9b61Q+TSLpPM=;
        b=qXpoz4KSRdwBIxNobWj1lf15doQ2SnNkJzRBdux+rZoJHzTPBizMipZthb4+mmXp5q
         uNwTEwhHCkQWv6yz2Ex8fWc6TNQFE2t2eXHhh6oq+u+Cq4x615WKiHgSu+VkrpVSn2AJ
         yPh5A7JMAmDrsv5a2FYxTdaXUh7NBEcI/lPRf/wJYmS9dzR3u7Zz2WA39+olPMCFszVK
         FvSUf+uHlNiQP5eOXavtRuDofs1FKlyunHIsT6dL169sJgGwF9X5tHekCQzPshat8vLA
         OMxPkIjy+5fq+6TuG/D8XwIS8LGBvNssW1NXYAfHAgE76OdUuXBpuvXKUs1EYiukb+Lp
         n1Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d15si4053585edb.99.2019.04.24.23.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 23:37:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5232FAE5E;
	Thu, 25 Apr 2019 06:37:28 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:37:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Fan Du <fan.du@intel.com>
Cc: akpm@linux-foundation.org, fengguang.wu@intel.com,
	dan.j.williams@intel.com, dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com, ying.huang@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Message-ID: <20190425063727.GJ12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 09:21:30, Fan Du wrote:
[...]
> However PMEM has different characteristics from DRAM,
> the more reasonable or desirable fallback style would be:
> DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
> When DRAM is exhausted, try PMEM then. 

Why and who does care? NUMA is fundamentally about memory nodes with
different access characteristics so why is PMEM any special?

-- 
Michal Hocko
SUSE Labs

