Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56FBBC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 083F3257C3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:38:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 083F3257C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8072C6B0272; Fri, 31 May 2019 04:38:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790B06B0274; Fri, 31 May 2019 04:38:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67FD56B0276; Fri, 31 May 2019 04:38:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 157926B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:38:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y12so12865695ede.19
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:38:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WV/Bt78Zvh3IqdfHz4dmUPlTd+8NY/6tHhR2h8zWlYk=;
        b=OUmpWoSPeoCjeFCA2MAQ85sG0LN6Y3tgJFpsOsL9/eNibF9uJDOR76KvZO+aMCuqR+
         C6fhfbbKOgch8AIb9v+mtHS2db+kc79HMnn3+gz4PmbXx2fYJ7j3qs1mq0TIUC2Ryz75
         joEYtQO5FUhxknCL7/Yg79+VT6leJIm55y7gE4bWJnxWUrCasIy0M2FsCwOhYzA+U9fE
         82cnOycUOu8EiOHQ3saC6mt7nr9Xex4hUwZI2/vGGO6t1bGysS2J8VB7bG0xOSI/RdWN
         /Do8IvD+ag9wLqnaLn1ND2CRYjS0P+jsGcGSpzG35QQ3669pJ3X4y73GWnYTZDqs5NIG
         ZBbA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVMhJl/JY+PdScFAz7J4S2HOEsGLVMhPi073TCYnBSlAR1f6Kze
	qczaTeLff6sY2aaN2VW54EtTla8qhvJ4MunR+4rUnuMYpVE6ufSPcOY7y9jpGKvVZ2W9I6mqU2x
	DU22st/sJnPGpJnwU4StcpVcCvRDLP3/aIUNRTPff9+KdnJ+GSwH/EwICY5AF7Nw=
X-Received: by 2002:a17:906:2594:: with SMTP id m20mr8069984ejb.217.1559291880651;
        Fri, 31 May 2019 01:38:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuaZfFlMCxRjc1Yne7aPL6SkBsZ4Xl6oLYFZIR8ninjnqV7QpfITP0OwMxpGs0k9H6gqEe
X-Received: by 2002:a17:906:2594:: with SMTP id m20mr8069920ejb.217.1559291879558;
        Fri, 31 May 2019 01:37:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559291879; cv=none;
        d=google.com; s=arc-20160816;
        b=R/AESXRoTAyu8eAEGxOaLmoYVqbwvu+lDLG4iVJYilQ51HPkEqQdcyt0EfI8iIMZAK
         vPSJmCKKoAT8oGwEk9soN1c5M5Ic2X/Lv5M1mYvBL4ghcEajIckJ2qUjE96SVrP6EbSS
         Glw21s30geVwUFeLwZ8yfWoPUu3UIVVL6+T/B9KbPqS0DskwuaBWNWXYD2NLx1oxwzj/
         ac5sva/RGDikMALW5LsOXnbmoNC0hsjMshHVM+bwxKI6M+h+paVc/iM54knpC/Cfceqo
         SqJ06dFoqAUZ7jlw5DQo6YPn6Y/f4p9gtac2yc1G5jnbpmijWMmRoLCpiAFeGHISjxjW
         u8sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WV/Bt78Zvh3IqdfHz4dmUPlTd+8NY/6tHhR2h8zWlYk=;
        b=zyqKyM0hBMbVb5m9DPGgsmDLWbKy5JqKQJw4yVDbP+3/3NNYLlvqB0g7rqDN9Ajl+N
         MLaFIjHeh9pMGLb3cKyXiZhrpn7sbht58nnLggHfSU0xNCLcrzQ32E4o9lVuq1phhxZO
         CP9e29DUj2+WMQKOlGxgKmpKyX34oHnY0XpMZslPIDLcM/t/hu60St6UCtwHE0cHHzro
         knjOrxdCXqzjQbkuDlRgmAvrtn1aojY3fbQjZd4l8dHzSfMNO59e84nmIy/LqOCVbHKv
         Bz2PpW09qKgJi9u1//F9CT9p7er8VXxdGoCdHlKPxEKWmOsmrgjNO2rxRGAq9/DmXuqO
         Lz9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si3823490edy.279.2019.05.31.01.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 01:37:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD507AC2E;
	Fri, 31 May 2019 08:37:58 +0000 (UTC)
Date: Fri, 31 May 2019 10:37:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 5/6] mm: introduce external memory hinting API
Message-ID: <20190531083757.GH6896@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531064313.193437-6-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 15:43:12, Minchan Kim wrote:
> There is some usecase that centralized userspace daemon want to give
> a memory hint like MADV_[COLD|PAGEEOUT] to other process. Android's
> ActivityManagerService is one of them.
> 
> It's similar in spirit to madvise(MADV_WONTNEED), but the information
> required to make the reclaim decision is not known to the app. Instead,
> it is known to the centralized userspace daemon(ActivityManagerService),
> and that daemon must be able to initiate reclaim on its own without
> any app involvement.
> 
> To solve the issue, this patch introduces new syscall process_madvise(2).
> It could give a hint to the exeternal process of pidfd.
> 
>  int process_madvise(int pidfd, void *addr, size_t length, int advise,
> 			unsigned long cookie, unsigned long flag);
> 
> Since it could affect other process's address range, only privileged
> process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> gives it the right to ptrace the process could use it successfully.
> 
> The syscall has a cookie argument to privode atomicity(i.e., detect
> target process's address space change since monitor process has parsed
> the address range of target process so the operaion could fail in case
> of happening race). Although there is no interface to get a cookie
> at this moment, it could be useful to consider it as argument to avoid
> introducing another new syscall in future. It could support *atomicity*
> for disruptive hint(e.g., MADV_DONTNEED|FREE).
> flag argument is reserved for future use if we need to extend the API.

Providing an API that is incomplete will not fly. Really. As this really
begs for much more discussion and it would be good to move on with the
core idea of the pro active memory memory management from userspace
usecase. Could you split out the core change so that we can move on and
leave the external for a later discussion. I believe this would lead to
a smoother integration.
-- 
Michal Hocko
SUSE Labs

