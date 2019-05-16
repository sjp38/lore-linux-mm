Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C6EC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:21:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FA3821473
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:21:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FA3821473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34E646B0005; Thu, 16 May 2019 10:21:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FEA26B0006; Thu, 16 May 2019 10:21:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EEC66B0007; Thu, 16 May 2019 10:21:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C454B6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 10:21:45 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id a20so1080647wme.9
        for <linux-mm@kvack.org>; Thu, 16 May 2019 07:21:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3pBYZyFUkM5nWJomyVpE/m2x1DxoC1ycwj8/edxQgVk=;
        b=A76izdSILhsK/QdmqdKFBFIzWBINNslElFyTVjYwCK6u394ew5uP0DIeF559OhaEMu
         DSy9ZT8VebUKFxuFjXaWkSZF7o1CUJuSqO0kmEX54/qZxnlv8Znx+xvPHC0YJYnmAoRt
         6HcK5IviFmRLixAlMk4QpI5QeWoL8iKU4sfNP9bGdgPl5Lo6fiT3QeuLOEbN5H/a/52q
         JPAb9RJQQ78fDhelmIsEKzfFrp7D48jufqNFZbByiU/cOEkLDXtLttauZN2LEXweEoCh
         A1MfmW2Z0MlxajyUbb/msgSeeFUKAe4gZxymfV3HoJAVcR0OInjLuUQ0CIOOXK4oyl71
         ypNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXR5DGLkbgCppl/ZTBPfMP0SX+owOrgfqFZA9ANtSgpSupPAVyw
	ghLk6Y6Po2L7ZOrvhFKvRdT1+o+hlWFruJJiBFdRtWnTb+/LyG4XHeHjczC68J8yBBNmEdyttFx
	9mW5nxNr5D87XL6BfzCkQn61ki2LZGaUaytk5om6STLzzsn3Fsm+wP3s4BA0tGdaChg==
X-Received: by 2002:a5d:4988:: with SMTP id r8mr19675112wrq.57.1558016505262;
        Thu, 16 May 2019 07:21:45 -0700 (PDT)
X-Received: by 2002:a5d:4988:: with SMTP id r8mr19675053wrq.57.1558016504599;
        Thu, 16 May 2019 07:21:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558016504; cv=none;
        d=google.com; s=arc-20160816;
        b=DS12W32bnh2tADzkgTjUshlKvOpRdjZIuLcPkuT58lHvAqHvhikUE+t1jYLJLDJIFq
         xZBTgMCqf2UEMGBlW1xZFilKHuv/ySdlL7O4t5J0veMTiPqx2VAoj0G4MmiaoJmwJs0V
         BCXyOJJqKZTR72oxLSHjVkl8/754QLXm99TM43GIh2NJKnBm44HOheQwWRJYM6ZQpaVI
         XpMGJZG2XxZMOqIvtWr8J3m3OiimqQUlEBLQ25dsBq3UYqeXGcjS3U4lrokHena48R89
         t9Z5kh/hmDmSm+rPXq5qG5qwyXRWZJvPkh5K4g+8LGSgrsSw1+3aTRwbbG5OQelM7Rk9
         gZDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3pBYZyFUkM5nWJomyVpE/m2x1DxoC1ycwj8/edxQgVk=;
        b=JXPFNrShWIFnmKjvM1cIj+/UyFS0w+HbFQKL7GfTYv/5TFB0MG+RZ+IBSgXPVEmabQ
         1uqw+7E1iDREvJx2qw1XQvSim/75xUWLC3qJgwUig1Mle0aykqOl9BU2tUby+9jRGtWK
         d13EKkbjf/+rliFZ1GreHQ/8fv0MZ8s9iiyJYvkqz1s/4rrK7Wg+ZflqCZGQRgM7gHyc
         87/ZlJoevjqFxQA2ETMLiEnUJdA8B5gQqC0GH4tPSbHPdxNyU2jiQrri+0CxdRTWfxII
         XfP1OIfedai4D9L05fPmHmlM9p4yg9k/owTU1fjrcHI5SVfuIlHrcvczuEjtECt07k2M
         hGGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f76sor3413931wme.13.2019.05.16.07.21.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 07:21:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxXwoK109kD/ez3T5lP/j8A8AQ1AFMnns5SxEo7Ap1IuaYOUMPIMyPdhIllQencoKBO77rrOw==
X-Received: by 2002:a1c:2245:: with SMTP id i66mr12110548wmi.19.1558016504222;
        Thu, 16 May 2019 07:21:44 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id j82sm7364200wmj.40.2019.05.16.07.21.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 07:21:43 -0700 (PDT)
Date: Thu, 16 May 2019 16:21:42 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm/ksm, proc: introduce remote madvise
Message-ID: <20190516142142.qti3zfevuf67dedn@butterfly.localdomain>
References: <20190516094234.9116-1-oleksandr@redhat.com>
 <20190516104412.GN16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516104412.GN16651@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Thu, May 16, 2019 at 12:44:12PM +0200, Michal Hocko wrote:
> On Thu 16-05-19 11:42:29, Oleksandr Natalenko wrote:
> [...]
> > * to mark all the eligible VMAs as mergeable, use:
> > 
> >    # echo merge > /proc/<pid>/madvise
> > 
> > * to unmerge all the VMAs, use:
> > 
> >    # echo unmerge > /proc/<pid>/madvise
> 
> Please do not open a new thread until a previous one reaches some
> conclusion. I have outlined some ways to go forward in
> http://lkml.kernel.org/r/20190515145151.GG16651@dhcp22.suse.cz.
> I haven't heard any feedback on that, yet you open a 3rd way in a
> different thread. This will not help to move on with the discussion.
> 
> Please follow up on that thread.

Sure, I will follow the thread once and if there are responses. Consider
this one to be an intermediate summary of current suggestions and also
an indication that it is better to have the code early for public eyes.

Thank you.

> -- 
> Michal Hocko
> SUSE Labs

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

