Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA3ABC06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B992520659
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:20:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B992520659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FEA56B0006; Mon,  1 Jul 2019 05:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AFBE8E0003; Mon,  1 Jul 2019 05:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C68D8E0002; Mon,  1 Jul 2019 05:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id E495C6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:20:39 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id k15so16413111eda.6
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:20:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=57krlvtseETjfpJnbB+lPGw5QKkwshNm2rVueJtb018=;
        b=PsJ4HvXCcxnG/5nrJd6Tv5sAhDuvKkFTAP8EvcLxupDR6cwzOuNNaWSNnrfmNUrrRt
         4SB6qHmqyU6dBxhFloFvxKmei549P3y86ZViO4Lop6OUV/3m9YogKJkOpp9gYhO6jvzG
         JkglYciAfX97EuPTihRq8Tag/RWTNUu4AmSRTGdjqaCJ84vHlAwYANO/WZUHRlZnZG8X
         5hIcrQnDj6ibiP0AuOrV+WnnWd9KDWhaq2tc6lAtDmN5qn7vIPpOVdr+fnI54xXq8+jL
         zT2hKevzKFSbHjFF/hL+fGT6BUwEm6WvOXivA9SeEuyRRCVipZ/rxMQBd0FmuPRP/Q5A
         3RQQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU/xlAp6tawwOOW3e/IWywm2KFz9d3/NQASi/X7N+3q08j8bL8U
	oYIZUdvDumtQamQHd6tP02gqxtGDJ9wrgrhi3MpDJN3/indXZsQ1ODkL8QQYBEf/Y/mwh7Gp9UR
	AC1Id4ZVKWIRlLRe4KHMWdcyjOUBq7aUlV5SfINJUL+pOzRF242BHaKL0x4go9ss=
X-Received: by 2002:a17:906:7281:: with SMTP id b1mr22282793ejl.63.1561972839502;
        Mon, 01 Jul 2019 02:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPaEmGo1EuFO1JeR5TTiKk4MgD3qAOTtqUMUhp+IoJ2ay2RJ2iTsi0h6YvdLvr1K9ZMvYe
X-Received: by 2002:a17:906:7281:: with SMTP id b1mr22282735ejl.63.1561972838640;
        Mon, 01 Jul 2019 02:20:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561972838; cv=none;
        d=google.com; s=arc-20160816;
        b=l0jjHT6MAUuyfDe2JU6EREHvHSsHWaVbbTs2lzmBgWFW6SJaG4xbeJmEoxu6U95kma
         lmXgELaaHw3NB9UZvsrKN34294BcU6PyO5qN1GsPoE70RahvAvrlgKiXDda9WASkyn3A
         NG6hx5Cr2XToT78LS6onQsbgegZvzs/TIaO9kYUbWfKQJLFUYNe7JXElbDRX6bYSpPW3
         XuC40CviB2IidwgiommFgNbUlsGjNpdItPJgyK+7esD993RBw3xv7GcZX1ac3auieX7n
         1LiZ2YveFCH7LyeLFBaGNK4WxQ2Klx4LM5llcDjHV/FWCcNQb6NP3fI0TVF0Zpb8COUn
         RgFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=57krlvtseETjfpJnbB+lPGw5QKkwshNm2rVueJtb018=;
        b=UnVkbu984BsgilVibw+OCnGCrTEFEL/kMBsiGy2CwymoaKNZyuUWk1y3ytRTrSH7DC
         1XwkQLvcnnDPtT1Vv+jK5LpzMWtwLpKzMo0ZA5h1JRIOIKNpcC+jp6lFacVFlUwcLocA
         RV9+2OVbyzW04I0BA/LjWspSR605ClgYymZj0fYMMFw7cGJwUQn27lDBYLLFuzdzVFx/
         uDZVyQHho2nO5f+Ty5eGPPTvoN4665Br53DEiO8fY1LmnasoQ4S/URjddN/T/b3OiW9k
         6eC0d3PSn+8FDPz6+4NppOacrCK9Opx3Uk8auyhnMH6Z++kj6OVEZFQRoMedCJuIdGCr
         VqbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m38si9009225edd.215.2019.07.01.02.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 02:20:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98C0EB02C;
	Mon,  1 Jul 2019 09:20:37 +0000 (UTC)
Date: Mon, 1 Jul 2019 11:20:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, urezki@gmail.com,
	rpenyaev@suse.de, guro@fb.com, aryabinin@virtuozzo.com,
	rppt@linux.ibm.com, mingo@kernel.org, rick.p.edgecombe@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/5] mm/vmalloc.c: improve readability and rewrite
 vmap_area
Message-ID: <20190701092037.GL6376@dhcp22.suse.cz>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190630075650.8516-1-lpf.vector@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 30-06-19 15:56:45, Pengfei Li wrote:
> Hi,
> 
> This series of patches is to reduce the size of struct vmap_area.
> 
> Since the members of struct vmap_area are not being used at the same time,
> it is possible to reduce its size by placing several members that are not
> used at the same time in a union.
> 
> The first 4 patches did some preparatory work for this and improved
> readability.
> 
> The fifth patch is the main patch, it did the work of rewriting vmap_area.
> 
> More details can be obtained from the commit message.

None of the commit messages talk about the motivation. Why do we want to
add quite some code to achieve this? How much do we save? This all
should be a part of the cover letter.

> Thanks,
> 
> Pengfei
> 
> Pengfei Li (5):
>   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
>   mm/vmalloc.c: Introduce a wrapper function of
>     insert_vmap_area_augment()
>   mm/vmalloc.c: Rename function __find_vmap_area() for readability
>   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
>   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> 
>  include/linux/vmalloc.h |  28 +++++---
>  mm/vmalloc.c            | 144 +++++++++++++++++++++++++++-------------
>  2 files changed, 117 insertions(+), 55 deletions(-)
> 
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

