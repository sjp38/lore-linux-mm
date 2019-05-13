Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B82DC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:51:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F0462085A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:51:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F0462085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 495C06B0006; Mon, 13 May 2019 04:51:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 445EB6B000C; Mon, 13 May 2019 04:51:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30E506B000E; Mon, 13 May 2019 04:51:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D50046B0006
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:51:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so16911712eda.11
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:51:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HedTAL7Jg7MJfkG2nL5FzwXD9+7+XcTxbbIDEQ2YCWM=;
        b=LAu1/SGTjxehvw6HvgvHaWfOH0rwayLamW6ccQVwd/B1FuHIeKh+HaHdXfY6ba+nax
         pEkNfVVMr9bQiwW8v5nr05EKB/NS/fBKecx7f3lWyGziwtf8yGeEmpBU13/gc3symCrv
         1ZVfgmhlyvLu6AjMo/vhv7E8Ib7vx5pULt82C4iTsxrS5K5+1SjPPSamWAiPshMz2X62
         SX/0tL4KnarCqMDeb2PEkjd8t1/GKWi9IaBfrNqlTOflakEYjAm279rwuDhvrK9xukck
         rI1IemvPp0dIJsjuR305vTe0QaOeMOuR0OUqa9KH4qjBVGsdCfZX5/iE9HqinRt8YkW0
         RRYw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVtLIj1ayJ38oT9lGw821Eudk51nlSUnh+Ul7z0kbxG4/JqBJiG
	n7d21TsQlQPvMKmBlvuwIFJsEkgBhLBSvuqauWiMywDp7DDJt+mHPTzw/YBwi1aDM9VReD0kHlj
	+etA2GtX6STBr+/8+nUAKkILPAUt+t27YmKytyHkdUYunhRElAoPF89E7rfS/Da8=
X-Received: by 2002:a50:9765:: with SMTP id d34mr28153634edb.195.1557737476444;
        Mon, 13 May 2019 01:51:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3hJlsVfDc48u/VNIipTdkG82L5DQjMdt4WpFy9j2veYbViuXjgV+1w+jzz/oDBqe8XEWU
X-Received: by 2002:a50:9765:: with SMTP id d34mr28153578edb.195.1557737475712;
        Mon, 13 May 2019 01:51:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557737475; cv=none;
        d=google.com; s=arc-20160816;
        b=cvEhvT2k3LK4n0vK686oQ4MQOSpMCJyGUYX+8DyXXUO7fPNT26bVQOq27fnIDGG80X
         1QXmqQCPAl4v8wapmV9+sIVpkiLiBBocpdJnRcrWUeAHy0tU9IHr7BtRUUyv+xlfMwgn
         x/UnnrOBA3mLE1S5ND2It790ny25dyyjhkU3YNfoOsx7FPEYtcPQuRLI01GbfQXSTKMA
         s04xUFuiKs1UNahEMZaoP+3ZZF+A/v0XsIg3W5zacvOYuqrHF5YPPCE7UBuMtO8KeAUi
         jLuejuR9lincsgQQgYuZ0dt7SdN7wy5vHrxf73uRKuy8LEFEuMR4LTr9fHkRhhWvjoMQ
         OB8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HedTAL7Jg7MJfkG2nL5FzwXD9+7+XcTxbbIDEQ2YCWM=;
        b=i2u7Iqi2t2pCe6DltCMtXA+fZdMrXFw/HzX9LQ+GmEkw61Yw0buZott9PmK2BW+v7l
         pzVQhNuwE0fNnNdoE9FyKEfLjWZuC4mDhBsPpO6nsrdfTO9VesOPT/+wo3bvyRhXnUWn
         ZyIkqQ5Bd/CosBF222AglZ8f6HUboMssn0eH9IaKw/4VOZtFVX09bDCELoNZtDrnDJ6g
         rQlWW3PD3UzxBnS155Eei20JnyMocbNWGqwJoaPlP2SbWHbO+6TzExSTNECixmAdNgH1
         FlLdcSCghzo+G2oDfxEO/zgIUBosqs1nu1rxwFb41L+CNS09/vTDV4NLv2KEzHT/wwM5
         xkiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh16si497337ejb.161.2019.05.13.01.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 01:51:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 12230AECD;
	Mon, 13 May 2019 08:51:15 +0000 (UTC)
Date: Mon, 13 May 2019 10:51:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>,
	Amir Goldstein <amir73il@gmail.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [RESEND PATCH v2 2/2] memcg, fsnotify: no oom-kill for remote
 memcg charging
Message-ID: <20190513085114.GD24036@dhcp22.suse.cz>
References: <20190512160927.80042-1-shakeelb@google.com>
 <20190512160927.80042-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190512160927.80042-2-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 12-05-19 09:09:27, Shakeel Butt wrote:
[...]
> diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
> index 6b9c27548997..f78fd4c8f12d 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
> @@ -288,10 +288,13 @@ struct fanotify_event *fanotify_alloc_event(struct fsnotify_group *group,
>  	/*
>  	 * For queues with unlimited length lost events are not expected and
>  	 * can possibly have security implications. Avoid losing events when
> -	 * memory is short.
> +	 * memory is short. Also make sure to not trigger OOM killer in the
> +	 * target memcg for the limited size queues.
>  	 */
>  	if (group->max_events == UINT_MAX)
>  		gfp |= __GFP_NOFAIL;
> +	else
> +		gfp |= __GFP_RETRY_MAYFAIL;
>  
>  	/* Whoever is interested in the event, pays for the allocation. */
>  	memalloc_use_memcg(group->memcg);
> diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> index ff30abd6a49b..17c08daa1ba7 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -99,9 +99,12 @@ int inotify_handle_event(struct fsnotify_group *group,
>  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
>  			      fsn_mark);
>  
> -	/* Whoever is interested in the event, pays for the allocation. */
> +	/*
> +	 * Whoever is interested in the event, pays for the allocation. However
> +	 * do not trigger the OOM killer in the target memcg.

Both comments would be much more helpful if they mentioned _why_ we do
not want to trigger the OOM iller.

> +	 */
>  	memalloc_use_memcg(group->memcg);
> -	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT);
> +	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT | __GFP_RETRY_MAYFAIL);
>  	memalloc_unuse_memcg();
>  
>  	if (unlikely(!event)) {
-- 
Michal Hocko
SUSE Labs

