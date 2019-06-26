Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED0AEC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7B6920663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:15:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7B6920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E79F8E0003; Wed, 26 Jun 2019 08:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397A78E0002; Wed, 26 Jun 2019 08:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ADB78E0003; Wed, 26 Jun 2019 08:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E97B58E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:15:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so2954250eds.14
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8GA34TnliigvzzmigKheCVA78yj6cP/myZ6XZIL8i5o=;
        b=P3F22Lo63Ghu/fQv0bsp8JVfAvnyZEV3y/UKt79IxZNOtbvZKKrxAK79Cw9qywA3Bl
         QzF7YvMEIW6KIu2yi/XxZ8MrzHLv6t3qk1a7eXmrMRY+jOLsdny6/qsQVrmZMjpAMc5f
         LYfckjQEpzXk9nf9Y4nITjeOLBBb6IgH+xuEZkoOXeiPd9gfJ9CNiNo6yqm5cUQ0M717
         UzrlFQqI9B+dhzy0hS5KnLBx42Win6/lTb9FEILnPPkcjUFQnTXhVdZAO+xkvsDECSor
         aGQbDQHlOkcibOt4+EzwrRJWuBOfePJ2Zgi2oOYrrrWPoN7wOwRDvhdiVCuB8CqnSzmY
         Pw3A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUi5CiPF3RM39zkf6N08SyTsa0ve9ddGKavppNlxtmb2Q6BLO0h
	gAV8pCRO9Z3FU6XUbd2cDR+sRtvChmPYvayT7jyglK0fY3wOvNPhr5L7FL6dTcYt4pMWPfzZO4C
	UKX5y6Yv6NnbwpSaHdtxXZPWqmpUjZ/IbE9sMPo/vwYE2xfVDnH5deYqms/I6OXU=
X-Received: by 2002:a50:b104:: with SMTP id k4mr4746242edd.75.1561551321546;
        Wed, 26 Jun 2019 05:15:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6mcipH9SzPUt2xTSRJRbq5yORAjiqguCEpcNWnIQkKmr+W+RxvCNwSuzRYulI8C+Dn/NX
X-Received: by 2002:a50:b104:: with SMTP id k4mr4746159edd.75.1561551320792;
        Wed, 26 Jun 2019 05:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551320; cv=none;
        d=google.com; s=arc-20160816;
        b=Rsy7PE8W/q9UL+w8WTBbAjz4kS8c8UwD6GyGbr4LvIaF0VeuwL2tmmlH9aMi+KFpJi
         B4ekHYz4X2eb4eQEOeZDWWNmEwulCDr+eNqfNNtA/QeK3X1/osyQubtj3KRsOfGINam4
         UGm/Ufz/8jEYFikCEC55GijNi8uYUiFbOlI2uVTIHOwASkbiXXkgixtKGQd9jvFEnOYG
         K0nxi9CGUo0r2ItHm+Mco1TAVzEPkm1NDwXeVgd3iKLG6cKLpHs2rMrfpZyf8vtmfvZX
         sP7+CkSq0UaDapM/ynQNthq2r8Y8NMC0DbIzSlmxt+y9ZSY179wY3QTjSnhmGiZoBv66
         fftw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8GA34TnliigvzzmigKheCVA78yj6cP/myZ6XZIL8i5o=;
        b=bxT6ofMEbtV1YksHnt1PdiH+OPGYW3VJ+GCcNrWUAZYql72e1r3iPiZ0KGj5IUxiRI
         6aiEhFw2e+GOQ66UKEd4OhBuk7T10a+bjcUBTOb6+uUbNDBh1CYpUCJcL9fq3PM/WMZE
         10Uia8qkUO8PN3S/xgF4/qxe/1yDnaWVBP0XVUs1ip/Ht5K54Slxsp+8aIWURZ8/jaxg
         T8qmu9UZc/7c9YRXhzqgnqnRL/EBwvpUQPS/BP1b8X4Rwk6X8MM4YeDY+i27LY9wF9iC
         ae7nUDWN9sRTmAu+E8fPIEFXjdlUvStM2+/HJvAj3PVAU8uKCIzc7mBDDR2lnc+u1fK+
         qzXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a56si3260995edc.379.2019.06.26.05.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 05:15:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EDABDAF3A;
	Wed, 26 Jun 2019 12:15:19 +0000 (UTC)
Date: Wed, 26 Jun 2019 14:15:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Message-ID: <20190626121519.GS17798@dhcp22.suse.cz>
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
 <20190626065118.GJ17798@dhcp22.suse.cz>
 <a94acd91-2bae-0634-b8a4-d5c8674b54f2@i-love.sakura.ne.jp>
 <20190626104737.GQ17798@dhcp22.suse.cz>
 <3ec3304f-7d3f-cb08-5635-12c6b9c0905c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ec3304f-7d3f-cb08-5635-12c6b9c0905c@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 20:46:02, Tetsuo Handa wrote:
> On 2019/06/26 19:47, Michal Hocko wrote:
> > On Wed 26-06-19 19:19:20, Tetsuo Handa wrote:
> >> Is "mempolicy_nodemask_intersects(tsk) returning true when tsk already
> >> passed mpol_put_task_policy(tsk) in do_exit()" what we want?
> >>
> >> If tsk is an already exit()ed thread group leader, that thread group is
> >> needlessly selected by the OOM killer because mpol_put_task_policy()
> >> returns true?
> > 
> > I am sorry but I do not really see how this is related to this
> > particular patch. Are you suggesting that has_intersects_mems_allowed is
> > racy? More racy now?
> 
> I'm suspecting the correctness of has_intersects_mems_allowed().

THen this deserves an own email thread. Thanks!
-- 
Michal Hocko
SUSE Labs

