Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95F81C433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 21:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5167C2070B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 21:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="jrIqJ7ge"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5167C2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E58848E0003; Sun, 28 Jul 2019 17:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E096A8E0002; Sun, 28 Jul 2019 17:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF7878E0003; Sun, 28 Jul 2019 17:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3A3D8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 17:39:14 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o11so44691797qtq.10
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 14:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YH3/wT+cTox718QKlVPN3VNrRnEKlV12MOV4OX51RgA=;
        b=BW+nhBvtxiVocS7SbfU9ffFpA6db2tav2P+3RIjnytWDvosg8+c1f+rWBEdI9hRkf+
         z2WF4qLXdo23solJlhhoz44uFv10InQvas/43zWuEqflafEfn8YCXEBK/upEp8SshQ/R
         rR2GLeYroU7uiLvWMNyB7FBa/pmqnIfAHtX+wXbR7+7CQJim4btp9pAM0jVv69VbgzgP
         9P6w9OqaKrzurs0VcXB0LqZwc5XqBVr1U6MuPaCHDulN+xjLQ8XK+95kxWwqyXnX4hO/
         3PnwRnW6csO6tZVOwNn3LM131z93AMzDiSRZWQOk5FOrRh2jXUQN0DAycyhNgVR2IK5j
         GXgQ==
X-Gm-Message-State: APjAAAXCE8b1hkus/CVFM8ZrY95Q52OARhV2umBP/gfPqXxU493vidP0
	k0DuYy2jgix+ygpE8KNRuje41NK7QnqxZ/aEeKEjJMkuwNCayPiyM5zg1ioRyaEjvCuFMuwYNOQ
	0UK6tSXC3VuPDwSopixEzdLtcN4sTWbduCnfwQmV7JgA/disgbNi/INcGGdTMGmgSEA==
X-Received: by 2002:a37:9ec8:: with SMTP id h191mr75407382qke.229.1564349954429;
        Sun, 28 Jul 2019 14:39:14 -0700 (PDT)
X-Received: by 2002:a37:9ec8:: with SMTP id h191mr75407358qke.229.1564349953848;
        Sun, 28 Jul 2019 14:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564349953; cv=none;
        d=google.com; s=arc-20160816;
        b=ujNA3+NHOIkP4vNaixvrrDBkXzLNd9iXdc6qv0C2DfYNGVzwils4Ip5SLHiwUIY5qm
         WRCgaDq8PqEfRWFgHmsudoC8VRZYmtPuYkXnI+O/JTYbA5MfhNO6Yv4MG6aoeL85R5Zd
         9Zx53XVpCbzBD4BBPtGu2EJBz+1ZDcH17jZP4+8B/jrDh+5LZZogYuLw94RUp9gCS6jB
         vWjlzRnd9yq0Btgz2VKAceoqIXg97Txb0c5FA9jjGsV5FTgpIZByUVCFLT2liCGyhZRZ
         ZwY0VKwHXm5i30ySyPENRbZ7ihE0oFpqJhT8yYyUERPkzAoJ+o2wkoMfGhw+OO/GoQv1
         6Yng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YH3/wT+cTox718QKlVPN3VNrRnEKlV12MOV4OX51RgA=;
        b=ucKvuVW/GBUlxC21T/F9mMAtdSCnx7cBIOwhWnLv7VxzaJx4ziFpbfAvENpB9JBpLS
         InNhJyr/tMCFOX1BYbgvd92Ebw+d9yxjZkHBrvyVDu1RApBKuwA0uBbQqr3NHGHMBAIT
         +CRGaBVVBGQjlZEy9pfdGEbQm9BTymvthVSmxTzGbJOg4Tg4L9k6BjHuEPN+E2TIyc2f
         PHKL0ZQNtkcU+uUYO0xh1WS8WXyTPfXMBaOLFjCEMuCjwndIqbRvmx+WuNS/4jzTbob0
         dTp4uxwRp98EPjiE3KxggjO2mkb6ejZ1Mcb4A3Ntmutqex9KAeT6wpMD4O6lZe0ffdvT
         8JtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=jrIqJ7ge;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 5sor50631190qvy.52.2019.07.28.14.39.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Jul 2019 14:39:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=jrIqJ7ge;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YH3/wT+cTox718QKlVPN3VNrRnEKlV12MOV4OX51RgA=;
        b=jrIqJ7geMyt3Nn8m5sFlBvbgaeBpqJVm/l/SZW/WXi7dKuP4muj9HCQXHz0jTivXkC
         I1/Qhwlgs8XqOOPoGoydOnL+OEe3jLrq2tRARU7Ff0lqKM5TpSfaDVH4caKeObGi+8vy
         MefyjADc2LUvA7Oz+bpIXhocppf1jILL63CX0=
X-Google-Smtp-Source: APXvYqyVT2VgEEMPpkMQCCj5rnFGVpkZLpAQ3yGYm3a86qXec/2goBgdvj52z3louGSZGggDKZwKrQ==
X-Received: by 2002:a0c:e5c6:: with SMTP id u6mr58990963qvm.102.1564349953210;
        Sun, 28 Jul 2019 14:39:13 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::53b0])
        by smtp.gmail.com with ESMTPSA id t29sm23521011qtt.42.2019.07.28.14.39.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 28 Jul 2019 14:39:12 -0700 (PDT)
Date: Sun, 28 Jul 2019 22:39:10 +0100
From: Chris Down <chris@chrisdown.name>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
	Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
	p.kramme@profihost.ag
Subject: Re: No memory reclaim while reaching MemoryHigh
Message-ID: <20190728213910.GA138427@chrisdown.name>
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
 <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
 <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stefan,

Stefan Priebe - Profihost AG writes:
>anon 8113229824

You mention this problem happens if you set memory.high to 6.5G, however in 
steady state your application is 8G. What makes you think it (both its RSS and 
other shared resources like the page cache and other shared resources) can 
compress to 6.5G without memory thrashing?

I expect you're just setting memory.high so low that we end up having to 
constantly thrash the disk due to reclaim, from the evidence you presented.

