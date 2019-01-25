Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9B2C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 17:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E8CD218D0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 17:37:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E8CD218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 116368E00E0; Fri, 25 Jan 2019 12:37:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C44B8E00DF; Fri, 25 Jan 2019 12:37:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE948E00E0; Fri, 25 Jan 2019 12:37:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 946A28E00DF
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 12:37:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so4045529ede.19
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 09:37:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dDrdJUiF5uEIwGmqijReuoL0Zy23mJNHKqopI9fAgec=;
        b=hxElFY0MUm2nS8HUMaT/HYqQbbfcU6s8FpZqertng3NoiQJmBiIq+d4Q5DGUC5dCfu
         mOqdDtqYP/U6pDH0F3p+grChoAjpi+w7ItgJZ1WtT+WD2IX+cM3owfiv+bdCxdJi0Bap
         Mzju/IqkrgukjqrW+JwoqD0uMOgfwntuh667ROC+DhLErmPJRg7OV0/aq5S0TQf31MVm
         IyL2Dkm63eYNMx8rR9dqFFv+BIINredpLJY0Xrn3d1Wk3kmhN91Vm34xqUmWHG5cdqMj
         8Lc33MqnYcqXz0VgpSd51Tm9yAOFQWMbfyp9+adpvfZ2aaakGyMMi86QspLMI/38SqAa
         dNLA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdwcer+ArjtoL6rKyzGCUvs+puBoz97s8jA9hNVk3U3sMQUGjir
	an33xU/D/u579dm4imdg4FdW8e1uO08j9PL6eyrbo3joAZzI+T57R2CyHOpOh+JLAshwbQj5OPk
	bi/hSjne5mpRHYhlaDESz57gQ37ci9O07A+RLf4FcMnykXE7gGC2qxV4JuKrqkn0=
X-Received: by 2002:a17:906:5e43:: with SMTP id b3mr10553050eju.200.1548437836160;
        Fri, 25 Jan 2019 09:37:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6CbJqadNHMO4kwcffF6tw15BXMnFt041cfxJu8GptwX1VqNEvggClrSKtilgEEhja/8PDD
X-Received: by 2002:a17:906:5e43:: with SMTP id b3mr10553011eju.200.1548437835297;
        Fri, 25 Jan 2019 09:37:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548437835; cv=none;
        d=google.com; s=arc-20160816;
        b=NWi8+Ij7/pzIh+F4oIYdUQrMdJIUNbY007/2d7i6uwhN03Bth/ygiWrjdo77jducBO
         L4ThYT8cOyHBFhfJY31ddC2LS5MfAsqE6eITpHPgqBX0Mjl3M+ZCWIJbGNi/J788Z6CR
         lGvE/4K7hbrIJoYLXiCpfAr9Wi1e87XFv4YxKTH74sJIMGYXhQK7/W4tVPwgxf4/z+JH
         f/4GoSVPc7yU4qHkOduy7erGBggwjxjCeuVnFVFCT2cK2oe1xPS7ZgptSVecz+kwzvV2
         tnHCDpWK4AqW0iIuczWnbF55Ke+PXwwKf+yn8kxuEyh6550OWahpp0frQqqYsCeGDLE8
         wqEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dDrdJUiF5uEIwGmqijReuoL0Zy23mJNHKqopI9fAgec=;
        b=DB4qz4h0eInPnUlb2h4nElBS8hUP8GbiaalJXPND3he6Wpm4P8myOesH9Fb1ild6hG
         wgw0HJVQk0+lNFhEe2o6ydmlopdKU12e3VeJV/8T0GrXYNnDh2DLuiMgVFVyvvk6xZZw
         tfSQyT8KngsYRGJJ4B6AI6mZy5k3ZleD6nezppD3PD9K6JFSg1QyX1KmJkAYnYLJNdm9
         K0hwlJA35f4Xsm8LbuXNFPhvnUjj8bWqfG5vWayAQIZ3TNagzZHARPhjg2ASRJy3q20t
         4q0X3p7nmVGvGr9D1DB64K1xP97+7XL0DV+hP4gGuP+DYeiVmj2Gh4UYH5wGLDEzc6wn
         2aZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x52si423200edx.285.2019.01.25.09.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 09:37:15 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C5F19ABCB;
	Fri, 25 Jan 2019 17:37:14 +0000 (UTC)
Date: Fri, 25 Jan 2019 18:37:13 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190125173713.GD20411@dhcp22.suse.cz>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20190125165152.GK50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125173713.1e8k7eeksgX0IiMFYvW81pcSWrSM5nZcUaGhlzA_ybQ@z>

On Fri 25-01-19 08:51:52, Tejun Heo wrote:
[...]
> > I do see your point about consistency. But it is also important to
> > consider the usability of this interface. As already mentioned, catching
> > an oom event at a level where the oom doesn't happen and having hard
> > time to identify that place without races is a not a straightforward API
> > to use. So it might be really the case that the api is actually usable
> > for its purpose.
> 
> What if a user wants to monitor any ooms in the subtree tho, which is
> a valid use case?

How is that information useful without know which memcg the oom applies
to?

> If local event monitoring is useful and it can be,
> let's add separate events which are clearly identifiable to be local.
> Right now, it's confusing like hell.

From a backward compatible POV it should be a new interface added.
Please note that I understand that this might be confusing with the rest
of the cgroup APIs but considering that this is the first time somebody
is actually complaining and the interface is "production ready" for more
than three years I am not really sure the situation is all that bad.
-- 
Michal Hocko
SUSE Labs

