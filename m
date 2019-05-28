Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 673C9C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:01:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 394852075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:01:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 394852075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35956B0270; Tue, 28 May 2019 03:01:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABDD36B0273; Tue, 28 May 2019 03:01:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AD6F6B0275; Tue, 28 May 2019 03:01:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD026B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:01:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l3so31619750edl.10
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:01:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VsEZeZyKJD21zOgPBT85SNgxNMfsFhTiXEtr/1+69eI=;
        b=MU6ukqczGtHTqYi6kLAumPxmAlNchsGyXGikuUXDHwicsOR70ZXt3bXG4sSmmHXfiP
         qrDBBM5PLC0T83bVYgpmvvBNojNn68VKccjbReMqhento5oyFXkPUASyUoaCXXeRVSGz
         qQUpIvJPLbyNWF341sb91Tkmr/aFbU48heU6gaScujvkRWGVW1x8sVw986yskpW6nfuA
         ZzlaA45OzrIkVhQVt8geLX3oTcRj5J+PTGTK4GUrPkrqpazVlRfQ7FZccX7cz3U19s2I
         u0Lv1cNBoolML/Pp+zcN/WVivWJ+mASbojRHZOXuOR87yfXYz2jkAXBpQG1/Bb4aZxMr
         8rzg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUc0MNHS6IARk6elF5RjIfYDb77UoauD78x0UVgTX1G7Fia4A20
	AELc1ZgWSM1/uWltahhYYDIs7MsC6k7jMIObH8VdLiRXD0WrYk3XLaQPlyeZM3/+mxrFjq3SsQk
	aHg3aNGulIrr5Y9NubyvsFXTwVg1JOVsnaB1hGv73biWdOmDLI4ycA0eT3Op9H78=
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr126331749edt.276.1559026893873;
        Tue, 28 May 2019 00:01:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzY+bmShZUxxdEeQBN6jzN1wqSUdZS+/WMsiTb+wzdmTqVS0jYbx/4JJHkCBF1cfe197+S
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr126331647edt.276.1559026892958;
        Tue, 28 May 2019 00:01:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026892; cv=none;
        d=google.com; s=arc-20160816;
        b=tl3RoHPa5kuYSqFYIfXvG1v2u9sV77aUQP4ZOTx5MS4P4yFY4Z0INwU+kyAkK5Q9Yf
         fyIQ1Rx8BPDWCG5wG8jP6NfuIPNFznSSf8HW0qSP4zo3GmBZwp7yJgWJwgtVsm7E64KF
         uM0LmkTIZysAC4yAzmC6qj0jRuAfvH2VWS4wRTDQaDGuv1o3bd4y8a9d8I8S2V35v3Yl
         +FZbNPglf5edAZAYEfxuyfiztN5SM/B6OkHNR+nge26or+WESd5QdHzmMHJPXmD5oLD/
         1dF2WtuB9Z17eNrQN18ZHFYCGH0v+2QhodsojvywfrViecwWGC5BoCL7/FOhSF/lp7dl
         MWKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VsEZeZyKJD21zOgPBT85SNgxNMfsFhTiXEtr/1+69eI=;
        b=G0/viQ8GhVRmEVGvfJrXt2zqy2+/XZcHKsGxzpV7JqYrbm/wwf1RofAmvBewNIanO1
         rvtWbSYNvf0t8sHzaEDnRzY+tcFsDjWzbR6agxj1QIrZZPPAFXoURe2vMjFXrKSGjpEx
         4Pajgv0ylJTGO9/DQTTsiFH9d5lY3yfGOS68NQb8moj8Gm5XK5t2TkSXR2jwf0rPNHxO
         F2v4Nx2ZlBcYnL7wG/dg7tW1KQn7VQ4nRjqakX+iQacG6L4AKqolU3RHzezOWhAKDvlZ
         pxSnT5KA+1i0RrKGyLvTaqT7a1MqV17apMgCUUw41XgDNcy2BNG78xPQwdJrbfxrGbqW
         iEIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq8si1124165ejb.236.2019.05.28.00.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 00:01:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ACA3EAD7E;
	Tue, 28 May 2019 07:01:31 +0000 (UTC)
Date: Tue, 28 May 2019 09:01:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Rik van Riel <riel@surriel.com>, Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 0/7] mm: reparent slab memory on cgroup removal
Message-ID: <20190528070128.GM1658@dhcp22.suse.cz>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190522214347.GA10082@tower.DHCP.thefacebook.com>
 <20190522145906.60c9e70ac0ed7ee3918a124c@linux-foundation.org>
 <20190522222254.GA5700@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522222254.GA5700@castle>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 22-05-19 22:23:01, Roman Gushchin wrote:
> On Wed, May 22, 2019 at 02:59:06PM -0700, Andrew Morton wrote:
> > On Wed, 22 May 2019 21:43:54 +0000 Roman Gushchin <guro@fb.com> wrote:
> > 
> > > Is this patchset good to go? Or do you have any remaining concerns?
> > > 
> > > It has been carefully reviewed by Shakeel; and also Christoph and Waiman
> > > gave some attention to it.
> > > 
> > > Since commit 172b06c32b94 ("mm: slowly shrink slabs with a relatively")
> > > has been reverted, the memcg "leak" problem is open again, and I've heard
> > > from several independent people and companies that it's a real problem
> > > for them. So it will be nice to close it asap.
> > > 
> > > I suspect that the fix is too heavy for stable, unfortunately.
> > > 
> > > Please, let me know if you have any issues that preventing you
> > > from pulling it into the tree.
> > 
> > I looked, and put it on ice for a while, hoping to hear from
> > mhocko/hannes.  Did they look at the earlier versions?
> 
> Johannes has definitely looked at one of early versions of the patchset,
> and one of the outcomes was his own patchset about pushing memcg stats
> up by the tree, which eliminated the need to deal with memcg stats
> on kmem_cache reparenting.
> 
> The problem and the proposed solution have been discussed on latest LSFMM,
> and I didn't hear any opposition. So I assume that Michal is at least
> not against the idea in general. A careful code review is always welcome,
> of course.

I didn't get to review this properly (ETOOBUSY). This is a tricky area
so a careful review is definitely due. I would really appreciate if
Vladimir could have a look. I understand he is busy with other stuff but
a highlevel review from him would be really helpful.
-- 
Michal Hocko
SUSE Labs

