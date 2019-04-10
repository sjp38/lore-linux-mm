Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 062C9C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C34A020830
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:54:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C34A020830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D47F6B0003; Wed, 10 Apr 2019 15:54:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4847D6B0005; Wed, 10 Apr 2019 15:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 377B36B0006; Wed, 10 Apr 2019 15:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA5AF6B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:54:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p90so1832205edp.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 12:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BEw+zpwtoGsN8GNgkVXhTtmFpQDYvQ9jV+gpZs/+t9k=;
        b=bm+4Hzs/TiAePpLpMT88Tx1d5rnMIAg9NVdw7H4NTn27dbT76DVUqmOilX+OhO0m/D
         I+gf7bIDYhtVwU7aBmniU9oHrdCtV5FZLb/l35bIslt1d0uHYNJ5wU1+JN7lQIYoTc4u
         R6kwqla3cO9QVVYt3AqpY2o9mIcflM4J3zvNTf38voIANawIeBtqeduEa2k1p2T6I19+
         wUgc7UoLEI7XqZwNg+ieneAVmF3Ofh6f6w06EDPgfDF+TAxiU/boSChWZf/EqimwH4GO
         FzfXiYGfwzTk9CUfjmFB77b2jLXRaP85DHRHhGJ1DRkp5/n3cxXlkxERyvnxocyzC1Xh
         Ye5A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWlAGYCWGeiPCryu0d0w5tLe+2c+PeD3QPUgvcrQidK4kySPO94
	QJDmTGEabmltaF0JZq7F11dn6m4rOy2dlaVQ7TlKpDLmWXWBRmJuIVZuReSop+PaLpbjtdw9H3f
	UAsz6XCsxZ3AVR9qto+XrFDYhAlS+CymE7kzf18f4cSfKxKkVBzLQqEnxSkjGAHI=
X-Received: by 2002:a50:ca0d:: with SMTP id d13mr27958687edi.72.1554926090385;
        Wed, 10 Apr 2019 12:54:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwr3q7wv5FBQ6Qv6ILxGO0HjsK+5WHfymH0SEEr6cqZ3T4pbjIvGu6f1bH1IaMjxpDV7gDW
X-Received: by 2002:a50:ca0d:: with SMTP id d13mr27958654edi.72.1554926089605;
        Wed, 10 Apr 2019 12:54:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554926089; cv=none;
        d=google.com; s=arc-20160816;
        b=0EL6Kg1447UO6Lx1u7WWvYVrWh4i1z79hwjf1JobTlkCY6CRMesM4Q8KNHbmsE6UH4
         xI59Az6DnYuJGCvBWVoC+zg8K+Z4GcNepc/SIUh+P1gJq3/sLGRDsHBfDzwdhzF7r6QZ
         79rzBIeMDs7tTZhVm46rLdqAftws4WF+Fn1fmAasgfOX1Jxov9FmrBLEHOG2J8y/BEBg
         WceutKyDQzC6Ihu0+HoqIGuaUJ8KPF/Mge8FWAq+JaQ3of4Gnsi0pwj7EOmPm2/2+6do
         5aC7tKXijpYYnTtDYixi8HxPYfLmeyal4XpC3okh6oNt5h0CtwJ5Es0dNEOqMlGwVz0y
         1lFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BEw+zpwtoGsN8GNgkVXhTtmFpQDYvQ9jV+gpZs/+t9k=;
        b=sgMk1QhpjBDqynsONE+Lpk8Q6+4jq2Dsa5eU1RKvE9gwkouKjlJcij//e97K3CO16w
         n1ifCK75OFan0KCRGL/TGqNDyciwY/Kyb7NW0EyAhoJ9Kfj58afD5x+su+UG14dFXCYW
         8qFgfvHnCSHvDOBkWLvrmu7DsUebCC6P8qPRabIhDt96VKnUXHL+qmci2UtxDcGh/OIp
         x0YumT4k1wyR3ibYeqWmqTaEk3XFI2RGDQU6HZzPcM7Z0xImJ5zKkJbvjXE3FG+iCsgR
         YbEFBy1qZ1JdqIb0Yq3CUXBq/NUeC/6jTMiYoBL6reYv7R+B3OGSgZ0fU/heztLou8Y/
         TRJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6si1813164edd.252.2019.04.10.12.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 12:54:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EC13CAC31;
	Wed, 10 Apr 2019 19:54:47 +0000 (UTC)
Date: Wed, 10 Apr 2019 21:54:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Message-ID: <20190410195443.GL10383@dhcp22.suse.cz>
References: <20190410191321.9527-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410191321.9527-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-04-19 15:13:19, Waiman Long wrote:
> The current control mechanism for memory cgroup v2 lumps all the memory
> together irrespective of the type of memory objects. However, there
> are cases where users may have more concern about one type of memory
> usage than the others.
> 
> We have customer request to limit memory consumption on anonymous memory
> only as they said the feature was available in other OSes like Solaris.

Please be more specific about a usecase.

> To allow finer-grained control of memory, this patchset 2 new control
> knobs for memory controller:
>  - memory.subset.list for specifying the type of memory to be under control.
>  - memory.subset.high for the high limit of memory consumption of that
>    memory type.

Please be more specific about the semantic.

I am really skeptical about this feature to be honest, though.

> For simplicity, the limit is not hierarchical and applies to only tasks
> in the local memory cgroup.

This is a no-go to begin with.

> Waiman Long (2):
>   mm/memcontrol: Finer-grained control for subset of allocated memory
>   mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event
> 
>  Documentation/admin-guide/cgroup-v2.rst |  35 +++++++++
>  include/linux/memcontrol.h              |   8 ++
>  mm/memcontrol.c                         | 100 +++++++++++++++++++++++-
>  3 files changed, 142 insertions(+), 1 deletion(-)
> 
> -- 
> 2.18.1

-- 
Michal Hocko
SUSE Labs

