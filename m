Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4E89C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 06:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72F892070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 06:25:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72F892070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81348E0003; Mon, 29 Jul 2019 02:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C31AB8E0002; Mon, 29 Jul 2019 02:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B208A8E0003; Mon, 29 Jul 2019 02:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6154C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:25:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so37664399edt.4
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 23:25:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=K6g8++WH41POG/ZREs7EijTLSEFeYIMBi5pbvJlxPvQ=;
        b=pD0ZKFzN0PJhzL/09YE+dyWQ9b0a1juYvAauyAyeCT6jRkIVnNyArkOFejoR1yugbf
         fYkUJfWr5RHfUoMdYowrzeXsQeQg+7qMNyFhD1dPdF59QPu2hTd+H7iXeoTrSxGsMpb8
         0Ixjc6NcOdkG5xny0gb//bMHnxSI9hnl9s5twO+prOPJREhAy8yuUCiew32K3/B8nSVq
         LJCdbG0pva7SvzjlxV2j2z58G1GzjePaUXLVNwNMK1zo5Zk+KqsKrWJLQzk3XATj7/G7
         OD83WikwgjxNmtaJvLDCL8eLcw/Vc81OoHrAzvN5mpwN4vyMI2LWEYYw8AA0uGzWZvtO
         s6RQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVGYd82hbiw96VIi5iY/cU3dm6PpBpHC0UpTQhiaHhPrqqxluVw
	ZaDyovUl7ZdXk1MuWGzwC1m2kZ9zDutiCdjfKt4SepxpHXjoAk8DL1e9ixvR7GsfDESS4FuwtmZ
	/NpILNefOycKVFfc7Am2nNHJVFD8YsXWNT5CRLGaJlgcEY5SMqRlLlxlSbZaZvMU=
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr81273597ejj.164.1564381502977;
        Sun, 28 Jul 2019 23:25:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1XFbBRba1SRRD8yknI+ENQ2gMiS4R8PO0aP5xIwDXUMxFPwcvipFXRbN8hsvvzjs+13ls
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr81273573ejj.164.1564381502250;
        Sun, 28 Jul 2019 23:25:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564381502; cv=none;
        d=google.com; s=arc-20160816;
        b=O9+uFnrKKXpvPC69+n1yu/OILKwFNH0upYhHfDwW0FK+/PQA+uh+cXhdGCVUEWvxpt
         MU3SoAUpU72zM+3YzYnUvK0YzVQ/OlpKYxxylJZSNWXZ7f61xQp9gtvAI1+m2OHbguV1
         avgILVMMHAwbp338akA18Ty9SdCJ0+DB5CFViKpO8at9QT5b8wrFGXYWjnGtrmQ9qS8c
         2Y409mAbbVuVpHJ74zUIG5JjYNLgBir77Ma2QHxiUc+0KzdXofDfTi0Yjh0AdiuM+3Id
         vartgJhl85mYF0SdOISdoliXjrJ2wQ4bAVeGoc/h9vUuMX9AsDfKgGp5USJvbzfdvCKE
         BjvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=K6g8++WH41POG/ZREs7EijTLSEFeYIMBi5pbvJlxPvQ=;
        b=d2sKbP8TWuD1qC+D1nMJ+mPy1l9gusyer4laJdDrRJK1wECSWplx52tJKa3Q/XNvC3
         8TgTAqo9xam7m4UiYuKOSxAqxlfe1Cz+VYv3oG0HuBWqbWueiQSjix0izPfG8mY1sugT
         6NOJyZGZAX8QPIcGGCCvjxsCRC+rG3183GvTEoaoKZ16QDxf+Ska/7vpMmWJ2yurFrFr
         o1oKuikJcQwR1QNOJhNWGF8CFTspEaXnbE9YgNm9FEVU6QICpCvnB7Ltwwgm96EBN2vo
         9p53S2SuMvlOf267TBMkEs8WF78WxF+4JkI8K3xxCqawXstMQLJ1hTMgGjvvvsC9/gmW
         id8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si13905903ejp.141.2019.07.28.23.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 23:25:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 765A3ADFC;
	Mon, 29 Jul 2019 06:25:01 +0000 (UTC)
Date: Mon, 29 Jul 2019 08:25:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
Subject: Re: [PATCH v2] mm: memcontrol: fix use after free in
 mem_cgroup_iter()
Message-ID: <20190729062500.GB9330@dhcp22.suse.cz>
References: <20190726021247.16162-1-miles.chen@mediatek.com>
 <20190726124933.GN6142@dhcp22.suse.cz>
 <20190726125533.GO6142@dhcp22.suse.cz>
 <1564184878.19817.5.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564184878.19817.5.camel@mtkswgap22>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 27-07-19 07:47:58, Miles Chen wrote:
> On Fri, 2019-07-26 at 14:55 +0200, Michal Hocko wrote:
[...]
> > > I am sorry, I didn't get to comment an earlier version but I am
> > > wondering whether it makes more sense to do and explicit invalidation.
> > > 
> 
> I think we should keep the original v2 version, the reason is the 
> !use_hierarchy does not imply we can reach root_mem_cgroup:
> 
> cd /sys/fs/cgroup/memory/0
> mkdir 1
> cd /sys/fs/cgroup/memory/0/1
> echo 1 > memory.use_hierarchy // only 1 and its children has
> use_hierarchy set
> mkdir 2
> 
> rmdir 2 // parent_mem_cgroup(2) goes up to 1

You are right I have missed this case. I am not sure anybody is using
layout like that but your fix is more robust and catches that case as
well.

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

