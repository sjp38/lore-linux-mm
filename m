Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3973C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:57:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7987820657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:57:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="cgQvEXGq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7987820657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 129186B0005; Thu, 16 May 2019 13:57:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D9D66B0006; Thu, 16 May 2019 13:57:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F09F96B0007; Thu, 16 May 2019 13:57:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D08626B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 13:57:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g19so3913082qtb.18
        for <linux-mm@kvack.org>; Thu, 16 May 2019 10:57:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bcnfQY6UYyRStLiSmuTZOVFUbTzk6P+Gmm7BbKAmwyU=;
        b=YoSp2TA7tnKufk8DKOvjpfSByVXtquYN3nxATW0uXdqFV5Bu2Rk7RHvPQ1fEpUqC8k
         0rfaib5Jb01wSTv+yUCmZcgANOx4yhukhhsLrgX8RyoYDXDvqfr5vX7ZFJUlar1GJiLi
         DVWp7hagPRWgX9Qg5qXXIa0PhPSdMX8C3B8YPZ3xnT64LWh7Vv/TuWWTlLaBG3VRHzJb
         IsmIiL1Nxpe5UUa3N1VuqXoQ845A2TghoZvRkNgtkcol/1g92BRwuATa4hfmJQoOhzKL
         ysUzGoNgUPpmTIzBfWd5UPv48/mHcvfFZ3D0eKdfcHz46ZGaE7un33w5smrOF4Oxz5Sm
         dh6Q==
X-Gm-Message-State: APjAAAWSWpm4YX9Tszcz6z35Vl/e/kdBHAWebapdPJsIQarhlz7dwXIB
	uTPz8/giGtYa7nf9O3rL6uiRq/GL5fk6FVW5Pyc0L7SKt8B7NeSlWucCB3V7eY1V870OF6C3e89
	4YHpYiMXWmZwaDZTnSP4OWstO4nYcO5bNF7XBeeVzorCSW518oXT5DKJRxMLxK1ZWdg==
X-Received: by 2002:a0c:d7cd:: with SMTP id g13mr40868178qvj.159.1558029420508;
        Thu, 16 May 2019 10:57:00 -0700 (PDT)
X-Received: by 2002:a0c:d7cd:: with SMTP id g13mr40868124qvj.159.1558029419661;
        Thu, 16 May 2019 10:56:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558029419; cv=none;
        d=google.com; s=arc-20160816;
        b=QZySiKJarkD+O+rSbyFCFJuh8SYP5TanRbDRb9kVRRw4JDTrdHXKadzfI6ToiSTSx2
         dD/92RbB0FA8tcXo5gEQ4jVYlynDJex/kAZs6RSPM1mLZTO/NL231hhyjarpN3ieRIFc
         MTRgekvj/TY+nH5WxaSCQDxcdLXtOBXpR1ulGr7C8Qj6SwHMVyIes86gm045RWuPIvfd
         lhBhon1CudL4gBoQKne1yJU7Uq1ARcX4qZ/Kl7vHO7gLdFE77EJB23/7PPIR5I1qzFjZ
         B4kKGLU7CczZo3JpmhdRbntaMWDceCjfK9IwhpVPWn+68M7PJ0VFDGomUkyF+411EvAt
         mHMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bcnfQY6UYyRStLiSmuTZOVFUbTzk6P+Gmm7BbKAmwyU=;
        b=TBGmZFnp2gB1cEIbkzlsybA53GE/0586BcqV6avdNAudDeOtFFNnnolrM/qlDFirBF
         XHkAD9VdnejC51lpccwdXZfvEDCLJdJy5jK/Wd1PtaWcyiZU+xpp4HOkCuGBrCO5w2Cc
         N8QSdK1k97Brg+e+iYlLeQtqVx/ELDmFnF9gdj/9pFe1xRWoSkiAykRTFgRm4aNSbwux
         DY5vX2kMhubnUdao7EW/ZHuDEQ6HMkxXUf5wORmrUi45L+b908oUf5J0soeVJTgApeRd
         87uHRoLtJXob2KNAMBTFFIf06bryRFPx3jlwr16SpBLFlQwbyBkFP6ZZzBV3D1IOIWKP
         jdiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=cgQvEXGq;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g136sor3470883qke.140.2019.05.16.10.56.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 10:56:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=cgQvEXGq;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bcnfQY6UYyRStLiSmuTZOVFUbTzk6P+Gmm7BbKAmwyU=;
        b=cgQvEXGqW3uJsJG9b+dK2N/cDz3BRPEjJu+tvCpLVBFxuPhuD61ZEeLlmXg2LXDD81
         9j/El74ihm7rBYSC44gkXw1rRFuAhlTbE8+uL+kZ32ezLBwnnlUM/uLdI1yD+ySC9+eM
         0+HMufBCBDMT65ba17Iq8Ly+p5aNGv35sxAWPBb8ShXqWNY5KFyOFwocVhGKykt3G/ie
         wX+JUwysDAwORWcI6YDMhbAmlouhcV9fb65nlqNLu3kvEuoYGgztUxjb1cb4hcbhY/MU
         nXlojvj+DTffd2557vhyClUuWe3uSiS55KoOzvn4RA1J43jihR0qRcWymWWsiZLl1iBv
         7iiQ==
