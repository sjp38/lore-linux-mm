Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE081C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F4462084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F4462084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18A1B6B0003; Mon, 29 Apr 2019 07:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1397D6B0006; Mon, 29 Apr 2019 07:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1C3E6B0007; Mon, 29 Apr 2019 07:30:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B43696B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:30:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h12so1913040edl.23
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:30:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/pasL2o63KWnSx4IhrMqry5HNoe8luyELiHwEYIvWiY=;
        b=EFw6EEMLcgo3Vwb1HBJjgKqBHgow9xUG9ENe+7SfDpedcnfQN7Gw/huHYrBQpDygOl
         H4lKeqLRlLozhzgU2SV1xC5MDpOsK5Mxpyw//uSNSGYLxNT/sXpLqa07Z0BkNTZFunC/
         6qZfen388O5QZR2ZQ1dYj16vf9Wkrfq9FjHWVxeVhBveTu/Djzh6Xaak3I0ThDj0NJCa
         PUbK+Ydwqo4gzm25rsYnflfAWtknxQG1e9xpucMC6LPv8C3+0lr3QaKg8HsKV5Oo9jS2
         Lf4K7tLctcUDefNav8Ulp5e5xzLC9LtnTwYpj23hjIJt0cmSOowSRrZs2nPpQ6RPDbGD
         DEYQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUxV+edJJ2Rt2Gi7t9noO60CNS578D28oVLI7Ud0AY31Ie2+IFo
	7NPPB4AptvYP1h/okTUwUGLC7ncDdpc+uYz65ElYIURYga/+g3zC6DywhST+YgHcDr7x9U6zeVd
	dnMHX3+4qHaB7Bcfx57lkY2SrYX0lZ0JwZ9YuHIvF3XUKt/CK5XVZBuCGtHZuux8=
X-Received: by 2002:a17:906:e01:: with SMTP id l1mr2749526eji.273.1556537427307;
        Mon, 29 Apr 2019 04:30:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNTZPaRvKFX2CFCes30X/UWHyd6CZNnc+xnuXwOPOv2ADqrnijAfkU6nDdjVVl7Kk1HJA+
X-Received: by 2002:a17:906:e01:: with SMTP id l1mr2749494eji.273.1556537426504;
        Mon, 29 Apr 2019 04:30:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556537426; cv=none;
        d=google.com; s=arc-20160816;
        b=rDvFSCEAcBzyeP7lPS7LXoecRKTI0HrkoEUcPvviloUexZExXYCXXMiqbpb4TnLcld
         QR6fK1yrNKLJzeIJt7cRPjgNO6M9OMNSQp2fAh5dLTCWeic/tZCakjkglcez9Jh8STM9
         vdiVFn/JkW63Cmo2qMfg14JZUQbDcdMuK2KCT50qxugUEYpPSf5f4pQ7HYJVQuxD6dRR
         kNQgDlEnCoWsn1wOcY0YFDPmlSCjEuy8KU+zS2vqLaqugRG59qa+/ZaB9WZ2JqHxeJ7z
         ZQhslnBWfqhNZNDmFcMbZHT02rCFgiH5pKGNCCa6rsLO/YIQVYIIWBg8QVV78FSYoWLE
         qfMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/pasL2o63KWnSx4IhrMqry5HNoe8luyELiHwEYIvWiY=;
        b=n7vVmch9QFGhFh6ANEXg4f3V8sCecTsE19GZY11THA7w7qNVF0r+ZCqooYqOYp/riK
         YZzDzUojhi+pSMgX2M4hsKhQBTgEICQBffPnxShPyIxg4FfM0YInJ9PEW0ZGr+gAbqq5
         0Wd0Q5zRDD9bGzB+V4msDqDpo+bJDLdbgT73LOR3PdmVdC7Qnc7F51WXRDwI1wO+CFtJ
         5PRqKvKkUFfnyqIMheSfNPolGi3JVaxRY02NZ1GGkFCjC5xH1bUjuGK0PnyxhowX66Jz
         U9MUZAGqDYVf3Y6Uf1XB7jKe0BVDMBAfFz6dntA8wj0v6tIAx2yzr0BCCV4XiCpg6k+l
         yYMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6si3291146ejb.67.2019.04.29.04.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:30:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 90B80AE84;
	Mon, 29 Apr 2019 11:30:25 +0000 (UTC)
Date: Mon, 29 Apr 2019 07:30:22 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
Message-ID: <20190429112916.GI21837@dhcp22.suse.cz>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429105939.11962-1-jslaby@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 12:59:39, Jiri Slaby wrote:
[...]
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -	/*
> -	 * This needs node 0 to be always present, even
> -	 * in the systems supporting sparse numa ids.
> -	 */
> -	return !!lru->node[0].memcg_lrus;
> +	return !!lru->node[first_online_node].memcg_lrus;
>  }
>  
>  static inline struct list_lru_one *

How come this doesn't blow up later - e.g. in memcg_destroy_list_lru
path which does iterate over all existing nodes thus including the
node 0.
-- 
Michal Hocko
SUSE Labs

