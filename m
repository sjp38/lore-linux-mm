Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD505C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:00:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAD7420989
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:00:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K5mTZO29"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAD7420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48AA86B0284; Tue, 28 May 2019 14:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43AE56B0288; Tue, 28 May 2019 14:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 351846B0289; Tue, 28 May 2019 14:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C92896B0284
	for <linux-mm@kvack.org>; Tue, 28 May 2019 14:00:31 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e20so3910011ljg.11
        for <linux-mm@kvack.org>; Tue, 28 May 2019 11:00:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=gzRimgoeRu7R/UsHOkPXtR9NqQokG6oQDoPTeeW4GsA=;
        b=o0vwPobsJ8fZ+XEXr6bxFeIZUJOArEvJVVj7owi5kVNbBYoIoy5oKsrt5udbeNE/6i
         he9wVgMi3vVr3v8kDZJo5+uyaVlQsZtIWH9UIEI5DT7mE+WWefq9bX7V5Tgp1sl4SfFg
         CUOIeDzJu5A14ikdK2y00PSQCRrspUErhxBRIsRjpMo7ixMb8DNMZh/qCmhBtystuLCa
         RYePS7vhbvZ2b3j5EBHZ9c5gyPSL2OQrVsuYOlPnhm3mmJzRgReIzmNQQWqqcq4USutH
         eD+dczXKzFm3WvfclGhX0IbIzs8N+eoB36+3bfBhZWKc8E6T4UYMkG4E2ywBz8XzIA//
         5fqw==
X-Gm-Message-State: APjAAAVMl+E/2Fiy5l4zZ9Id0L4I7xP/AsWpldCiOxGeJAO3Wjz3xuv9
	8rFD2lO9HT+Y05R/F/Gv3SnKW84rPRNUyRVqZhTsJl2ClJRfeW/U04+2fPZyUY/qHWh2JX/uevk
	nex1lEnv5P6DbTr+nhmN4yZ5cC5SlNogyOeszFTKLUsWPGT3+qwuGRlUh4y5eMiXfow==
X-Received: by 2002:ac2:4899:: with SMTP id x25mr8694600lfc.44.1559066431151;
        Tue, 28 May 2019 11:00:31 -0700 (PDT)
X-Received: by 2002:ac2:4899:: with SMTP id x25mr8694548lfc.44.1559066430132;
        Tue, 28 May 2019 11:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559066430; cv=none;
        d=google.com; s=arc-20160816;
        b=wS1jCiS2AXK6VVIaKiWubHI46xcIfK1Ia3XwCxjrYNPrCQyQFD8HMKy/xkMcDnhYoP
         t2AvRViBs5kVznpzcrt88bwHLulaa/1qdbzFCiyp6PbtTbQApqkJwY/hu89HjIYgx7yh
         kJqPInfmDqFP1I/LnOZgOjMDjNMagswe/sCWAouU/KaYGj1nmHGCVEiNJpD8tkQjcX1X
         uiCQgP8IsM+oodYATKhcFTXajY+lIK+LmzgLmBGL4HxJH+D6tGLEj7jJCs8rfhx+AYhm
         y3Lje34ju9uFrcL9QlWZNBuHd1TirIhItfqOAn7MKQGfgsdCE5gJ+8T6jkY74hGxUjig
         pCqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=gzRimgoeRu7R/UsHOkPXtR9NqQokG6oQDoPTeeW4GsA=;
        b=hVs/jYjZW21m/Y5NVbBk84hK8kHWYQAOFjVqv/knKxVXYVaAg0nmU2wRTIxju8UQ7r
         xjfJMjWOxHbC6b/V4iE3YFFX7+PRTQE6arIyh3RuACb7BvxsKv3GOnIieBFU3gxRjK13
         R1prWMC2z5grwQKWQi1rnPRL27AFqZAl9vhPtEqQGhEKlczEgj9+qqq/goBhFUo1Ae1f
         nDM+/S3DiHVaYYZeJR7ESEHoAon9AGTNfeZWA9oL2Tx5+wh/C2hnuLSAQOrCEesncFmr
         06t4h8Ws59C1KISWhh6teMz6yf1M1eiHmoplKxe9j7tdmFtT8utnfmYw3YRo0nAQCADz
         srkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K5mTZO29;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor3956014lfi.48.2019.05.28.11.00.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 11:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K5mTZO29;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=gzRimgoeRu7R/UsHOkPXtR9NqQokG6oQDoPTeeW4GsA=;
        b=K5mTZO29tbBaLBfmC9xktb9UyEHFJm7cNGH2ho7TmDNYxAatoyUag706Zd7cjqjf28
         KkeBW1GaNsqZpGtuXpPL2jgCnJM5DuHaiEWuudtfGOhqTqHMJOGDCHv8YAGmcWlXiSLK
         tvB79wzMLr5Um6QS7j3cKNsAv1752T6NIpZ/9dqKNuDh+uFqgoopmTVuvev/Ic1UEPV9
         POninSj+/FBXrDQrPHxHzYlplgfdBdt11aQdVLcmU7bI3aGISf73jtSTKnsqq7hOE1Hl
         V+x+dWvcxXzA/c6PZ2CFDN+iGZBodzbs4Zs7PsfeskXJix3j7cStbEXLgSLKM7CJ7KPj
         kKnQ==
X-Google-Smtp-Source: APXvYqza2BE+UrIAhAKBPOR5jKGph27QtzFQbF50zdcH09u6RqUIDrc1Df0ox4XY650tVc7LO0usqA==
X-Received: by 2002:ac2:5285:: with SMTP id q5mr8975099lfm.146.1559066429696;
        Tue, 28 May 2019 11:00:29 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id e19sm3048133ljj.62.2019.05.28.11.00.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 11:00:29 -0700 (PDT)
Date: Tue, 28 May 2019 21:00:26 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
Message-ID: <20190528180026.zb6yaxdeapwx5r3v@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com>
 <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 08:08:28PM +0300, Vladimir Davydov wrote:
> Hello Roman,
> 
> On Tue, May 21, 2019 at 01:07:33PM -0700, Roman Gushchin wrote:
> > This commit makes several important changes in the lifecycle
> > of a non-root kmem_cache, which also affect the lifecycle
> > of a memory cgroup.
> > 
> > Currently each charged slab page has a page->mem_cgroup pointer
> > to the memory cgroup and holds a reference to it.
> > Kmem_caches are held by the memcg and are released with it.
> > It means that none of kmem_caches are released unless at least one
> > reference to the memcg exists, which is not optimal.
> > 
> > So the current scheme can be illustrated as:
> > page->mem_cgroup->kmem_cache.
> > 
> > To implement the slab memory reparenting we need to invert the scheme
> > into: page->kmem_cache->mem_cgroup.
> > 
> > Let's make every page to hold a reference to the kmem_cache (we
> > already have a stable pointer), and make kmem_caches to hold a single
> > reference to the memory cgroup.
> 
> Is there any reason why we can't reference both mem cgroup and kmem
> cache per each charged kmem page? I mean,
> 
>   page->mem_cgroup references mem_cgroup
>   page->kmem_cache references kmem_cache
>   mem_cgroup references kmem_cache while it's online
> 
> TBO it seems to me that not taking a reference to mem cgroup per charged
> kmem page makes the code look less straightforward, e.g. as you
> mentioned in the commit log, we have to use mod_lruvec_state() for memcg
> pages and mod_lruvec_page_state() for root pages.

I think I completely missed the point here. In the following patch you
move kmem caches from a child to the parent cgroup on offline (aka
reparent them). That's why you can't maintain page->mem_cgroup. Sorry
for misunderstanding.

