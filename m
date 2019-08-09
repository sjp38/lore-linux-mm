Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90C82C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 06:40:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 352C720C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 06:40:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 352C720C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962996B0005; Fri,  9 Aug 2019 02:40:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913656B0006; Fri,  9 Aug 2019 02:40:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 801CB6B0007; Fri,  9 Aug 2019 02:40:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3157C6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 02:40:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k37so2942543eda.7
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 23:40:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fnPtn6B8s96HblkvsHqtryue2rYvQNk3t1Ptk1YJ7A4=;
        b=Xho0kkrNoV0voKY3P1xEHtR8wMe7mGBjYoMBFwUj3OuAEA7DjXkAYqBrMHnT47nF/H
         OhLIBWlZtY2QP8rnkUxrAOOLa6PVqOzRhlasD6Dlm/Aii8MaUms8hwC6wRKlyYw/MkSO
         ABMiILxu9aKvHft04JNadyoIGYs109sOkvJzd/Ws4ecLsbN/uNORa1Jq7dnktdtfWwdp
         ZW7bgM60Rb9YxGh05n6syoCPqp1DrLeHf2ZQNP/WWs5OcuqOGQYxoayYAEVN4xZ/demT
         1XV42dW0darAv746qbkwh2popMvyoN12AUlZwW37gLIToFva0t+eK1i1Pt2WRESRqJZS
         d6eA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWS7jg8Hjt+gII8ZuovVrNRyW6LCcG8EjztRHzETcLytno4IVpK
	Eda0TiFOWtDm7m2eRdBqC+HeFqy07x9KaL7ztEhZMay0+v0r+fwhm8YJzw38ssCIEqKyXLPPdgB
	efy/jWpqQb+hQWEn9rfmkgGjd4znmR0hEzCeDI4XSybd9g13y1DNJTtTCh4wXHZM=
X-Received: by 2002:aa7:d6d3:: with SMTP id x19mr19940072edr.119.1565332835758;
        Thu, 08 Aug 2019 23:40:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCH2Y3IjbrVsXVftEthmoQJ8JtDiUNjW6QxNEN1ZXTcgCkTJExzd5bdPea6PRR79jNrSyS
X-Received: by 2002:aa7:d6d3:: with SMTP id x19mr19940024edr.119.1565332834994;
        Thu, 08 Aug 2019 23:40:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565332834; cv=none;
        d=google.com; s=arc-20160816;
        b=U6FtLc03PExru75W1W7Vef1zpdZYITsC+mMtrL3hn4PgCYz7gMT/d13wWNhOBQHUOs
         SfOhqKMjvTMgl+znd3pxFuc+XM2tYxmLp7uxGnZ6er95cCGMBJTqXLO6DBtUjtCIfsus
         vG7jyuYGlhTkdhh7cnMfQh70rUSxMWHNHgSQ+9/xG3LgbIpRrD4499ZCylqPwOPs6RCj
         jQN0x5i34u9Jf6CIGMJmPZmdn4kglbK7GjKFFdoWUdcjI+GrCgDBzV2Zmo8dpkCkGLiF
         N+gavsldfcr2CKh7Z26iQIBCNXA3il8y/qStc4PS98U023ucsjwYfYUfZCF7ZE6aS8w5
         Sd2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fnPtn6B8s96HblkvsHqtryue2rYvQNk3t1Ptk1YJ7A4=;
        b=WheTML1uW3ARM4tpRFg+S7yz7euJEykl9+lNJ56urVCcpAciDbw/5DkTYHSR8OFHxO
         qIevyR1xujxZ7MCc7Z6ieq77SsA2vOhODC+N1oBiFHqA16ouA9hnELSmpbVlT2Cy0aaf
         uM3Aqf4zT2qtaFjtKRcEapPZQks3q3jqSyC0lcs2KHdRG4i9/v4HSxIJVEF56NbVfTX9
         7G4gR0LcdCFPtHlfpNUXs2jI38XGIlKa7j87HRy1rdAB4ZP8xw9xmEBiruX4Wgaw89a3
         qu/cC0Fqkg56nbc7YuxcXRwYS8rzjvlMWwXM+Afc70IsfcI3WoRDsHIrWipFj9K+ZRfx
         XXFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z20si31163382ejb.393.2019.08.08.23.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 23:40:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CF531ABD2;
	Fri,  9 Aug 2019 06:40:33 +0000 (UTC)
Date: Fri, 9 Aug 2019 08:40:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
Message-ID: <20190809064032.GJ18351@dhcp22.suse.cz>
References: <20190808183247.28206-1-echron@arista.com>
 <20190808185119.GF18351@dhcp22.suse.cz>
 <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
 <20190808200715.GI18351@dhcp22.suse.cz>
 <CAM3twVS7tqcHmHqjzJqO5DEsxzLfBaYF0FjVP+Jjb1ZS4rA9qA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVS7tqcHmHqjzJqO5DEsxzLfBaYF0FjVP+Jjb1ZS4rA9qA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Again, please do not top post - it makes a mess of any longer
discussion]

On Thu 08-08-19 15:15:12, Edward Chron wrote:
> In our experience far more (99.9%+) OOM events are not kernel issues,
> they're user task memory issues.
> Properly maintained Linux kernel only rarely have issues.
> So useful information about the killed task, displayed in a manner
> that can be quickly digested, is very helpful.
> But it turns out the totalpages parameter is also critical to make
> sense of what is shown.

We already do print that information (see mem_cgroup_print_oom_meminfo
resp. show_mem).

> So if we report the fooWidget task was using ~15% of memory (I know
> this is just an approximation but it is often an adequate metric) we
> often can tell just from that the number is larger than expected so we
> can start there.
> Even though the % is a ballpark number, if you are familiar with the
> tasks on your system and approximately how much memory you expect them
> to use you can often tell if memory usage is excessive.
> This is not always the case but it is a fair amount of the time.
> So the % of memory field is helpful. But we've found we need totalpages as well.
> The totalpages effects the % of memory the task uses.

Is it too difficult to calculate that % from the data available in the
existing report? I would expect this would be a quite simple script
which I would consider a better than changing the kernel code.

[...]
> The oom_score tells us how Linux calculated the score for the task,
> the oom_score_adj effects this so it is helpful to have that in
> conjunction with the oom_score.
> If the adjust is high it can tell us that the task was acting as a
> canary and so it's oom_score is high even though it's memory
> utilization can be modest or low.

I am sorry but I still do not get it. How are you going to use that
information without seeing other eligible tasks. oom_score is just a
normalized memory usage + some heuristics potentially (we have given a
discount to root processes until just recently). So this value only
makes sense to the kernel oom killer implementation. Note that the
equation might change in the future (that has happen in the past several
times) so looking at the value in isolation might be quite misleading.

I can see some point in printing oom_score_adj, though. Seeing biased -
one way or the other - tasks being selected might confirm the setting is
reasonable or otherwise (e.g. seeing tasks with negative scores will
give an indication that they might be not biased enough). Then you can
go and check the eligible tasks dump and see what happened. So this part
makes some sense to me.
-- 
Michal Hocko
SUSE Labs

