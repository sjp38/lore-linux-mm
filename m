Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F46BC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:06:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B1A820693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B1A820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAF478E0006; Wed, 31 Jul 2019 05:06:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60418E0001; Wed, 31 Jul 2019 05:06:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A75E48E0006; Wed, 31 Jul 2019 05:06:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71EC28E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:06:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so30844555edv.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:06:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0D1reMCoi5d05BUvdr2a4ikcjxJEngxtk9htVS4S66o=;
        b=G+D5JjIbfdpcpbQ4cK8AhJDQMYOrBSPREqpezEJER7x9YRQxT5kvYVlSvdhb1Dnb9S
         LIMSwduBB1/Ah8D7SDGuS+LXciXXJ+CVReE9JK3FIDHVr0TBgMGcFoUzobiyMBBPL7Sv
         BEOz/UMqELL31mp8x2IxSp82SnpCgQS033L3M3n3DDsDfoSWUWWSbAtHmOXISoVK1TCv
         CBB4Y4Nlde8Pk/5Emh2xQgSptr1o+UsxpQu1TBLFt9+QZccreUR3bWdy0MTQ/UUsv14U
         OlMypEPEplff2HGSS59p63rUdDEw4DEMtvbfEOCQ3giMHjWlCryNN2dYLCUtSJE4pHh2
         mIcg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW1dBHJOdZkKbYcyivKMgbYgyQ59jFl47U9Z0JsBqHSB6SCUZZ3
	Q6rZSjjpEXKG0z6XsXk4OiT7GqeQs08CxqQwi05/vPXyY1S4YqoM4xfUYV4P+VPcRPGGPr7l/9u
	bA+eXyL5lnIQq/kRdpppAbmiSRZwymMFGKDiJ6TzaMa0sqHunXZFoLLLuSljuKS4=
X-Received: by 2002:a50:9ec3:: with SMTP id a61mr6921734edf.184.1564564016037;
        Wed, 31 Jul 2019 02:06:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyddZytW/VMizryJpu8+dUVhm9BDQwFVeb1OxqrTKK6bwSxEAh+KizvRekCVldPSVlymPk6
X-Received: by 2002:a50:9ec3:: with SMTP id a61mr6921674edf.184.1564564015151;
        Wed, 31 Jul 2019 02:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564564015; cv=none;
        d=google.com; s=arc-20160816;
        b=qru2oFQnMhcl4BT/GCzTwTLtn7ajOlBwLdHIPydF2OYkAm06oWLKwpBDORwtrD2raS
         Fov//fvwpYBjnvRHaf1HSCOod5AhVfCostW6hBGtZRFVPXctKO58fILscPldlcDx5fkW
         865qyOrm0vK/qvr4yTUTM5c6E99ejQ2s4q3rzkt7KNYG0pWm9Y28UJEoxmrGCpbw5gRp
         Xcq1ywvyWa7kk2bDuHP/z/AzTMg+JSIkeZSAllYVQoYqAN5Gqprahkmgp4dKqMmP4E56
         2/4k+95WjiApZU1bX2iOp4uNevgowRqGfr8wa9GPu336fWa6qpkRzIvsVYzi0Tf68U3E
         hUUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0D1reMCoi5d05BUvdr2a4ikcjxJEngxtk9htVS4S66o=;
        b=WgBaovTogM4Fw5Hkeyo9vrOXFqsnSoSqg37LTXqBJTGPCSNyv1ZoxC0MJLIEgNY15K
         fPevQs/OhJiNaVjTZoADWZjv7M7VVb829stECp79Ali8JpJR/Te1bjos1HU6Wuidqnsq
         tXMfxGAZDVIFGhcC421lzkCVsHRx3oyzL72+hellFBD0BOHiOx4umwW7/4PZy6ik/QGa
         VD5XkI3v0SihmT9IWrRTc9UwJUZ05cnNksfVZZGElYNhLDiuysee68Jx+H0AIAP8+/54
         8c9mmk0VzHpADTbih2D//8qaQVjLeBXss3i+pSK0wNaLOAujdZV5HIdvI2hw8HqY+XoC
         JF3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si19931700edb.442.2019.07.31.02.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 02:06:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 90E14ABE9;
	Wed, 31 Jul 2019 09:06:54 +0000 (UTC)
Date: Wed, 31 Jul 2019 11:06:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731090653.GD9330@dhcp22.suse.cz>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 30-07-19 12:57:43, Andrew Morton wrote:
> On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > Add mempool allocations for struct kmemleak_object and
> > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > under memory pressure. Additionally, mask out all the gfp flags passed
> > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > 
> > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > different minimum pool size (defaulting to NR_CPUS * 4).
> 
> Why would anyone ever want to alter this?  Is there some particular
> misbehaviour which this will improve?  If so, what is it?

I do agree with Andrew here. Can we simply go with no tunning for now
and only add it based on some real life reports that the auto-tuning is
not sufficient?

-- 
Michal Hocko
SUSE Labs

