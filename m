Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A920CC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7878821901
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7878821901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DB768E004C; Thu, 25 Jul 2019 04:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 096EE8E0031; Thu, 25 Jul 2019 04:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E951B8E004C; Thu, 25 Jul 2019 04:05:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2CC18E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:05:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so31678140edw.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:05:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rlvw6TLXFdSdmxtp4U1HmMLshXs+xYsf/NoONBfffgs=;
        b=Uua1ilEXiofHenqzY9Qv/REjxaqeuUyA2BKmq9uNxjYlC1WlWMvUC1oPPU16xE615W
         b/1b0S+VVt5ZRijkafoAXy04ooXKupgDtVpHH1xg/Ivaoepi95guX3D6eq9a6WdFoW8V
         XCm3MT81lXv/LcIMYrsmaAGKClEaJeA/y0tTiIxxacXNLh2mX4G9R58rxqD61ib0B+U3
         CSx7oxgU5KQ2Gco21TaILDUnEDaMFmDAhbowxgknZXBhTRAAA8Nm1EKlVuYv66ByqqWS
         4nT7vpHPQsdCJ2DUIE+z6FC//0M7R1Ofrh7ecBW0hWnPM8dXbx9vAwhDXh9/SG9Pldxz
         75zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAV5UiEnudgqQqWq1QTc5m7K5MfGsejOZy5ofAYpe588S+Tqjb2h
	iEdcaseWd2i4D+h8O/euUa+N4SJbq0BjJRIWN+16ONU/2ERjWj6o9q1YYn766l3icPokRpGruc9
	TCs+nDyfYqT6+cOvjOEmrIu6uQnqaY+Dw6P2uiuhgggiaKrd6nbEittWrcI+xce9Kbg==
X-Received: by 2002:a17:906:80cc:: with SMTP id a12mr66192104ejx.132.1564041956269;
        Thu, 25 Jul 2019 01:05:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLUvreG/chWPcP2Y6RaU4fonadASQMDM+jVOiSu7JoVrK5oTbjeQwt8HBjJApUHrvMYQZe
X-Received: by 2002:a17:906:80cc:: with SMTP id a12mr66192009ejx.132.1564041955554;
        Thu, 25 Jul 2019 01:05:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564041955; cv=none;
        d=google.com; s=arc-20160816;
        b=cHdGvkpX/ETVZR3yZt1qdxBCsbZPedbsDdUxrHTEoZrGjEXjzpEAdwnQVjXkbXprxG
         BWN7XUHtzuNI0k3zKCtZat0rgjo362eEGH6wCl+6EcbIFErMpFJ1x3hsZSl7YjckrumR
         0Xv+2zCddGE15UT3JHqVp9RMDv9VW1rIXDYQZkr4Upk/3791sALDAxg5ABo2JbwX1i+L
         su/zW7DQ2ChuWmKuZf/XsGWUVyZCEdnp1a9st5dNWsquoPyr/QDIqgVQy2ZNJZNY/3PT
         opFVNFSSDcQTt6Fo0MVjqrZYv/MNdHc61DXsBQlL+oaBdsbXdm4DBM4nx6suY/FY6Klz
         PqCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rlvw6TLXFdSdmxtp4U1HmMLshXs+xYsf/NoONBfffgs=;
        b=WefR4SnDh/rR3IGLls86bISTEr53AYHfWoWEF5Kn2j6mHZPn1R460rME7aeLsZ842W
         JB82jJCOPDQCEf137elEq0xrH4fxgfhegFzD3EiXdKTf+CX5Gacu4wn14L+QIIZ2YrcE
         ppU+kEPRKcQ2/e0FdwwREw8Z5/kgXytxD7Xz8QNqh7qiLUeqUWP1V0qDYRv9dZDXFagF
         SUVKMZFeLbIv42Rfix/cvy5t/PaJYiEGyABUHDxHyMnof8Zl0m4+7Bhec2+FZzHi07JK
         LhmrTVkNvC4XJBfYw+1XqSafsj/iilhJE7E4uxIyF1TrpcadDMpX2IEGAzhgqOn8uRHM
         I66Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si11333736edf.297.2019.07.25.01.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:05:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1B416AFF4;
	Thu, 25 Jul 2019 08:05:55 +0000 (UTC)
Date: Thu, 25 Jul 2019 09:05:51 +0100
From: Mel Gorman <mgorman@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim
 perform dryrun detection
Message-ID: <20190725080551.GB2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190724175014.9935-2-mike.kravetz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:50:12AM -0700, Mike Kravetz wrote:
> From: Hillf Danton <hdanton@sina.com>
> 
> Address the issue of should_continue_reclaim continuing true too often
> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> This could happen during hugetlb page allocation causing stalls for
> minutes or hours.
> 
> Restructure code so that false will be returned in this case even if
> there are plenty of inactive pages.
> 
> Need better description from Hillf Danton
> Need SOB from Hillf Danton

Agreed that the description could do with improvement. However, it
makes sense that if compaction reports it can make progress that it is
unnecessary to continue reclaiming. There might be side-effects with
allocation latencies in other cases but that would come at the cost of
potential premature reclaim which has consequences of itself. Overall I
think it's an improvement so I'll ack it once it has a S-O-B.

-- 
Mel Gorman
SUSE Labs

