Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1959EC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:10:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD05D2171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:10:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="HGtEDNLt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD05D2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CFFA6B026C; Fri, 12 Apr 2019 16:10:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57FEA6B026D; Fri, 12 Apr 2019 16:10:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4707F6B026E; Fri, 12 Apr 2019 16:10:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3F56B026C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:10:08 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o34so9875625qte.5
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:10:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KL4HVhtEWvgQo7HQOLpi2CSpq8VK+yUMixkba3uKDZg=;
        b=UGFBk+gNK9NY0sXPL/IfL7mDucim3p5tjOfBkcWVFtkcWJDUOn1otFzThw9y6JeaCi
         FTqCME2DvQ2iUz+F6B7KcggaFSpK9wSl2u9GleLVGyle4Etqm6/XB3quqLM71bfFRv0J
         yWGSU99UcrgON904HDfoKhSAPyItM+HOdBGHeU0PstcKdEmGZU39Xtwo92SXEj8dJiGE
         9QLthHt69DQ22dROHZj8MDBC79RahWBcmjKm/OMswKToLoC2d0IW0yfF/PHY9IzSmVn7
         OBdThWU69FV2s8qvZrEIEpXsZM8d24viPZCqv8xEu1lahuDe77e9QHCwHGtvuiafsCyV
         fIEQ==
X-Gm-Message-State: APjAAAWfofZ0EqPDdFiL5tpiSGpMrCVS9hIIJcakXWHVSkiFFVPLDjgf
	u0ndWL5feIZrx4Icdwfd1OLVUwdlVE740rTD9j7zDdz+JqDSZFsf55UGqQxNEuKNpDryMDDaY8P
	XxnMm3Ljaa1BhDrHWs/gxiP8IdRz3x1VQH4Ls7TMhXWHufe9sB2n6URl4IbjvHHxRHQ==
X-Received: by 2002:aed:3ee7:: with SMTP id o36mr50091239qtf.355.1555099807875;
        Fri, 12 Apr 2019 13:10:07 -0700 (PDT)
X-Received: by 2002:aed:3ee7:: with SMTP id o36mr50091185qtf.355.1555099807185;
        Fri, 12 Apr 2019 13:10:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555099807; cv=none;
        d=google.com; s=arc-20160816;
        b=lI/2XWT88fI5vsQYz7FCsVN3mZCo11lvhaifH/Mb0hrE3WH/lqGgGinRZbZZrdRDUK
         tEyk8Q3yMAGWHuy9fbPdtvqucR+32lYy+P7xaONAoI3kCiJ/iOSPyfTPD4pCs51pplXO
         36nG3M7KT94qpuZEZnDOimNfZoGLffgNfTDP6TieSQSMjzH2ZutbiAgzZlfXBMSZzUoi
         G+fqqzCnuuPWmRkqbCgBGdO+u6CAJmnJgB8VceGRgtinK/u50rrlb23ATzTPL3G1u3xF
         w82qspkgLBM0vOHp1O+Xp0bqDRGb9BUDGPkr5slQqTJNJzKH7uEBhJ7+pyVsKots5I7A
         W1BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KL4HVhtEWvgQo7HQOLpi2CSpq8VK+yUMixkba3uKDZg=;
        b=j9ayEwwtZ/6haTXhYUbUXDErCudTNDmERPqCNxuxHAMPHnxdHYuxcwN7n0LC3h+i2x
         KLp7X2P9wCkNmRnw0ffH50dUUZxmsegV0mO9j2QqcYQxgi72hGDwQPgAbRXitV3J55XY
         BwCN5o2JAgIqgb9aMm3/d/8129YthKLuv8FrG4gPtkBfTcd2iQ3Wu3X2MhlH+QJdNMLG
         9/sQf3sO7eo8Bgji2pt3qj9EOvX4Wg/U6lSE5gcZ4vafvlqCq+OOn3Ly2tw+syVa6ecx
         XZXmf8wAJqd+G9OMaUzc8GvQPAP5Uf37hC+Wm6UG5YKIhiM0mlIlgUahmd7bTG5jaw3N
         BcHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HGtEDNLt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i19sor58036610qtr.49.2019.04.12.13.10.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 13:10:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HGtEDNLt;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KL4HVhtEWvgQo7HQOLpi2CSpq8VK+yUMixkba3uKDZg=;
        b=HGtEDNLthqGLuedDvcWcQ1HekO50r/XS7jrtBnh6XFA8NQFzosqhgjcfVaTaVT21+F
         w1q4VXl9ZZ9XnyKnnt0oXaOx+G2HR836hSnHm+9tRa5ftCZLstYd0AmiEW69ToQNXSTT
         UaeyyJp9/M8MV9kQTD8tmlwbXPv2hp1lB+mozU7oDB9/SA4wsWc68mC8tHAWkn5i+TDh
         om6ankdEU3FtXwv7KGCbZuNEApBQdcCi3mxFmA+66xv+wuiLEvVmNfZmkBNj6XwwGz4f
         ehrnYoRllpVANXpOkKs+Ru/sR8PkPWgDKm/CRtFatWXmj7YYDjE7crWKlgGZ7hnywrmM
         XVXA==
X-Google-Smtp-Source: APXvYqyznUBkQ5ObYucraFFP8fAIuNA92TJl1aJ+E2y+kZ9Z+GajEJUt/00i36XImcgl7jG7D8VsOQ==
X-Received: by 2002:ac8:3855:: with SMTP id r21mr48809369qtb.264.1555099806611;
        Fri, 12 Apr 2019 13:10:06 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id h22sm34758855qth.68.2019.04.12.13.10.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 13:10:05 -0700 (PDT)
Date: Fri, 12 Apr 2019 16:10:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com,
	Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
Message-ID: <20190412201004.GA27187@cmpxchg.org>
References: <20190412151507.2769-1-hannes@cmpxchg.org>
 <20190412151507.2769-4-hannes@cmpxchg.org>
 <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 12:55:10PM -0700, Shakeel Butt wrote:
> We also faced this exact same issue as well and had the similar solution.
> 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Thanks for the review!

> (Unrelated to this patchset) I think there should also a way to get
> the exact memcg stats. As the machines are getting bigger (more cpus
> and larger basic page size) the accuracy of stats are getting worse.
> Internally we have an additional interface memory.stat_exact for that.
> However I am not sure in the upstream kernel will an additional
> interface is better or something like /proc/sys/vm/stat_refresh which
> sync all per-cpu stats.

I was talking to Roman about this earlier as well and he mentioned it
would be nice to have periodic flushing of the per-cpu caches. The
global vmstat has something similar. We might be able to hook into
those workers, but it would likely require some smarts so we don't
walk the entire cgroup tree every couple of seconds.

We haven't had any actual problems with the per-cpu fuzziness, mainly
because the cgroups of interest also grow in size as the machines get
bigger, and so the relative error doesn't increase.

Are your requirements that the error dissipates over time (waiting for
a threshold convergence somewhere?) or do you have automation that
gets decisions wrong due to the error at any given point in time?

