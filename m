Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81655C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:21:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BC14208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:21:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BC14208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBD436B0003; Wed, 19 Jun 2019 01:21:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D46588E0002; Wed, 19 Jun 2019 01:21:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE6418E0001; Wed, 19 Jun 2019 01:21:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4006B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:21:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so24465242edr.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:21:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xFRGzeiFO8+pD19Md0LFWfOM4XJAqNPTCfgtFjKFPaA=;
        b=GN4CeJZRo8ibBlv0HVEK4YBDL686hiWPh37AWQcFaerFyTG683Cw+pqTDh/uUamrSJ
         xbX1s7lX+K4BN/DmbHdFOFCeX83SG1+4qYMeYcm3whxbBNFKW8nRbHk6+dxSliVNTUec
         TVg+83S43d1FrELxpKEhs5STVZCOKpzdUneFQRBJ+uMckD9/g74AIPcKw/oliIj451JB
         Yik+ZQXc2XmuloUUzPn9jgPD8w+BmZGmuIT67/+B9Rzpm1j6wfgeFrYQFlftEF2rDR3e
         gN5ETQBr6l8zC5Wqpd/JrsoheVoW03CMYfTDQVwQ9MFgd0cCujRntH3BRX44o2E286Dd
         k/ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXKm9+FRcq/lPF30H7gzeTnBB8jRcdcSEUc+ut31m+umtZOBJy/
	jICCNsYzoKAUvpe05WofDn/2+/+oHgBZkyPbhYpTmq8jGiahZQteMT/sBcGT29H2fG6y2FpQLcX
	1t+6UK+5UbBbrFgd9h0HWEjJIhW+vYtIyhfizzgDwM/Vr8LHRoQMWPNZB2cdaUw8=
X-Received: by 2002:a17:906:1f44:: with SMTP id d4mr93255235ejk.195.1560921696005;
        Tue, 18 Jun 2019 22:21:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Q2zRpZv/Y7O5JHFL88v8XRlVW6mOMcYeacMRv85Daw8RDyNKofOQ6ospMUGpePV+QMss
X-Received: by 2002:a17:906:1f44:: with SMTP id d4mr93255202ejk.195.1560921695286;
        Tue, 18 Jun 2019 22:21:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921695; cv=none;
        d=google.com; s=arc-20160816;
        b=pZrd1x7Qu57WdzAVYFjO99AplA4AwvxBH/aOMzgi8zbmreyFH4fMG3mqvyrSlebLYi
         KtFT/uyM1Xg5oj8YDxBWkP7nERXObLOFqvN6rfJJWCOC7/kmOfpuM7USPzRPJgUBZpuV
         LJZSXfG2TNHqgu4Ae6zFcaKR3MaB66ZTEDuKlcXX01f8QuUnkjAGs32V5ZyBaeSFvpLS
         uWc4Wha6aOlh+ZcBU/yIzXZ77o3WAhdWPFGb7vXUWw0VocMCVt5dI7dj/fGRrU+BMATN
         oNW0YUIlWv06jGYOzmi3ZXB1oTeyznK5mRKjz0JUGdNdrzAi80jToSVrB42COOY02VXr
         49sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xFRGzeiFO8+pD19Md0LFWfOM4XJAqNPTCfgtFjKFPaA=;
        b=RkVYar/ktBPzaMz0mCzoxncLM0xd5Y02vOfXKcZ4GnqWqEDotXr/AsAhbfrTcNgeV7
         M6t+IH8U9YEoHjHlBoMoyKmK4liP8wAUL0AKNK9LIuo8lzEUlqDWmhblMS5DS1GDu0zn
         YV6MyB7qOkLbQceRSzfOoIi8rvM6nul88O7WF7MUwTJ+SaFIxu+DLcOSEWgAUGySMmXk
         OMizxC41fJfU/RM6eo+yVLJ4ZjM0gNAAWsK0YZU9tvugEwGMGHwp4a9tF57QjiF6befd
         vU41AtD1YPQIakxAGWvZ68uLBBx7iseJagApSw1Onhb+FfuTktaCV/eg5269Q85iEY7y
         Qo0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a20si10562463ejr.109.2019.06.18.22.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 22:21:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60E36AE04;
	Wed, 19 Jun 2019 05:21:34 +0000 (UTC)
Date: Wed, 19 Jun 2019 07:21:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
Message-ID: <20190619052133.GB2968@dhcp22.suse.cz>
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190618130253.GH3318@dhcp22.suse.cz>
 <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
 <20190618182848.GJ3318@dhcp22.suse.cz>
 <68c2592d-b747-e6eb-329f-7a428bff1f86@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <68c2592d-b747-e6eb-329f-7a428bff1f86@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 14:13:16, Yang Shi wrote:
[...]
> > > > > Change migrate_page_add() to check if the page is movable or not, if it
> > > > > is unmovable, just return -EIO.  We don't have to check non-LRU movable
> > > > > pages since just zsmalloc and virtio-baloon support this.  And, they
> > > > > should be not able to reach here.
> > > > You are not checking whether the page is movable, right? You only rely
> > > > on PageLRU check which is not really an equivalent thing. There are
> > > > movable pages which are not LRU and also pages might be off LRU
> > > > temporarily for many reasons so this could lead to false positives.
> > > I'm supposed non-LRU movable pages could not reach here. Since most of them
> > > are not mmapable, i.e. virtio-balloon, zsmalloc. zram device is mmapable,
> > > but the page fault to that vma would end up allocating user space pages
> > > which are on LRU. If I miss something please let me know.
> > That might be true right now but it is a very subtle assumption that
> > might break easily in the future. The point is still that even LRU pages
> > might be isolated from the LRU list temporarily and you do not want this
> > to cause the failure easily.
> 
> I used to have !__PageMovable(page), but it was removed since the
> aforementioned reason. I could add it back.
> 
> For the temporary off LRU page, I did a quick search, it looks the most
> paths have to acquire mmap_sem, so it can't race with us here. Page
> reclaim/compaction looks like the only race. But, since the mapping should
> be preserved even though the page is off LRU temporarily unless the page is
> reclaimed, so we should be able to exclude temporary off LRU pages by
> calling page_mapping() and page_anon_vma().
> 
> So, the fix may look like:
> 
> if (!PageLRU(head) && !__PageMovable(page)) {
>     if (!(page_mapping(page) || page_anon_vma(page)))
>         return -EIO;

This is getting even more muddy TBH. Is there any reason that we have to
handle this problem during the isolation phase rather the migration?
-- 
Michal Hocko
SUSE Labs