X-Google-Smtp-Source: APXvYqznhLu3pkDLRhIZaeCnSQT/mT9vHrnEax9MJ7d8wP8ZSTawPdwoSoNBFcCMfZSxbMFkUvb6+Q==
X-Received: by 2002:a37:dcc4:: with SMTP id v187mr7145177qki.290.1558029416922;
        Thu, 16 May 2019 10:56:56 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id o6sm972349qtc.47.2019.05.16.10.56.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 10:56:56 -0700 (PDT)
Date: Thu, 16 May 2019 13:56:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org,
	guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190516175655.GA25818@cmpxchg.org>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213124729.GI4525@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:47:29PM +0100, Michal Hocko wrote:
> On Tue 12-02-19 14:45:42, Andrew Morton wrote:
> [...]
> > From: Chris Down <chris@chrisdown.name>
> > Subject: mm, memcg: consider subtrees in memory.events
> > 
> > memory.stat and other files already consider subtrees in their output, and
> > we should too in order to not present an inconsistent interface.
> > 
> > The current situation is fairly confusing, because people interacting with
> > cgroups expect hierarchical behaviour in the vein of memory.stat,
> > cgroup.events, and other files.  For example, this causes confusion when
> > debugging reclaim events under low, as currently these always read "0" at
> > non-leaf memcg nodes, which frequently causes people to misdiagnose breach
> > behaviour.  The same confusion applies to other counters in this file when
> > debugging issues.
> > 
> > Aggregation is done at write time instead of at read-time since these
> > counters aren't hot (unlike memory.stat which is per-page, so it does it
> > at read time), and it makes sense to bundle this with the file
> > notifications.
> > 
> > After this patch, events are propagated up the hierarchy:
> > 
> >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> >     low 0
> >     high 0
> >     max 0
> >     oom 0
> >     oom_kill 0
> >     [root@ktst ~]# systemd-run -p MemoryMax=1 true
> >     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
> >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> >     low 0
> >     high 0
> >     max 7
> >     oom 1
> >     oom_kill 1
> > 
> > As this is a change in behaviour, this can be reverted to the old
> > behaviour by mounting with the `memory_localevents' flag set.  However, we
> > use the new behaviour by default as there's a lack of evidence that there
> > are any current users of memory.events that would find this change
> > undesirable.
> > 
> > Link: http://lkml.kernel.org/r/20190208224419.GA24772@chrisdown.name
> > Signed-off-by: Chris Down <chris@chrisdown.name>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Roman Gushchin <guro@fb.com>
> > Cc: Dennis Zhou <dennis@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> FTR: As I've already said here [1] I can live with this change as long
> as there is a larger consensus among cgroup v2 users. So let's give this
> some more time before merging to see whether there is such a consensus.
> 
> [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz

It's been three months without any objections. Can we merge this for
v5.2 please? We still have users complaining about this inconsistent
behavior (the last one was yesterday) and we'd rather not carry any
out of tree patches.

